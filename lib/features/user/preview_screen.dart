import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/grid_provider.dart';
import '../../providers/template_provider.dart';
import '../../models/grid_config.dart';
import 'result_screen.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final List<_StickerItem> _stickers = [];
  _StickerItem? _selectedSticker;

  final List<IconData> _availableStickers = [
    Icons.favorite,
    Icons.star,
    Icons.emoji_emotions,
    Icons.celebration,
    Icons.local_fire_department,
    Icons.music_note,
    Icons.pets,
    Icons.cake,
    Icons.thumb_up,
    Icons.flash_on,
  ];

  void _addSticker(IconData icon) {
    setState(() {
      _stickers.add(
        _StickerItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          icon: icon,
          position: const Offset(150, 150),
          scale: 1.0,
        ),
      );
    });
  }

  void _removeSelectedSticker() {
    if (_selectedSticker != null) {
      setState(() {
        _stickers.removeWhere((s) => s.id == _selectedSticker!.id);
        _selectedSticker = null;
      });
    }
  }

  void _proceedToResult() {
    context.read<SessionProvider>().moveToReview();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>().currentSession;
    final selectedGrid = context.watch<GridProvider>().selectedGrid;
    final selectedTemplate = context.watch<TemplateProvider>().selectedTemplate;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Row(
          children: [
            // Left Panel - Preview
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Grid Layout with Photos
                      if (selectedGrid != null && session != null)
                        _buildPhotoGrid(selectedGrid, session.capturedPhotos),

                      // Template Overlay
                      if (selectedTemplate != null &&
                          File(selectedTemplate.imagePath).existsSync())
                        Image.file(
                          File(selectedTemplate.imagePath),
                          fit: BoxFit.cover,
                        ),

                      // Stickers
                      ..._stickers.map((sticker) {
                        final isSelected = _selectedSticker?.id == sticker.id;
                        return Positioned(
                          left: sticker.position.dx,
                          top: sticker.position.dy,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSticker = sticker;
                              });
                            },
                            onPanUpdate: (details) {
                              setState(() {
                                final index = _stickers.indexWhere(
                                  (s) => s.id == sticker.id,
                                );
                                if (index != -1) {
                                  _stickers[index] = sticker.copyWith(
                                    position: sticker.position + details.delta,
                                  );
                                  _selectedSticker = _stickers[index];
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : null,
                              child: Icon(
                                sticker.icon,
                                size: 48 * sticker.scale,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Right Panel - Sticker Selection
            Container(
              width: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.emoji_emotions, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Stickers',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sticker Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _availableStickers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _addSticker(_availableStickers[index]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _availableStickers[index],
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Delete Selected
                  if (_selectedSticker != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: _removeSelectedSticker,
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: _proceedToResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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

class _StickerItem {
  final String id;
  final IconData icon;
  final Offset position;
  final double scale;

  _StickerItem({
    required this.id,
    required this.icon,
    required this.position,
    this.scale = 1.0,
  });

  _StickerItem copyWith({
    String? id,
    IconData? icon,
    Offset? position,
    double? scale,
  }) {
    return _StickerItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      scale: scale ?? this.scale,
    );
  }
}
