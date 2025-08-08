import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/shared/models/obd_response.dart';
import 'package:new_obd2_tool/core/services/obd_service.dart';
import 'package:new_obd2_tool/shared/models/connection_config.dart';

void main() {
  group('Dashboard Quick Actions - OBD Response Handling', () {
    test('should correctly identify successful DTC scan response', () {
      // Mode 03 response with DTCs
      const rawResponse = '43 02 01 33 03 00';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData['dtcs'], isA<List<String>>());
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(2));
      expect(dtcs, contains('P0133'));
      expect(dtcs, contains('P0300'));
    });

    test('should correctly handle empty DTC scan response', () {
      // Mode 03 response with no DTCs
      const rawResponse = '43 00';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData['dtcs'], isA<List<String>>());
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(0));
    });

    test('should correctly identify successful DTC clear response', () {
      // Mode 04 clear success
      const rawResponse = '44';
      final response = OBDResponse.fromRaw(rawResponse, '04');
      
      expect(response.isSuccess, true);
      expect(response.parsedData['cleared'], equals(true));
    });

    test('should correctly identify DTC clear response with OK', () {
      // ELM327 OK response for clear
      const rawResponse = 'OK';
      final response = OBDResponse.fromRaw(rawResponse, '04');
      
      expect(response.isSuccess, true);
      expect(response.parsedData['cleared'], equals(true));
    });

    test('should handle DTC scan error response', () {
      // Error response
      const rawResponse = 'NO DATA';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isSuccess, false);
      expect(response.hasError, true);
      expect(response.errorMessage, equals('NO DATA'));
    });

    test('should handle DTC clear error response', () {
      // Error response for clear
      const rawResponse = 'ERROR';
      final response = OBDResponse.fromRaw(rawResponse, '04');
      
      expect(response.isSuccess, false);
      expect(response.hasError, true);
      expect(response.errorMessage, equals('ERROR'));
    });

    test('should parse various DTC system types', () {
      // Test all system types: P, C, B, U
      const rawResponse = '43 04 01 23 40 45 80 67 C0 89';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isSuccess, true);
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(4));
      expect(dtcs, contains('P0123')); // Powertrain
      expect(dtcs, contains('C0045')); // Chassis  
      expect(dtcs, contains('B0067')); // Body
      expect(dtcs, contains('U0089')); // Network
    });

    test('should handle Mode 03 response with padding', () {
      // Response with extra data/padding
      const rawResponse = '43 01 01 33 00 00 00 00';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isSuccess, true);
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });
  });

  group('OBD Service Interface Requirements', () {
    test('should have resetAdapterAndReinit method in abstract interface', () {
      // Verify the method exists in the abstract interface
      // This is a compile-time check that the method was added
      final service = MockOBDService();
      expect(service.resetAdapterAndReinit, isA<Function>());
    });
  });
}

// Mock implementation for testing interface compliance
class MockOBDService implements OBDService {
  @override
  bool get isConnected => false;

  @override
  Stream<ConnectionStatus> get connectionStatus => Stream.empty();

  @override
  Stream<OBDResponse> get dataStream => Stream.empty();

  @override
  Future<bool> connect(ConnectionConfig config) async => false;

  @override
  Future<void> disconnect() async {}

  @override
  Future<Map<String, dynamic>> getLiveData() async => {};

  @override
  Future<OBDResponse> sendCommand(String command) async {
    return OBDResponse.fromRaw('NO DATA', command);
  }

  @override
  Future<List<String>> scanForDevices() async => [];

  @override
  Future<void> resetAdapterAndReinit() async {
    // Mock implementation
  }
}