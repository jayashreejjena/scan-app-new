import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:odisha_air_map/navigators/routes_management.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ScannerController extends GetxController {
  final cameraController = Rxn<CameraController>();

  final isLoading = false.obs;
  final isInternetConnected = true.obs;
  final savedImagePath = RxnString();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    savedImagePath.value = null;
    _initConnectivity();
    initializeCamera();
  }

  void _initConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    Connectivity().checkConnectivity().then(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = !results.contains(ConnectivityResult.none);
    isInternetConnected.value = connected;
    if (!connected) {
      Get.snackbar(
        "No Internet",
        "Please connect to the internet to scan.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      cameraController.value = controller;

      // Auto-Zoom Logic
      final maxZoom = await controller.getMaxZoomLevel();
      double initialZoom = 2.0;
      if (initialZoom > maxZoom) initialZoom = maxZoom;
      await controller.setZoomLevel(initialZoom);
    } catch (e) {
      log("❌ Camera init error: $e");
    }
  }

  void cancelScan() async {
    isLoading.value = false; // 1. Stop the loading spinner
    savedImagePath.value = null; // 2. Remove the captured image

    // 3. Resume the camera preview immediately
    final controller = cameraController.value;
    if (controller != null && controller.value.isInitialized) {
      await controller.resumePreview();
    }
    log("🚫 Scan Cancelled by User");
  }

  Future<void> scanImage() async {
    if (!isInternetConnected.value) return;

    final controller = cameraController.value;
    if (controller == null || !controller.value.isInitialized) return;
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      await controller.setFocusMode(FocusMode.locked);
      await Future.delayed(const Duration(milliseconds: 300));

      savedImagePath.value = null;

      final XFile file = await controller.takePicture();
      await controller.setFocusMode(FocusMode.auto);
      await controller.pausePreview();

      if (!isLoading.value) {
        _resumeSafe();
        return;
      }

      final Uint8List rawBytes = await file.readAsBytes();
      final Uint8List processedBytes = await compute(
        processImageInIsolate,
        rawBytes,
      );

      if (!isLoading.value) {
        _resumeSafe();
        return;
      }

      final File savedImage = await saveToDisk(processedBytes);
      savedImagePath.value = savedImage.path;

      final result = await uploadForDetection(processedBytes);

      if (!isLoading.value) {
        log("⚠️ API finished but user cancelled. Aborting navigation.");
        _resumeSafe();
        return;
      }
      await _resumeSafe();

      if (result != null) {
        isLoading.value = false;
        RouteManagement.goToExploreCategory(
          arguments: {...result, "imagePath": savedImage.path},
        );
      } else {
        _showErrorSnackbar();
      }
    } catch (e) {
      log("❌ Scan error: $e");
      _showErrorSnackbar(msg: "Failed to scan image");
      await _resumeSafe();
    } finally {
      if (savedImagePath.value != null && isLoading.value) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _resumeSafe() async {
    final controller = cameraController.value;
    if (controller != null && controller.value.isInitialized) {
      await controller.resumePreview();
    }
  }

  void _showErrorSnackbar({String msg = "Could not identify the marker"}) {
    isLoading.value = false; // Stop loading UI
    Get.snackbar(
      "No Match",
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }

  static Uint8List processImageInIsolate(Uint8List inputBytes) {
    img.Image? original = img.decodeImage(inputBytes);
    if (original == null) return inputBytes;

    final int size = original.width < original.height
        ? original.width
        : original.height;
    img.Image cropped = img.copyCrop(
      original,
      x: (original.width - size) ~/ 2,
      y: (original.height - size) ~/ 2,
      width: size,
      height: size,
    );
    img.Image resized = img.copyResize(cropped, width: 800, height: 800);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  Future<File> saveToDisk(Uint8List imageBytes) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory scanDir = Directory(p.join(appDir.path, 'scanned_images'));
    if (!await scanDir.exists()) await scanDir.create(recursive: true);

    final String fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File imageFile = File(p.join(scanDir.path, fileName));
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }

  Future<Map<String, dynamic>?> uploadForDetection(Uint8List imageBytes) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://omap.okcl.org/api/patterns/detect/'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: 'scan.jpg'),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    cameraController.value?.dispose();
    super.onClose();
  }
}
