import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:odisha_air_map/model/location_pattern.dart';
import 'package:odisha_air_map/utils/app_constants.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final String apiUrl = "https://omap.okcl.org/api/patterns/get_all_patterns/";

  int totalFiles = 0;
  int downloadedFiles = 0;

  final isOfflineModeEnabled = false.obs;

  final downloadProgress = 0.0.obs;
  final isLoading = false.obs;
  final isFullyDownloaded = false.obs;

  final patterns = <LocationPattern>[].obs;

  late Directory mediaDir;
  late Box<LocationPattern> patternsBox;

  @override
  void onInit() {
    super.onInit();
    patternsBox = Hive.box<LocationPattern>('location_patterns');
    _initMediaDirectory().then((_) {
      checkDownloadStatus();
      isOfflineModeEnabled.value = false;
    });
  }

  Future<void> checkDownloadStatus() async {
    try {
      // If nothing local, definitely not offline ready
      if (patternsBox.isEmpty) {
        isFullyDownloaded.value = false;
        log("🌐 No offline data yet");
        return;
      }

      // 🌐 Fetch backend list
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        log("⚠️ Could not verify backend content");
        return;
      }

      final List<dynamic> backendData = json.decode(response.body);

      final localIds = _getLocalPatternIds();
      final backendIds = _getBackendPatternIds(backendData);

      log("📦 Local patterns: ${localIds.length}");
      log("🌍 Backend patterns: ${backendIds.length}");

      if (localIds.containsAll(backendIds) && backendIds.isNotEmpty) {
        patterns.assignAll(patternsBox.values.toList());
        isFullyDownloaded.value = true;

        log("✅ DATA LOADED FROM LOCAL STORAGE (Offline ready)");
      } else {
        isFullyDownloaded.value = false;

        log("⚠️ Offline data incomplete – update available");
      }
    } catch (e) {
      log("❌ checkDownloadStatus error: $e");
    }
  }

  Set<String> _getLocalPatternIds() {
    return patternsBox.values
        .map((p) => p.patternId)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Set<String> _getBackendPatternIds(List<dynamic> data) {
    return data
        .map((e) => e['pattern_id']?.toString())
        .whereType<String>()
        .toSet();
  }

  Future<void> _initMediaDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    mediaDir = Directory('${appDir.path}/media');

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    log("Media directory: ${mediaDir.path}");
  }

  Future<String?> downloadMediaFile(String? relativeUrl, String type) async {
    if (relativeUrl == null || relativeUrl.trim().isEmpty) {
      log("ℹ️ No $type URL");
      return null;
    }

    final fullUrl = relativeUrl.startsWith('http')
        ? relativeUrl
        : AppConstants.baseUrl + relativeUrl;

    final uri = Uri.parse(fullUrl);
    final fileName = uri.pathSegments.last;
    final localPath = '${mediaDir.path}/$fileName';
    final file = File(localPath);

    if (await file.exists()) {
      downloadedFiles++;
      _updateProgress(type, fileName, fromCache: true);
      return localPath;
    }

    final response = await http.get(uri);
    await file.writeAsBytes(response.bodyBytes);

    downloadedFiles++;
    _updateProgress(type, fileName);

    return localPath;
  }

  void _updateProgress(String type, String fileName, {bool fromCache = false}) {
    final source = fromCache ? "CACHE" : "DOWNLOAD";

    log(
      "📦 $source → $type → $fileName "
      "($downloadedFiles / $totalFiles)",
    );

    downloadProgress.value = totalFiles == 0
        ? 1.0
        : downloadedFiles / totalFiles;

    if (downloadedFiles == totalFiles) {
      log("🎉 ALL FILES DOWNLOADED SUCCESSFULLY");
    }
  }

  Future<void> getAllContent() async {
    try {
      isLoading(true);
      downloadedFiles = 0;
      totalFiles = 0;
      downloadProgress.value = 0.0;

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) throw "Server error";

      final List<dynamic> data = json.decode(response.body);

      // Count total files
      for (var item in data) {
        final content = item['location']['content'];
        if (content['model_url'] != null) totalFiles++;
        if (content['audio_url'] != null) totalFiles++;
        if (content['video_url'] != null) totalFiles++;
      }

      final List<LocationPattern> fetchedPatterns = [];

      for (var item in data) {
        final pattern = LocationPattern.fromJson(item);

        final content = pattern.location.content;

        final modelPath = await downloadMediaFile(content.modelUrl, 'model');
        final audioPath = await downloadMediaFile(content.audioUrl, 'audio');
        final videoPath = await downloadMediaFile(content.videoUrl, 'video');

        final updatedContent = content.copyWith(
          modelUrl: modelPath,
          audioUrl: audioPath,
          videoUrl: videoPath,
        );

        final updatedLocation = pattern.location.copyWith(
          content: updatedContent,
        );

        final updatedPattern = pattern.copyWith(location: updatedLocation);

        fetchedPatterns.add(updatedPattern);
      }

      await patternsBox.clear();
      await patternsBox.addAll(fetchedPatterns);
      patterns.assignAll(fetchedPatterns);

      isFullyDownloaded.value = true;
      isOfflineModeEnabled.value = true;

      log("🟢 Offline mode ENABLED");

      downloadProgress.value = 1.0;

      Get.snackbar("Success", "All content downloaded & ready offline");
    } catch (e) {
      Get.snackbar("Error", "Download failed: $e");
    } finally {
      isLoading(false);
    }
  }
}
