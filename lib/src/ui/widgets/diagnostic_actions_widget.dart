import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiagnosticActionsWidget extends ConsumerWidget {
  const DiagnosticActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnostic Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildActionCategory(
                  context,
                  'Trouble Codes',
                  Icons.error_outline,
                  [
                    _ActionItem(
                      'Read DTCs',
                      'Read all diagnostic trouble codes',
                      Icons.search,
                      () => _performAction(context, 'Read DTCs'),
                    ),
                    _ActionItem(
                      'Clear DTCs',
                      'Clear all diagnostic trouble codes',
                      Icons.clear_all,
                      () => _performAction(context, 'Clear DTCs'),
                    ),
                    _ActionItem(
                      'Pending Codes',
                      'Read pending trouble codes',
                      Icons.schedule,
                      () => _performAction(context, 'Pending Codes'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildActionCategory(
                  context,
                  'System Tests',
                  Icons.build,
                  [
                    _ActionItem(
                      'O2 Sensor Test',
                      'Test oxygen sensor functionality',
                      Icons.sensors,
                      () => _performAction(context, 'O2 Sensor Test'),
                    ),
                    _ActionItem(
                      'Catalyst Test',
                      'Test catalytic converter efficiency',
                      Icons.filter_alt,
                      () => _performAction(context, 'Catalyst Test'),
                    ),
                    _ActionItem(
                      'EVAP System Test',
                      'Test evaporative emission system',
                      Icons.water_drop,
                      () => _performAction(context, 'EVAP System Test'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildActionCategory(
                  context,
                  'ECU Programming',
                  Icons.memory,
                  [
                    _ActionItem(
                      'Read ECU Info',
                      'Read ECU identification and version',
                      Icons.info,
                      () => _performAction(context, 'Read ECU Info'),
                    ),
                    _ActionItem(
                      'Reset Adaptations',
                      'Reset ECU adaptive values',
                      Icons.restart_alt,
                      () => _showWarningDialog(context, 'Reset Adaptations'),
                    ),
                    _ActionItem(
                      'Program ECU',
                      'Flash new ECU firmware (Advanced)',
                      Icons.code,
                      () => _showWarningDialog(context, 'Program ECU'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCategory(
    BuildContext context,
    String title,
    IconData icon,
    List<_ActionItem> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...actions.map((action) => _buildActionTile(context, action)),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, _ActionItem action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            action.icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          action.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(action.description),
        trailing: const Icon(Icons.chevron_right),
        onTap: action.onTap,
      ),
    );
  }

  void _performAction(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Performing $action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Executing $action command...'),
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

    // Simulate action completion
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showWarningDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Warning: $action'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action can modify your vehicle\'s ECU settings. '
              'Please ensure you understand the risks before proceeding.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risks:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('• May void warranty'),
                  const Text('• Can cause vehicle malfunction'),
                  const Text('• Professional expertise recommended'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performAction(context, action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  _ActionItem(this.title, this.description, this.icon, this.onTap);
}