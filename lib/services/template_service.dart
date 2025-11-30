import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/template_config.dart';

class TemplateService {
  static const String _fileName = 'templates.json';
  static const String _templateFolder = 'templates';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<Directory> get _templateDir async {
    final path = await _localPath;
    final dir = Directory('$path/$_templateFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<TemplateConfig>> loadTemplates() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> data = json.decode(contents);
        return data.map((json) => TemplateConfig.fromJson(json)).toList();
      }
    } catch (e) {
      _debugPrint('Error loading templates: $e');
    }
    return [];
  }

  Future<void> saveTemplates(List<TemplateConfig> templates) async {
    try {
      final file = await _localFile;
      final String jsonString = json.encode(
        templates.map((e) => e.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
    } catch (e) {
      _debugPrint('Error saving templates: $e');
    }
  }

  Future<String?> saveTemplateImage(
    String sourcePath,
    String templateId,
  ) async {
    try {
      final templateDir = await _templateDir;
      final extension = sourcePath.split('.').last;
      final newPath = '${templateDir.path}/$templateId.$extension';

      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(newPath);
        return newPath;
      }
    } catch (e) {
      _debugPrint('Error saving template image: $e');
    }
    return null;
  }

  Future<void> deleteTemplateImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      _debugPrint('Error deleting template image: $e');
    }
  }

  void _debugPrint(String message) {
    print(message);
  }
}
