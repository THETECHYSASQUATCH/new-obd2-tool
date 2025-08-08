import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/core/models/obd_response.dart';
import 'package:new_obd2_tool/core/services/obd_service.dart';

void main() {
  group('Dashboard Quick Actions Integration', () {
    test('Mode 03 DTC scan response parsing works correctly', () {
      // Test single DTC response
      const singleDtcResponse = '43 01 01 33';
      final response = OBDResponse.fromRaw(singleDtcResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('dtcs'), true);
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });

    test('Mode 03 multiple DTCs response parsing works correctly', () {
      // Test multiple DTCs response: P0133, C0144, B0155, U0166
      const multipleDtcsResponse = '43 04 01 33 41 44 81 55 C1 66';
      final response = OBDResponse.fromRaw(multipleDtcsResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('dtcs'), true);
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(4));
      expect(dtcs, contains('P0133')); // Powertrain
      expect(dtcs, contains('C0144')); // Chassis
      expect(dtcs, contains('B0155')); // Body
      expect(dtcs, contains('U0166')); // Network
    });

    test('Mode 03 no DTCs response parsing works correctly', () {
      // Test no DTCs response
      const noDtcsResponse = '43 00';
      final response = OBDResponse.fromRaw(noDtcsResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('dtcs'), true);
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(0));
    });

    test('Mode 04 DTC clear success response parsing works correctly', () {
      // Test successful clear with OK response
      const clearSuccessResponse = 'OK';
      final response = OBDResponse.fromRaw(clearSuccessResponse, '04');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('cleared'), true);
      expect(response.parsedData['cleared'], equals(true));
    });

    test('Mode 04 DTC clear success with hex response parsing works correctly', () {
      // Test successful clear with 44 hex response
      const clearSuccessHexResponse = '44';
      final response = OBDResponse.fromRaw(clearSuccessHexResponse, '04');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('cleared'), true);
      expect(response.parsedData['cleared'], equals(true));
    });

    test('Mode 04 DTC clear failure response parsing works correctly', () {
      // Test failed clear with NO DATA response
      const clearFailureResponse = 'NO DATA';
      final response = OBDResponse.fromRaw(clearFailureResponse, '04');
      
      expect(response.isError, true);
      expect(response.errorMessage, equals('NO DATA'));
    });

    test('DTC parsing handles ELM327 artifacts correctly', () {
      // Test response with SEARCHING prefix and prompt suffix
      const artifactResponse = 'SEARCHING...43 01 01 33>';
      final response = OBDResponse.fromRaw(artifactResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('dtcs'), true);
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });

    test('DTC parsing handles end markers correctly', () {
      // Test response with DTC followed by 0000 end marker
      const endMarkerResponse = '43 01 01 33 00 00';
      final response = OBDResponse.fromRaw(endMarkerResponse, '03');
      
      expect(response.isSuccess, true);
      expect(response.parsedData.containsKey('dtcs'), true);
      
      final dtcs = response.parsedData['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });

    test('OBDService reset adapter method exists and is properly typed', () {
      // Verify the resetAdapterAndReinit method exists on both service implementations
      final mobileService = MobileOBDService();
      final desktopService = DesktopOBDService();
      
      // These should compile and be callable (testing method signature)
      expect(() => mobileService.resetAdapterAndReinit(), returnsNormally);
      expect(() => desktopService.resetAdapterAndReinit(), returnsNormally);
    });
  });
}