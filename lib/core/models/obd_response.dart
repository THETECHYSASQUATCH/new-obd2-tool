import 'dart:convert';
import 'dart:typed_data';

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
      status: ResponseStatus.values.byName(json['status']),
      parsedData: json['parsedData'] as Map<String, dynamic>? ?? {},
      errorMessage: json['errorMessage'] as String?,
      responseTime: (json['responseTime'] as num?)?.toDouble(),
      protocol: json['protocol'] as String?,
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
  
  /// Get value from parsed data with type casting
  T? getValue<T>(String key) {
    final value = parsedData[key];
    if (value is T) return value;
    return null;
  }

  /// Get a numeric value and convert to double
  double? getNumericValue(String key) {
    final value = parsedData[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'OBDResponse(command: $command, status: $status, timestamp: $timestamp)';
  }
}

class PIDDefinition {
  final String pid;
  final String name;
  final String description;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final String? formula;
  final PIDType type;
  final List<String> supportedProtocols;
  final Map<String, dynamic> metadata;

  const PIDDefinition({
    required this.pid,
    required this.name,
    required this.description,
    required this.unit,
    this.minValue,
    this.maxValue,
    this.formula,
    this.type = PIDType.numeric,
    this.supportedProtocols = const [],
    this.metadata = const {},
  });

  factory PIDDefinition.fromJson(Map<String, dynamic> json) {
    return PIDDefinition(
      pid: json['pid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      unit: json['unit'] as String,
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      formula: json['formula'] as String?,
      type: PIDType.values.byName(json['type'] ?? 'numeric'),
      supportedProtocols: List<String>.from(json['supportedProtocols'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'description': description,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
      'formula': formula,
      'type': type.name,
      'supportedProtocols': supportedProtocols,
      'metadata': metadata,
    };
  }

  /// Parse raw hex response data according to this PID definition
  dynamic parseResponse(String hexData) {
    switch (type) {
      case PIDType.numeric:
        return _parseNumericResponse(hexData);
      case PIDType.bitfield:
        return _parseBitfieldResponse(hexData);
      case PIDType.string:
        return _parseStringResponse(hexData);
      case PIDType.enum_:
        return _parseEnumResponse(hexData);
    }
  }

  double? _parseNumericResponse(String hexData) {
    try {
      if (hexData.isEmpty) return null;
      
      // Remove spaces and convert to uppercase
      final cleanHex = hexData.replaceAll(' ', '').toUpperCase();
      
      // Convert hex to integer
      final intValue = int.parse(cleanHex, radix: 16);
      
      // Apply formula if provided
      if (formula != null) {
        // Simple formula parsing for common cases
        // This is a simplified implementation
        if (formula!.contains('x')) {
          final formulaExpression = formula!.replaceAll('x', intValue.toString());
          // In a real implementation, you'd use a proper expression evaluator
          return double.tryParse(formulaExpression);
        }
      }
      
      return intValue.toDouble();
    } catch (e) {
      return null;
    }
  }

  Map<String, bool>? _parseBitfieldResponse(String hexData) {
    try {
      final intValue = int.parse(hexData.replaceAll(' ', ''), radix: 16);
      final result = <String, bool>{};
      
      // Parse bits based on metadata configuration
      final bitDefinitions = metadata['bits'] as Map<String, dynamic>?;
      if (bitDefinitions != null) {
        for (final entry in bitDefinitions.entries) {
          final bitPosition = entry.value as int;
          result[entry.key] = (intValue & (1 << bitPosition)) != 0;
        }
      }
      
      return result;
    } catch (e) {
      return null;
    }
  }

  String? _parseStringResponse(String hexData) {
    try {
      final bytes = <int>[];
      for (int i = 0; i < hexData.length; i += 2) {
        final hex = hexData.substring(i, i + 2);
        bytes.add(int.parse(hex, radix: 16));
      }
      return String.fromCharCodes(bytes);
    } catch (e) {
      return null;
    }
  }

  String? _parseEnumResponse(String hexData) {
    try {
      final intValue = int.parse(hexData.replaceAll(' ', ''), radix: 16);
      final enumValues = metadata['values'] as Map<String, dynamic>?;
      if (enumValues != null) {
        return enumValues[intValue.toString()] as String?;
      }
      return intValue.toString();
    } catch (e) {
      return null;
    }
  }
}

class DTCCode {
  final String code;
  final String description;
  final DTCStatus status;
  final DateTime? timestamp;
  final String? location;
  final int? priority;
  final Map<String, dynamic> metadata;

  const DTCCode({
    required this.code,
    required this.description,
    required this.status,
    this.timestamp,
    this.location,
    this.priority,
    this.metadata = const {},
  });

  factory DTCCode.fromJson(Map<String, dynamic> json) {
    return DTCCode(
      code: json['code'] as String,
      description: json['description'] as String,
      status: DTCStatus.values.byName(json['status']),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : null,
      location: json['location'] as String?,
      priority: json['priority'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'status': status.name,
      'timestamp': timestamp?.toIso8601String(),
      'location': location,
      'priority': priority,
      'metadata': metadata,
    };
  }

  bool get isActive => status == DTCStatus.active;
  bool get isPending => status == DTCStatus.pending;
  bool get isStored => status == DTCStatus.stored;
}

enum ResponseStatus {
  success,
  error,
  timeout,
  noData,
  unsupported,
}

enum PIDType {
  numeric,
  bitfield,
  string,
  enum_,
}

enum DTCStatus {
  active,
  pending,
  stored,
  cleared,
}

extension ResponseStatusExtension on ResponseStatus {
  String get displayName {
    switch (this) {
      case ResponseStatus.success:
        return 'Success';
      case ResponseStatus.error:
        return 'Error';
      case ResponseStatus.timeout:
        return 'Timeout';
      case ResponseStatus.noData:
        return 'No Data';
      case ResponseStatus.unsupported:
        return 'Unsupported';
    }
  }
}

extension DTCStatusExtension on DTCStatus {
  String get displayName {
    switch (this) {
      case DTCStatus.active:
        return 'Active';
      case DTCStatus.pending:
        return 'Pending';
      case DTCStatus.stored:
        return 'Stored';
      case DTCStatus.cleared:
        return 'Cleared';
    }
  }
}