import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraProvider with ChangeNotifier {
  final CameraService _cameraService = CameraService();

  CameraController? get controller => _cameraService.controller;
  bool get isInitialized => _cameraService.isInitialized;
  bool get hasMultipleCameras => (_cameraService.cameras?.length ?? 0) > 1;

  Future<void> initialize() async {
    await _cameraService.initialize();
    notifyListeners();
  }

  Future<XFile?> takePicture() async {
    return await _cameraService.takePicture();
  }

  Future<void> switchCamera() async {
    await _cameraService.switchCamera();
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
