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

  Future<void> _downloadAndCacheModel(String onlineUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String fileName = "model_${locationId}.glb";
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        log("📂 Using cached model: ${file.path}");
        localModelPath.value = file.path;
        return;
      }

      isModelDownloading.value = true;
      downloadProgress.value = 0.0;

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(onlineUrl))
        ..followRedirects = true;

      final response = await client.send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        List<int> bytes = [];

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            downloadProgress.value = receivedBytes / totalBytes;
          }
        }
        String startOfFile = String.fromCharCodes(bytes.take(10));
        if (startOfFile.contains("<!DOCT") || startOfFile.contains("<html")) {
          log(
            "❌ ERROR: Downloaded HTML instead of GLB. Check SharePoint Permissions.",
          );
          errorMessage.value =
              "Link expired or private. Please update the model link.";
          return;
        }

        await file.writeAsBytes(bytes);
        log("💾 Model saved: ${file.path}");
        localModelPath.value = file.path;
      } else {
        errorMessage.value = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      log("❌ Download Error: $e");
      errorMessage.value = "Connection failed";
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
