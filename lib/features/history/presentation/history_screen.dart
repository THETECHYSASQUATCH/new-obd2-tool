import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(diagnosticHistoryProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref),
            const SizedBox(height: 20),
            _buildFilterChips(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildHistoryList(context, history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Diagnostic History',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _exportHistory(),
              icon: const Icon(Icons.download),
              tooltip: 'Export History',
            ),
            IconButton(
              onPressed: () => ref.read(diagnosticHistoryProvider.notifier).clearHistory(),
              icon: const Icon(Icons.delete),
              tooltip: 'Clear History',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: true,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Errors'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Today'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('This Week'),
            selected: false,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<dynamic> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No diagnostic history yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start diagnosing your vehicle to see history here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final response = history[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: response.isError ? Colors.red : Colors.green,
            child: Icon(
              response.isError ? Icons.error : Icons.check,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Command: ${response.command}',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                response.isError 
                    ? 'Error: ${response.errorMessage}'
                    : 'Response: ${response.rawData}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              if (response.parsedData != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Value: ${response.parsedData!['value']} ${response.parsedData!['unit'] as String? ?? ''}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(response.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(value, response),
          ),
          onTap: () => _showResponseDetails(context, response),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _handleMenuAction(String action, dynamic response) {
    switch (action) {
      case 'details':
        // Show details dialog
        break;
      case 'copy':
        // Copy to clipboard
        break;
      case 'delete':
        // Delete item
        break;
    }
  }

  void _showResponseDetails(BuildContext context, dynamic response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Response Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Command', response.command),
              _buildDetailRow('Raw Response', response.rawData),
              _buildDetailRow('Timestamp', response.timestamp.toString()),
              if (response.isError)
                _buildDetailRow('Error', response.errorMessage ?? 'Unknown error'),
              if (response.parsedData != null) ...[
                const Divider(),
                Text(
                  'Parsed Data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...response.parsedData!.entries.map((entry) =>
                    _buildDetailRow(entry.key, entry.value.toString())),
              ],
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    // TODO: Implement history export functionality
  }
}