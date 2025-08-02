/// VW-specific data models

class VWLiveData {
  final double? dsgTransmissionTemperature;
  final Map<String, dynamic>? dsgClutchStatus;
  final Map<String, dynamic>? quattroAwdStatus;
  final double? adBlueLevel;
  final Map<String, dynamic>? dpfRegenerationStatus;
  final double? turboWastegatePosition;
  final double? egrValvePosition;
  final Map<String, dynamic>? airSuspensionHeight;
  final Map<String, dynamic>? adaptiveDampingControl;
  final Map<String, dynamic>? trafficSignRecognition;
  final bool? laneAssistStatus;
  final Map<String, dynamic>? parkingAssistStatus;
  final bool? startStopSystemStatus;
  final Map<String, dynamic>? batteryManagementSystem;
  final Map<String, dynamic>? infotainmentSystemStatus;
  final double? dsgHealthScore;
  final double? awdSystemEfficiency;
  final double? adBlueServiceRange;

  const VWLiveData({
    this.dsgTransmissionTemperature,
    this.dsgClutchStatus,
    this.quattroAwdStatus,
    this.adBlueLevel,
    this.dpfRegenerationStatus,
    this.turboWastegatePosition,
    this.egrValvePosition,
    this.airSuspensionHeight,
    this.adaptiveDampingControl,
    this.trafficSignRecognition,
    this.laneAssistStatus,
    this.parkingAssistStatus,
    this.startStopSystemStatus,
    this.batteryManagementSystem,
    this.infotainmentSystemStatus,
    this.dsgHealthScore,
    this.awdSystemEfficiency,
    this.adBlueServiceRange,
  });

  factory VWLiveData.fromMap(Map<String, dynamic> map) {
    return VWLiveData(
      dsgTransmissionTemperature: map['DSG Transmission Temperature']?.toDouble(),
      dsgClutchStatus: map['DSG Clutch Status'],
      quattroAwdStatus: map['Quattro AWD Status'],
      adBlueLevel: map['AdBlue/DEF Level']?.toDouble(),
      dpfRegenerationStatus: map['DPF Regeneration Status'],
      turboWastegatePosition: map['Turbo Wastegate Position']?.toDouble(),
      egrValvePosition: map['EGR Valve Position']?.toDouble(),
      airSuspensionHeight: map['Air Suspension Height'],
      adaptiveDampingControl: map['Adaptive Damping Control'],
      trafficSignRecognition: map['Traffic Sign Recognition'],
      laneAssistStatus: map['Lane Assist Status'],
      parkingAssistStatus: map['Parking Assist Status'],
      startStopSystemStatus: map['Start/Stop System Status'],
      batteryManagementSystem: map['Battery Management System'],
      infotainmentSystemStatus: map['Infotainment System Status'],
      dsgHealthScore: map['DSG Health Score']?.toDouble(),
      awdSystemEfficiency: map['AWD System Efficiency']?.toDouble(),
      adBlueServiceRange: map['AdBlue Service Range']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'DSG Transmission Temperature': dsgTransmissionTemperature,
      'DSG Clutch Status': dsgClutchStatus,
      'Quattro AWD Status': quattroAwdStatus,
      'AdBlue/DEF Level': adBlueLevel,
      'DPF Regeneration Status': dpfRegenerationStatus,
      'Turbo Wastegate Position': turboWastegatePosition,
      'EGR Valve Position': egrValvePosition,
      'Air Suspension Height': airSuspensionHeight,
      'Adaptive Damping Control': adaptiveDampingControl,
      'Traffic Sign Recognition': trafficSignRecognition,
      'Lane Assist Status': laneAssistStatus,
      'Parking Assist Status': parkingAssistStatus,
      'Start/Stop System Status': startStopSystemStatus,
      'Battery Management System': batteryManagementSystem,
      'Infotainment System Status': infotainmentSystemStatus,
      'DSG Health Score': dsgHealthScore,
      'AWD System Efficiency': awdSystemEfficiency,
      'AdBlue Service Range': adBlueServiceRange,
    };
  }

  VWLiveData copyWith({
    double? dsgTransmissionTemperature,
    Map<String, dynamic>? dsgClutchStatus,
    Map<String, dynamic>? quattroAwdStatus,
    double? adBlueLevel,
    Map<String, dynamic>? dpfRegenerationStatus,
    double? turboWastegatePosition,
    double? egrValvePosition,
    Map<String, dynamic>? airSuspensionHeight,
    Map<String, dynamic>? adaptiveDampingControl,
    Map<String, dynamic>? trafficSignRecognition,
    bool? laneAssistStatus,
    Map<String, dynamic>? parkingAssistStatus,
    bool? startStopSystemStatus,
    Map<String, dynamic>? batteryManagementSystem,
    Map<String, dynamic>? infotainmentSystemStatus,
    double? dsgHealthScore,
    double? awdSystemEfficiency,
    double? adBlueServiceRange,
  }) {
    return VWLiveData(
      dsgTransmissionTemperature: dsgTransmissionTemperature ?? this.dsgTransmissionTemperature,
      dsgClutchStatus: dsgClutchStatus ?? this.dsgClutchStatus,
      quattroAwdStatus: quattroAwdStatus ?? this.quattroAwdStatus,
      adBlueLevel: adBlueLevel ?? this.adBlueLevel,
      dpfRegenerationStatus: dpfRegenerationStatus ?? this.dpfRegenerationStatus,
      turboWastegatePosition: turboWastegatePosition ?? this.turboWastegatePosition,
      egrValvePosition: egrValvePosition ?? this.egrValvePosition,
      airSuspensionHeight: airSuspensionHeight ?? this.airSuspensionHeight,
      adaptiveDampingControl: adaptiveDampingControl ?? this.adaptiveDampingControl,
      trafficSignRecognition: trafficSignRecognition ?? this.trafficSignRecognition,
      laneAssistStatus: laneAssistStatus ?? this.laneAssistStatus,
      parkingAssistStatus: parkingAssistStatus ?? this.parkingAssistStatus,
      startStopSystemStatus: startStopSystemStatus ?? this.startStopSystemStatus,
      batteryManagementSystem: batteryManagementSystem ?? this.batteryManagementSystem,
      infotainmentSystemStatus: infotainmentSystemStatus ?? this.infotainmentSystemStatus,
      dsgHealthScore: dsgHealthScore ?? this.dsgHealthScore,
      awdSystemEfficiency: awdSystemEfficiency ?? this.awdSystemEfficiency,
      adBlueServiceRange: adBlueServiceRange ?? this.adBlueServiceRange,
    );
  }
}

class VWServiceTool {
  final String name;
  final String description;
  final String icon;
  final Map<String, dynamic>? parameters;

  const VWServiceTool({
    required this.name,
    required this.description,
    required this.icon,
    this.parameters,
  });

  factory VWServiceTool.fromMap(Map<String, dynamic> map) {
    return VWServiceTool(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      parameters: map['parameters'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'parameters': parameters,
    };
  }
}

class VWServiceResult {
  final String toolName;
  final bool success;
  final Map<String, dynamic> data;
  final String? errorMessage;
  final DateTime timestamp;

  const VWServiceResult({
    required this.toolName,
    required this.success,
    required this.data,
    this.errorMessage,
    required this.timestamp,
  });

  factory VWServiceResult.fromMap(Map<String, dynamic> map) {
    return VWServiceResult(
      toolName: map['toolName'] ?? '',
      success: map['success'] ?? false,
      data: map['data'] ?? {},
      errorMessage: map['errorMessage'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toolName': toolName,
      'success': success,
      'data': data,
      'errorMessage': errorMessage,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class VWProgrammingOperation {
  final String ecuType;
  final String operation;
  final Map<String, dynamic> parameters;
  final bool requiresSecurityAccess;
  final int estimatedTimeMinutes;

  const VWProgrammingOperation({
    required this.ecuType,
    required this.operation,
    required this.parameters,
    this.requiresSecurityAccess = true,
    this.estimatedTimeMinutes = 5,
  });

  factory VWProgrammingOperation.fromMap(Map<String, dynamic> map) {
    return VWProgrammingOperation(
      ecuType: map['ecuType'] ?? '',
      operation: map['operation'] ?? '',
      parameters: map['parameters'] ?? {},
      requiresSecurityAccess: map['requiresSecurityAccess'] ?? true,
      estimatedTimeMinutes: map['estimatedTimeMinutes'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ecuType': ecuType,
      'operation': operation,
      'parameters': parameters,
      'requiresSecurityAccess': requiresSecurityAccess,
      'estimatedTimeMinutes': estimatedTimeMinutes,
    };
  }
}