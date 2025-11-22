import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_provider.dart';
import '../../providers/grid_provider.dart';

class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedGrid = context.watch<GridProvider>().selectedGrid;

    return Scaffold(
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          if (!cameraProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera Preview
              CameraPreview(cameraProvider.controller!),

              // Grid Info Overlay
              if (selectedGrid != null)
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${selectedGrid.name} (${selectedGrid.slots.length} shots)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              // Overlay Controls
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () async {
                        final image = await cameraProvider.takePicture();
                        if (image != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Picture taken: ${image.path}'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Icon(Icons.camera),
                    ),
                    if (cameraProvider.hasMultipleCameras) ...[
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: () {
                          cameraProvider.switchCamera();
                        },
                        child: const Icon(Icons.switch_camera),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
