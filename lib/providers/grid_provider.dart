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
    _availableGrids = await _gridService.loadGrids();
    notifyListeners();
  }

  void selectGrid(GridConfig grid) {
    _selectedGrid = grid;
    notifyListeners();
  }

  Future<void> addGrid(GridConfig grid) async {
    _availableGrids.add(grid);
    notifyListeners();
    await _save();
  }

  Future<void> updateGrid(GridConfig grid) async {
    final index = _availableGrids.indexWhere((g) => g.id == grid.id);
    if (index != -1) {
      _availableGrids[index] = grid;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteGrid(String id) async {
    _availableGrids.removeWhere((g) => g.id == id);
    if (_selectedGrid?.id == id) {
      _selectedGrid = null;
    }
    notifyListeners();
    await _save();
  }

  Future<void> resetToDefaults() async {
    _availableGrids = await _gridService.loadDefaultGrids();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    await _gridService.saveGrids(_availableGrids);
  }
}
