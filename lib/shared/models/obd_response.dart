class OBDResponse {
  final String rawData;
  final String command;
  final DateTime timestamp;
  final bool isError;
  final String? errorMessage;
  final Map<String, dynamic>? parsedData;
  
  const OBDResponse({
    required this.rawData,
    required this.command,
    required this.timestamp,
    this.isError = false,
    this.errorMessage,
    this.parsedData,
  });
  
  factory OBDResponse.fromRaw(String raw, [String command = '']) {
    final timestamp = DateTime.now();
    final cleanedData = raw.trim().replaceAll('\r', '').replaceAll('\n', '');
    
    // Check for error responses
    if (cleanedData.contains('ERROR') || 
        cleanedData.contains('NO DATA') ||
        cleanedData.contains('?')) {
      return OBDResponse(
        rawData: cleanedData,
        command: command,
        timestamp: timestamp,
        isError: true,
        errorMessage: cleanedData,
      );
    }
    
    // Parse the response based on command type
    final parsedData = _parseResponse(cleanedData, command);
    
    return OBDResponse(
      rawData: cleanedData,
      command: command,
      timestamp: timestamp,
      parsedData: parsedData,
    );
  }
  
  static Map<String, dynamic>? _parseResponse(String data, String command) {
    try {
      // Remove spaces and convert to uppercase
      final cleanData = data.replaceAll(' ', '').toUpperCase();
      
      // Parse based on PID
      switch (command.toUpperCase()) {
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
        // TODO: Enhanced PID support - add more standard PIDs for comprehensive vehicle diagnostics
        case '0106': // Short term fuel trim—Bank 1
          return _parseFuelTrim(cleanData, 'Short term fuel trim—Bank 1');
        case '0107': // Long term fuel trim—Bank 1
          return _parseFuelTrim(cleanData, 'Long term fuel trim—Bank 1');
        case '0108': // Short term fuel trim—Bank 2
          return _parseFuelTrim(cleanData, 'Short term fuel trim—Bank 2');
        case '0109': // Long term fuel trim—Bank 2
          return _parseFuelTrim(cleanData, 'Long term fuel trim—Bank 2');
        case '010E': // Timing advance
          return _parseTimingAdvance(cleanData);
        case '011F': // Run time since engine start
          return _parseRunTime(cleanData);
        case '0103': // Fuel system status
          return _parseFuelSystemStatus(cleanData);
        case '0112': // Secondary air status
          return _parseSecondaryAirStatus(cleanData);
        case '011E': // Auxiliary input status
          return _parseAuxiliaryStatus(cleanData);
        default:
          return {'raw_hex': cleanData};
      }
    } catch (e) {
      return {'parse_error': e.toString()};
    }
  }
  
  static Map<String, dynamic> _parseRPM(String data) {
    if (data.length >= 8 && data.startsWith('410C')) {
      final a = int.parse(data.substring(4, 6), radix: 16);
      final b = int.parse(data.substring(6, 8), radix: 16);
      final rpm = ((a * 256) + b) / 4;
      return {
        'value': rpm,
        'unit': 'RPM',
        'description': 'Engine RPM',
      };
    }
    return {'error': 'Invalid RPM response'};
  }
  
  static Map<String, dynamic> _parseSpeed(String data) {
    if (data.length >= 6 && data.startsWith('410D')) {
      final speed = int.parse(data.substring(4, 6), radix: 16);
      return {
        'value': speed,
        'unit': 'km/h',
        'description': 'Vehicle Speed',
      };
    }
    return {'error': 'Invalid speed response'};
  }
  
  static Map<String, dynamic> _parseTemperature(String data) {
    if (data.length >= 6 && data.startsWith('4105')) {
      final temp = int.parse(data.substring(4, 6), radix: 16) - 40;
      return {
        'value': temp,
        'unit': '°C',
        'description': 'Engine Coolant Temperature',
      };
    }
    return {'error': 'Invalid temperature response'};
  }
  
  static Map<String, dynamic> _parseIntakeTemp(String data) {
    if (data.length >= 6 && data.startsWith('410F')) {
      final temp = int.parse(data.substring(4, 6), radix: 16) - 40;
      return {
        'value': temp,
        'unit': '°C',
        'description': 'Intake Air Temperature',
      };
    }
    return {'error': 'Invalid intake temperature response'};
  }
  
  static Map<String, dynamic> _parseEngineLoad(String data) {
    if (data.length >= 6 && data.startsWith('4104')) {
      final load = (int.parse(data.substring(4, 6), radix: 16) * 100) / 255;
      return {
        'value': load.round(),
        'unit': '%',
        'description': 'Calculated Engine Load',
      };
    }
    return {'error': 'Invalid engine load response'};
  }
  
  static Map<String, dynamic> _parseThrottlePosition(String data) {
    if (data.length >= 6 && data.startsWith('4111')) {
      final position = (int.parse(data.substring(4, 6), radix: 16) * 100) / 255;
      return {
        'value': position.round(),
        'unit': '%',
        'description': 'Throttle Position',
      };
    }
    return {'error': 'Invalid throttle position response'};
  }
  
  static Map<String, dynamic> _parseFuelPressure(String data) {
    if (data.length >= 6 && data.startsWith('410A')) {
      final pressure = int.parse(data.substring(4, 6), radix: 16) * 3;
      return {
        'value': pressure,
        'unit': 'kPa',
        'description': 'Fuel Pressure',
      };
    }
    return {'error': 'Invalid fuel pressure response'};
  }
  
  static Map<String, dynamic> _parseManifoldPressure(String data) {
    if (data.length >= 6 && data.startsWith('410B')) {
      final pressure = int.parse(data.substring(4, 6), radix: 16);
      return {
        'value': pressure,
        'unit': 'kPa',
        'description': 'Intake Manifold Pressure',
      };
    }
    return {'error': 'Invalid manifold pressure response'};
  }
  
  static Map<String, dynamic> _parseMAF(String data) {
    if (data.length >= 8 && data.startsWith('4110')) {
      final a = int.parse(data.substring(4, 6), radix: 16);
      final b = int.parse(data.substring(6, 8), radix: 16);
      final maf = ((a * 256) + b) / 100;
      return {
        'value': maf,
        'unit': 'g/s',
        'description': 'MAF Air Flow Rate',
      };
    }
    return {'error': 'Invalid MAF response'};
  }
  
  // TODO: Enhanced PID parsing functions for comprehensive vehicle diagnostics
  static Map<String, dynamic> _parseFuelTrim(String data, String description) {
    if (data.length >= 6 && data.startsWith('41')) {
      final value = int.parse(data.substring(4, 6), radix: 16);
      final trim = (value - 128) * 100 / 128;
      return {
        'value': trim.round(),
        'unit': '%',
        'description': description,
      };
    }
    return {'error': 'Invalid fuel trim response'};
  }
  
  static Map<String, dynamic> _parseTimingAdvance(String data) {
    if (data.length >= 6 && data.startsWith('410E')) {
      final value = int.parse(data.substring(4, 6), radix: 16);
      final advance = (value - 128) / 2;
      return {
        'value': advance,
        'unit': '°',
        'description': 'Timing advance',
      };
    }
    return {'error': 'Invalid timing advance response'};
  }
  
  static Map<String, dynamic> _parseRunTime(String data) {
    if (data.length >= 8 && data.startsWith('411F')) {
      final a = int.parse(data.substring(4, 6), radix: 16);
      final b = int.parse(data.substring(6, 8), radix: 16);
      final runtime = (a * 256) + b;
      return {
        'value': runtime,
        'unit': 's',
        'description': 'Run time since engine start',
      };
    }
    return {'error': 'Invalid runtime response'};
  }
  
  static Map<String, dynamic> _parseFuelSystemStatus(String data) {
    if (data.length >= 6 && data.startsWith('4103')) {
      final status = int.parse(data.substring(4, 6), radix: 16);
      String statusText;
      switch (status & 0x0F) {
        case 1:
          statusText = 'Open loop due to insufficient engine temperature';
          break;
        case 2:
          statusText = 'Closed loop, using oxygen sensor feedback';
          break;
        case 4:
          statusText = 'Open loop due to engine load OR fuel cut due to deceleration';
          break;
        case 8:
          statusText = 'Open loop due to system failure';
          break;
        default:
          statusText = 'Unknown status';
      }
      return {
        'value': status,
        'status_text': statusText,
        'unit': '',
        'description': 'Fuel system status',
      };
    }
    return {'error': 'Invalid fuel system status response'};
  }
  
  static Map<String, dynamic> _parseSecondaryAirStatus(String data) {
    if (data.length >= 6 && data.startsWith('4112')) {
      final status = int.parse(data.substring(4, 6), radix: 16);
      String statusText;
      switch (status) {
        case 1:
          statusText = 'Upstream';
          break;
        case 2:
          statusText = 'Downstream of catalytic converter';
          break;
        case 4:
          statusText = 'From the outside atmosphere or off';
          break;
        case 8:
          statusText = 'Pump commanded on for diagnostics';
          break;
        default:
          statusText = 'Not supported';
      }
      return {
        'value': status,
        'status_text': statusText,
        'unit': '',
        'description': 'Secondary air status',
      };
    }
    return {'error': 'Invalid secondary air status response'};
  }
  
  static Map<String, dynamic> _parseAuxiliaryStatus(String data) {
    if (data.length >= 6 && data.startsWith('411E')) {
      final status = int.parse(data.substring(4, 6), radix: 16);
      final isPtoActive = (status & 0x01) != 0;
      return {
        'value': status,
        'pto_active': isPtoActive,
        'unit': '',
        'description': 'Auxiliary input status',
      };
    }
    return {'error': 'Invalid auxiliary status response'};
  }
  
  Map<String, dynamic> toJson() {
    return {
      'rawData': rawData,
      'command': command,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
      'errorMessage': errorMessage,
      'parsedData': parsedData,
    };
  }
  
  factory OBDResponse.fromJson(Map<String, dynamic> json) {
    return OBDResponse(
      rawData: json['rawData'] as String,
      command: json['command'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      parsedData: json['parsedData'] as Map<String, dynamic>?,
    );
  }
  
  @override
  String toString() {
    if (isError) {
      return 'OBDResponse(ERROR: $errorMessage)';
    }
    return 'OBDResponse(command: $command, data: $parsedData)';
  }
}