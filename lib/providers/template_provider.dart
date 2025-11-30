import 'package:flutter/material.dart';
import '../models/template_config.dart';
import '../services/template_service.dart';

class TemplateProvider with ChangeNotifier {
  final TemplateService _templateService = TemplateService();
  List<TemplateConfig> _templates = [];
  TemplateConfig? _selectedTemplate;
  bool _isLoading = false;

  List<TemplateConfig> get templates => _templates;
  TemplateConfig? get selectedTemplate => _selectedTemplate;
  bool get isLoading => _isLoading;

  List<TemplateConfig> getTemplatesForGrid(String gridId) {
    return _templates.where((t) => t.gridId == gridId).toList();
  }

  Future<void> loadTemplates() async {
    _isLoading = true;
    notifyListeners();

    _templates = await _templateService.loadTemplates();

    _isLoading = false;
    notifyListeners();
  }

  void selectTemplate(TemplateConfig template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void clearSelection() {
    _selectedTemplate = null;
    notifyListeners();
  }

  Future<void> addTemplate(
    TemplateConfig template,
    String sourceImagePath,
  ) async {
    // Save the image file
    final savedPath = await _templateService.saveTemplateImage(
      sourceImagePath,
      template.id,
    );

    if (savedPath != null) {
      final templateWithPath = template.copyWith(imagePath: savedPath);
      _templates.add(templateWithPath);
      notifyListeners();
      await _save();
    }
  }

  Future<void> updateTemplate(TemplateConfig template) async {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _templates[index] = template;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteTemplate(String id) async {
    final template = _templates.firstWhere((t) => t.id == id);
    await _templateService.deleteTemplateImage(template.imagePath);

    _templates.removeWhere((t) => t.id == id);
    if (_selectedTemplate?.id == id) {
      _selectedTemplate = null;
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    await _templateService.saveTemplates(_templates);
  }
}
