import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/data_logging_service.dart';
import '../../../shared/providers/app_providers.dart';

/// Enhanced data export and logging management screen
class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  final DataLoggingService _loggingService = DataLoggingService.instance;
  List<LoggingSession> _sessions = [];
  List<LoggingSession> _selectedSessions = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _includeMetadata = true;
  bool _compressOutput = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    
    try {
      await _loggingService.initialize();
      _sessions = _loggingService.sessions;
      
      if (_selectedDateRange != null) {
        _sessions = _loggingService.getSessionsByDateRange(
          _selectedDateRange!.start,
          _selectedDateRange!.end,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load sessions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Export & Logging'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh sessions',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep),
                  title: Text('Clear All Sessions'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Logging Settings'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterAndOptionsPanel(),
                Expanded(child: _buildSessionsList()),
                _buildExportPanel(),
              ],
            ),
      floatingActionButton: _buildLoggingFab(),
    );
  }

  Widget _buildFilterAndOptionsPanel() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter & Export Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDateRange,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date Range',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDateRange != null
                            ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                            : 'All dates',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButtonFormField<ExportFormat>(
                  value: _selectedFormat,
                  decoration: const InputDecoration(
                    labelText: 'Export Format',
                    border: OutlineInputBorder(),
                  ),
                  items: ExportFormat.values.map((format) {
                    return DropdownMenuItem(
                      value: format,
                      child: Text(format.displayName),
                    );
                  }).toList(),
                  onChanged: (format) {
                    if (format != null) {
                      setState(() => _selectedFormat = format);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _includeMetadata,
                      onChanged: (value) {
                        setState(() => _includeMetadata = value ?? true);
                      },
                    ),
                    const Text('Include metadata'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _compressOutput,
                      onChanged: (value) {
                        setState(() => _compressOutput = value ?? false);
                      },
                    ),
                    const Text('Compress output'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No logging sessions found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new logging session to collect data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Checkbox(
                value: _selectedSessions.length == _sessions.length,
                tristate: true,
                onChanged: _toggleSelectAll,
              ),
              Text(
                'Sessions (${_sessions.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_selectedSessions.isNotEmpty)
                Text(
                  '${_selectedSessions.length} selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              final isSelected = _selectedSessions.contains(session);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleSessionSelection(session),
                  ),
                  title: Text(
                    session.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(session.startTime),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.data_usage, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${session.totalDataPoints} points'),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(_formatDuration(session.duration)),
                          const SizedBox(width: 16),
                          Icon(Icons.tune, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${session.enabledPids.length} PIDs'),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) => _handleSessionAction(action, session),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('View Details'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Export Individually'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _toggleSessionSelection(session),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExportPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export ${_selectedSessions.length} session(s)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Total: ${_getTotalDataPoints()} data points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _selectedSessions.isNotEmpty ? _exportSelectedSessions : null,
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggingFab() {
    final isLogging = _loggingService.isLogging;
    
    return FloatingActionButton.extended(
      onPressed: isLogging ? _stopLogging : _startLogging,
      icon: Icon(isLogging ? Icons.stop : Icons.play_arrow),
      label: Text(isLogging ? 'Stop Logging' : 'Start Logging'),
      backgroundColor: isLogging ? Colors.red : null,
    );
  }

  // Event handlers
  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedSessions = List.from(_sessions);
      } else {
        _selectedSessions.clear();
      }
    });
  }

  void _toggleSessionSelection(LoggingSession session) {
    setState(() {
      if (_selectedSessions.contains(session)) {
        _selectedSessions.remove(session);
      } else {
        _selectedSessions.add(session);
      }
    });
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (dateRange != null) {
      setState(() => _selectedDateRange = dateRange);
      await _loadSessions();
    }
  }

  Future<void> _startLogging() async {
    try {
      await _loggingService.startLogging();
      _showSuccessSnackBar('Data logging started');
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to start logging: $e');
    }
  }

  Future<void> _stopLogging() async {
    try {
      final session = await _loggingService.stopLogging();
      if (session != null) {
        _showSuccessSnackBar('Logging stopped: ${session.totalDataPoints} data points saved');
        await _loadSessions();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to stop logging: $e');
    }
  }

  Future<void> _exportSelectedSessions() async {
    if (_selectedSessions.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      switch (_selectedFormat) {
        case ExportFormat.json:
          await _exportAsJson();
          break;
        case ExportFormat.csv:
          await _exportAsCsv();
          break;
        case ExportFormat.archive:
          await _exportAsArchive();
          break;
      }

      _showSuccessSnackBar('Export completed successfully');
    } catch (e) {
      _showErrorSnackBar('Export failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAsJson() async {
    // TODO: Implement JSON export with file saving
    for (final session in _selectedSessions) {
      final jsonData = await _loggingService.exportToJson(session);
      // Save to file or share
      debugPrint('JSON export for ${session.name}: ${jsonData.length} characters');
    }
  }

  Future<void> _exportAsCsv() async {
    // TODO: Implement CSV export with file saving
    for (final session in _selectedSessions) {
      final csvData = await _loggingService.exportToCsv(session);
      // Save to file or share
      debugPrint('CSV export for ${session.name}: ${csvData.length} characters');
    }
  }

  Future<void> _exportAsArchive() async {
    // TODO: Implement archive export with file saving
    final archiveData = await _loggingService.exportToArchive(
      _selectedSessions,
      includeJson: true,
      includeCsv: true,
    );
    debugPrint('Archive export: ${archiveData.length} bytes');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'settings':
        _showLoggingSettings();
        break;
    }
  }

  void _handleSessionAction(String action, LoggingSession session) {
    switch (action) {
      case 'view':
        _showSessionDetails(session);
        break;
      case 'export':
        _exportSingleSession(session);
        break;
      case 'delete':
        _deleteSession(session);
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Sessions'),
        content: const Text(
          'This will permanently delete all logging sessions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _loggingService.clearAllSessions();
              await _loadSessions();
              _showSuccessSnackBar('All sessions cleared');
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showLoggingSettings() {
    // TODO: Implement logging settings dialog
    _showSnackBar('Logging settings dialog coming soon');
  }

  void _showSessionDetails(LoggingSession session) {
    final stats = _loggingService.getSessionStatistics(session);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.name),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Start Time', DateFormat('MMM dd, yyyy HH:mm:ss').format(session.startTime)),
              _buildDetailRow('Duration', _formatDuration(session.duration)),
              _buildDetailRow('Data Points', '${stats['totalDataPoints']}'),
              _buildDetailRow('Enabled PIDs', '${stats['enabledPidsCount']}'),
              _buildDetailRow('Error Count', '${stats['errorCount']}'),
              if (session.description != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Description', session.description!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSingleSession(LoggingSession session) async {
    setState(() => _selectedSessions = [session]);
    await _exportSelectedSessions();
  }

  Future<void> _deleteSession(LoggingSession session) async {
    await _loggingService.deleteSession(session.id);
    await _loadSessions();
    _showSuccessSnackBar('Session deleted');
  }

  // Helper methods
  int _getTotalDataPoints() {
    return _selectedSessions.fold(0, (sum, session) => sum + session.totalDataPoints);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Unknown';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

enum ExportFormat {
  json('JSON'),
  csv('CSV'),
  archive('ZIP Archive');

  const ExportFormat(this.displayName);
  final String displayName;
}