import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_provider.dart';
import '../../providers/grid_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/template_provider.dart';
import 'preview_screen.dart';

class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen>
    with TickerProviderStateMixin {
  bool _isCountingDown = false;
  int _countdownValue = 3;
  bool _showFlash = false;
  Timer? _inactivityTimer;
  static const int inactivityTimeout = 60; // seconds

  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraProvider>().initialize();
    });

    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _countdownAnimation = Tween<double>(begin: 1.5, end: 0.8).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.easeOut),
    );

    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: inactivityTimeout), () {
      _showTimeoutDialog();
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Timeout'),
        content: const Text('Your session has timed out due to inactivity.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<SessionProvider>().resetSession();
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  Future<void> _startCountdown() async {
    if (_isCountingDown) return;

    _resetInactivityTimer();

    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i >= 1; i--) {
      setState(() {
        _countdownValue = i;
      });
      _countdownController.forward(from: 0);
      await Future.delayed(const Duration(seconds: 1));
    }

    await _capturePhoto();
  }

  Future<void> _capturePhoto() async {
    // Show flash effect
    setState(() {
      _showFlash = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final cameraProvider = context.read<CameraProvider>();
    final sessionProvider = context.read<SessionProvider>();
    final image = await cameraProvider.takePicture();

    setState(() {
      _showFlash = false;
      _isCountingDown = false;
    });

    if (image != null && mounted) {
      sessionProvider.addCapturedPhoto(image.path);

      final session = sessionProvider.currentSession;
      if (session != null && session.isComplete) {
        // All photos captured, go to preview
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreviewScreen()),
          );
        }
      } else {
        // Show captured photo briefly
        _showCapturedPreview(image.path);
      }
    }

    _resetInactivityTimer();
  }

  void _showCapturedPreview(String imagePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Photo ${context.read<SessionProvider>().currentSession?.photosTaken ?? 0} captured!',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _retakeLastPhoto() {
    final sessionProvider = context.read<SessionProvider>();
    final session = sessionProvider.currentSession;
    if (session != null && session.capturedPhotos.isNotEmpty) {
      sessionProvider.retakePhoto(session.capturedPhotos.length - 1);
    }
    _resetInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    final selectedGrid = context.watch<GridProvider>().selectedGrid;
    final selectedTemplate = context.watch<TemplateProvider>().selectedTemplate;
    final session = context.watch<SessionProvider>().currentSession;

    return GestureDetector(
      onTap: _resetInactivityTimer,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<CameraProvider>(
          builder: (context, cameraProvider, child) {
            if (!cameraProvider.isInitialized) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                // Camera Preview (Mirrored)
                Transform.scale(
                  scaleX: -1, // Mirror horizontally
                  child: CameraPreview(cameraProvider.controller!),
                ),

                // Template Overlay
                if (selectedTemplate != null &&
                    File(selectedTemplate.imagePath).existsSync())
                  Positioned.fill(
                    child: Image.file(
                      File(selectedTemplate.imagePath),
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.7),
                    ),
                  ),

                // Flash Effect
                if (_showFlash) Container(color: Colors.white),

                // Countdown Overlay
                if (_isCountingDown)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _countdownAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _countdownAnimation.value,
                            child: Text(
                              '$_countdownValue',
                              style: const TextStyle(
                                fontSize: 200,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Top Bar - Progress Info
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 24,
                      right: 24,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cancel Session?'),
                                content: const Text('All photos will be lost.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Continue'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<SessionProvider>()
                                          .resetSession();
                                      Navigator.pop(ctx);
                                      Navigator.of(
                                        context,
                                      ).popUntil((route) => route.isFirst);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        if (selectedGrid != null && session != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Photo ${session.photosTaken + 1} of ${selectedGrid.slots.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (cameraProvider.hasMultipleCameras)
                          IconButton(
                            icon: const Icon(
                              Icons.switch_camera,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              cameraProvider.switchCamera();
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Progress Indicators
                if (selectedGrid != null && session != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 80,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(selectedGrid.slots.length, (
                        index,
                      ) {
                        final isCaptured = index < session.photosTaken;
                        final isCurrent = index == session.currentSlotIndex;

                        return Container(
                          width: isCurrent ? 16 : 12,
                          height: isCurrent ? 16 : 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCaptured
                                ? Colors.green
                                : isCurrent
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            border: isCurrent
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: isCaptured
                              ? const Icon(
                                  Icons.check,
                                  size: 8,
                                  color: Colors.white,
                                )
                              : null,
                        );
                      }),
                    ),
                  ),

                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                      top: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Retake Button
                        if (session != null &&
                            session.capturedPhotos.isNotEmpty)
                          IconButton(
                            onPressed: _isCountingDown
                                ? null
                                : _retakeLastPhoto,
                            icon: const Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 32,
                            ),
                          )
                        else
                          const SizedBox(width: 48),

                        // Capture Button
                        GestureDetector(
                          onTap: _isCountingDown ? null : _startCountdown,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),

                        // Placeholder for symmetry
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
