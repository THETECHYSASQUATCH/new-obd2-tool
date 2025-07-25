import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import '../models/ecu_programming.dart';
import '../models/vehicle_info.dart';
import 'vehicle_service.dart';
import 'obd_service.dart';
import 'secure_storage_service.dart';

class EcuProgrammingService {
  static final StreamController<ProgrammingSession> _sessionController = 
      StreamController<ProgrammingSession>.broadcast();
  
  static final Map<String, ProgrammingSession> _activeSessions = {};
  static final List<EcuInfo> _discoveredEcus = [];

  static Stream<ProgrammingSession> get sessionStream => _sessionController.stream;
  static List<EcuInfo> get discoveredEcus => List.unmodifiable(_discoveredEcus);

  /// Initialize the ECU programming service
  static Future<void> initialize() async {
    try {
      await _loadPreviousSessions();
      debugPrint('ECU Programming Service initialized');
    } catch (e) {
      debugPrint('Error initializing ECU Programming Service: $e');
    }
  }

  /// Discover available ECUs in the vehicle
  static Future<List<EcuInfo>> discoverEcus() async {
    _discoveredEcus.clear();
    
    final vehicle = VehicleService.selectedVehicle;
    if (vehicle == null) {
      throw Exception('No vehicle selected. Please select a vehicle first.');
    }

    // Simulate ECU discovery based on vehicle type
    await _simulateEcuDiscovery(vehicle);
    
    debugPrint('Discovered ${_discoveredEcus.length} ECUs');
    return List.from(_discoveredEcus);
  }

  static Future<void> _simulateEcuDiscovery(VehicleInfo vehicle) async {
    // Simulate discovery delay
    await Future.delayed(const Duration(seconds: 2));

    // Add common ECUs based on vehicle type
    _discoveredEcus.addAll([
      const EcuInfo(
        id: 'engine_ecu',
        name: 'Engine Control Module',
        type: EcuType.engine,
        address: '0x7E0',
        partNumber: 'ECM-001',
        softwareVersion: '1.2.3',
        programmingSupported: true,
        supportedModes: [ProgrammingMode.flash, ProgrammingMode.calibration],
      ),
      const EcuInfo(
        id: 'transmission_ecu',
        name: 'Transmission Control Module',
        type: EcuType.transmission,
        address: '0x7E1',
        partNumber: 'TCM-001',
        softwareVersion: '2.1.0',
        programmingSupported: true,
        supportedModes: [ProgrammingMode.flash, ProgrammingMode.adaptation],
      ),
    ]);

    // Add hybrid ECU for hybrid vehicles
    if (vehicle.engine?.toLowerCase().contains('hybrid') == true) {
      _discoveredEcus.add(const EcuInfo(
        id: 'hybrid_ecu',
        name: 'Hybrid Control Module',
        type: EcuType.hybrid,
        address: '0x7E2',
        partNumber: 'HCM-001',
        softwareVersion: '3.0.1',
        programmingSupported: true,
        supportedModes: [ProgrammingMode.flash, ProgrammingMode.calibration],
      ));
    }
  }

  /// Start a programming session
  static Future<ProgrammingSession> startProgrammingSession({
    required String ecuId,
    required ProgrammingMode mode,
    required String filePath,
  }) async {
    final ecu = _discoveredEcus.firstWhere(
      (e) => e.id == ecuId,
      orElse: () => throw Exception('ECU not found: $ecuId'),
    );

    if (!ecu.programmingSupported) {
      throw Exception('ECU does not support programming: ${ecu.name}');
    }

    if (!ecu.supportedModes.contains(mode)) {
      throw Exception('ECU does not support programming mode: $mode');
    }

    // Check if file exists and is valid
    if (!await File(filePath).exists()) {
      throw Exception('Programming file not found: $filePath');
    }

    final sessionId = _generateSessionId();
    final session = ProgrammingSession(
      id: sessionId,
      ecuId: ecuId,
      mode: mode,
      startTime: DateTime.now(),
      status: ProgrammingStatus.connecting,
      filePath: filePath,
      log: ['Session started'],
    );

    _activeSessions[sessionId] = session;
    _sessionController.add(session);

    // Start the programming process asynchronously
    _runProgrammingSession(sessionId);

    return session;
  }

  /// Create backup of ECU before programming
  static Future<String> createEcuBackup(String ecuId) async {
    final ecu = _discoveredEcus.firstWhere(
      (e) => e.id == ecuId,
      orElse: () => throw Exception('ECU not found: $ecuId'),
    );

    // Simulate backup creation
    await Future.delayed(const Duration(seconds: 3));

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = 'backups/${ecu.name}_backup_$timestamp.bin';
    
    // In a real implementation, this would read the ECU data
    debugPrint('Created backup for ${ecu.name}: $backupPath');
    
    return backupPath;
  }

  /// Verify programming file integrity
  static Future<bool> verifyProgrammingFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      // Calculate checksum
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      
      // In a real implementation, you would verify against known checksums
      debugPrint('File checksum: ${digest.toString()}');
      
      return true;
    } catch (e) {
      debugPrint('Error verifying file: $e');
      return false;
    }
  }

  /// Cancel an active programming session
  static Future<void> cancelSession(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    final updatedSession = session.copyWith(
      status: ProgrammingStatus.cancelled,
      endTime: DateTime.now(),
      log: [...session.log, 'Session cancelled by user'],
    );

    _activeSessions[sessionId] = updatedSession;
    _sessionController.add(updatedSession);
  }

  /// Get active programming sessions
  static List<ProgrammingSession> getActiveSessions() {
    return _activeSessions.values
        .where((session) => session.isActive)
        .toList();
  }

  /// Get programming session by ID
  static ProgrammingSession? getSession(String sessionId) {
    return _activeSessions[sessionId];
  }

  static Future<void> _runProgrammingSession(String sessionId) async {
    ProgrammingSession session = _activeSessions[sessionId]!;
    
    try {
      // Authenticate
      session = session.copyWith(
        status: ProgrammingStatus.authenticating,
        progress: 10.0,
        log: [...session.log, 'Authenticating with ECU'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);
      
      await Future.delayed(const Duration(seconds: 2));

      // Create backup
      final backupPath = await createEcuBackup(session.ecuId);
      session = session.copyWith(
        status: ProgrammingStatus.reading,
        progress: 20.0,
        backupPath: backupPath,
        log: [...session.log, 'Backup created: $backupPath'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);

      await Future.delayed(const Duration(seconds: 3));

      // Erase
      session = session.copyWith(
        status: ProgrammingStatus.erasing,
        progress: 30.0,
        log: [...session.log, 'Erasing ECU memory'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);

      await Future.delayed(const Duration(seconds: 2));

      // Program
      session = session.copyWith(
        status: ProgrammingStatus.programming,
        progress: 40.0,
        log: [...session.log, 'Programming ECU...'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);

      // Simulate programming progress
      for (int i = 40; i <= 80; i += 10) {
        await Future.delayed(const Duration(milliseconds: 800));
        session = session.copyWith(
          progress: i.toDouble(),
          log: [...session.log, 'Programming progress: $i%'],
        );
        _activeSessions[sessionId] = session;
        _sessionController.add(session);
      }

      // Verify
      session = session.copyWith(
        status: ProgrammingStatus.verifying,
        progress: 90.0,
        log: [...session.log, 'Verifying programming'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);

      await Future.delayed(const Duration(seconds: 2));

      // Complete
      session = session.copyWith(
        status: ProgrammingStatus.completed,
        progress: 100.0,
        endTime: DateTime.now(),
        log: [...session.log, 'Programming completed successfully'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);

    } catch (e) {
      session = session.copyWith(
        status: ProgrammingStatus.error,
        endTime: DateTime.now(),
        errorMessage: e.toString(),
        log: [...session.log, 'Error: $e'],
      );
      _activeSessions[sessionId] = session;
      _sessionController.add(session);
    }
  }

  static Future<void> _loadPreviousSessions() async {
    // In a real implementation, load previous sessions from storage
  }

  static String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  static void dispose() {
    _sessionController.close();
  }
}