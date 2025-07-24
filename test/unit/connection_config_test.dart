import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/shared/models/connection_config.dart';
import 'package:new_obd2_tool/core/services/obd_service.dart';

void main() {
  group('ConnectionConfig', () {
    test('should create Bluetooth connection config correctly', () {
      final config = ConnectionConfig.bluetooth(
        name: 'ELM327',
        address: '00:11:22:33:44:55',
      );
      
      expect(config.type, equals(ConnectionType.bluetooth));
      expect(config.name, equals('ELM327'));
      expect(config.address, equals('00:11:22:33:44:55'));
      expect(config.baudRate, isNull);
      expect(config.port, isNull);
    });

    test('should create Serial connection config correctly', () {
      final config = ConnectionConfig.serial(
        port: '/dev/ttyUSB0',
        baudRate: 115200,
      );
      
      expect(config.type, equals(ConnectionType.serial));
      expect(config.name, equals('Serial /dev/ttyUSB0'));
      expect(config.address, equals('/dev/ttyUSB0'));
      expect(config.baudRate, equals(115200));
      expect(config.port, equals('/dev/ttyUSB0'));
    });

    test('should create WiFi connection config correctly', () {
      final config = ConnectionConfig.wifi(
        name: 'OBDLink MX+',
        address: '192.168.4.1',
      );
      
      expect(config.type, equals(ConnectionType.wifi));
      expect(config.name, equals('OBDLink MX+'));
      expect(config.address, equals('192.168.4.1'));
      expect(config.baudRate, isNull);
      expect(config.port, isNull);
    });

    test('should convert to and from JSON correctly', () {
      final originalConfig = ConnectionConfig.bluetooth(
        name: 'ELM327',
        address: '00:11:22:33:44:55',
      );
      
      final json = originalConfig.toJson();
      final reconstructedConfig = ConnectionConfig.fromJson(json);
      
      expect(reconstructedConfig.type, equals(originalConfig.type));
      expect(reconstructedConfig.name, equals(originalConfig.name));
      expect(reconstructedConfig.address, equals(originalConfig.address));
      expect(reconstructedConfig.baudRate, equals(originalConfig.baudRate));
      expect(reconstructedConfig.port, equals(originalConfig.port));
    });

    test('should handle equality correctly', () {
      final config1 = ConnectionConfig.bluetooth(
        name: 'ELM327',
        address: '00:11:22:33:44:55',
      );
      
      final config2 = ConnectionConfig.bluetooth(
        name: 'ELM327',
        address: '00:11:22:33:44:55',
      );
      
      final config3 = ConnectionConfig.bluetooth(
        name: 'Different',
        address: '00:11:22:33:44:55',
      );
      
      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should have correct hash codes', () {
      final config1 = ConnectionConfig.bluetooth(
        name: 'ELM327',
        address: '00:11:22:33:44:55',
      );
      
      final config2 = ConnectionConfig.bluetooth(
        name: 'ELM327',
        address: '00:11:22:33:44:55',
      );
      
      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('should use default baud rate for serial connections', () {
      final config = ConnectionConfig.serial(port: '/dev/ttyUSB0');
      
      expect(config.baudRate, equals(38400));
    });

    test('should handle invalid JSON gracefully', () {
      final json = {
        'type': 'invalid_type',
        'name': 'Test',
        'address': 'test_address',
      };
      
      final config = ConnectionConfig.fromJson(json);
      expect(config.type, equals(ConnectionType.bluetooth)); // Default fallback
    });
  });
}