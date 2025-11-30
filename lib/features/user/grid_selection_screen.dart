import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grid_provider.dart';
import '../../providers/session_provider.dart';
import '../../models/grid_config.dart';
import 'template_selection_screen.dart';

class GridSelectionScreen extends StatefulWidget {
  const GridSelectionScreen({super.key});

  @override
  State<GridSelectionScreen> createState() => _GridSelectionScreenState();
}

class _GridSelectionScreenState extends State<GridSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GridProvider>().loadGrids();
    });
  }

  void _selectGrid(GridConfig grid) {
    context.read<GridProvider>().selectGrid(grid);
    context.read<SessionProvider>().selectGrid(grid);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TemplateSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.indigo.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        context.read<SessionProvider>().resetSession();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Choose Your Layout',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid Options
              Expanded(
                child: Consumer<GridProvider>(
                  builder: (context, gridProvider, child) {
                    if (gridProvider.availableGrids.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: gridProvider.availableGrids.length,
                      itemBuilder: (context, index) {
                        final grid = gridProvider.availableGrids[index];
                        return _buildGridCard(grid);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(GridConfig grid) {
    return GestureDetector(
      onTap: () => _selectGrid(grid),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grid Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scale = constraints.maxWidth / grid.canvasWidth;
                    final height = grid.canvasHeight * scale;
                    final actualHeight = constraints.maxHeight.clamp(
                      0.0,
                      height,
                    );
                    final actualScale = actualHeight / grid.canvasHeight;

                    return Center(
                      child: Container(
                        width: grid.canvasWidth * actualScale,
                        height: actualHeight,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: grid.slots.map((slot) {
                            return Positioned(
                              left: slot.x * actualScale,
                              top: slot.y * actualScale,
                              width: slot.width * actualScale,
                              height: slot.height * actualScale,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.photo_camera,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Grid Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    grid.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${grid.slots.length} Photos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
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
}
