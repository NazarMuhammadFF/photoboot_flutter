import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  List<CameraDescription>? get cameras => _cameras;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _initializeController(_cameras![_selectedCameraIndex]);
      } else {
        debugPrint('No cameras found');
      }
    } catch (e) {
      debugPrint('Error fetching cameras: $e');
    }
  }

  Future<void> _initializeController(
    CameraDescription cameraDescription,
  ) async {
    final previousController = _controller;

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousController?.dispose();

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<XFile?> takePicture() async {
    if (!isInitialized) return null;

    try {
      return await _controller!.takePicture();
    } on CameraException catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initializeController(_cameras![_selectedCameraIndex]);
  }

  Future<void> dispose() async {
    await _controller?.dispose();
  }
}
