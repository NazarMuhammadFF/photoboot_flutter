import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/camera_provider.dart';
import '../../../../providers/printer_provider.dart';

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
              Consumer<CameraProvider>(
                builder: (context, camera, _) {
                  final isConnected = camera.isInitialized;
                  return _buildStatusCard(
                    context,
                    title: 'Camera',
                    status: isConnected ? 'Connected' : 'Disconnected',
                    icon: isConnected
                        ? Icons.camera_alt
                        : Icons.camera_alt_outlined,
                    color: isConnected ? Colors.green : Colors.red,
                  );
                },
              ),
              const SizedBox(width: 16),
              Consumer<PrinterProvider>(
                builder: (context, printer, _) {
                  final isReady = printer.selectedPrinter != null;
                  return _buildStatusCard(
                    context,
                    title: 'Printer',
                    status: isReady
                        ? 'Ready: ${printer.selectedPrinter!.name}'
                        : 'No Printer Selected',
                    icon: Icons.print,
                    color: isReady ? Colors.green : Colors.orange,
                  );
                },
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
