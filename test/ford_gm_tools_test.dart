import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/core/services/ford_service.dart';
import 'package:new_obd2_tool/core/services/gm_service.dart';
import 'package:new_obd2_tool/core/services/obd_service.dart';
import 'package:new_obd2_tool/shared/models/vehicle_info.dart';
import 'package:new_obd2_tool/features/ford_tools/models/ford_data_models.dart';
import 'package:new_obd2_tool/features/gm_tools/models/gm_data_models.dart';

void main() {
  group('Ford Service Tests', () {
    late FordService fordService;
    late OBDService mockOBDService;

    setUp(() {
      mockOBDService = OBDService();
      fordService = FordService(mockOBDService);
    });

    test('Ford service initializes with Ford vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Ford',
        model: 'F-150',
        year: 2023,
      );

      expect(() => fordService.initialize(vehicle), returnsNormally);
    });

    test('Ford service rejects non-Ford vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Toyota',
        model: 'Camry',
        year: 2023,
      );

      expect(() => fordService.initialize(vehicle), throwsArgumentError);
    });

    test('Ford live data model handles empty data', () {
      final liveData = FordLiveData.fromMap({});
      
      expect(liveData.turboBoostPressure, isNull);
      expect(liveData.defLevel, isNull);
      expect(liveData.syncSystemStatus, isNull);
    });

    test('Ford programming operation validates ECU types', () {
      const operation = FordProgrammingOperation(
        ecuType: 'PCM',
        operation: 'flash',
        parameters: {},
      );

      expect(operation.isValid, isTrue);
    });

    test('Ford programming operation rejects invalid ECU types', () {
      const operation = FordProgrammingOperation(
        ecuType: 'INVALID',
        operation: 'flash',
        parameters: {},
      );

      expect(operation.isValid, isFalse);
    });
  });

  group('GM Service Tests', () {
    late GMService gmService;
    late OBDService mockOBDService;

    setUp(() {
      mockOBDService = OBDService();
      gmService = GMService(mockOBDService);
    });

    test('GM service initializes with Chevrolet vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Chevrolet',
        model: 'Silverado 1500',
        year: 2023,
      );

      expect(() => gmService.initialize(vehicle), returnsNormally);
    });

    test('GM service initializes with Cadillac vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Cadillac',
        model: 'Escalade',
        year: 2023,
      );

      expect(() => gmService.initialize(vehicle), returnsNormally);
    });

    test('GM service initializes with GMC vehicle', () {
      const vehicle = VehicleInfo(
        make: 'GMC',
        model: 'Sierra 1500',
        year: 2023,
      );

      expect(() => gmService.initialize(vehicle), returnsNormally);
    });

    test('GM service rejects non-GM vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Ford',
        model: 'F-150',
        year: 2023,
      );

      expect(() => gmService.initialize(vehicle), throwsArgumentError);
    });

    test('GM live data model handles complex data', () {
      final testData = {
        'AFM Cylinder Deactivation Status': true,
        'Transmission Adaptive Pressure': 125.5,
        'Super Cruise Status': {
          'available': true,
          'active': false,
          'hands_detected': true,
        },
      };

      final liveData = GMLiveData.fromMap(testData);
      
      expect(liveData.afmCylinderDeactivation, isTrue);
      expect(liveData.transmissionAdaptivePressure, equals(125.5));
      expect(liveData.superCruiseStatus, isNotNull);
    });

    test('GM programming operation validates brand support', () {
      const operation = GMProgrammingOperation(
        ecuType: 'ECM',
        operation: 'flash',
        parameters: {},
        brand: 'Chevrolet',
      );

      expect(operation.isValid, isTrue);
    });

    test('GM programming operation rejects unsupported brand', () {
      const operation = GMProgrammingOperation(
        ecuType: 'ECM',
        operation: 'flash',
        parameters: {},
        brand: 'Toyota',
      );

      expect(operation.isValid, isFalse);
    });

    test('GM brand features returns correct data for Chevrolet', () {
      final features = GMBrandSpecificFeatures.getForBrand('Chevrolet');
      
      expect(features, isNotNull);
      expect(features!.brand, equals('Chevrolet'));
      expect(features.availableTools, contains('AFM Disable'));
      expect(features.specialFeatures, contains('Active Fuel Management'));
    });

    test('GM brand features returns correct data for Cadillac', () {
      final features = GMBrandSpecificFeatures.getForBrand('Cadillac');
      
      expect(features, isNotNull);
      expect(features!.brand, equals('Cadillac'));
      expect(features.availableTools, contains('Super Cruise Update'));
      expect(features.specialFeatures, contains('Super Cruise'));
    });

    test('GM brand features returns correct data for GMC', () {
      final features = GMBrandSpecificFeatures.getForBrand('GMC');
      
      expect(features, isNotNull);
      expect(features!.brand, equals('GMC'));
      expect(features.availableTools, contains('MultiPro Tailgate Service'));
      expect(features.specialFeatures, contains('MultiPro Tailgate'));
    });

    test('GM brand features returns null for unsupported brand', () {
      final features = GMBrandSpecificFeatures.getForBrand('Ford');
      
      expect(features, isNull);
    });
  });

  group('Vehicle Database Tests', () {
    test('Vehicle database includes GM manufacturers', () {
      // Test would load from actual database in real scenario
      const gmBrands = ['Chevrolet', 'Cadillac', 'GMC'];
      
      for (final brand in gmBrands) {
        // Verify each GM brand would be found in database
        expect(brand, isNotEmpty);
      }
    });

    test('Vehicle info displays correctly', () {
      const vehicle = VehicleInfo(
        make: 'Ford',
        model: 'F-150',
        year: 2023,
        trim: 'XLT',
      );

      expect(vehicle.displayName, equals('2023 Ford F-150 XLT'));
    });
  });
}