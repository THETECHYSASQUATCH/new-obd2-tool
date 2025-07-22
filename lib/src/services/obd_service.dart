import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/obd_models.dart';
import 'platform_service.dart';

/// Provider for the OBD-II service
final obdServiceProvider = Provider<OBDService>((ref) {
  return OBDService(ref.read(platformServiceProvider));
});

/// Provider for connection state
final connectionStateProvider = StateNotifierProvider<ConnectionStateNotifier, ConnectionState>((ref) {
  return ConnectionStateNotifier(ref.read(obdServiceProvider));
});

/// Provider for available devices
final availableDevicesProvider = StateNotifierProvider<AvailableDevicesNotifier, List<OBDDevice>>((ref) {
  return AvailableDevicesNotifier(ref.read(obdServiceProvider));
});

/// Main OBD-II service class that handles communication with OBD-II adapters
class OBDService {
  final PlatformService _platformService;
  final StreamController<List<DiagnosticTroubleCode>> _dtcController = StreamController.broadcast();
  final StreamController<LiveDataPoint> _liveDataController = StreamController.broadcast();
  
  OBDDevice? _currentDevice;
  bool _isScanning = false;
  bool _isConnected = false;
  
  OBDService(this._platformService);

  /// Stream of diagnostic trouble codes
  Stream<List<DiagnosticTroubleCode>> get dtcStream => _dtcController.stream;
  
  /// Stream of live data points
  Stream<LiveDataPoint> get liveDataStream => _liveDataController.stream;
  
  /// Current connected device
  OBDDevice? get currentDevice => _currentDevice;
  
  /// Whether currently scanning for devices
  bool get isScanning => _isScanning;
  
  /// Whether connected to a device
  bool get isConnected => _isConnected;

  /// Start scanning for available OBD-II devices
  Future<List<OBDDevice>> scanForDevices() async {
    if (_isScanning) return [];
    
    _isScanning = true;
    try {
      debugPrint('Starting OBD-II device scan...');
      
      // Platform-specific device scanning
      final devices = await _platformService.scanForOBDDevices();
      
      debugPrint('Found ${devices.length} OBD-II devices');
      return devices;
    } catch (e) {
      debugPrint('Error scanning for devices: $e');
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  /// Connect to an OBD-II device
  Future<bool> connectToDevice(OBDDevice device) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      debugPrint('Connecting to device: ${device.name}');
      
      final success = await _platformService.connectToDevice(device);
      
      if (success) {
        _currentDevice = device.copyWith(isConnected: true);
        _isConnected = true;
        debugPrint('Successfully connected to ${device.name}');
        
        // Initialize connection with basic commands
        await _initializeConnection();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    if (!_isConnected || _currentDevice == null) return;

    try {
      debugPrint('Disconnecting from ${_currentDevice!.name}');
      
      await _platformService.disconnect();
      
      _currentDevice = null;
      _isConnected = false;
      
      debugPrint('Disconnected successfully');
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  /// Read diagnostic trouble codes from the vehicle
  Future<List<DiagnosticTroubleCode>> readDTCs() async {
    if (!_isConnected) {
      throw Exception('Not connected to OBD-II device');
    }

    try {
      debugPrint('Reading diagnostic trouble codes...');
      
      final dtcs = await _platformService.readDTCs();
      
      debugPrint('Found ${dtcs.length} diagnostic trouble codes');
      _dtcController.add(dtcs);
      
      return dtcs;
    } catch (e) {
      debugPrint('Error reading DTCs: $e');
      rethrow;
    }
  }

  /// Clear diagnostic trouble codes
  Future<bool> clearDTCs() async {
    if (!_isConnected) {
      throw Exception('Not connected to OBD-II device');
    }

    try {
      debugPrint('Clearing diagnostic trouble codes...');
      
      final success = await _platformService.clearDTCs();
      
      if (success) {
        debugPrint('DTCs cleared successfully');
        // Refresh DTC list
        await readDTCs();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error clearing DTCs: $e');
      return false;
    }
  }

  /// Get vehicle information
  Future<VehicleInfo> getVehicleInfo() async {
    if (!_isConnected) {
      throw Exception('Not connected to OBD-II device');
    }

    try {
      debugPrint('Reading vehicle information...');
      
      final vehicleInfo = await _platformService.getVehicleInfo();
      
      debugPrint('Vehicle info retrieved: $vehicleInfo');
      return vehicleInfo;
    } catch (e) {
      debugPrint('Error reading vehicle info: $e');
      rethrow;
    }
  }

  /// Start live data streaming
  Future<void> startLiveDataStream(List<String> pids) async {
    if (!_isConnected) {
      throw Exception('Not connected to OBD-II device');
    }

    try {
      debugPrint('Starting live data stream for PIDs: $pids');
      
      await _platformService.startLiveDataStream(pids, (dataPoint) {
        _liveDataController.add(dataPoint);
      });
      
    } catch (e) {
      debugPrint('Error starting live data stream: $e');
      rethrow;
    }
  }

  /// Stop live data streaming
  Future<void> stopLiveDataStream() async {
    try {
      debugPrint('Stopping live data stream...');
      await _platformService.stopLiveDataStream();
    } catch (e) {
      debugPrint('Error stopping live data stream: $e');
    }
  }

  /// Initialize connection with basic commands
  Future<void> _initializeConnection() async {
    try {
      // Send basic initialization commands
      await _platformService.sendCommand('ATZ'); // Reset
      await _platformService.sendCommand('ATE0'); // Echo off
      await _platformService.sendCommand('ATL0'); // Line feed off
      await _platformService.sendCommand('ATS0'); // Space off
      await _platformService.sendCommand('ATSP0'); // Auto protocol
      
      debugPrint('OBD-II connection initialized');
    } catch (e) {
      debugPrint('Error initializing connection: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _dtcController.close();
    _liveDataController.close();
  }
}

/// Connection state management
class ConnectionState {
  final bool isConnected;
  final bool isConnecting;
  final OBDDevice? device;
  final String? error;

  const ConnectionState({
    this.isConnected = false,
    this.isConnecting = false,
    this.device,
    this.error,
  });

  ConnectionState copyWith({
    bool? isConnected,
    bool? isConnecting,
    OBDDevice? device,
    String? error,
  }) {
    return ConnectionState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      device: device ?? this.device,
      error: error ?? this.error,
    );
  }
}

/// State notifier for connection state
class ConnectionStateNotifier extends StateNotifier<ConnectionState> {
  final OBDService _obdService;

  ConnectionStateNotifier(this._obdService) : super(const ConnectionState());

  Future<void> connect(OBDDevice device) async {
    state = state.copyWith(isConnecting: true, error: null);
    
    try {
      final success = await _obdService.connectToDevice(device);
      
      if (success) {
        state = state.copyWith(
          isConnected: true,
          isConnecting: false,
          device: device,
        );
      } else {
        state = state.copyWith(
          isConnecting: false,
          error: 'Failed to connect to device',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    await _obdService.disconnect();
    state = const ConnectionState();
  }
}

/// State notifier for available devices
class AvailableDevicesNotifier extends StateNotifier<List<OBDDevice>> {
  final OBDService _obdService;

  AvailableDevicesNotifier(this._obdService) : super([]);

  Future<void> scanForDevices() async {
    try {
      final devices = await _obdService.scanForDevices();
      state = devices;
    } catch (e) {
      debugPrint('Error in device scan: $e');
      state = [];
    }
  }

  void clearDevices() {
    state = [];
  }
}