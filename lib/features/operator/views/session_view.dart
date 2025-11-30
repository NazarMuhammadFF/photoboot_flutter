import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/session_provider.dart';
import '../../../models/session_state.dart';

class SessionView extends StatelessWidget {
  const SessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        final session = sessionProvider.currentSession;

        if (session == null || session.status == SessionStatus.idle) {
          return _buildNoSession(context, sessionProvider);
        }

        return _buildActiveSession(context, session, sessionProvider);
      },
    );
  }

  Widget _buildNoSession(BuildContext context, SessionProvider provider) {
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
            child: const Icon(Icons.monitor, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Session',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Waiting for user to start a session...',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Demo button to simulate session
              OutlinedButton.icon(
                onPressed: () {
                  provider.startSession();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Simulate Session (Demo)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession(
    BuildContext context,
    SessionState session,
    SessionProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(session.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(session.status)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(session.status),
                      style: TextStyle(
                        color: _getStatusColor(session.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Force End Session'),
                      content: const Text(
                        'Are you sure you want to force end this session? '
                        'This will reset the user app.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.forceEndSession();
                            Navigator.pop(ctx);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Force End'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.stop),
                label: const Text('Force End Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Session Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.grid_on,
                  title: 'Selected Grid',
                  value: session.selectedGrid?.name ?? 'Not selected',
                  subtitle: session.selectedGrid != null
                      ? '${session.selectedGrid!.slots.length} slots'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.image,
                  title: 'Selected Template',
                  value: session.selectedTemplate?.name ?? 'None',
                  subtitle: null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.timer,
                  title: 'Session Duration',
                  value: _formatDuration(
                    DateTime.now().difference(session.startedAt),
                  ),
                  subtitle: 'Started at ${_formatTime(session.startedAt)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Progress Section
          Text(
            'Capture Progress',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Slot ${session.currentSlotIndex + 1} of ${session.totalSlots}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${(session.progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: session.progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Slot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(session.totalSlots, (index) {
                      final isCaptured = index < session.photosTaken;
                      final isCurrent = index == session.currentSlotIndex;

                      return Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isCaptured
                              ? Colors.green
                              : isCurrent
                              ? Colors.orange
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrent
                              ? Border.all(color: Colors.orange, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: isCaptured
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Captured Photos Preview
          if (session.capturedPhotos.isNotEmpty) ...[
            Text(
              'Captured Photos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: session.capturedPhotos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo, size: 32, color: Colors.grey),
                          const SizedBox(height: 4),
                          Text(
                            'Photo ${index + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.idle:
        return Colors.grey;
      case SessionStatus.gridSelection:
      case SessionStatus.templateSelection:
        return Colors.blue;
      case SessionStatus.capturing:
        return Colors.orange;
      case SessionStatus.editing:
      case SessionStatus.reviewing:
        return Colors.purple;
      case SessionStatus.printing:
        return Colors.teal;
      case SessionStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.idle:
        return 'Idle';
      case SessionStatus.gridSelection:
        return 'Selecting Grid';
      case SessionStatus.templateSelection:
        return 'Selecting Template';
      case SessionStatus.capturing:
        return 'Capturing Photos';
      case SessionStatus.editing:
        return 'Editing';
      case SessionStatus.reviewing:
        return 'Reviewing';
      case SessionStatus.printing:
        return 'Printing';
      case SessionStatus.completed:
        return 'Completed';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
