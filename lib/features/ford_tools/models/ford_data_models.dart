/// Ford-specific data models

class FordLiveData {
  final double? turboBoostPressure;
  final double? egrValvePosition;
  final double? defLevel;
  final double? transmissionTemperature;
  final String? syncSystemStatus;
  final bool? adaptiveCruiseControl;
  final bool? laneKeepingAssist;
  final Map<String, dynamic>? ecoBoostData;
  final String? fourWdStatus;
  final Map<String, dynamic>? trailerBrakeStatus;
  final double? ecoBoostEfficiency;
  final double? transmissionHealthScore;

  const FordLiveData({
    this.turboBoostPressure,
    this.egrValvePosition,
    this.defLevel,
    this.transmissionTemperature,
    this.syncSystemStatus,
    this.adaptiveCruiseControl,
    this.laneKeepingAssist,
    this.ecoBoostData,
    this.fourWdStatus,
    this.trailerBrakeStatus,
    this.ecoBoostEfficiency,
    this.transmissionHealthScore,
  });

  factory FordLiveData.fromMap(Map<String, dynamic> map) {
    return FordLiveData(
      turboBoostPressure: map['Turbo Boost Pressure']?.toDouble(),
      egrValvePosition: map['EGR Valve Position']?.toDouble(),
      defLevel: map['DEF Level']?.toDouble(),
      transmissionTemperature: map['Transmission Temperature']?.toDouble(),
      syncSystemStatus: map['SYNC System Status'],
      adaptiveCruiseControl: map['Adaptive Cruise Control'],
      laneKeepingAssist: map['Lane Keeping Assist'],
      ecoBoostData: map['EcoBoost Performance Data'],
      fourWdStatus: map['4WD Status'],
      trailerBrakeStatus: map['Trailer Brake Controller'],
      ecoBoostEfficiency: map['EcoBoost Efficiency']?.toDouble(),
      transmissionHealthScore: map['Transmission Health Score']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Turbo Boost Pressure': turboBoostPressure,
      'EGR Valve Position': egrValvePosition,
      'DEF Level': defLevel,
      'Transmission Temperature': transmissionTemperature,
      'SYNC System Status': syncSystemStatus,
      'Adaptive Cruise Control': adaptiveCruiseControl,
      'Lane Keeping Assist': laneKeepingAssist,
      'EcoBoost Performance Data': ecoBoostData,
      '4WD Status': fourWdStatus,
      'Trailer Brake Controller': trailerBrakeStatus,
      'EcoBoost Efficiency': ecoBoostEfficiency,
      'Transmission Health Score': transmissionHealthScore,
    };
  }
}

class FordServiceToolResult {
  final String toolName;
  final bool success;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? errorMessage;

  const FordServiceToolResult({
    required this.toolName,
    required this.success,
    required this.data,
    required this.timestamp,
    this.errorMessage,
  });

  factory FordServiceToolResult.success({
    required String toolName,
    required Map<String, dynamic> data,
  }) {
    return FordServiceToolResult(
      toolName: toolName,
      success: true,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  factory FordServiceToolResult.failure({
    required String toolName,
    required String errorMessage,
  }) {
    return FordServiceToolResult(
      toolName: toolName,
      success: false,
      data: {},
      timestamp: DateTime.now(),
      errorMessage: errorMessage,
    );
  }
}

class FordProgrammingOperation {
  final String ecuType;
  final String operation;
  final Map<String, dynamic> parameters;
  final bool requiresSecurityAccess;
  final Duration estimatedDuration;

  const FordProgrammingOperation({
    required this.ecuType,
    required this.operation,
    required this.parameters,
    this.requiresSecurityAccess = true,
    this.estimatedDuration = const Duration(minutes: 5),
  });

  static const List<String> supportedEcuTypes = [
    'PCM', 'TCM', 'BCM', 'SYNC', 'ABS', 'HVAC'
  ];

  static const List<String> supportedOperations = [
    'flash', 'calibration', 'configuration', 'reset'
  ];

  bool get isValid {
    return supportedEcuTypes.contains(ecuType) && 
           supportedOperations.contains(operation.toLowerCase());
  }
}