import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';

class DiagnosticWidget extends ConsumerStatefulWidget {
  const DiagnosticWidget({super.key});

  @override
  ConsumerState<DiagnosticWidget> createState() => _DiagnosticWidgetState();
}

class _DiagnosticWidgetState extends ConsumerState<DiagnosticWidget> {
  final _commandController = TextEditingController();
  final List<String> _quickCommands = [
    '0100', // PIDs supported
    '0101', // Monitor status
    '0103', // Fuel system status
    '010C', // Engine RPM
    '010D', // Vehicle speed
    '0105', // Engine coolant temperature
    '0104', // Calculated engine load
    '0111', // Throttle position
  ];

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDTCSection(),
          const SizedBox(height: 20),
          _buildQuickCommandsSection(),
          const SizedBox(height: 20),
          _buildCustomCommandSection(),
          const SizedBox(height: 20),
          _buildResponseHistory(),
        ],
      ),
    );
  }

  Widget _buildDTCSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostic Trouble Codes (DTCs)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scanForDTCs(),
                    icon: const Icon(Icons.search),
                    label: const Text('Scan for DTCs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _clearDTCs(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear DTCs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDTCList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDTCList() {
    // Placeholder DTC data
    final dtcs = [
      {'code': 'P0171', 'description': 'System Too Lean (Bank 1)'},
      {'code': 'P0300', 'description': 'Random/Multiple Cylinder Misfire'},
    ];

    if (dtcs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('No diagnostic trouble codes found'),
          ],
        ),
      );
    }

    return Column(
      children: dtcs.map((dtc) {
        return Card(
          color: Colors.red.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(
              dtc['code']! as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dtc['description']! as String),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showDTCDetails(dtc),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickCommandsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Commands',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickCommands.map((command) {
                final description = AppConstants.standardPids[command] ?? 'Unknown';
                return ActionChip(
                  label: Text('$command\n${description.split(' ').take(3).join(' ')}'),
                  onPressed: () => _sendCommand(command),
                  tooltip: description,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCommandSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom OBD-II Command',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    decoration: const InputDecoration(
                      labelText: 'Enter OBD-II Command (e.g., 010C)',
                      border: OutlineInputBorder(),
                      hintText: '010C for Engine RPM',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (value) => _sendCommand(value),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _sendCommand(_commandController.text),
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Common PIDs: 010C (RPM), 010D (Speed), 0105 (Coolant Temp), 0104 (Engine Load)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseHistory() {
    final history = ref.watch(diagnosticHistoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Response History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => ref.read(diagnosticHistoryProvider.notifier).clearHistory(),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text('No diagnostic responses yet'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length.clamp(0, 10), // Show last 10 responses
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final response = history[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      'Command: ${response.command}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Response: ${response.rawData}',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        if (response.parsedData != null)
                          Text(
                            'Parsed: ${response.parsedData}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      '${response.timestamp.hour}:${response.timestamp.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    leading: response.isError
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanForDTCs() async {
    try {
      final connectionActions = ref.read(connectionActionsProvider);
      
      // Send command to read DTCs
      await connectionActions.sendCommand('03'); // Read stored DTCs
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DTC scan completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning DTCs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearDTCs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear DTCs'),
        content: const Text(
          'Are you sure you want to clear all diagnostic trouble codes? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final connectionActions = ref.read(connectionActionsProvider);
        await connectionActions.sendCommand('04'); // Clear DTCs
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DTCs cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing DTCs: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _sendCommand(String command) async {
    if (command.trim().isEmpty) return;

    try {
      final connectionActions = ref.read(connectionActionsProvider);
      await connectionActions.sendCommand(command.trim().toUpperCase());
      
      _commandController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Command $command sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending command: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDTCDetails(Map<String, String> dtc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('DTC: ${dtc['code'] as String}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(dtc['description']! as String),
            const SizedBox(height: 16),
            Text(
              'Possible Causes:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '• Faulty sensor\n'
              '• Wiring issues\n'
              '• Vacuum leaks\n'
              '• Engine mechanical problems',
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended Actions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '• Inspect related components\n'
              '• Check wiring and connections\n'
              '• Consult service manual\n'
              '• Seek professional diagnosis',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}