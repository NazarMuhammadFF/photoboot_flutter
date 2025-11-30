import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/grid_config.dart';

class GridService {
  static const String _fileName = 'grids.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<GridConfig>> loadGrids() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> data = json.decode(contents);
        return data.map((json) => GridConfig.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading local grids: $e');
    }

    // Fallback to assets if local file doesn't exist or fails
    return await loadDefaultGrids();
  }

  Future<List<GridConfig>> loadDefaultGrids() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/grids/default_grids.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => GridConfig.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading default grids: $e');
      return [];
    }
  }

  Future<void> saveGrids(List<GridConfig> grids) async {
    try {
      final file = await _localFile;
      final String jsonString = json.encode(
        grids.map((e) => e.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving grids: $e');
    }
  }

  void debugPrint(String message) {
    // Simple wrapper for print to avoid lint issues if needed,
    // or use flutter/foundation.dart's debugPrint
    print(message);
  }
}
