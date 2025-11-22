import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> saveImageLocally(List<int> imageBytes, String fileName) async {
    final path = await _localPath;
    final file = File('$path/$fileName');
    return file.writeAsBytes(imageBytes);
  }

  // Google Drive implementation will be added later
}
