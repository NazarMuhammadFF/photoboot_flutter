import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/printer_provider.dart';
import 'package:printing/printing.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().loadPrinters();
    });
  }

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
            Consumer<PrinterProvider>(
              builder: (context, printerProvider, child) {
                if (printerProvider.printers.isEmpty) {
                  return const ListTile(
                    title: Text('No printers found'),
                    subtitle: Text('Please check your printer connection'),
                  );
                }
                return ListTile(
                  title: const Text('Select Printer'),
                  subtitle: Text(printerProvider.selectedPrinter?.name ?? 'None'),
                  trailing: DropdownButton<Printer>(
                    value: printerProvider.selectedPrinter,
                    onChanged: (Printer? newValue) {
                      if (newValue != null) {
                        printerProvider.selectPrinter(newValue);
                      }
                    },
                    items: printerProvider.printers.map<DropdownMenuItem<Printer>>((Printer printer) {
                      return DropdownMenuItem<Printer>(
                        value: printer,
                        child: Text(
                          printer.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Paper Size'),
              subtitle: const Text('4R (4x6 inches)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implement paper size selection
              },
            ),
            SwitchListTile(
              title: const Text('Auto-Cut'),
              subtitle: const Text('Cut paper after printing'),
              value: true,
              onChanged: (val) {
                // TODO: Implement auto-cut toggle
              },
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
              onTap: () {
                // TODO: Navigate to Grid Editor
              },
            ),
            ListTile(
              title: const Text('Manage Templates'),
              subtitle: const Text('Upload overlay images'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to Template Manager
              },
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
