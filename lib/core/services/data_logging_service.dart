import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import '../../shared/models/obd_response.dart';

/// Enhanced data logging service for OBD-II diagnostic data
/// Supports real-time logging, export to multiple formats, and data management
class DataLoggingService {
  static DataLoggingService? _instance;
  static DataLoggingService get instance => _instance ??= DataLoggingService._internal();
  
  DataLoggingService._internal();

  final List<LoggedDataPoint> _sessionData = [];
  final List<LoggingSession> _sessions = [];
  bool _isLogging = false;
  LoggingSession? _currentSession;
  
  // Configuration
  int _maxDataPointsPerSession = 10000;
  int _maxSessionsStored = 50;
  Duration _loggingInterval = const Duration(seconds: 1);
  Set<String> _enabledPids = {};
  
  // Getters
  bool get isLogging => _isLogging;
  LoggingSession? get currentSession => _currentSession;
  List<LoggingSession> get sessions => List.unmodifiable(_sessions);
  List<LoggedDataPoint> get currentSessionData => List.unmodifiable(_sessionData);
  Set<String> get enabledPids => Set.unmodifiable(_enabledPids);
  
  /// Initialize the logging service
  Future<void> initialize() async {
    await _loadConfiguration();
    await _loadSessions();
  }

  /// Start a new logging session
  Future<LoggingSession> startLogging({
    String? sessionName,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isLogging) {
      throw StateError('Logging session already in progress');
    }

    _sessionData.clear();
    _currentSession = LoggingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: sessionName ?? 'Session ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
      description: description,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
      enabledPids: Set.from(_enabledPids),
    );

    _isLogging = true;
    debugPrint('Data logging started: ${_currentSession!.name}');
    
    return _currentSession!;
  }

  /// Stop the current logging session
  Future<LoggingSession?> stopLogging() async {
    if (!_isLogging || _currentSession == null) {
      return null;
    }

    _currentSession = _currentSession!.copyWith(
      endTime: DateTime.now(),
      dataPoints: List.from(_sessionData),
      totalDataPoints: _sessionData.length,
    );

    _isLogging = false;
    
    // Add to sessions list
    _sessions.insert(0, _currentSession!);
    
    // Limit stored sessions
    if (_sessions.length > _maxSessionsStored) {
      _sessions.removeRange(_maxSessionsStored, _sessions.length);
    }

    await _saveSessions();
    debugPrint('Data logging stopped: ${_currentSession!.name} (${_sessionData.length} data points)');
    
    final completedSession = _currentSession!;
    _currentSession = null;
    _sessionData.clear();
    
    return completedSession;
  }

  /// Log a new data point during an active session
  void logDataPoint(OBDResponse response) {
    if (!_isLogging || _currentSession == null) {
      return;
    }

    // Only log enabled PIDs
    if (!_enabledPids.contains(response.command)) {
      return;
    }

    // Check session size limit
    if (_sessionData.length >= _maxDataPointsPerSession) {
      debugPrint('Session data limit reached, stopping logging');
      stopLogging();
      return;
    }

    final dataPoint = LoggedDataPoint(
      timestamp: DateTime.now(),
      pid: response.command,
      rawResponse: response.rawResponse,
      parsedValue: response.parsedData?['value'],
      unit: response.parsedData?['unit'] ?? '',
      isError: response.isError,
      errorMessage: response.isError ? response.rawResponse : null,
    );

    _sessionData.add(dataPoint);
  }

  /// Configure logging settings
  Future<void> configureLogging({
    Set<String>? enabledPids,
    Duration? loggingInterval,
    int? maxDataPointsPerSession,
    int? maxSessionsStored,
  }) async {
    if (enabledPids != null) {
      _enabledPids = Set.from(enabledPids);
    }
    if (loggingInterval != null) {
      _loggingInterval = loggingInterval;
    }
    if (maxDataPointsPerSession != null) {
      _maxDataPointsPerSession = maxDataPointsPerSession;
    }
    if (maxSessionsStored != null) {
      _maxSessionsStored = maxSessionsStored;
    }
    
    await _saveConfiguration();
  }

  /// Export session data to CSV format
  Future<String> exportToCsv(LoggingSession session) async {
    final headers = ['Timestamp', 'PID', 'Value', 'Unit', 'Raw Response', 'Error'];
    final rows = <List<String>>[headers];

    for (final dataPoint in session.dataPoints) {
      rows.add([
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dataPoint.timestamp),
        dataPoint.pid,
        dataPoint.parsedValue?.toString() ?? '',
        dataPoint.unit,
        dataPoint.rawResponse,
        dataPoint.isError ? (dataPoint.errorMessage ?? 'Error') : '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export session data to JSON format
  Future<String> exportToJson(LoggingSession session) async {
    final sessionJson = {
      'session': session.toJson(),
      'exportTime': DateTime.now().toIso8601String(),
      'exportVersion': '1.1.0',
    };

    return const JsonEncoder.withIndent('  ').convert(sessionJson);
  }

  /// Export session data to compressed archive
  Future<List<int>> exportToArchive(List<LoggingSession> sessions, {
    bool includeJson = true,
    bool includeCsv = true,
  }) async {
    final archive = Archive();

    for (final session in sessions) {
      final sessionFolder = 'session_${session.id}';
      
      // Add session metadata
      final metadataJson = const JsonEncoder.withIndent('  ').convert(session.toJson());
      archive.addFile(ArchiveFile(
        '$sessionFolder/metadata.json',
        metadataJson.length,
        utf8.encode(metadataJson),
      ));

      if (includeJson) {
        final jsonData = await exportToJson(session);
        archive.addFile(ArchiveFile(
          '$sessionFolder/data.json',
          jsonData.length,
          utf8.encode(jsonData),
        ));
      }

      if (includeCsv) {
        final csvData = await exportToCsv(session);
        archive.addFile(ArchiveFile(
          '$sessionFolder/data.csv',
          csvData.length,
          utf8.encode(csvData),
        ));
      }
    }

    // Add export summary
    final summary = {
      'exportTime': DateTime.now().toIso8601String(),
      'sessionsCount': sessions.length,
      'totalDataPoints': sessions.fold<int>(0, (sum, session) => sum + session.dataPoints.length),
      'exportVersion': '1.1.0',
    };
    final summaryJson = const JsonEncoder.withIndent('  ').convert(summary);
    archive.addFile(ArchiveFile(
      'export_summary.json',
      summaryJson.length,
      utf8.encode(summaryJson),
    ));

    return ZipEncoder().encode(archive)!;
  }

  /// Save export data to file
  Future<String> saveExportToFile(List<int> data, String fileName) async {
    if (kIsWeb) {
      // For web platform, we'll need to use different approach
      // This is a placeholder for web file handling
      throw UnsupportedError('File saving not yet implemented for web platform');
    }

    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/obd2_exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final file = File('${exportsDir.path}/$fileName');
    await file.writeAsBytes(data);
    
    return file.path;
  }

  /// Delete a logging session
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    await _saveSessions();
  }

  /// Clear all logging sessions
  Future<void> clearAllSessions() async {
    _sessions.clear();
    await _saveSessions();
  }

  /// Get sessions filtered by date range
  List<LoggingSession> getSessionsByDateRange(DateTime startDate, DateTime endDate) {
    return _sessions.where((session) {
      return session.startTime.isAfter(startDate) && 
             session.startTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get aggregated statistics for a session
  Map<String, dynamic> getSessionStatistics(LoggingSession session) {
    final stats = <String, dynamic>{};
    
    // Group data points by PID
    final pidGroups = <String, List<LoggedDataPoint>>{};
    for (final dataPoint in session.dataPoints) {
      pidGroups.putIfAbsent(dataPoint.pid, () => []).add(dataPoint);
    }

    stats['totalDataPoints'] = session.dataPoints.length;
    stats['duration'] = session.endTime?.difference(session.startTime).inSeconds ?? 0;
    stats['enabledPidsCount'] = session.enabledPids.length;
    stats['errorCount'] = session.dataPoints.where((dp) => dp.isError).length;
    
    final pidStats = <String, Map<String, dynamic>>{};
    for (final entry in pidGroups.entries) {
      final pidData = entry.value;
      final numericValues = pidData
          .where((dp) => !dp.isError && dp.parsedValue is num)
          .map((dp) => (dp.parsedValue as num).toDouble())
          .toList();

      if (numericValues.isNotEmpty) {
        pidStats[entry.key] = {
          'count': pidData.length,
          'errorCount': pidData.where((dp) => dp.isError).length,
          'min': numericValues.reduce((a, b) => a < b ? a : b),
          'max': numericValues.reduce((a, b) => a > b ? a : b),
          'average': numericValues.reduce((a, b) => a + b) / numericValues.length,
          'unit': pidData.first.unit,
        };
      } else {
        pidStats[entry.key] = {
          'count': pidData.length,
          'errorCount': pidData.where((dp) => dp.isError).length,
        };
      }
    }
    
    stats['pidStatistics'] = pidStats;
    return stats;
  }

  // Private methods
  Future<void> _loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabledPidsJson = prefs.getStringList('logging_enabled_pids') ?? [];
      _enabledPids = Set.from(enabledPidsJson);
      
      _loggingInterval = Duration(
        milliseconds: prefs.getInt('logging_interval_ms') ?? 1000,
      );
      _maxDataPointsPerSession = prefs.getInt('logging_max_data_points') ?? 10000;
      _maxSessionsStored = prefs.getInt('logging_max_sessions') ?? 50;
    } catch (e) {
      debugPrint('Error loading logging configuration: $e');
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('logging_enabled_pids', _enabledPids.toList());
      await prefs.setInt('logging_interval_ms', _loggingInterval.inMilliseconds);
      await prefs.setInt('logging_max_data_points', _maxDataPointsPerSession);
      await prefs.setInt('logging_max_sessions', _maxSessionsStored);
    } catch (e) {
      debugPrint('Error saving logging configuration: $e');
    }
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('logging_sessions') ?? [];
      
      _sessions.clear();
      for (final sessionJson in sessionsJson) {
        try {
          final sessionMap = jsonDecode(sessionJson);
          _sessions.add(LoggingSession.fromJson(sessionMap));
        } catch (e) {
          debugPrint('Error parsing session data: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions.map((session) => jsonEncode(session.toJson())).toList();
      await prefs.setStringList('logging_sessions', sessionsJson);
    } catch (e) {
      debugPrint('Error saving sessions: $e');
    }
  }
}

/// Represents a single logged data point
class LoggedDataPoint {
  final DateTime timestamp;
  final String pid;
  final String rawResponse;
  final dynamic parsedValue;
  final String unit;
  final bool isError;
  final String? errorMessage;

  const LoggedDataPoint({
    required this.timestamp,
    required this.pid,
    required this.rawResponse,
    this.parsedValue,
    required this.unit,
    required this.isError,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'pid': pid,
    'rawResponse': rawResponse,
    'parsedValue': parsedValue,
    'unit': unit,
    'isError': isError,
    'errorMessage': errorMessage,
  };

  factory LoggedDataPoint.fromJson(Map<String, dynamic> json) => LoggedDataPoint(
    timestamp: DateTime.parse(json['timestamp']),
    pid: json['pid'],
    rawResponse: json['rawResponse'],
    parsedValue: json['parsedValue'],
    unit: json['unit'] ?? '',
    isError: json['isError'] ?? false,
    errorMessage: json['errorMessage'],
  );
}

/// Represents a logging session with metadata and data points
class LoggingSession {
  final String id;
  final String name;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> metadata;
  final Set<String> enabledPids;
  final List<LoggedDataPoint> dataPoints;
  final int totalDataPoints;

  const LoggingSession({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    this.endTime,
    required this.metadata,
    required this.enabledPids,
    this.dataPoints = const [],
    this.totalDataPoints = 0,
  });

  LoggingSession copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? metadata,
    Set<String>? enabledPids,
    List<LoggedDataPoint>? dataPoints,
    int? totalDataPoints,
  }) => LoggingSession(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    metadata: metadata ?? this.metadata,
    enabledPids: enabledPids ?? this.enabledPids,
    dataPoints: dataPoints ?? this.dataPoints,
    totalDataPoints: totalDataPoints ?? this.totalDataPoints,
  );

  Duration? get duration => endTime?.difference(startTime);
  bool get isActive => endTime == null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'metadata': metadata,
    'enabledPids': enabledPids.toList(),
    'dataPoints': dataPoints.map((dp) => dp.toJson()).toList(),
    'totalDataPoints': totalDataPoints,
  };

  factory LoggingSession.fromJson(Map<String, dynamic> json) => LoggingSession(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    enabledPids: Set<String>.from(json['enabledPids'] ?? []),
    dataPoints: (json['dataPoints'] as List?)
        ?.map((dp) => LoggedDataPoint.fromJson(dp))
        .toList() ?? [],
    totalDataPoints: json['totalDataPoints'] ?? 0,
  );
}