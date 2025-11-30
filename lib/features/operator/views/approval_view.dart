import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/session_provider.dart';
import '../../../models/session_state.dart';

class ApprovalView extends StatelessWidget {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        final pendingPrints = sessionProvider.pendingPrints;
        final allPrints = sessionProvider.printQueue;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Print Approval Queue',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 16),
                  if (pendingPrints.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pendingPrints.length} Pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (allPrints.any(
                    (p) =>
                        p.status == PrintRequestStatus.completed ||
                        p.status == PrintRequestStatus.rejected,
                  ))
                    TextButton.icon(
                      onPressed: () {
                        sessionProvider.clearCompletedPrints();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Completed'),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: allPrints.isEmpty
                    ? _buildEmptyState(context)
                    : _buildPrintList(context, allPrints, sessionProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.print, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            'Approval Queue Empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Print requests from users will appear here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintList(
    BuildContext context,
    List<PrintRequest> prints,
    SessionProvider provider,
  ) {
    return ListView.builder(
      itemCount: prints.length,
      itemBuilder: (context, index) {
        final request = prints[index];
        return _buildPrintCard(context, request, provider);
      },
    );
  }

  Widget _buildPrintCard(
    BuildContext context,
    PrintRequest request,
    SessionProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Image
            Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  request.previewPath.isNotEmpty &&
                      File(request.previewPath).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(request.previewPath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Preview', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 24),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Print Request',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Session: ${request.sessionId.substring(0, 8)}...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested: ${_formatDateTime(request.requestedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  if (request.status == PrintRequestStatus.pending)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.approvePrint(request.id);
                            // TODO: Actually send to printer
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Print approved! Sending to printer...',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Simulate print completion
                            Future.delayed(const Duration(seconds: 2), () {
                              provider.completePrint(request.id);
                            });
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            provider.rejectPrint(request.id);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    )
                  else if (request.status == PrintRequestStatus.approved)
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Printing...'),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PrintRequestStatus status) {
    Color color;
    String text;

    switch (status) {
      case PrintRequestStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case PrintRequestStatus.approved:
        color = Colors.blue;
        text = 'Approved';
        break;
      case PrintRequestStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case PrintRequestStatus.printing:
        color = Colors.purple;
        text = 'Printing';
        break;
      case PrintRequestStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case PrintRequestStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
