import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../constants/app_constants.dart';
import '../../shared/models/obd_response.dart';
import '../../shared/models/connection_config.dart';

enum ConnectionType { bluetooth, wifi, usb, serial }
enum ConnectionStatus { disconnected, connecting, connected, error }

abstract class OBDService {
  factory OBDService() {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileOBDService();
    } else {
      return DesktopOBDService();
    }
  }
  
  Stream<ConnectionStatus> get connectionStatus;
  Stream<OBDResponse> get dataStream;
  
  Future<bool> connect(ConnectionConfig config);
  Future<void> disconnect();
  Future<OBDResponse> sendCommand(String command);
  Future<List<String>> scanForDevices();
  bool get isConnected;
}

class MobileOBDService implements OBDService {
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<OBDResponse> _dataController = 
      StreamController<OBDResponse>.broadcast();
  
  BluetoothConnection? _bluetoothConnection;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  
  @override
  Stream<ConnectionStatus> get connectionStatus => _statusController.stream;
  
  @override
  Stream<OBDResponse> get dataStream => _dataController.stream;
  
  @override
  bool get isConnected => _currentStatus == ConnectionStatus.connected;
  
  @override
  Future<bool> connect(ConnectionConfig config) async {
    try {
      _updateStatus(ConnectionStatus.connecting);
      
      if (config.type == ConnectionType.bluetooth) {
        return await _connectBluetooth(config);
      }
      
      throw UnsupportedError('Connection type ${config.type} not supported on mobile');
    } catch (e) {
      _updateStatus(ConnectionStatus.error);
      debugPrint('Connection error: $e');
      return false;
    }
  }
  
  Future<bool> _connectBluetooth(ConnectionConfig config) async {
    try {
      final BluetoothDevice device = BluetoothDevice.fromMap({
        'address': config.address,
        'name': config.name,
      });
      
      _bluetoothConnection = await BluetoothConnection.toAddress(config.address);
      
      // Initialize OBD-II
      await _initializeOBD();
      
      // Start listening for data
      _bluetoothConnection!.input!.listen((Uint8List data) {
        final response = String.fromCharCodes(data);
        _dataController.add(OBDResponse.fromRaw(response));
      });
      
      _updateStatus(ConnectionStatus.connected);
      return true;
    } catch (e) {
      debugPrint('Bluetooth connection error: $e');
      return false;
    }
  }
  
  Future<void> _initializeOBD() async {
    // Send initialization commands
    await sendCommand(AppConstants.obdInitCommand);
    await Future.delayed(const Duration(milliseconds: 1000));
    await sendCommand(AppConstants.obdEchoOffCommand);
    await Future.delayed(const Duration(milliseconds: 500));
    await sendCommand(AppConstants.obdProtocolAutoCommand);
  }
  
  @override
  Future<void> disconnect() async {
    try {
      await _bluetoothConnection?.close();
      _bluetoothConnection = null;
      _updateStatus(ConnectionStatus.disconnected);
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }
  
  @override
  Future<OBDResponse> sendCommand(String command) async {
    if (!isConnected || _bluetoothConnection == null) {
      throw Exception('Not connected to OBD device');
    }
    
    try {
      _bluetoothConnection!.output.add(Uint8List.fromList(command.codeUnits));
      _bluetoothConnection!.output.add(Uint8List.fromList('\r\n'.codeUnits));
      await _bluetoothConnection!.output.allSent;
      
      // Wait for response with timeout
      final completer = Completer<OBDResponse>();
      late StreamSubscription subscription;
      
      subscription = dataStream.listen((response) {
        if (!completer.isCompleted) {
          completer.complete(response);
          subscription.cancel();
        }
      });
      
      // Timeout after 5 seconds
      Timer(const Duration(milliseconds: AppConstants.obdTimeoutMs), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError(TimeoutException(
            'Command timeout', 
            const Duration(milliseconds: AppConstants.obdTimeoutMs),
          ));
        }
      });
      
      return await completer.future;
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }
  
  @override
  Future<List<String>> scanForDevices() async {
    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices.map((device) => '${device.name} (${device.address})').toList();
    } catch (e) {
      debugPrint('Device scan error: $e');
      return [];
    }
  }
  
  void _updateStatus(ConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
  
  void dispose() {
    _statusController.close();
    _dataController.close();
    disconnect();
  }
}

class DesktopOBDService implements OBDService {
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<OBDResponse> _dataController = 
      StreamController<OBDResponse>.broadcast();
  
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  
  @override
  Stream<ConnectionStatus> get connectionStatus => _statusController.stream;
  
  @override
  Stream<OBDResponse> get dataStream => _dataController.stream;
  
  @override
  bool get isConnected => _currentStatus == ConnectionStatus.connected;
  
  @override
  Future<bool> connect(ConnectionConfig config) async {
    // Desktop implementation would use serial/USB connections
    // This is a placeholder for the actual implementation
    _updateStatus(ConnectionStatus.connecting);
    
    // Simulate connection for demo purposes
    await Future.delayed(const Duration(seconds: 2));
    _updateStatus(ConnectionStatus.connected);
    return true;
  }
  
  @override
  Future<void> disconnect() async {
    _updateStatus(ConnectionStatus.disconnected);
  }
  
  @override
  Future<OBDResponse> sendCommand(String command) async {
    if (!isConnected) {
      throw Exception('Not connected to OBD device');
    }
    
    // Simulate OBD response for demo purposes
    await Future.delayed(const Duration(milliseconds: 200));
    return OBDResponse.fromRaw('41 0C 1A F8'); // Example RPM response
  }
  
  @override
  Future<List<String>> scanForDevices() async {
    // Desktop implementation would scan serial ports
    return ['COM1', 'COM3', '/dev/ttyUSB0', '/dev/ttyACM0'];
  }
  
  void _updateStatus(ConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
  
  void dispose() {
    _statusController.close();
    _dataController.close();
    disconnect();
  }
}