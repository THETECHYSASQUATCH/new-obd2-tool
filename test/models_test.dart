import 'package:flutter_test/flutter_test.dart';
import 'package:obd2_diagnostics_tool/src/models/obd_models.dart';

void main() {
  group('OBD Models Tests', () {
    test('OBDDevice creation and equality', () {
      const device1 = OBDDevice(
        id: 'test_001',
        name: 'Test Device',
        address: '00:11:22:33:44:55',
        type: OBDConnectionType.bluetooth,
      );
      
      const device2 = OBDDevice(
        id: 'test_001',
        name: 'Test Device',
        address: '00:11:22:33:44:55',
        type: OBDConnectionType.bluetooth,
      );
      
      expect(device1, equals(device2));
      expect(device1.hashCode, equals(device2.hashCode));
    });
    
    test('OBDDevice copyWith functionality', () {
      const originalDevice = OBDDevice(
        id: 'test_001',
        name: 'Test Device',
        address: '00:11:22:33:44:55',
        type: OBDConnectionType.bluetooth,
        isConnected: false,
      );
      
      final connectedDevice = originalDevice.copyWith(isConnected: true);
      
      expect(connectedDevice.isConnected, isTrue);
      expect(connectedDevice.id, equals(originalDevice.id));
      expect(connectedDevice.name, equals(originalDevice.name));
    });
    
    test('DiagnosticTroubleCode creation', () {
      const dtc = DiagnosticTroubleCode(
        code: 'P0171',
        description: 'System Too Lean (Bank 1)',
        status: DTCStatus.active,
        severity: DTCSeverity.major,
      );
      
      expect(dtc.code, equals('P0171'));
      expect(dtc.status, equals(DTCStatus.active));
      expect(dtc.severity, equals(DTCSeverity.major));
    });
    
    test('VehicleInfo creation and copyWith', () {
      const vehicleInfo = VehicleInfo(
        vin: 'TEST123456789',
        make: 'Test Make',
        model: 'Test Model',
        year: 2023,
      );
      
      final updatedInfo = vehicleInfo.copyWith(
        engine: 'Test Engine',
        protocol: OBDProtocol.canBus,
      );
      
      expect(updatedInfo.vin, equals('TEST123456'));
      expect(updatedInfo.engine, equals('Test Engine'));
      expect(updatedInfo.protocol, equals(OBDProtocol.canBus));
    });
    
    test('LiveDataPoint normalized value calculation', () {
      final dataPoint = LiveDataPoint(
        pid: '010C',
        name: 'Engine RPM',
        value: 2500,
        unit: 'rpm',
        minValue: 0,
        maxValue: 5000,
        timestamp: DateTime.now(),
      );
      
      expect(dataPoint.normalizedValue, equals(0.5));
    });
    
    test('LiveDataPoint equality based on PID', () {
      final now = DateTime.now();
      
      final dataPoint1 = LiveDataPoint(
        pid: '010C',
        name: 'Engine RPM',
        value: 2000,
        unit: 'rpm',
        timestamp: now,
      );
      
      final dataPoint2 = LiveDataPoint(
        pid: '010C',
        name: 'Engine RPM',
        value: 3000,
        unit: 'rpm',
        timestamp: now.add(const Duration(seconds: 1)),
      );
      
      expect(dataPoint1, equals(dataPoint2)); // Same PID
      expect(dataPoint1.hashCode, equals(dataPoint2.hashCode));
    });
  });
  
  group('Enum Tests', () {
    test('OBDConnectionType display names', () {
      expect(OBDConnectionType.bluetooth.displayName, equals('Bluetooth'));
      expect(OBDConnectionType.wifi.displayName, equals('WiFi'));
      expect(OBDConnectionType.usb.displayName, equals('USB'));
      expect(OBDConnectionType.serial.displayName, equals('Serial'));
    });
    
    test('DTCStatus display names', () {
      expect(DTCStatus.active.displayName, equals('Active'));
      expect(DTCStatus.pending.displayName, equals('Pending'));
      expect(DTCStatus.permanent.displayName, equals('Permanent'));
      expect(DTCStatus.cleared.displayName, equals('Cleared'));
    });
    
    test('DTCSeverity display names', () {
      expect(DTCSeverity.critical.displayName, equals('Critical'));
      expect(DTCSeverity.major.displayName, equals('Major'));
      expect(DTCSeverity.minor.displayName, equals('Minor'));
      expect(DTCSeverity.info.displayName, equals('Information'));
    });
    
    test('OBDProtocol display names', () {
      expect(OBDProtocol.iso9141.displayName, equals('ISO 9141-2'));
      expect(OBDProtocol.kwp2000.displayName, equals('KWP2000'));
      expect(OBDProtocol.canBus.displayName, equals('CAN-BUS'));
      expect(OBDProtocol.j1850VPW.displayName, equals('J1850 VPW'));
      expect(OBDProtocol.j1850PWM.displayName, equals('J1850 PWM'));
    });
  });
}