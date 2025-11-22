import 'package:flutter/material.dart';

class ApprovalView extends StatelessWidget {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.approval, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Approval Queue Empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Print requests will appear here.'),
        ],
      ),
    );
  }
}
