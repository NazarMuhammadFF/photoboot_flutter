import 'package:flutter/material.dart';

class TemplateManagerView extends StatelessWidget {
  const TemplateManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              // TODO: Implement upload template
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Templates Uploaded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Upload PNG overlays to use as templates'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement upload
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload Template'),
            ),
          ],
        ),
      ),
    );
  }
}
