import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/core/services/vw_service.dart';
import 'package:new_obd2_tool/core/services/nissan_service.dart';
import 'package:new_obd2_tool/core/services/obd_service.dart';
import 'package:new_obd2_tool/shared/models/vehicle_info.dart';
import 'package:new_obd2_tool/features/vw_tools/models/vw_data_models.dart';
import 'package:new_obd2_tool/features/nissan_tools/models/nissan_data_models.dart';

// Mock OBD Service for testing
class MockOBDService extends OBDService {
  @override
  Future<Map<String, dynamic>> getLiveData() async {
    return {
      'Engine RPM': 2000,
      'Vehicle Speed': 45,
      'Coolant Temperature': 85,
      'Fuel Level': 75,
    };
  }

  @override
  Future<dynamic> sendCommand(String command) async {
    // Mock responses for different PIDs
    switch (command) {
      case 'VW01': // DSG Temperature
        return MockOBDResponse('41 VW01 AA', true);
      case 'VW02': // DSG Clutch Status
        return MockOBDResponse('41 VW02 01 00 14 1E', true);
      case 'VW03': // Quattro Status
        return MockOBDResponse('41 VW03 02 32 4B', true);
      case 'NS01': // CVT Temperature
        return MockOBDResponse('41 NS01 55', true);
      case 'NS02': // CVT Pressure
        return MockOBDResponse('41 NS02 28', true);
      case 'NS04': // ProPILOT Status
        return MockOBDResponse('41 NS04 01 01 01 01', true);
      default:
        return MockOBDResponse('NO DATA', false);
    }
  }
}

class MockOBDResponse {
  final String data;
  final bool isValid;
  
  MockOBDResponse(this.data, this.isValid);
}

void main() {
  group('VW Service Tests', () {
    late VWService vwService;
    late MockOBDService mockOBDService;

    setUp(() {
      mockOBDService = MockOBDService();
      vwService = VWService(mockOBDService);
    });

    test('VW Service initialization with valid VW vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Volkswagen',
        model: 'Golf',
        year: 2023,
        trim: 'GTI',
      );

      expect(() => vwService.initialize(vehicle), returnsNormally);
    });

    test('VW Service initialization with valid Audi vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Audi',
        model: 'A4',
        year: 2023,
        trim: 'Premium Plus',
      );

      expect(() => vwService.initialize(vehicle), returnsNormally);
    });

    test('VW Service initialization with invalid vehicle brand', () {
      const vehicle = VehicleInfo(
        make: 'Toyota',
        model: 'Camry',
        year: 2023,
        trim: 'LE',
      );

      expect(() => vwService.initialize(vehicle), throwsArgumentError);
    });

    test('VW live data retrieval', () async {
      const vehicle = VehicleInfo(
        make: 'Volkswagen',
        model: 'Golf',
        year: 2023,
        trim: 'GTI',
      );
      
      vwService.initialize(vehicle);
      final liveData = await vwService.getVWLiveData();

      expect(liveData, isA<Map<String, dynamic>>());
      expect(liveData['Engine RPM'], equals(2000));
      expect(liveData['Vehicle Speed'], equals(45));
    });

    test('VW service tool execution', () async {
      const vehicle = VehicleInfo(
        make: 'Volkswagen',
        model: 'Golf',
        year: 2023,
        trim: 'GTI',
      );
      
      vwService.initialize(vehicle);
      final result = await vwService.runVWServiceTool('vcds_scan', {});

      expect(result, isA<Map<String, dynamic>>());
      expect(result['diagnostic_trouble_codes'], isA<List>());
    });

    test('VW programming operation', () async {
      const vehicle = VehicleInfo(
        make: 'Volkswagen',
        model: 'Golf',
        year: 2023,
        trim: 'GTI',
      );
      
      vwService.initialize(vehicle);
      final success = await vwService.performVWProgramming(
        ecuType: 'Engine',
        operation: 'coding',
        parameters: {'feature': 'enable'},
      );

      expect(success, isTrue);
    });
  });

  group('Nissan Service Tests', () {
    late NissanService nissanService;
    late MockOBDService mockOBDService;

    setUp(() {
      mockOBDService = MockOBDService();
      nissanService = NissanService(mockOBDService);
    });

    test('Nissan Service initialization with valid Nissan vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Nissan',
        model: 'Altima',
        year: 2023,
        trim: 'SV',
      );

      expect(() => nissanService.initialize(vehicle), returnsNormally);
    });

    test('Nissan Service initialization with valid Infiniti vehicle', () {
      const vehicle = VehicleInfo(
        make: 'Infiniti',
        model: 'Q50',
        year: 2023,
        trim: 'Red Sport 400',
      );

      expect(() => nissanService.initialize(vehicle), returnsNormally);
    });

    test('Nissan Service initialization with invalid vehicle brand', () {
      const vehicle = VehicleInfo(
        make: 'Honda',
        model: 'Civic',
        year: 2023,
        trim: 'Sport',
      );

      expect(() => nissanService.initialize(vehicle), throwsArgumentError);
    });

    test('Nissan live data retrieval', () async {
      const vehicle = VehicleInfo(
        make: 'Nissan',
        model: 'Altima',
        year: 2023,
        trim: 'SV',
      );
      
      nissanService.initialize(vehicle);
      final liveData = await nissanService.getNissanLiveData();

      expect(liveData, isA<Map<String, dynamic>>());
      expect(liveData['Engine RPM'], equals(2000));
      expect(liveData['Vehicle Speed'], equals(45));
    });

    test('Nissan service tool execution', () async {
      const vehicle = VehicleInfo(
        make: 'Nissan',
        model: 'Altima',
        year: 2023,
        trim: 'SV',
      );
      
      nissanService.initialize(vehicle);
      final result = await nissanService.runNissanServiceTool('consult_scan', {});

      expect(result, isA<Map<String, dynamic>>());
      expect(result['diagnostic_trouble_codes'], isA<List>());
    });

    test('Nissan programming operation', () async {
      const vehicle = VehicleInfo(
        make: 'Nissan',
        model: 'Altima',
        year: 2023,
        trim: 'SV',
      );
      
      nissanService.initialize(vehicle);
      final success = await nissanService.performNissanProgramming(
        ecuType: 'ECM',
        operation: 'flash',
        parameters: {'software_version': '2023.1'},
      );

      expect(success, isTrue);
    });
  });

  group('VW Data Models Tests', () {
    test('VWLiveData fromMap conversion', () {
      final data = {
        'DSG Transmission Temperature': 85.0,
        'DSG Clutch Status': {'clutch_1_engaged': true, 'clutch_2_engaged': false},
        'Quattro AWD Status': {'mode': 'AWD', 'front_torque_percent': 60, 'rear_torque_percent': 40},
        'AdBlue/DEF Level': 75.0,
        'DSG Health Score': 92.5,
      };

      final vwLiveData = VWLiveData.fromMap(data);

      expect(vwLiveData.dsgTransmissionTemperature, equals(85.0));
      expect(vwLiveData.dsgClutchStatus?['clutch_1_engaged'], isTrue);
      expect(vwLiveData.quattroAwdStatus?['mode'], equals('AWD'));
      expect(vwLiveData.adBlueLevel, equals(75.0));
      expect(vwLiveData.dsgHealthScore, equals(92.5));
    });

    test('VWLiveData toMap conversion', () {
      const vwLiveData = VWLiveData(
        dsgTransmissionTemperature: 85.0,
        dsgClutchStatus: {'clutch_1_engaged': true, 'clutch_2_engaged': false},
        quattroAwdStatus: {'mode': 'AWD', 'front_torque_percent': 60, 'rear_torque_percent': 40},
        adBlueLevel: 75.0,
        dsgHealthScore: 92.5,
      );

      final map = vwLiveData.toMap();

      expect(map['DSG Transmission Temperature'], equals(85.0));
      expect(map['DSG Clutch Status']?['clutch_1_engaged'], isTrue);
      expect(map['Quattro AWD Status']?['mode'], equals('AWD'));
      expect(map['AdBlue/DEF Level'], equals(75.0));
      expect(map['DSG Health Score'], equals(92.5));
    });

    test('VWServiceTool model serialization', () {
      const tool = VWServiceTool(
        name: 'VCDS Scan',
        description: 'Comprehensive diagnostic scan',
        icon: 'search',
        parameters: {'deep_scan': true},
      );

      final map = tool.toMap();
      final reconstructed = VWServiceTool.fromMap(map);

      expect(reconstructed.name, equals(tool.name));
      expect(reconstructed.description, equals(tool.description));
      expect(reconstructed.icon, equals(tool.icon));
      expect(reconstructed.parameters?['deep_scan'], isTrue);
    });
  });

  group('Nissan Data Models Tests', () {
    test('NissanLiveData fromMap conversion', () {
      final data = {
        'CVT Transmission Temperature': 65.0,
        'CVT Fluid Pressure': 4.2,
        'CVT Pulley Ratio': 2.8,
        'ProPILOT Assist Status': {'available': true, 'active': false, 'steering_assist': true, 'speed_control': true},
        'CVT Health Score': 88.5,
      };

      final nissanLiveData = NissanLiveData.fromMap(data);

      expect(nissanLiveData.cvtTransmissionTemperature, equals(65.0));
      expect(nissanLiveData.cvtFluidPressure, equals(4.2));
      expect(nissanLiveData.cvtPulleyRatio, equals(2.8));
      expect(nissanLiveData.proPilotAssistStatus?['available'], isTrue);
      expect(nissanLiveData.cvtHealthScore, equals(88.5));
    });

    test('NissanLiveData toMap conversion', () {
      const nissanLiveData = NissanLiveData(
        cvtTransmissionTemperature: 65.0,
        cvtFluidPressure: 4.2,
        cvtPulleyRatio: 2.8,
        proPilotAssistStatus: {'available': true, 'active': false, 'steering_assist': true, 'speed_control': true},
        cvtHealthScore: 88.5,
      );

      final map = nissanLiveData.toMap();

      expect(map['CVT Transmission Temperature'], equals(65.0));
      expect(map['CVT Fluid Pressure'], equals(4.2));
      expect(map['CVT Pulley Ratio'], equals(2.8));
      expect(map['ProPILOT Assist Status']?['available'], isTrue);
      expect(map['CVT Health Score'], equals(88.5));
    });

    test('NissanServiceTool model serialization', () {
      const tool = NissanServiceTool(
        name: 'CONSULT Scan',
        description: 'CONSULT diagnostic scan',
        icon: 'search',
        parameters: {'full_scan': true},
      );

      final map = tool.toMap();
      final reconstructed = NissanServiceTool.fromMap(map);

      expect(reconstructed.name, equals(tool.name));
      expect(reconstructed.description, equals(tool.description));
      expect(reconstructed.icon, equals(tool.icon));
      expect(reconstructed.parameters?['full_scan'], isTrue);
    });
  });

  group('Integration Tests', () {
    test('VW brand-specific PID filtering', () async {
      final mockOBDService = MockOBDService();
      final vwService = VWService(mockOBDService);
      
      const volkswagen = VehicleInfo(make: 'Volkswagen', model: 'Golf', year: 2023, trim: 'GTI');
      const audi = VehicleInfo(make: 'Audi', model: 'A4', year: 2023, trim: 'Premium Plus');
      
      vwService.initialize(volkswagen);
      final vwData = await vwService.getVWLiveData();
      
      vwService.initialize(audi);
      final audiData = await vwService.getVWLiveData();
      
      // Different brands should have different available PIDs
      expect(vwData.keys.toSet(), isNot(equals(audiData.keys.toSet())));
    });

    test('Nissan brand-specific PID filtering', () async {
      final mockOBDService = MockOBDService();
      final nissanService = NissanService(mockOBDService);
      
      const nissan = VehicleInfo(make: 'Nissan', model: 'Altima', year: 2023, trim: 'SV');
      const infiniti = VehicleInfo(make: 'Infiniti', model: 'Q50', year: 2023, trim: 'Red Sport 400');
      
      nissanService.initialize(nissan);
      final nissanData = await nissanService.getNissanLiveData();
      
      nissanService.initialize(infiniti);
      final infinitiData = await nissanService.getNissanLiveData();
      
      // Different brands should have different available PIDs
      expect(nissanData.keys.toSet(), isNot(equals(infinitiData.keys.toSet())));
    });

    test('Service disposal', () {
      final mockOBDService = MockOBDService();
      final vwService = VWService(mockOBDService);
      final nissanService = NissanService(mockOBDService);
      
      const vehicle = VehicleInfo(make: 'Volkswagen', model: 'Golf', year: 2023, trim: 'GTI');
      vwService.initialize(vehicle);
      
      const nissanVehicle = VehicleInfo(make: 'Nissan', model: 'Altima', year: 2023, trim: 'SV');
      nissanService.initialize(nissanVehicle);
      
      // Should not throw exceptions
      expect(() => vwService.dispose(), returnsNormally);
      expect(() => nissanService.dispose(), returnsNormally);
    });
  });

  group('Error Handling Tests', () {
    test('VW Service handles uninitialized state', () async {
      final mockOBDService = MockOBDService();
      final vwService = VWService(mockOBDService);
      
      expect(() async => await vwService.getVWLiveData(), throwsStateError);
    });

    test('Nissan Service handles uninitialized state', () async {
      final mockOBDService = MockOBDService();
      final nissanService = NissanService(mockOBDService);
      
      expect(() async => await nissanService.getNissanLiveData(), throwsStateError);
    });

    test('VW Service handles unknown service tool', () async {
      final mockOBDService = MockOBDService();
      final vwService = VWService(mockOBDService);
      
      const vehicle = VehicleInfo(make: 'Volkswagen', model: 'Golf', year: 2023, trim: 'GTI');
      vwService.initialize(vehicle);
      
      expect(() async => await vwService.runVWServiceTool('unknown_tool', {}), throwsArgumentError);
    });

    test('Nissan Service handles unknown service tool', () async {
      final mockOBDService = MockOBDService();
      final nissanService = NissanService(mockOBDService);
      
      const vehicle = VehicleInfo(make: 'Nissan', model: 'Altima', year: 2023, trim: 'SV');
      nissanService.initialize(vehicle);
      
      expect(() async => await nissanService.runNissanServiceTool('unknown_tool', {}), throwsArgumentError);
    });
  });
}