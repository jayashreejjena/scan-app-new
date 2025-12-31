import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _baseFolder = 'odisha_air_map';

  static Future<Directory> getBaseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final baseDir = Directory('${dir.path}/$_baseFolder');

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    return baseDir;
  }

  static Future<String> getFilePath(String url) async {
    final baseDir = await getBaseDir();
    final fileName = Uri.parse(url).pathSegments.last;
    return '${baseDir.path}/$fileName';
  }
}
