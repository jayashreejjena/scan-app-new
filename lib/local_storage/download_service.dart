import 'dart:io';
import 'package:http/http.dart' as http;

class DownloadService {
  static Future<String> downloadIfNeeded(
    String url,
    String localPath,
  ) async {
    final file = File(localPath);

    if (await file.exists()) {
      return localPath; // already downloaded
    }

    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);

    return localPath;
  }
}
