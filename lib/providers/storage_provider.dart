import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class StorageProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  Future<File> saveImage(List<int> imageBytes, String fileName) async {
    return await _storageService.saveImageLocally(imageBytes, fileName);
  }
}
