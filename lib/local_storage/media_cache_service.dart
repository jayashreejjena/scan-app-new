import 'package:odisha_air_map/local_storage/storage_service.dart';
import 'package:odisha_air_map/local_storage/download_service.dart';

class MediaCacheService {
  static const String baseUrl = 'https://omap.okcl.org';

  static String buildFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  static Future<Map<String, String>> cacheAllMedia(
      Map<String, dynamic> content) async {
    final modelUrl = buildFullUrl(content['model_url']);
    final audioUrl = buildFullUrl(content['audio_url']);
    final videoUrl = buildFullUrl(content['video_url']);

    final modelPath =
        await StorageService.getFilePath(modelUrl);
    final audioPath =
        await StorageService.getFilePath(audioUrl);
    final videoPath =
        await StorageService.getFilePath(videoUrl);

    return {
      'model_path':
          await DownloadService.downloadIfNeeded(modelUrl, modelPath),
      'audio_path':
          await DownloadService.downloadIfNeeded(audioUrl, audioPath),
      'video_path':
          await DownloadService.downloadIfNeeded(videoUrl, videoPath),
    };
  }
}
