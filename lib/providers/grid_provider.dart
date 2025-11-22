import 'package:flutter/material.dart';
import '../models/grid_config.dart';
import '../services/grid_service.dart';

class GridProvider with ChangeNotifier {
  final GridService _gridService = GridService();
  List<GridConfig> _availableGrids = [];
  GridConfig? _selectedGrid;

  List<GridConfig> get availableGrids => _availableGrids;
  GridConfig? get selectedGrid => _selectedGrid;

  Future<void> loadGrids() async {
    _availableGrids = await _gridService.loadDefaultGrids();
    notifyListeners();
  }

  void selectGrid(GridConfig grid) {
    _selectedGrid = grid;
    notifyListeners();
  }
}
