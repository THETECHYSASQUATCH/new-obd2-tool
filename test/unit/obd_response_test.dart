import 'package:flutter_test/flutter_test.dart';
import 'package:obd2_diagnostics_tool/shared/models/obd_response.dart';

void main() {
  group('OBDResponse', () {
    test('should parse RPM response correctly', () {
      const rawResponse = '41 0C 1A F8';
      final response = OBDResponse.fromRaw(rawResponse, '010C');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(1726.0));
      expect(response.parsedData!['unit'], equals('RPM'));
      expect(response.parsedData!['description'], equals('Engine RPM'));
    });

    test('should parse vehicle speed response correctly', () {
      const rawResponse = '41 0D 50';
      final response = OBDResponse.fromRaw(rawResponse, '010D');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(80));
      expect(response.parsedData!['unit'], equals('km/h'));
      expect(response.parsedData!['description'], equals('Vehicle Speed'));
    });

    test('should parse coolant temperature response correctly', () {
      const rawResponse = '41 05 5A';
      final response = OBDResponse.fromRaw(rawResponse, '0105');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(50)); // 90 - 40 = 50°C
      expect(response.parsedData!['unit'], equals('°C'));
      expect(response.parsedData!['description'], equals('Engine Coolant Temperature'));
    });

    test('should parse engine load response correctly', () {
      const rawResponse = '41 04 80';
      final response = OBDResponse.fromRaw(rawResponse, '0104');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(50)); // (128 * 100) / 255 = ~50%
      expect(response.parsedData!['unit'], equals('%'));
      expect(response.parsedData!['description'], equals('Calculated Engine Load'));
    });

    test('should parse throttle position response correctly', () {
      const rawResponse = '41 11 FF';
      final response = OBDResponse.fromRaw(rawResponse, '0111');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(100)); // (255 * 100) / 255 = 100%
      expect(response.parsedData!['unit'], equals('%'));
      expect(response.parsedData!['description'], equals('Throttle Position'));
    });

    test('should handle error responses', () {
      const rawResponse = 'NO DATA';
      final response = OBDResponse.fromRaw(rawResponse, '010C');
      
      expect(response.isError, true);
      expect(response.errorMessage, equals('NO DATA'));
      expect(response.parsedData, isNull);
    });

    test('should handle unknown command responses', () {
      const rawResponse = '41 FF 12 34';
      final response = OBDResponse.fromRaw(rawResponse, '01FF');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['raw_hex'], equals('41FF1234'));
    });

    test('should convert to and from JSON correctly', () {
      const rawResponse = '41 0C 1A F8';
      final originalResponse = OBDResponse.fromRaw(rawResponse, '010C');
      
      final json = originalResponse.toJson();
      final reconstructedResponse = OBDResponse.fromJson(json);
      
      expect(reconstructedResponse.rawData, equals(originalResponse.rawData));
      expect(reconstructedResponse.command, equals(originalResponse.command));
      expect(reconstructedResponse.isError, equals(originalResponse.isError));
      expect(reconstructedResponse.parsedData, equals(originalResponse.parsedData));
    });

    test('should handle fuel pressure response correctly', () {
      const rawResponse = '41 0A 50';
      final response = OBDResponse.fromRaw(rawResponse, '010A');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(240)); // 80 * 3 = 240 kPa
      expect(response.parsedData!['unit'], equals('kPa'));
      expect(response.parsedData!['description'], equals('Fuel Pressure'));
    });

    test('should handle manifold pressure response correctly', () {
      const rawResponse = '41 0B 65';
      final response = OBDResponse.fromRaw(rawResponse, '010B');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(101)); // 101 kPa
      expect(response.parsedData!['unit'], equals('kPa'));
      expect(response.parsedData!['description'], equals('Intake Manifold Pressure'));
    });

    test('should handle MAF air flow response correctly', () {
      const rawResponse = '41 10 12 34';
      final response = OBDResponse.fromRaw(rawResponse, '0110');
      
      expect(response.isError, false);
      expect(response.parsedData, isNotNull);
      expect(response.parsedData!['value'], equals(46.60)); // ((18 * 256) + 52) / 100 = 46.60 g/s
      expect(response.parsedData!['unit'], equals('g/s'));
      expect(response.parsedData!['description'], equals('MAF Air Flow Rate'));
    });
  });
}