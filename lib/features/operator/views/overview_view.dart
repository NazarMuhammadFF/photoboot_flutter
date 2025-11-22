import 'package:flutter/material.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Status',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusCard(
                context,
                title: 'Camera',
                status: 'Connected',
                icon: Icons.camera_alt,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatusCard(
                context,
                title: 'Printer',
                status: 'Ready',
                icon: Icons.print,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatusCard(
                context,
                title: 'Network',
                status: 'Offline',
                icon: Icons.wifi_off,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
