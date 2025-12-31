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
  final savedImagePath = RxnString(); // Stores the path of the cropped image

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    savedImagePath.value = null;

    _initConnectivity();
    initializeCamera();
  }

  // ===================== CONNECTIVITY =====================
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

  // ===================== CAMERA INITIALIZATION =====================
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
      log("✅ Camera initialized");
    } catch (e) {
      log("❌ Camera init error: $e");
    }
  }

  // ===================== SCAN BUTTON ACTION =====================
  // ===================== SCAN BUTTON ACTION =====================
  Future<void> scanImage() async {
    if (!isInternetConnected.value) {
      Get.snackbar(
        "No Internet",
        "Connect to the internet",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final controller = cameraController.value;
    if (controller == null || !controller.value.isInitialized) return;

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      savedImagePath.value = null;

      final XFile file = await controller.takePicture();

      await controller.pausePreview();

      final Uint8List rawBytes = await file.readAsBytes();

      final Uint8List processedBytes = await compute(
        processImageInIsolate,
        rawBytes,
      );

      final File savedImage = await saveToDisk(processedBytes);

      savedImagePath.value = savedImage.path;
      log("💾 Processed Image saved at: ${savedImage.path}");

      final result = await uploadForDetection(processedBytes);

      if (cameraController.value != null && controller.value.isInitialized) {
        await controller.resumePreview();
      }

      if (result != null) {
        log("🎉 Detection SUCCESS");
        RouteManagement.goToExploreCategory(
          arguments: {...result, "imagePath": savedImage.path},
        );
      } else {
        // --- CHANGED COLOR TO RED ---
        Get.snackbar(
          "No Match",
          "Could not identify object. Try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      log("❌ Scan error: $e");

      // --- CHANGED COLOR TO RED ---
      Get.snackbar(
        "Error",
        "Failed to scan image",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );

      savedImagePath.value = null;

      if (cameraController.value != null && controller.value.isInitialized) {
        await controller.resumePreview();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ===================== BACKGROUND IMAGE PROCESSING =====================
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

  // ===================== SAVE FILE =====================
  Future<File> saveToDisk(Uint8List imageBytes) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory scanDir = Directory(p.join(appDir.path, 'scanned_images'));

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    // Delete old images to save space (Optional cleanup)
    if (scanDir.existsSync()) {
      scanDir.listSync().forEach((f) {
        try {
          f.deleteSync();
        } catch (_) {}
      });
    }

    final String fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File imageFile = File(p.join(scanDir.path, fileName));
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }

  // ===================== API UPLOAD =====================
  Future<Map<String, dynamic>?> uploadForDetection(Uint8List imageBytes) async {
    try {
      log("📤 Sending image to API");
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
      log("🌐 API ${response.statusCode}: $body");

      if (response.statusCode == 200) {
        return json.decode(body);
      }
      return null;
    } catch (e) {
      log("❌ API error: $e");
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
