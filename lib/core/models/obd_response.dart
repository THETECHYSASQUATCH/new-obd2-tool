import 'dart:convert';

enum ResponseStatus { success, error, timeout, invalid }

class OBDResponse {
  final String command;
  final String rawResponse;
  final DateTime timestamp;
  final ResponseStatus status;
  final Map<String, dynamic> parsedData;
  final String? errorMessage;
  final double? responseTime;
  final String? protocol;

  const OBDResponse({
    required this.command,
    required this.rawResponse,
    required this.timestamp,
    required this.status,
    this.parsedData = const {},
    this.errorMessage,
    this.responseTime,
    this.protocol,
  });

  factory OBDResponse.fromJson(Map<String, dynamic> json) {
    return OBDResponse(
      command: json['command'] as String,
      rawResponse: json['rawResponse'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: ResponseStatus.values.byName(json['status'] as String),
      parsedData: (json['parsedData'] as Map?)?.cast<String, dynamic>() ?? {},
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
  Map<String, dynamic> get data => parsedData;

  // Typed getters
  T? getValue<T>(String key) {
    final value = parsedData[key];
    if (value is T) return value;
    return null;
  }

  double? getNumericValue(String key) {
    final value = parsedData[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() {
    final base = 'OBDResponse(command: $command, status: ${status.name}, raw: $rawResponse)';
    if (hasError) return '$base, error: $errorMessage';
    if (parsedData.isNotEmpty) return '$base, parsed: ${jsonEncode(parsedData)}';
    return base;
  }

  // ===== Parsing =====

  static Map<String, dynamic>? _parseResponse(String cleanData, String cmd) {
    final upperCmd = cmd.toUpperCase();

    // Mode-based parsing
    if (upperCmd == '03' || cleanData.startsWith('43')) {
      final bytes = _hexToBytes(cleanData);
      final dtcs = _decodeDTCs(bytes);
      return {'dtcs': dtcs};
    }

    if (upperCmd == '04' || cleanData == 'OK' || cleanData == '44') {
      final cleared = cleanData == 'OK' || cleanData == '44';
      return {'cleared': cleared};
    }

    // PID-based parsing (Mode 01)
    final bytes = _hexToBytes(cleanData);
    if (bytes.length >= 3 && bytes[0] == 0x41) {
      final pid = bytes[1];

      switch (pid) {
        case 0x0C: // RPM
          if (bytes.length >= 4) {
            final a = bytes[2];
            final b = bytes[3];
            final rpm = ((a * 256 + b) / 4.0);
            return {
              'value': rpm,
              'unit': 'RPM',
              'description': 'Engine RPM',
            };
          }
          break;

        case 0x0D: // Speed
          final a = bytes[2];
          return {
            'value': a,
            'unit': 'km/h',
            'description': 'Vehicle Speed',
          };

        case 0x05: // Coolant Temp
          final a = bytes[2];
          return {
            'value': a - 40,
            'unit': '°C',
            'description': 'Engine Coolant Temperature',
          };

        case 0x0F: // Intake Air Temp
          final a = bytes[2];
          return {
            'value': a - 40,
            'unit': '°C',
            'description': 'Intake Air Temperature',
          };

        case 0x04: // Calculated Engine Load
          final a = bytes[2];
          final load = ((a * 100) / 255.0).round();
          return {
            'value': load,
            'unit': '%',
            'description': 'Calculated Engine Load',
          };

        case 0x11: // Throttle Position
          final a = bytes[2];
          final throttle = ((a * 100) / 255.0).round();
          return {
            'value': throttle,
            'unit': '%',
            'description': 'Throttle Position',
          };

        case 0x0A: // Fuel Pressure
          final a = bytes[2];
          final pressure = a * 3; // kPa
          return {
            'value': pressure,
            'unit': 'kPa',
            'description': 'Fuel Pressure',
          };

        case 0x0B: // Intake Manifold Pressure
          final a = bytes[2];
          return {
            'value': a,
            'unit': 'kPa',
            'description': 'Intake Manifold Pressure',
          };

        case 0x10: // MAF Air Flow Rate
          if (bytes.length >= 4) {
            final a = bytes[2];
            final b = bytes[3];
            final maf = ((a * 256) + b) / 100.0; // g/s
            return {
              'value': double.parse(maf.toStringAsFixed(2)),
              'unit': 'g/s',
              'description': 'MAF Air Flow Rate',
            };
          }
          break;

        default:
          // Unknown PID: return raw hex
          return {'raw_hex': cleanData};
      }
    }

    // Fallback: provide raw hex
    return {'raw_hex': cleanData};
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