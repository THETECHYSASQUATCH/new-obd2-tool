import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd2_diagnostics_tool/src/services/obd_service.dart';
import 'package:obd2_diagnostics_tool/src/services/platform_service.dart';
import 'package:obd2_diagnostics_tool/src/models/obd_models.dart';

void main() {
  group('OBD Service Tests', () {
    late ProviderContainer container;
    late OBDService obdService;
    
    setUp(() {
      container = ProviderContainer();
      obdService = container.read(obdServiceProvider);
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('Initial state should be disconnected', () {
      expect(obdService.isConnected, isFalse);
      expect(obdService.isScanning, isFalse);
      expect(obdService.currentDevice, isNull);
    });
    
    test('Device scanning should return mock devices', () async {
      final devices = await obdService.scanForDevices();
      
      expect(devices, isNotEmpty);
      expect(devices.first.type, isA<OBDConnectionType>());
      expect(devices.first.name, isNotEmpty);
    });
    
    test('Connection state should update correctly', () async {
      final connectionNotifier = container.read(connectionStateProvider.notifier);
      const mockDevice = OBDDevice(
        id: 'test_device',
        name: 'Mock Device',
        address: 'mock_address',
        type: OBDConnectionType.bluetooth,
      );
      
      // Initial state
      expect(container.read(connectionStateProvider).isConnected, isFalse);
      
      // Simulate connection
      await connectionNotifier.connect(mockDevice);
      
      final connectionState = container.read(connectionStateProvider);
      expect(connectionState.isConnected, isTrue);
      expect(connectionState.device?.id, equals('test_device'));
    });
    
    test('DTC reading should return mock data', () async {
      // First connect to a device
      const mockDevice = OBDDevice(
        id: 'test_device',
        name: 'Mock Device',
        address: 'mock_address',
        type: OBDConnectionType.bluetooth,
      );
      
      await obdService.connectToDevice(mockDevice);
      
      final dtcs = await obdService.readDTCs();
      
      expect(dtcs, isNotEmpty);
      expect(dtcs.first.code, isNotEmpty);
      expect(dtcs.first.description, isNotEmpty);
    });
    
    test('Vehicle info should return mock data when connected', () async {
      const mockDevice = OBDDevice(
        id: 'test_device',
        name: 'Mock Device',
        address: 'mock_address',
        type: OBDConnectionType.bluetooth,
      );
      
      await obdService.connectToDevice(mockDevice);
      
      final vehicleInfo = await obdService.getVehicleInfo();
      
      expect(vehicleInfo.vin, isNotNull);
      expect(vehicleInfo.make, isNotNull);
      expect(vehicleInfo.model, isNotNull);
    });
    
    test('Should throw exception when reading DTCs without connection', () async {
      expect(
        () async => await obdService.readDTCs(),
        throwsA(isA<Exception>()),
      );
    });
    
    test('Should throw exception when getting vehicle info without connection', () async {
      expect(
        () async => await obdService.getVehicleInfo(),
        throwsA(isA<Exception>()),
      );
    });
    
    test('Disconnection should reset state', () async {
      const mockDevice = OBDDevice(
        id: 'test_device',
        name: 'Mock Device',
        address: 'mock_address',
        type: OBDConnectionType.bluetooth,
      );
      
      // Connect first
      await obdService.connectToDevice(mockDevice);
      expect(obdService.isConnected, isTrue);
      expect(obdService.currentDevice, isNotNull);
      
      // Then disconnect
      await obdService.disconnect();
      expect(obdService.isConnected, isFalse);
      expect(obdService.currentDevice, isNull);
    });
  });
  
  group('Platform Service Tests', () {
    late PlatformService platformService;
    
    setUp(() {
      platformService = PlatformService();
    });
    
    test('Should scan and return mock devices', () async {
      final devices = await platformService.scanForOBDDevices();
      
      expect(devices, isNotEmpty);
      
      // Check that we have different connection types
      final connectionTypes = devices.map((d) => d.type).toSet();
      expect(connectionTypes.length, greaterThan(1));
    });
    
    test('Should return mock DTCs', () async {
      final dtcs = await platformService.readDTCs();
      
      expect(dtcs, hasLength(2));
      expect(dtcs.first.code, equals('P0171'));
      expect(dtcs.last.code, equals('P0301'));
    });
    
    test('Should return mock vehicle info', () async {
      final vehicleInfo = await platformService.getVehicleInfo();
      
      expect(vehicleInfo.vin, equals('WBAFR7C50BC123456'));
      expect(vehicleInfo.make, equals('BMW'));
      expect(vehicleInfo.model, equals('3 Series'));
      expect(vehicleInfo.year, equals(2023));
      expect(vehicleInfo.protocol, equals(OBDProtocol.canBus));
    });
    
    test('Should successfully simulate device connection', () async {
      const mockDevice = OBDDevice(
        id: 'test_device',
        name: 'Mock Device',
        address: 'mock_address',
        type: OBDConnectionType.bluetooth,
      );
      
      final result = await platformService.connectToDevice(mockDevice);
      expect(result, isTrue);
    });
    
    test('Clear DTCs should return success', () async {
      final result = await platformService.clearDTCs();
      expect(result, isTrue);
    });
    
    test('Send command should return response', () async {
      final response = await platformService.sendCommand('ATZ');
      expect(response, isNotEmpty);
    });
  });
}