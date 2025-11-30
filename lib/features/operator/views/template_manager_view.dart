import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../providers/template_provider.dart';
import '../../../providers/grid_provider.dart';
import '../../../models/template_config.dart';

class TemplateManagerView extends StatefulWidget {
  const TemplateManagerView({super.key});

  @override
  State<TemplateManagerView> createState() => _TemplateManagerViewState();
}

class _TemplateManagerViewState extends State<TemplateManagerView> {
  String? _selectedGridFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateProvider>().loadTemplates();
      context.read<GridProvider>().loadGrids();
    });
  }

  void _showUploadDialog() {
    final nameController = TextEditingController();
    String? selectedGridId;
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final grids = context.read<GridProvider>().availableGrids;

          return AlertDialog(
            title: const Text('Upload Template'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedGridId,
                    decoration: const InputDecoration(
                      labelText: 'Compatible Grid',
                      border: OutlineInputBorder(),
                    ),
                    items: grids.map((grid) {
                      return DropdownMenuItem(
                        value: grid.id,
                        child: Text(grid.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedGridId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedImagePath != null
                        ? Stack(
                            children: [
                              Center(
                                child: Image.file(
                                  File(selectedImagePath!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setDialogState(() {
                                      selectedImagePath = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () async {
                              // For now, show a text input for file path
                              // In production, use file_picker package
                              final pathController = TextEditingController();
                              final path = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Enter Image Path'),
                                  content: TextField(
                                    controller: pathController,
                                    decoration: const InputDecoration(
                                      hintText: 'C:/path/to/image.png',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        ctx,
                                        pathController.text,
                                      ),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              if (path != null && path.isNotEmpty) {
                                setDialogState(() {
                                  selectedImagePath = path;
                                });
                              }
                            },
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Click to select PNG overlay'),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      selectedGridId == null ||
                      selectedImagePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final template = TemplateConfig(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    imagePath: '',
                    gridId: selectedGridId!,
                  );

                  context.read<TemplateProvider>().addTemplate(
                    template,
                    selectedImagePath!,
                  );

                  Navigator.pop(context);
                },
                child: const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _showUploadDialog,
            tooltip: 'Upload Template',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Consumer<GridProvider>(
            builder: (context, gridProvider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Filter by Grid: '),
                    const SizedBox(width: 8),
                    DropdownButton<String?>(
                      value: _selectedGridFilter,
                      hint: const Text('All Grids'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Grids'),
                        ),
                        ...gridProvider.availableGrids.map((grid) {
                          return DropdownMenuItem<String?>(
                            value: grid.id,
                            child: Text(grid.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGridFilter = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Template Grid
          Expanded(
            child: Consumer2<TemplateProvider, GridProvider>(
              builder: (context, templateProvider, gridProvider, child) {
                if (templateProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var templates = templateProvider.templates;
                if (_selectedGridFilter != null) {
                  templates = templates
                      .where((t) => t.gridId == _selectedGridFilter)
                      .toList();
                }

                if (templates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No Templates Found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Upload PNG overlays to use as templates'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showUploadDialog,
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Template'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    final grid = gridProvider.availableGrids
                        .where((g) => g.id == template.gridId)
                        .firstOrNull;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.grey[200],
                              child: File(template.imagePath).existsSync()
                                  ? Image.file(
                                      File(template.imagePath),
                                      fit: BoxFit.contain,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  template.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Grid: ${grid?.name ?? "Unknown"}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Delete Template',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete "${template.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  context
                                                      .read<TemplateProvider>()
                                                      .deleteTemplate(
                                                        template.id,
                                                      );
                                                  Navigator.pop(ctx);
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
