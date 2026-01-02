import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocationDetails {
  final int id;
  final String locationId;
  final String name;
  final String description;
  final String? audioUrl;
  final String? videoUrl;
  final String? modelUrl;
  final List<dynamic> facts;

  LocationDetails({
    required this.id,
    required this.locationId,
    required this.name,
    required this.description,
    this.audioUrl,
    this.videoUrl,
    this.modelUrl,
    this.facts = const [],
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? {};

    return LocationDetails(
      id: json['id'] ?? 0,
      locationId: json['location_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      audioUrl: content['audio_url'],
      videoUrl: content['video_url'],
      modelUrl: content['model_url'],
      facts: content['facts'] ?? [],
    );
  }
}

class ObjectDetectedController extends GetxController {
  final isLoading = true.obs;
  final isModelDownloading = false.obs;
  final errorMessage = RxnString();
  final locationDetails = Rxn<LocationDetails>();
  final localModelPath = RxnString();
  
  // 1. ADDED: Variable to track download progress (0.0 to 1.0)
  final downloadProgress = 0.0.obs;

  late int locationId;

  static const String baseUrl = "http://omap.okcl.org";

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args == null || args is! int) {
      errorMessage.value = "Missing location ID";
      isLoading.value = false;
      return;
    }

    locationId = args;
    fetchLocationDetails();
  }

  Future<void> fetchLocationDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final url = "$baseUrl/api/locations/$locationId/";
      log("📡 Fetching: $url");

      final response = await http.get(Uri.parse(url));
      log("📝 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        locationDetails.value = LocationDetails.fromJson(jsonData);
        log("✅ Location Loaded: ${locationDetails.value?.name}");

        isLoading.value = false;

        final modelUrl = getResolvedModelUrl();
        if (modelUrl != null) {
          await _downloadAndCacheModel(modelUrl);
        }
      } else {
        errorMessage.value = "Failed to load location";
        isLoading.value = false;
      }
    } catch (e, stack) {
      errorMessage.value = "Error: $e";
      log("❌ Exception: $e");
      log("$stack");
      isLoading.value = false;
    }
  }

  // 2. UPDATED: Modified to support progress tracking using HttpClient
  Future<void> _downloadAndCacheModel(String onlineUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = onlineUrl.split('/').last;
      final file = File('${directory.path}/$fileName');

      // Check cache first
      if (await file.exists()) {
        log("📂 Found cached model at: ${file.path}");
        localModelPath.value = file.path;
        return; 
      }

      isModelDownloading.value = true;
      downloadProgress.value = 0.0; // Reset progress
      log("⬇️ Downloading model from: $onlineUrl");

      // --- START NATIVE DOWNLOAD LOGIC ---
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(onlineUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength;
        int receivedBytes = 0;

        final IOSink sink = file.openWrite();

        // Stream the response to track progress
        await response.listen((List<int> chunk) {
          receivedBytes += chunk.length;
          sink.add(chunk);

          if (totalBytes != -1) {
            // Update the observable variable
            downloadProgress.value = receivedBytes / totalBytes;
          }
        }).asFuture();

        await sink.flush();
        await sink.close();

        log("💾 Model saved to: ${file.path}");
        localModelPath.value = file.path;
      } else {
        log("⚠️ Failed to download model: ${response.statusCode}");
      }
    } catch (e) {
      log("❌ Error caching model: $e");
    } finally {
      isModelDownloading.value = false;
    }
  }

  String? getResolvedModelUrl() {
    final modelUrl = locationDetails.value?.modelUrl;
    if (modelUrl == null || modelUrl.isEmpty) return null;

    if (modelUrl.startsWith('http')) {
      return modelUrl;
    }
    return "$baseUrl$modelUrl";
  }

  String? getResolvedAudioUrl() {
    final url = locationDetails.value?.audioUrl;
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? url : "$baseUrl$url";
  }

  String? getResolvedVideoUrl() {
    final url = locationDetails.value?.videoUrl;
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? url : "$baseUrl$url";
  }
}