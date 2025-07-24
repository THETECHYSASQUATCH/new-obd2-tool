// TODO: Unit tests for connection profile functionality and security features
// Tests the ConnectionProfile model and validation logic

import 'package:test/test.dart';
import 'package:new_obd2_tool/shared/models/connection_profile.dart';
import 'package:new_obd2_tool/core/services/obd_service.dart';
import 'package:new_obd2_tool/core/services/secure_storage_service.dart';

void main() {
  group('ConnectionProfile', () {
    test('should create ConnectionProfile with valid data', () {
      final profile = ConnectionProfile.create(
        name: 'Test Profile',
        description: 'Test description',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );

      expect(profile.name, equals('Test Profile'));
      expect(profile.description, equals('Test description'));
      expect(profile.type, equals(ConnectionType.bluetooth));
      expect(profile.address, equals('00:1D:A5:68:98:8B'));
      expect(profile.id.length, equals(16));
      expect(profile.createdAt, isNotNull);
      expect(profile.lastUsed, isNotNull);
    });

    test('should validate Bluetooth address format', () {
      // Valid Bluetooth addresses
      final validProfile1 = ConnectionProfile.create(
        name: 'BT Device 1',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );
      expect(validProfile1.validate(), isEmpty);

      final validProfile2 = ConnectionProfile.create(
        name: 'BT Device 2',
        type: ConnectionType.bluetooth,
        address: 'aa:bb:cc:dd:ee:ff',
      );
      expect(validProfile2.validate(), isEmpty);

      // Invalid Bluetooth addresses
      final invalidProfile1 = ConnectionProfile.create(
        name: 'Invalid BT 1',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98',  // Too short
      );
      expect(invalidProfile1.validate(), isNotEmpty);

      final invalidProfile2 = ConnectionProfile.create(
        name: 'Invalid BT 2',
        type: ConnectionType.bluetooth,
        address: '00-1D-A5-68-98-8B-XX',  // Too long
      );
      expect(invalidProfile2.validate(), isNotEmpty);

      final invalidProfile3 = ConnectionProfile.create(
        name: 'Invalid BT 3',
        type: ConnectionType.bluetooth,
        address: 'invalid-address',
      );
      expect(invalidProfile3.validate(), isNotEmpty);
    });

    test('should validate WiFi IP addresses', () {
      // Valid IP addresses
      final validProfile1 = ConnectionProfile.create(
        name: 'WiFi Device 1',
        type: ConnectionType.wifi,
        address: '192.168.1.100',
      );
      expect(validProfile1.validate(), isEmpty);

      final validProfile2 = ConnectionProfile.create(
        name: 'WiFi Device 2',
        type: ConnectionType.wifi,
        address: '10.0.0.1',
      );
      expect(validProfile2.validate(), isEmpty);

      // Valid hostnames
      final validProfile3 = ConnectionProfile.create(
        name: 'WiFi Device 3',
        type: ConnectionType.wifi,
        address: 'obd.local',
      );
      expect(validProfile3.validate(), isEmpty);

      // Invalid IP addresses
      final invalidProfile1 = ConnectionProfile.create(
        name: 'Invalid WiFi 1',
        type: ConnectionType.wifi,
        address: '999.999.999.999',  // Out of range
      );
      expect(invalidProfile1.validate(), isNotEmpty);

      final invalidProfile2 = ConnectionProfile.create(
        name: 'Invalid WiFi 2',
        type: ConnectionType.wifi,
        address: '192.168.1',  // Incomplete
      );
      expect(invalidProfile2.validate(), isNotEmpty);
    });

    test('should validate serial/USB connections', () {
      // Valid serial connections
      final validProfile1 = ConnectionProfile.create(
        name: 'Serial Device 1',
        type: ConnectionType.serial,
        address: 'COM3',
        port: 'COM3',
        baudRate: 38400,
      );
      expect(validProfile1.validate(), isEmpty);

      final validProfile2 = ConnectionProfile.create(
        name: 'USB Device 1',
        type: ConnectionType.usb,
        address: '/dev/ttyUSB0',
        port: '/dev/ttyUSB0',
        baudRate: 115200,
      );
      expect(validProfile2.validate(), isEmpty);

      // Invalid serial connections
      final invalidProfile1 = ConnectionProfile.create(
        name: 'Invalid Serial 1',
        type: ConnectionType.serial,
        address: 'COM3',
        // Missing port
      );
      expect(invalidProfile1.validate(), isNotEmpty);

      final invalidProfile2 = ConnectionProfile.create(
        name: 'Invalid Serial 2',
        type: ConnectionType.serial,
        address: 'COM3',
        port: 'COM3',
        baudRate: 12345,  // Invalid baud rate
      );
      expect(invalidProfile2.validate(), isNotEmpty);
    });

    test('should validate profile name and description', () {
      // Valid name
      final validProfile = ConnectionProfile.create(
        name: 'Valid Name',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );
      expect(validProfile.validate(), isEmpty);

      // Empty name
      final invalidProfile1 = ConnectionProfile.create(
        name: '',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );
      expect(invalidProfile1.validate(), isNotEmpty);

      // Name too long
      final longName = 'A' * 100;  // Exceeds maxConnectionNameLength
      final invalidProfile2 = ConnectionProfile.create(
        name: longName,
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );
      expect(invalidProfile2.validate(), isNotEmpty);
    });

    test('should copy with updated values', () {
      final original = ConnectionProfile.create(
        name: 'Original',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );

      final updated = original.copyWith(
        name: 'Updated',
        description: 'New description',
        isSecure: true,
      );

      expect(updated.id, equals(original.id));
      expect(updated.name, equals('Updated'));
      expect(updated.description, equals('New description'));
      expect(updated.isSecure, isTrue);
      expect(updated.type, equals(original.type));
      expect(updated.address, equals(original.address));
    });

    test('should convert to ConnectionConfig', () {
      final bluetoothProfile = ConnectionProfile.create(
        name: 'BT Device',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );

      final config = bluetoothProfile.toConnectionConfig();
      expect(config.type, equals(ConnectionType.bluetooth));
      expect(config.name, equals('BT Device'));
      expect(config.address, equals('00:1D:A5:68:98:8B'));
    });

    test('should serialize to and from JSON', () {
      final profile = ConnectionProfile.create(
        name: 'Test Profile',
        description: 'Test description',
        type: ConnectionType.wifi,
        address: '192.168.1.100',
        customParameters: {'timeout': '5000'},
        isSecure: true,
      );

      final json = profile.toJson();
      final fromJson = ConnectionProfile.fromJson(json);

      expect(fromJson.id, equals(profile.id));
      expect(fromJson.name, equals(profile.name));
      expect(fromJson.description, equals(profile.description));
      expect(fromJson.type, equals(profile.type));
      expect(fromJson.address, equals(profile.address));
      expect(fromJson.customParameters, equals(profile.customParameters));
      expect(fromJson.isSecure, equals(profile.isSecure));
    });

    test('should generate unique IDs', () {
      final profile1 = ConnectionProfile.create(
        name: 'Profile 1',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8B',
      );

      final profile2 = ConnectionProfile.create(
        name: 'Profile 2',
        type: ConnectionType.bluetooth,
        address: '00:1D:A5:68:98:8C',
      );

      expect(profile1.id, isNot(equals(profile2.id)));
      expect(profile1.id.length, equals(16));
      expect(profile2.id.length, equals(16));
    });
  });

  group('ConnectionPreset', () {
    test('should have common presets available', () {
      expect(ConnectionPreset.commonPresets.length, greaterThan(0));
      
      final bluetoothPreset = ConnectionPreset.commonPresets
          .firstWhere((preset) => preset.type == ConnectionType.bluetooth);
      
      expect(bluetoothPreset.name, isNotEmpty);
      expect(bluetoothPreset.description, isNotEmpty);
      expect(bluetoothPreset.defaultSettings, isNotEmpty);
    });

    test('should create profile from preset', () {
      final preset = ConnectionPreset.commonPresets.first;
      final profile = preset.createProfile(
        profileName: 'From Preset',
        address: 'test-address',
        customParams: {'extra': 'param'},
      );

      expect(profile.name, equals('From Preset'));
      expect(profile.type, equals(preset.type));
      expect(profile.address, equals('test-address'));
      expect(profile.customParameters.containsKey('extra'), isTrue);
    });
  });

  group('InputValidator', () {
    test('should validate profile names', () {
      // Valid names
      expect(InputValidator.validateProfileName('Valid Name'), isEmpty);
      expect(InputValidator.validateProfileName('Test-Profile_123'), isEmpty);

      // Invalid names
      expect(InputValidator.validateProfileName(''), isNotEmpty);
      expect(InputValidator.validateProfileName('A' * 100), isNotEmpty);
    });

    test('should validate addresses', () {
      // Valid addresses
      expect(InputValidator.validateAddress('192.168.1.1'), isEmpty);
      expect(InputValidator.validateAddress('test.example.com'), isEmpty);
      expect(InputValidator.validateAddress('/dev/ttyUSB0'), isEmpty);

      // Invalid addresses
      expect(InputValidator.validateAddress(''), isNotEmpty);
      expect(InputValidator.validateAddress('A' * 200), isNotEmpty);
    });

    test('should validate update intervals', () {
      // Valid intervals
      expect(InputValidator.validateUpdateInterval(1000), isEmpty);
      expect(InputValidator.validateUpdateInterval(5000), isEmpty);

      // Invalid intervals
      expect(InputValidator.validateUpdateInterval(100), isNotEmpty);  // Too short
      expect(InputValidator.validateUpdateInterval(20000), isNotEmpty);  // Too long
    });
  });

  group('SecureStorageService', () {
    test('should validate input strings', () {
      // Valid inputs
      expect(SecureStorageService.validateInput('Valid input'), isTrue);
      expect(SecureStorageService.validateInput('Test123!@#'), isTrue);

      // Invalid inputs
      expect(SecureStorageService.validateInput(''), isFalse);
      expect(SecureStorageService.validateInput('<script>alert("xss")</script>'), isFalse);
      expect(SecureStorageService.validateInput('javascript:void(0)'), isFalse);
      expect(SecureStorageService.validateInput('A' * 2000), isFalse);  // Too long
    });

    test('should sanitize input strings', () {
      final dangerous = '<script>alert("test")</script>';
      final sanitized = SecureStorageService.sanitizeInput(dangerous);
      
      expect(sanitized, isNot(contains('<')));
      expect(sanitized, isNot(contains('>')));
      expect(sanitized, isNot(contains('"')));
      expect(sanitized, isNot(contains("'")));
    });

    test('should limit input length during sanitization', () {
      final longInput = 'A' * 2000;
      final sanitized = SecureStorageService.sanitizeInput(longInput);
      
      expect(sanitized.length, lessThanOrEqualTo(1000));
    });
  });
}