import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/grid_config.dart';

class GridService {
  Future<List<GridConfig>> loadDefaultGrids() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/grids/default_grids.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => GridConfig.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading grids: $e');
      return [];
    }
  }

  void debugPrint(String message) {
    // Simple wrapper for print to avoid lint issues if needed,
    // or use flutter/foundation.dart's debugPrint
    print(message);
  }
}
