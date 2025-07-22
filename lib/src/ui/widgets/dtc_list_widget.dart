import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DTCListWidget extends ConsumerWidget {
  const DTCListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: _buildDTCList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Diagnostic Trouble Codes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement DTC reading
            _showReadDTCDialog(context);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Read DTCs'),
        ),
      ],
    );
  }

  Widget _buildDTCList(BuildContext context) {
    // TODO: Replace with actual DTC data from state management
    final mockDTCs = [
      _DTCItem(
        code: 'P0171',
        description: 'System Too Lean (Bank 1)',
        severity: DTCSeverity.warning,
        status: 'Active',
      ),
      _DTCItem(
        code: 'P0301',
        description: 'Cylinder 1 Misfire Detected',
        severity: DTCSeverity.critical,
        status: 'Pending',
      ),
    ];

    if (mockDTCs.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: mockDTCs.length,
      itemBuilder: (context, index) {
        final dtc = mockDTCs[index];
        return _buildDTCCard(context, dtc);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'No Trouble Codes Found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your vehicle has no active diagnostic trouble codes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDTCCard(BuildContext context, _DTCItem dtc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: dtc.severity.color.withOpacity(0.1),
          child: Icon(
            dtc.severity.icon,
            color: dtc.severity.color,
          ),
        ),
        title: Text(
          dtc.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dtc.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: dtc.severity.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dtc.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: dtc.severity.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Text('Clear Code'),
            ),
          ],
          onSelected: (value) {
            // TODO: Handle DTC actions
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value action for ${dtc.code}')),
            );
          },
        ),
      ),
    );
  }

  void _showReadDTCDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading DTCs'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reading diagnostic trouble codes from vehicle ECU...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DTCItem {
  final String code;
  final String description;
  final DTCSeverity severity;
  final String status;

  _DTCItem({
    required this.code,
    required this.description,
    required this.severity,
    required this.status,
  });
}

enum DTCSeverity {
  critical(Colors.red, Icons.error),
  warning(Colors.orange, Icons.warning),
  info(Colors.blue, Icons.info);

  const DTCSeverity(this.color, this.icon);
  final Color color;
  final IconData icon;
}