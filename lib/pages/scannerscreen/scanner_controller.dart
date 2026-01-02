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

      // --- AUTO-ZOOM LOGIC ---
      // We force a zoom because your markers are small.
      // This acts like "Portrait Mode" for markers.
      final maxZoom = await controller.getMaxZoomLevel();
      double initialZoom = 2.0; // 2.0x is a good sweet spot for markers

      // Safety check to ensure we don't exceed hardware limits
      if (initialZoom > maxZoom) initialZoom = maxZoom;

      await controller.setZoomLevel(initialZoom);
      // -----------------------

      log("✅ Camera initialized with Zoom: $initialZoom");
    } catch (e) {
      log("❌ Camera init error: $e");
    }
  }

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

      // 1. Take Picture
      final XFile file = await controller.takePicture();

      // 2. Pause Preview (Freeze UI)
      await controller.pausePreview();

      // 3. Process in Background (Crop center square)
      final Uint8List rawBytes = await file.readAsBytes();
      final Uint8List processedBytes = await compute(
        processImageInIsolate,
        rawBytes,
      );

      // 4. Save to Disk
      final File savedImage = await saveToDisk(processedBytes);
      savedImagePath.value = savedImage.path;
      log("💾 Processed Image saved at: ${savedImage.path}");

      // 5. Upload API
      final result = await uploadForDetection(processedBytes);

      // 6. Resume Preview
      if (cameraController.value != null && controller.value.isInitialized) {
        await controller.resumePreview();
      }

      // 7. Handle Result
      if (result != null) {
        log("🎉 Detection SUCCESS");
        RouteManagement.goToExploreCategory(
          arguments: {...result, "imagePath": savedImage.path},
        );
      } else {
        Get.snackbar(
          "No Match",
          "Could not identify the marker. Try getting closer.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      log("❌ Scan error: $e");
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

  // ===================== IMAGE PROCESSING ISOLATE =====================
  // This runs on a separate thread to prevent UI stutter
  static Uint8List processImageInIsolate(Uint8List inputBytes) {
    img.Image? original = img.decodeImage(inputBytes);
    if (original == null) return inputBytes;

    // Crop a square from the center
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

    // Resize to 800x800 for faster upload/processing
    img.Image resized = img.copyResize(cropped, width: 800, height: 800);

    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  // ===================== SAVE UTILS =====================
  Future<File> saveToDisk(Uint8List imageBytes) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory scanDir = Directory(p.join(appDir.path, 'scanned_images'));

    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    // Cleanup old images (simple logic)
    try {
      if (scanDir.listSync().length > 10) {
        scanDir.deleteSync(recursive: true);
        await scanDir.create();
      }
    } catch (_) {}

    final String fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File imageFile = File(p.join(scanDir.path, fileName));
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }

  // ===================== API UPLOAD =====================
  Future<Map<String, dynamic>?> uploadForDetection(Uint8List imageBytes) async {
    try {
      log("📤 Sending image to API...");
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
      log("🌐 API Status: ${response.statusCode}");
      log("🌐 API Body: $body");

      if (response.statusCode == 200) {
        final decoded = json.decode(body);
        // Add specific check if your API returns {success: false} even on 200 OK
        return decoded;
      }
      return null;
    } catch (e) {
      log("❌ API error: $e");
      return null;
    }
  }
  void resetScanner() {
    savedImagePath.value = null; 
    isLoading.value = false;     
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    cameraController.value?.dispose();
    super.onClose();
  }
}
