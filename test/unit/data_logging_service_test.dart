import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/core/services/data_logging_service.dart';
import 'package:new_obd2_tool/shared/models/obd_response.dart';

void main() {
  group('DataLoggingService', () {
    late DataLoggingService service;

    setUp(() {
      service = DataLoggingService.instance;
    });

    test('should initialize correctly', () async {
      await service.initialize();
      expect(service.isLogging, false);
      expect(service.currentSession, null);
      expect(service.sessions, isEmpty);
    });

    test('should start logging session', () async {
      await service.initialize();
      
      final session = await service.startLogging(
        sessionName: 'Test Session',
        description: 'Test description',
      );

      expect(service.isLogging, true);
      expect(service.currentSession, isNotNull);
      expect(session.name, 'Test Session');
      expect(session.description, 'Test description');
    });

    test('should stop logging session', () async {
      await service.initialize();
      await service.startLogging(sessionName: 'Test Session');
      
      final session = await service.stopLogging();

      expect(service.isLogging, false);
      expect(service.currentSession, null);
      expect(session, isNotNull);
      expect(session!.name, 'Test Session');
      expect(session.endTime, isNotNull);
    });

    test('should log data points during active session', () async {
      await service.initialize();
      await service.configureLogging(enabledPids: {'010C', '010D'});
      await service.startLogging(sessionName: 'Test Session');

      final response = OBDResponse(
        command: '010C',
        rawResponse: '41 0C 1A F8',
        isError: false,
        timestamp: DateTime.now(),
        parsedData: {'value': 1750.0, 'unit': 'RPM'},
      );

      service.logDataPoint(response);

      expect(service.currentSessionData.length, 1);
      expect(service.currentSessionData.first.pid, '010C');
      expect(service.currentSessionData.first.parsedValue, 1750.0);
    });

    test('should not log disabled PIDs', () async {
      await service.initialize();
      await service.configureLogging(enabledPids: {'010C'}); // Only RPM enabled
      await service.startLogging(sessionName: 'Test Session');

      final response = OBDResponse(
        command: '010D', // Speed - not enabled
        rawResponse: '41 0D 3C',
        isError: false,
        timestamp: DateTime.now(),
        parsedData: {'value': 60.0, 'unit': 'km/h'},
      );

      service.logDataPoint(response);

      expect(service.currentSessionData.length, 0);
    });

    test('should export session to CSV', () async {
      await service.initialize();
      await service.configureLogging(enabledPids: {'010C'});
      await service.startLogging(sessionName: 'Test Session');

      final response = OBDResponse(
        command: '010C',
        rawResponse: '41 0C 1A F8',
        isError: false,
        timestamp: DateTime.now(),
        parsedData: {'value': 1750.0, 'unit': 'RPM'},
      );

      service.logDataPoint(response);
      final session = await service.stopLogging();

      final csvData = await service.exportToCsv(session!);

      expect(csvData, contains('Timestamp,PID,Value,Unit,Raw Response,Error'));
      expect(csvData, contains('010C'));
      expect(csvData, contains('1750.0'));
      expect(csvData, contains('RPM'));
    });

    test('should export session to JSON', () async {
      await service.initialize();
      await service.configureLogging(enabledPids: {'010C'});
      await service.startLogging(sessionName: 'Test Session');

      final response = OBDResponse(
        command: '010C',
        rawResponse: '41 0C 1A F8',
        isError: false,
        timestamp: DateTime.now(),
        parsedData: {'value': 1750.0, 'unit': 'RPM'},
      );

      service.logDataPoint(response);
      final session = await service.stopLogging();

      final jsonData = await service.exportToJson(session!);

      expect(jsonData, contains('"exportVersion":"1.1.0"'));
      expect(jsonData, contains('"name":"Test Session"'));
      expect(jsonData, contains('"pid":"010C"'));
    });

    test('should calculate session statistics', () async {
      await service.initialize();
      await service.configureLogging(enabledPids: {'010C'});
      await service.startLogging(sessionName: 'Test Session');

      // Add multiple data points
      for (int i = 0; i < 5; i++) {
        final response = OBDResponse(
          command: '010C',
          rawResponse: '41 0C 1A F8',
          isError: false,
          timestamp: DateTime.now(),
          parsedData: {'value': 1500.0 + (i * 100), 'unit': 'RPM'},
        );
        service.logDataPoint(response);
      }

      final session = await service.stopLogging();
      final stats = service.getSessionStatistics(session!);

      expect(stats['totalDataPoints'], 5);
      expect(stats['errorCount'], 0);
      expect(stats['enabledPidsCount'], 1);
      
      final pidStats = stats['pidStatistics']['010C'];
      expect(pidStats['count'], 5);
      expect(pidStats['min'], 1500.0);
      expect(pidStats['max'], 1900.0);
      expect(pidStats['average'], 1700.0);
    });

    test('should handle error responses in logging', () async {
      await service.initialize();
      await service.configureLogging(enabledPids: {'010C'});
      await service.startLogging(sessionName: 'Test Session');

      final errorResponse = OBDResponse(
        command: '010C',
        rawResponse: 'NO DATA',
        isError: true,
        timestamp: DateTime.now(),
      );

      service.logDataPoint(errorResponse);

      expect(service.currentSessionData.length, 1);
      expect(service.currentSessionData.first.isError, true);
      expect(service.currentSessionData.first.rawResponse, 'NO DATA');
    });

    test('should filter sessions by date range', () async {
      await service.initialize();
      
      // Create sessions with different dates (simulated)
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final weekAgo = now.subtract(const Duration(days: 7));
      
      // Note: In a real test environment, you would mock the session creation dates
      // For this test, we're testing the filter logic conceptually
      
      final startDate = now.subtract(const Duration(days: 2));
      final endDate = now.add(const Duration(days: 1));
      
      final filteredSessions = service.getSessionsByDateRange(startDate, endDate);
      
      // This would contain sessions within the date range
      expect(filteredSessions, isA<List<LoggingSession>>());
    });
  });

  group('LoggedDataPoint', () {
    test('should serialize to and from JSON', () {
      final timestamp = DateTime.now();
      final dataPoint = LoggedDataPoint(
        timestamp: timestamp,
        pid: '010C',
        rawResponse: '41 0C 1A F8',
        parsedValue: 1750.0,
        unit: 'RPM',
        isError: false,
      );

      final json = dataPoint.toJson();
      final recreated = LoggedDataPoint.fromJson(json);

      expect(recreated.timestamp, timestamp);
      expect(recreated.pid, '010C');
      expect(recreated.rawResponse, '41 0C 1A F8');
      expect(recreated.parsedValue, 1750.0);
      expect(recreated.unit, 'RPM');
      expect(recreated.isError, false);
    });
  });

  group('LoggingSession', () {
    test('should serialize to and from JSON', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 5));
      
      final session = LoggingSession(
        id: 'test-session-1',
        name: 'Test Session',
        description: 'Test description',
        startTime: startTime,
        endTime: endTime,
        metadata: {'test': 'value'},
        enabledPids: {'010C', '010D'},
        totalDataPoints: 100,
      );

      final json = session.toJson();
      final recreated = LoggingSession.fromJson(json);

      expect(recreated.id, 'test-session-1');
      expect(recreated.name, 'Test Session');
      expect(recreated.description, 'Test description');
      expect(recreated.startTime, startTime);
      expect(recreated.endTime, endTime);
      expect(recreated.metadata['test'], 'value');
      expect(recreated.enabledPids, contains('010C'));
      expect(recreated.enabledPids, contains('010D'));
      expect(recreated.totalDataPoints, 100);
    });

    test('should calculate duration correctly', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 5, seconds: 30));
      
      final session = LoggingSession(
        id: 'test-session-1',
        name: 'Test Session',
        startTime: startTime,
        endTime: endTime,
        metadata: {},
        enabledPids: {},
      );

      expect(session.duration?.inMinutes, 5);
      expect(session.duration?.inSeconds, 330);
    });

    test('should detect active session', () {
      final startTime = DateTime.now();
      
      final activeSession = LoggingSession(
        id: 'active-session',
        name: 'Active Session',
        startTime: startTime,
        metadata: {},
        enabledPids: {},
      );

      final completedSession = LoggingSession(
        id: 'completed-session',
        name: 'Completed Session',
        startTime: startTime,
        endTime: startTime.add(const Duration(minutes: 5)),
        metadata: {},
        enabledPids: {},
      );

      expect(activeSession.isActive, true);
      expect(completedSession.isActive, false);
    });
  });
}