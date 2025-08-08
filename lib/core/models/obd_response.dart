import 'dart:convert';

enum ResponseStatus { success, error, timeout, invalid }

class OBDResponse {
  final String command;
  final String rawResponse;
  final DateTime timestamp;
  final ResponseStatus status;
  final Map<String, dynamic>? parsedData;
  final String? errorMessage;
  final double? responseTime;
  final String? protocol;

  const OBDResponse({
    required this.command,
    required this.rawResponse,
    required this.timestamp,
    required this.status,
    this.parsedData,
    this.errorMessage,
    this.responseTime,
    this.protocol,
  });

  factory OBDResponse.fromJson(Map<String, dynamic> json) {
    return OBDResponse(
      command: json['command'] as String,
      rawResponse: json['rawResponse'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: ResponseStatus.values.byName(json['status']),
      parsedData: json['parsedData'] as Map<String, dynamic>?,
      errorMessage: json['errorMessage'] as String?,
      responseTime: (json['responseTime'] as num?)?.toDouble(),
      protocol: json['protocol'] as String?,
    );
  }

  /// Create an OBDResponse from a raw string.
  /// Includes parsing logic for common PIDs and modes.
  factory OBDResponse.fromRaw(String raw, [String command = '']) {
    final timestamp = DateTime.now();
    final cleanedData = raw
        .trim()
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .replaceAll('>', '')
        .toUpperCase();

    // Known error patterns
    if (cleanedData.contains('ERROR') ||
        cleanedData.contains('NO DATA') ||
        cleanedData.contains('?')) {
      return OBDResponse(
        command: command,
        rawResponse: cleanedData,
        timestamp: timestamp,
        status: ResponseStatus.error,
        errorMessage: cleanedData,
        parsedData: null,
      );
    }

    // Parse if possible
    final parsed = _parseResponse(cleanedData, command);

    return OBDResponse(
      command: command,
      rawResponse: cleanedData,
      timestamp: timestamp,
      status: ResponseStatus.success,
      parsedData: parsed ?? {'raw_hex': cleanedData},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'rawResponse': rawResponse,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'parsedData': parsedData,
      'errorMessage': errorMessage,
      'responseTime': responseTime,
      'protocol': protocol,
    };
  }

  OBDResponse copyWith({
    String? command,
    String? rawResponse,
    DateTime? timestamp,
    ResponseStatus? status,
    Map<String, dynamic>? parsedData,
    String? errorMessage,
    double? responseTime,
    String? protocol,
  }) {
    return OBDResponse(
      command: command ?? this.command,
      rawResponse: rawResponse ?? this.rawResponse,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      parsedData: parsedData ?? this.parsedData,
      errorMessage: errorMessage ?? this.errorMessage,
      responseTime: responseTime ?? this.responseTime,
      protocol: protocol ?? this.protocol,
    );
  }

  bool get isSuccess => status == ResponseStatus.success;
  bool get hasError => status == ResponseStatus.error;

  // Compatibility getters (for existing service code/tests)
  bool get isValid => status == ResponseStatus.success;
  bool get isError => status == ResponseStatus.error;
  String get rawData => rawResponse;
  Map<String, dynamic> get data => parsedData ?? {};

  // Typed getters
  T? getValue<T>(String key) {
    final value = parsedData?[key];
    if (value is T) return value;
    return null;
  }

  double? getNumericValue(String key) {
    final value = parsedData?[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() {
    final base = 'OBDResponse(command: $command, status: ${status.name}, raw: $rawResponse)';
    if (hasError) return '$base, error: $errorMessage';
    if (parsedData != null && parsedData!.isNotEmpty) return '$base, parsed: ${jsonEncode(parsedData)}';
    return base;
  }

  // ===== Parsing =====

  static Map<String, dynamic>? _parseResponse(String cleanData, String cmd) {
    final upperCmd = cmd.toUpperCase();

    // Mode-based parsing
    if (upperCmd == '03' || cleanData.startsWith('43')) {
      return _parseDtcList(cleanData);
    }

    if (upperCmd == '04' || cleanData == 'OK' || cleanData == '44') {
      final cleared = cleanData == 'OK' || cleanData == '44';
      return {'cleared': cleared};
    }

    // Enhanced PID-based parsing (Mode 01)
    switch (upperCmd) {
      case '010C': // Engine RPM
        return _parseRPM(cleanData);
      case '010D': // Vehicle Speed
        return _parseSpeed(cleanData);
      case '0105': // Engine Coolant Temperature
        return _parseTemperature(cleanData);
      case '010F': // Intake Air Temperature
        return _parseIntakeTemp(cleanData);
      case '0104': // Calculated Engine Load
        return _parseEngineLoad(cleanData);
      case '0111': // Throttle Position
        return _parseThrottlePosition(cleanData);
      case '010A': // Fuel Pressure
        return _parseFuelPressure(cleanData);
      case '010B': // Intake Manifold Pressure
        return _parseManifoldPressure(cleanData);
      case '0110': // MAF Air Flow Rate
        return _parseMAF(cleanData);
      default:
        // Fallback: try generic PID parsing
        final bytes = _hexToBytes(cleanData);
        if (bytes.length >= 3 && bytes[0] == 0x41) {
          final pid = bytes[1];
          switch (pid) {
            case 0x0C: return _parseRpmFromBytes(bytes);
            case 0x0D: return _parseSpeedFromBytes(bytes);
            case 0x05: return _parseTemperatureFromBytes(bytes);
            case 0x0F: return _parseIntakeTempFromBytes(bytes);
            case 0x04: return _parseEngineLoadFromBytes(bytes);
            case 0x11: return _parseThrottleFromBytes(bytes);
            case 0x0A: return _parseFuelPressureFromBytes(bytes);
            case 0x0B: return _parseManifoldPressureFromBytes(bytes);
            case 0x10: return _parseMAFFromBytes(bytes);
            default: return {'raw_hex': cleanData};
          }
        }
        return {'raw_hex': cleanData};
    }
  }

  static Map<String, dynamic> _parseRPM(String data) {
    if (data.length >= 8 && data.startsWith('410C')) {
      final a = int.parse(data.substring(4, 6), radix: 16);
      final b = int.parse(data.substring(6, 8), radix: 16);
      final rpm = ((a * 256) + b) / 4.0;
      return {'value': rpm, 'unit': 'RPM', 'description': 'Engine RPM'};
    }
    return {'error': 'Invalid RPM response'};
  }

  static Map<String, dynamic> _parseRpmFromBytes(List<int> bytes) {
    if (bytes.length >= 4) {
      final a = bytes[2];
      final b = bytes[3];
      final rpm = ((a * 256) + b) / 4.0;
      return {'value': rpm, 'unit': 'RPM', 'description': 'Engine RPM'};
    }
    return {'error': 'Invalid RPM response'};
  }

  static Map<String, dynamic> _parseSpeed(String data) {
    if (data.length >= 6 && data.startsWith('410D')) {
      final speed = int.parse(data.substring(4, 6), radix: 16);
      return {'value': speed, 'unit': 'km/h', 'description': 'Vehicle Speed'};
    }
    return {'error': 'Invalid speed response'};
  }

  static Map<String, dynamic> _parseSpeedFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final speed = bytes[2];
      return {'value': speed, 'unit': 'km/h', 'description': 'Vehicle Speed'};
    }
    return {'error': 'Invalid speed response'};
  }

  static Map<String, dynamic> _parseTemperature(String data) {
    if (data.length >= 6 && data.startsWith('4105')) {
      final temp = int.parse(data.substring(4, 6), radix: 16) - 40;
      return {'value': temp, 'unit': '°C', 'description': 'Engine Coolant Temperature'};
    }
    return {'error': 'Invalid temperature response'};
  }

  static Map<String, dynamic> _parseTemperatureFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final temp = bytes[2] - 40;
      return {'value': temp, 'unit': '°C', 'description': 'Engine Coolant Temperature'};
    }
    return {'error': 'Invalid temperature response'};
  }

  static Map<String, dynamic> _parseIntakeTemp(String data) {
    if (data.length >= 6 && data.startsWith('410F')) {
      final temp = int.parse(data.substring(4, 6), radix: 16) - 40;
      return {'value': temp, 'unit': '°C', 'description': 'Intake Air Temperature'};
    }
    return {'error': 'Invalid intake temperature response'};
  }

  static Map<String, dynamic> _parseIntakeTempFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final temp = bytes[2] - 40;
      return {'value': temp, 'unit': '°C', 'description': 'Intake Air Temperature'};
    }
    return {'error': 'Invalid intake temperature response'};
  }

  static Map<String, dynamic> _parseEngineLoad(String data) {
    if (data.length >= 6 && data.startsWith('4104')) {
      final load = (int.parse(data.substring(4, 6), radix: 16) * 100) / 255;
      return {'value': load.round(), 'unit': '%', 'description': 'Calculated Engine Load'};
    }
    return {'error': 'Invalid engine load response'};
  }

  static Map<String, dynamic> _parseEngineLoadFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final load = ((bytes[2] * 100) / 255.0).round();
      return {'value': load, 'unit': '%', 'description': 'Calculated Engine Load'};
    }
    return {'error': 'Invalid engine load response'};
  }

  static Map<String, dynamic> _parseThrottlePosition(String data) {
    if (data.length >= 6 && data.startsWith('4111')) {
      final position = (int.parse(data.substring(4, 6), radix: 16) * 100) / 255;
      return {'value': position.round(), 'unit': '%', 'description': 'Throttle Position'};
    }
    return {'error': 'Invalid throttle position response'};
  }

  static Map<String, dynamic> _parseThrottleFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final throttle = ((bytes[2] * 100) / 255.0).round();
      return {'value': throttle, 'unit': '%', 'description': 'Throttle Position'};
    }
    return {'error': 'Invalid throttle position response'};
  }

  static Map<String, dynamic> _parseFuelPressure(String data) {
    if (data.length >= 6 && data.startsWith('410A')) {
      final pressure = int.parse(data.substring(4, 6), radix: 16) * 3;
      return {'value': pressure, 'unit': 'kPa', 'description': 'Fuel Pressure'};
    }
    return {'error': 'Invalid fuel pressure response'};
  }

  static Map<String, dynamic> _parseFuelPressureFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final pressure = bytes[2] * 3;
      return {'value': pressure, 'unit': 'kPa', 'description': 'Fuel Pressure'};
    }
    return {'error': 'Invalid fuel pressure response'};
  }

  static Map<String, dynamic> _parseManifoldPressure(String data) {
    if (data.length >= 6 && data.startsWith('410B')) {
      final pressure = int.parse(data.substring(4, 6), radix: 16);
      return {'value': pressure, 'unit': 'kPa', 'description': 'Intake Manifold Pressure'};
    }
    return {'error': 'Invalid manifold pressure response'};
  }

  static Map<String, dynamic> _parseManifoldPressureFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final pressure = bytes[2];
      return {'value': pressure, 'unit': 'kPa', 'description': 'Intake Manifold Pressure'};
    }
    return {'error': 'Invalid manifold pressure response'};
  }

  static Map<String, dynamic> _parseMAF(String data) {
    if (data.length >= 8 && data.startsWith('4110')) {
      final a = int.parse(data.substring(4, 6), radix: 16);
      final b = int.parse(data.substring(6, 8), radix: 16);
      final maf = ((a * 256) + b) / 100.0;
      return {'value': double.parse(maf.toStringAsFixed(2)), 'unit': 'g/s', 'description': 'MAF Air Flow Rate'};
    }
    return {'error': 'Invalid MAF response'};
  }

  static Map<String, dynamic> _parseMAFFromBytes(List<int> bytes) {
    if (bytes.length >= 4) {
      final a = bytes[2];
      final b = bytes[3];
      final maf = ((a * 256) + b) / 100.0;
      return {'value': double.parse(maf.toStringAsFixed(2)), 'unit': 'g/s', 'description': 'MAF Air Flow Rate'};
    }
    return {'error': 'Invalid MAF response'};
  }

  static Map<String, dynamic> _parseDtcList(String data) {
    try {
      // Sanitize response - remove common ELM327 artifacts
      String cleanData = data.replaceAll('>', '').replaceAll('SEARCHING...', '').replaceAll(' ', '').toUpperCase();
      
      // Find Mode 03 positive response (43)
      int responseStart = cleanData.indexOf('43');
      if (responseStart == -1) {
        // No DTCs found or invalid response
        return {'dtcs': <String>[]};
      }
      
      // Extract the payload after '43' and the number of DTCs byte
      String payload = cleanData.substring(responseStart + 4); // Skip '43' + count byte
      
      List<String> dtcs = [];
      
      // Process DTCs in pairs of 4 hex characters (2 bytes each)
      for (int i = 0; i < payload.length - 3; i += 4) {
        String dtcHex = payload.substring(i, i + 4);
        
        // Stop if we hit 0000 (end marker)
        if (dtcHex == '0000') break;
        
        if (dtcHex.length == 4) {
          String? dtcCode = _decodeDtcFromBytes(dtcHex.substring(0, 2), dtcHex.substring(2, 4));
          if (dtcCode != null) {
            dtcs.add(dtcCode);
          }
        }
      }
      
      return {'dtcs': dtcs};
    } catch (e) {
      return {'dtcs': <String>[], 'parse_error': e.toString()};
    }
  }

  static String? _decodeDtcFromBytes(String aHex, String bHex) {
    try {
      int a = int.parse(aHex, radix: 16);
      int b = int.parse(bHex, radix: 16);
      
      // Extract system letter from high 2 bits of A
      String system;
      switch ((a >> 6) & 0x03) {
        case 0: system = 'P'; break; // Powertrain
        case 1: system = 'C'; break; // Chassis
        case 2: system = 'B'; break; // Body
        case 3: system = 'U'; break; // Network
        default: return null;
      }
      
      // Extract 4 hex digits from remaining bits per SAE J2012
      int digit1 = (a >> 4) & 0x03;
      int digit2 = a & 0x0F;
      int digit3 = (b >> 4) & 0x0F;
      int digit4 = b & 0x0F;
      
      return '$system$digit1${digit2.toRadixString(16).toUpperCase()}${digit3.toRadixString(16).toUpperCase()}${digit4.toRadixString(16).toUpperCase()}';
    } catch (e) {
      return null;
    }
  }

  static List<int> _hexToBytes(String hex) {
    final clean = hex.replaceAll(' ', '').toUpperCase();
    if (clean.length % 2 != 0) return [];
    final out = <int>[];
    for (var i = 0; i < clean.length; i += 2) {
      out.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return out;
  }

  static List<String> _decodeDTCs(List<int> bytes) {
    final dtcs = <String>[];
    if (bytes.isEmpty) return dtcs;

    int startIndex = 0;
    if (bytes[0] == 0x43) {
      // If count byte exists, it is bytes[1]
      startIndex = 2; // skip '43' and count
      if (bytes.length < 4) startIndex = 1; // minimal defensive shift
    }

    if (startIndex >= bytes.length) startIndex = 0;

    for (int i = startIndex; i + 1 < bytes.length; i += 2) {
      final a = bytes[i];
      final b = bytes[i + 1];
      if (a == 0x00 && b == 0x00) continue;

      final typeIndex = (a & 0xC0) >> 6; // 0=P,1=C,2=B,3=U
      final type = ['P', 'C', 'B', 'U'][typeIndex];
      final d1 = (a & 0x30) >> 4;        // 0..3
      final d2 = (a & 0x0F);             // 0..15
      final d3 = (b & 0xF0) >> 4;        // 0..15
      final d4 = (b & 0x0F);             // 0..15

      final code = '$type$d1${d2.toRadixString(16).toUpperCase()}'
          '${d3.toRadixString(16).toUpperCase()}'
          '${d4.toRadixString(16).toUpperCase()}';

      dtcs.add(code);
    }

    return dtcs;
  }
}

enum ResponseStatus {
  success,
  error,
  timeout,
  invalid,
}