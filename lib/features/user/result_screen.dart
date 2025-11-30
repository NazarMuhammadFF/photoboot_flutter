import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/session_provider.dart';
import '../../providers/grid_provider.dart';
import '../../models/grid_config.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _requestPrint(BuildContext context) {
    // For now, we'll use a placeholder path
    // In production, this would be the actual generated image path
    final session = context.read<SessionProvider>().currentSession;
    if (session != null) {
      context.read<SessionProvider>().requestPrint('preview_placeholder');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Printing...'),
            ],
          ),
          content: const Text(
            'Your print request has been sent.\n'
            'Please wait for operator approval.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _goHome(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  void _showQRCode(BuildContext context) {
    // Generate a placeholder URL for the QR code
    // In production, this would be the actual cloud storage URL
    const downloadUrl = 'https://photobooth.example.com/download/session123';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan to Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: downloadUrl,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan this QR code with your phone\nto download your photos',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    context.read<SessionProvider>().completeSession();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>().currentSession;
    final selectedGrid = context.watch<GridProvider>().selectedGrid;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade900, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Photos Are Ready!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you\'d like to get your photos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 48),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: selectedGrid != null && session != null
                        ? _buildPhotoGrid(selectedGrid, session.capturedPhotos)
                        : const Center(
                            child: Icon(
                              Icons.photo_library,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Print Button
                    _buildActionButton(
                      icon: Icons.print,
                      label: 'Print',
                      color: Colors.orange,
                      onPressed: () => _requestPrint(context),
                    ),
                    const SizedBox(width: 24),
                    // Download Button
                    _buildActionButton(
                      icon: Icons.qr_code,
                      label: 'Download',
                      color: Colors.blue,
                      onPressed: () => _showQRCode(context),
                    ),
                    const SizedBox(width: 24),
                    // Done Button
                    _buildActionButton(
                      icon: Icons.home,
                      label: 'Done',
                      color: Colors.green,
                      onPressed: () => _goHome(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(GridConfig grid, List<String> photos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / grid.canvasWidth;
        final scaleY = constraints.maxHeight / grid.canvasHeight;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        return Center(
          child: Container(
            width: grid.canvasWidth * scale,
            height: grid.canvasHeight * scale,
            color: Colors.grey.shade800,
            child: Stack(
              children: List.generate(grid.slots.length, (index) {
                final slot = grid.slots[index];
                final hasPhoto = index < photos.length;

                return Positioned(
                  left: slot.x * scale,
                  top: slot.y * scale,
                  width: slot.width * scale,
                  height: slot.height * scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      border: Border.all(color: Colors.grey.shade600),
                    ),
                    child: hasPhoto
                        ? Image.file(File(photos[index]), fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.photo,
                              color: Colors.grey.shade500,
                              size: 32,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
