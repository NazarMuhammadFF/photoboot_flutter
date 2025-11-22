import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Configuration',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          title: 'Printer Settings',
          children: [
            ListTile(
              title: const Text('Paper Size'),
              subtitle: const Text('4R (4x6 inches)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            SwitchListTile(
              title: const Text('Auto-Cut'),
              subtitle: const Text('Cut paper after printing'),
              value: true,
              onChanged: (val) {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          title: 'Grid & Templates',
          children: [
            ListTile(
              title: const Text('Manage Grids'),
              subtitle: const Text('Edit layout configurations'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Manage Templates'),
              subtitle: const Text('Upload overlay images'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(child: Column(children: children)),
      ],
    );
  }
}
