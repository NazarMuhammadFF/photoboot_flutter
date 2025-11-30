import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/printer_provider.dart';
import 'package:printing/printing.dart';

enum PaperSize { r4, a4 }

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PaperSize _selectedPaperSize = PaperSize.r4;
  bool _autoCut = true;
  bool _cloudBackup = false;
  String _storagePath = 'C:/Users/Public/Documents/PhotoBooth';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().loadPrinters();
    });
  }

  void _showPaperSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Paper Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<PaperSize>(
              title: const Text('4R (4x6 inches)'),
              subtitle: const Text('Standard photo booth size'),
              value: PaperSize.r4,
              groupValue: _selectedPaperSize,
              onChanged: (value) {
                setState(() {
                  _selectedPaperSize = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<PaperSize>(
              title: const Text('A4'),
              subtitle: const Text('Standard paper size with tiling'),
              value: PaperSize.a4,
              groupValue: _selectedPaperSize,
              onChanged: (value) {
                setState(() {
                  _selectedPaperSize = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStoragePathDialog() {
    final controller = TextEditingController(text: _storagePath);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Storage Path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Path',
            hintText: 'C:/path/to/folder',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _storagePath = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage path updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Configuration',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),

        // Printer Settings
        _buildSection(
          context,
          title: 'Printer Settings',
          icon: Icons.print,
          children: [
            Consumer<PrinterProvider>(
              builder: (context, printerProvider, child) {
                if (printerProvider.printers.isEmpty) {
                  return ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text('No printers found'),
                    subtitle: const Text(
                      'Please check your printer connection',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        printerProvider.loadPrinters();
                      },
                    ),
                  );
                }
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Select Printer'),
                  subtitle: Text(
                    printerProvider.selectedPrinter?.name ?? 'None selected',
                  ),
                  trailing: DropdownButton<Printer>(
                    value: printerProvider.selectedPrinter,
                    underline: const SizedBox(),
                    onChanged: (Printer? newValue) {
                      if (newValue != null) {
                        printerProvider.selectPrinter(newValue);
                      }
                    },
                    items: printerProvider.printers
                        .map<DropdownMenuItem<Printer>>((Printer printer) {
                          return DropdownMenuItem<Printer>(
                            value: printer,
                            child: Text(
                              printer.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .toList(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_size_select_large),
              title: const Text('Paper Size'),
              subtitle: Text(
                _selectedPaperSize == PaperSize.r4 ? '4R (4x6 inches)' : 'A4',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showPaperSizeDialog,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.content_cut),
              title: const Text('Auto-Cut'),
              subtitle: const Text('Automatically cut paper after printing'),
              value: _autoCut,
              onChanged: (val) {
                setState(() {
                  _autoCut = val;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Storage Settings
        _buildSection(
          context,
          title: 'Storage Settings',
          icon: Icons.folder,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Local Storage Path'),
              subtitle: Text(
                _storagePath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: _showStoragePathDialog,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.cloud_upload),
              title: const Text('Cloud Backup'),
              subtitle: const Text('Upload photos to Google Drive'),
              value: _cloudBackup,
              onChanged: (val) {
                setState(() {
                  _cloudBackup = val;
                });
                if (val) {
                  // Show auth dialog placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google Drive integration coming soon!'),
                    ),
                  );
                  setState(() {
                    _cloudBackup = false;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Session Settings
        _buildSection(
          context,
          title: 'Session Settings',
          icon: Icons.timer,
          children: [
            ListTile(
              leading: const Icon(Icons.hourglass_empty),
              title: const Text('Inactivity Timeout'),
              subtitle: const Text('60 seconds'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implement timeout selector
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Countdown Duration'),
              subtitle: const Text('3 seconds'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implement countdown selector
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // About Section
        _buildSection(
          context,
          title: 'About',
          icon: Icons.info,
          children: [
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset All Settings'),
              subtitle: const Text('Restore default configuration'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text(
                      'Are you sure you want to reset all settings to defaults?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedPaperSize = PaperSize.r4;
                            _autoCut = true;
                            _cloudBackup = false;
                            _storagePath =
                                'C:/Users/Public/Documents/PhotoBooth';
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings reset to defaults'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
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
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}
