import 'package:flutter_test/flutter_test.dart';
import 'package:new_obd2_tool/shared/models/obd_response.dart';

void main() {
  group('OBDResponse DTC Parsing', () {
    test('should parse Mode 03 response with single DTC correctly', () {
      // Example: 43 01 01 33 - Mode 03 response with 1 DTC: P0133 (O2 Sensor Circuit Slow Response)
      const rawResponse = '43 01 01 33';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['dtcs'], isA<List<String>>());
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });

    test('should parse Mode 03 response with multiple DTCs correctly', () {
      // Example: 43 03 01 33 03 00 02 20 - Mode 03 response with 3 DTCs: P0133, P0300, P0220
      const rawResponse = '43 03 01 33 03 00 02 20';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(3));
      expect(dtcs, contains('P0133'));
      expect(dtcs, contains('P0300'));
      expect(dtcs, contains('P0220'));
    });

    test('should parse Mode 03 response with no DTCs', () {
      // Example: 43 00 - Mode 03 response with 0 DTCs
      const rawResponse = '43 00';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(0));
    });

    test('should parse Mode 03 response with ELM327 artifacts', () {
      // Example with SEARCHING and prompt: SEARCHING...43 01 01 33>
      const rawResponse = 'SEARCHING...43 01 01 33>';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });

    test('should parse different DTC system types correctly', () {
      // Test P, C, B, U system codes
      // 43 04 01 33 41 44 81 55 C1 66 - P0133, C0144, B0155, U0166
      const rawResponse = '43 04 01 33 41 44 81 55 C1 66';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(4));
      expect(dtcs, contains('P0133')); // Powertrain
      expect(dtcs, contains('C0144')); // Chassis
      expect(dtcs, contains('B0155')); // Body
      expect(dtcs, contains('U0166')); // Network
    });

    test('should parse Mode 04 clear success response', () {
      // ELM327 typically responds with "OK" for successful clear
      const rawResponse = 'OK>';
      final response = OBDResponse.fromRaw(rawResponse, '04');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['cleared'], equals(true));
    });

    test('should parse Mode 04 clear success with hex response', () {
      // Some adapters may respond with 44 for Mode 04 success
      const rawResponse = '44';
      final response = OBDResponse.fromRaw(rawResponse, '04');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['cleared'], equals(true));
    });

    test('should handle Mode 04 clear failure', () {
      // No OK or 44 response indicates failure
      const rawResponse = 'NO DATA';
      final response = OBDResponse.fromRaw(rawResponse, '04');
      
      expect(response.isError, true);
      expect(response.errorMessage, equals('NO DATA'));
    });

    test('should handle Mode 03 invalid response', () {
      // Response without 43 prefix
      const rawResponse = '41 00';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(0));
    });

    test('should handle DTC with end marker 0000', () {
      // Response with DTC followed by 0000 end marker
      const rawResponse = '43 01 01 33 00 00';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs.length, equals(1));
      expect(dtcs[0], equals('P0133'));
    });

    test('should decode DTC bytes according to SAE J2012 format', () {
      // Test the internal DTC decoding logic with specific byte values
      // 01 33 should decode to P0133
      // High 2 bits of 01 (00) = P system
      // Remaining bits: 0133
      const rawResponse = '43 01 01 33';
      final response = OBDResponse.fromRaw(rawResponse, '03');
      
      final dtcs = response.parsedData!['dtcs'] as List<String>;
      expect(dtcs[0], equals('P0133'));
      
      // Test another: 43 01 C0 20 should be U0020
      const rawResponse2 = '43 01 C0 20';
      final response2 = OBDResponse.fromRaw(rawResponse2, '03');
      
      final dtcs2 = response2.parsedData!['dtcs'] as List<String>;
      expect(dtcs2[0], equals('U0020'));
    });
  });
}