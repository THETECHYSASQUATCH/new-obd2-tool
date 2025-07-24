// TODO: Unit tests for PID configuration functionality
// Tests the PidDisplayConfig and PidDisplayProfile models

import 'package:test/test.dart';
import 'package:new_obd2_tool/shared/models/pid_config.dart';
import 'package:new_obd2_tool/core/constants/app_constants.dart';

void main() {
  group('PidDisplayConfig', () {
    test('should create PidDisplayConfig with default values', () {
      final config = PidDisplayConfig.fromPid('010C');
      
      expect(config.pid, equals('010C'));
      expect(config.displayName, equals('Engine RPM'));
      expect(config.isEnabled, isTrue);
      expect(config.unit, equals('RPM'));
      expect(config.category, equals('Engine'));
      expect(config.canDisplay, isTrue);
    });

    test('should create PidDisplayConfig with custom values', () {
      final config = PidDisplayConfig(
        pid: '010D',
        displayName: 'Speed',
        isEnabled: false,
        displayOrder: 5,
        showProgressBar: false,
        customMinValue: 0,
        customMaxValue: 200,
        updateIntervalMs: 2000,
      );

      expect(config.pid, equals('010D'));
      expect(config.displayName, equals('Speed'));
      expect(config.isEnabled, isFalse);
      expect(config.displayOrder, equals(5));
      expect(config.showProgressBar, isFalse);
      expect(config.customMinValue, equals(0));
      expect(config.customMaxValue, equals(200));
      expect(config.updateIntervalMs, equals(2000));
    });

    test('should get effective min/max values', () {
      // Test with custom values
      final configWithCustom = PidDisplayConfig(
        pid: '010C',
        displayName: 'RPM',
        customMinValue: 500,
        customMaxValue: 8000,
      );
      
      expect(configWithCustom.minValue, equals(500));
      expect(configWithCustom.maxValue, equals(8000));

      // Test with default values from constants
      final configWithDefaults = PidDisplayConfig.fromPid('010C');
      expect(configWithDefaults.minValue, equals(0));
      expect(configWithDefaults.maxValue, equals(16383.75));
    });

    test('should copy with updated values', () {
      final original = PidDisplayConfig.fromPid('010C');
      final updated = original.copyWith(
        displayName: 'Engine Speed',
        isEnabled: false,
        updateIntervalMs: 3000,
      );

      expect(updated.pid, equals(original.pid));
      expect(updated.displayName, equals('Engine Speed'));
      expect(updated.isEnabled, isFalse);
      expect(updated.updateIntervalMs, equals(3000));
      expect(updated.displayOrder, equals(original.displayOrder));
    });

    test('should serialize to and from JSON', () {
      final config = PidDisplayConfig(
        pid: '010D',
        displayName: 'Vehicle Speed',
        isEnabled: true,
        displayOrder: 2,
        showProgressBar: true,
        customMinValue: 0,
        customMaxValue: 150,
        updateIntervalMs: 1500,
      );

      final json = config.toJson();
      final fromJson = PidDisplayConfig.fromJson(json);

      expect(fromJson.pid, equals(config.pid));
      expect(fromJson.displayName, equals(config.displayName));
      expect(fromJson.isEnabled, equals(config.isEnabled));
      expect(fromJson.displayOrder, equals(config.displayOrder));
      expect(fromJson.showProgressBar, equals(config.showProgressBar));
      expect(fromJson.customMinValue, equals(config.customMinValue));
      expect(fromJson.customMaxValue, equals(config.customMaxValue));
      expect(fromJson.updateIntervalMs, equals(config.updateIntervalMs));
    });

    test('should handle equality comparison', () {
      final config1 = PidDisplayConfig.fromPid('010C');
      final config2 = PidDisplayConfig.fromPid('010C');
      final config3 = PidDisplayConfig.fromPid('010D');

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
      expect(config1.hashCode, equals(config2.hashCode));
    });
  });

  group('PidDisplayProfile', () {
    test('should create default profile', () {
      final profile = PidDisplayProfile.createDefault();

      expect(profile.name, equals('Default Dashboard'));
      expect(profile.isDefault, isTrue);
      expect(profile.pidConfigs.length, greaterThan(0));
      expect(profile.enabledPids.length, greaterThan(0));
    });

    test('should group PIDs by category', () {
      final profile = PidDisplayProfile.createDefault();
      final grouped = profile.pidsByCategory;

      expect(grouped.containsKey('Engine'), isTrue);
      expect(grouped.containsKey('Vehicle'), isTrue);
      expect(grouped['Engine']?.length, greaterThan(0));
    });

    test('should get enabled PIDs sorted by display order', () {
      final pidConfigs = [
        PidDisplayConfig(pid: '010C', displayName: 'RPM', displayOrder: 2, isEnabled: true),
        PidDisplayConfig(pid: '010D', displayName: 'Speed', displayOrder: 1, isEnabled: true),
        PidDisplayConfig(pid: '0105', displayName: 'Temp', displayOrder: 3, isEnabled: false),
        PidDisplayConfig(pid: '0104', displayName: 'Load', displayOrder: 0, isEnabled: true),
      ];

      final profile = PidDisplayProfile(
        name: 'Test',
        pidConfigs: pidConfigs,
        lastModified: DateTime.now(),
      );

      final enabledPids = profile.enabledPids;
      expect(enabledPids.length, equals(3));
      expect(enabledPids[0].displayName, equals('Load')); // displayOrder: 0
      expect(enabledPids[1].displayName, equals('Speed')); // displayOrder: 1
      expect(enabledPids[2].displayName, equals('RPM')); // displayOrder: 2
    });

    test('should copy with updated values', () {
      final original = PidDisplayProfile.createDefault();
      final updated = original.copyWith(
        name: 'Custom Profile',
        description: 'My custom setup',
        isDefault: false,
      );

      expect(updated.name, equals('Custom Profile'));
      expect(updated.description, equals('My custom setup'));
      expect(updated.isDefault, isFalse);
      expect(updated.pidConfigs, equals(original.pidConfigs));
    });

    test('should serialize to and from JSON', () {
      final pidConfigs = [
        PidDisplayConfig.fromPid('010C'),
        PidDisplayConfig.fromPid('010D'),
      ];

      final profile = PidDisplayProfile(
        name: 'Test Profile',
        description: 'Test description',
        pidConfigs: pidConfigs,
        lastModified: DateTime.parse('2024-01-01T12:00:00Z'),
        isDefault: false,
      );

      final json = profile.toJson();
      final fromJson = PidDisplayProfile.fromJson(json);

      expect(fromJson.name, equals(profile.name));
      expect(fromJson.description, equals(profile.description));
      expect(fromJson.pidConfigs.length, equals(profile.pidConfigs.length));
      expect(fromJson.lastModified, equals(profile.lastModified));
      expect(fromJson.isDefault, equals(profile.isDefault));
    });
  });

  group('AppConstants PID metadata', () {
    test('should have complete metadata for standard PIDs', () {
      final pidMetadata = AppConstants.standardPids;

      // Test essential PIDs have proper metadata
      expect(pidMetadata['010C']?['name'], equals('Engine RPM'));
      expect(pidMetadata['010C']?['unit'], equals('RPM'));
      expect(pidMetadata['010C']?['category'], equals('Engine'));
      expect(pidMetadata['010C']?['canDisplay'], isTrue);
      expect(pidMetadata['010C']?['minValue'], isNotNull);
      expect(pidMetadata['010C']?['maxValue'], isNotNull);

      expect(pidMetadata['010D']?['name'], equals('Vehicle speed'));
      expect(pidMetadata['010D']?['unit'], equals('km/h'));
      expect(pidMetadata['010D']?['category'], equals('Vehicle'));
    });

    test('should maintain backward compatibility with legacy pidNames', () {
      final legacyNames = AppConstants.pidNames;
      
      expect(legacyNames['010C'], equals('Engine RPM'));
      expect(legacyNames['010D'], equals('Vehicle speed'));
      expect(legacyNames['0105'], equals('Engine coolant temperature'));
    });

    test('should have consistent displayOrder values', () {
      final pidMetadata = AppConstants.standardPids;
      final displayOrders = pidMetadata.values
          .map((data) => data['displayOrder'] as int)
          .toSet();

      // Should not have duplicate display orders
      expect(displayOrders.length, equals(pidMetadata.length));
    });
  });
}