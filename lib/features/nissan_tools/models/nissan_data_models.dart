/// Nissan-specific data models

class NissanLiveData {
  final double? cvtTransmissionTemperature;
  final double? cvtFluidPressure;
  final double? cvtPulleyRatio;
  final Map<String, dynamic>? proPilotAssistStatus;
  final Map<String, dynamic>? ePowerSystemStatus;
  final Map<String, dynamic>? intelligentAwdStatus;
  final Map<String, dynamic>? variableCompressionRatio;
  final Map<String, dynamic>? zoneBodyConstructionData;
  final Map<String, dynamic>? intelligentCruiseControl;
  final Map<String, dynamic>? aroundViewMonitorStatus;
  final bool? intelligentEmergencyBraking;
  final bool? blindSpotWarningStatus;
  final bool? laneDepartureWarning;
  final Map<String, dynamic>? intelligentForwardCollision;
  final bool? rearCrossTrafficAlert;
  final double? cvtHealthScore;
  final double? proPilotSystemReadiness;
  final double? ePowerEfficiency;

  const NissanLiveData({
    this.cvtTransmissionTemperature,
    this.cvtFluidPressure,
    this.cvtPulleyRatio,
    this.proPilotAssistStatus,
    this.ePowerSystemStatus,
    this.intelligentAwdStatus,
    this.variableCompressionRatio,
    this.zoneBodyConstructionData,
    this.intelligentCruiseControl,
    this.aroundViewMonitorStatus,
    this.intelligentEmergencyBraking,
    this.blindSpotWarningStatus,
    this.laneDepartureWarning,
    this.intelligentForwardCollision,
    this.rearCrossTrafficAlert,
    this.cvtHealthScore,
    this.proPilotSystemReadiness,
    this.ePowerEfficiency,
  });

  factory NissanLiveData.fromMap(Map<String, dynamic> map) {
    return NissanLiveData(
      cvtTransmissionTemperature: map['CVT Transmission Temperature']?.toDouble(),
      cvtFluidPressure: map['CVT Fluid Pressure']?.toDouble(),
      cvtPulleyRatio: map['CVT Pulley Ratio']?.toDouble(),
      proPilotAssistStatus: map['ProPILOT Assist Status'],
      ePowerSystemStatus: map['e-POWER System Status'],
      intelligentAwdStatus: map['Intelligent AWD Status'],
      variableCompressionRatio: map['Variable Compression Ratio'],
      zoneBodyConstructionData: map['Zone Body Construction Data'],
      intelligentCruiseControl: map['Intelligent Cruise Control'],
      aroundViewMonitorStatus: map['Around View Monitor Status'],
      intelligentEmergencyBraking: map['Intelligent Emergency Braking'],
      blindSpotWarningStatus: map['Blind Spot Warning Status'],
      laneDepartureWarning: map['Lane Departure Warning'],
      intelligentForwardCollision: map['Intelligent Forward Collision'],
      rearCrossTrafficAlert: map['Rear Cross Traffic Alert'],
      cvtHealthScore: map['CVT Health Score']?.toDouble(),
      proPilotSystemReadiness: map['ProPILOT System Readiness']?.toDouble(),
      ePowerEfficiency: map['e-POWER Efficiency']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CVT Transmission Temperature': cvtTransmissionTemperature,
      'CVT Fluid Pressure': cvtFluidPressure,
      'CVT Pulley Ratio': cvtPulleyRatio,
      'ProPILOT Assist Status': proPilotAssistStatus,
      'e-POWER System Status': ePowerSystemStatus,
      'Intelligent AWD Status': intelligentAwdStatus,
      'Variable Compression Ratio': variableCompressionRatio,
      'Zone Body Construction Data': zoneBodyConstructionData,
      'Intelligent Cruise Control': intelligentCruiseControl,
      'Around View Monitor Status': aroundViewMonitorStatus,
      'Intelligent Emergency Braking': intelligentEmergencyBraking,
      'Blind Spot Warning Status': blindSpotWarningStatus,
      'Lane Departure Warning': laneDepartureWarning,
      'Intelligent Forward Collision': intelligentForwardCollision,
      'Rear Cross Traffic Alert': rearCrossTrafficAlert,
      'CVT Health Score': cvtHealthScore,
      'ProPILOT System Readiness': proPilotSystemReadiness,
      'e-POWER Efficiency': ePowerEfficiency,
    };
  }

  NissanLiveData copyWith({
    double? cvtTransmissionTemperature,
    double? cvtFluidPressure,
    double? cvtPulleyRatio,
    Map<String, dynamic>? proPilotAssistStatus,
    Map<String, dynamic>? ePowerSystemStatus,
    Map<String, dynamic>? intelligentAwdStatus,
    Map<String, dynamic>? variableCompressionRatio,
    Map<String, dynamic>? zoneBodyConstructionData,
    Map<String, dynamic>? intelligentCruiseControl,
    Map<String, dynamic>? aroundViewMonitorStatus,
    bool? intelligentEmergencyBraking,
    bool? blindSpotWarningStatus,
    bool? laneDepartureWarning,
    Map<String, dynamic>? intelligentForwardCollision,
    bool? rearCrossTrafficAlert,
    double? cvtHealthScore,
    double? proPilotSystemReadiness,
    double? ePowerEfficiency,
  }) {
    return NissanLiveData(
      cvtTransmissionTemperature: cvtTransmissionTemperature ?? this.cvtTransmissionTemperature,
      cvtFluidPressure: cvtFluidPressure ?? this.cvtFluidPressure,
      cvtPulleyRatio: cvtPulleyRatio ?? this.cvtPulleyRatio,
      proPilotAssistStatus: proPilotAssistStatus ?? this.proPilotAssistStatus,
      ePowerSystemStatus: ePowerSystemStatus ?? this.ePowerSystemStatus,
      intelligentAwdStatus: intelligentAwdStatus ?? this.intelligentAwdStatus,
      variableCompressionRatio: variableCompressionRatio ?? this.variableCompressionRatio,
      zoneBodyConstructionData: zoneBodyConstructionData ?? this.zoneBodyConstructionData,
      intelligentCruiseControl: intelligentCruiseControl ?? this.intelligentCruiseControl,
      aroundViewMonitorStatus: aroundViewMonitorStatus ?? this.aroundViewMonitorStatus,
      intelligentEmergencyBraking: intelligentEmergencyBraking ?? this.intelligentEmergencyBraking,
      blindSpotWarningStatus: blindSpotWarningStatus ?? this.blindSpotWarningStatus,
      laneDepartureWarning: laneDepartureWarning ?? this.laneDepartureWarning,
      intelligentForwardCollision: intelligentForwardCollision ?? this.intelligentForwardCollision,
      rearCrossTrafficAlert: rearCrossTrafficAlert ?? this.rearCrossTrafficAlert,
      cvtHealthScore: cvtHealthScore ?? this.cvtHealthScore,
      proPilotSystemReadiness: proPilotSystemReadiness ?? this.proPilotSystemReadiness,
      ePowerEfficiency: ePowerEfficiency ?? this.ePowerEfficiency,
    );
  }
}

class NissanServiceTool {
  final String name;
  final String description;
  final String icon;
  final Map<String, dynamic>? parameters;

  const NissanServiceTool({
    required this.name,
    required this.description,
    required this.icon,
    this.parameters,
  });

  factory NissanServiceTool.fromMap(Map<String, dynamic> map) {
    return NissanServiceTool(
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

class NissanServiceResult {
  final String toolName;
  final bool success;
  final Map<String, dynamic> data;
  final String? errorMessage;
  final DateTime timestamp;

  const NissanServiceResult({
    required this.toolName,
    required this.success,
    required this.data,
    this.errorMessage,
    required this.timestamp,
  });

  factory NissanServiceResult.fromMap(Map<String, dynamic> map) {
    return NissanServiceResult(
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

class NissanProgrammingOperation {
  final String ecuType;
  final String operation;
  final Map<String, dynamic> parameters;
  final bool requiresConsultMode;
  final int estimatedTimeMinutes;

  const NissanProgrammingOperation({
    required this.ecuType,
    required this.operation,
    required this.parameters,
    this.requiresConsultMode = true,
    this.estimatedTimeMinutes = 6,
  });

  factory NissanProgrammingOperation.fromMap(Map<String, dynamic> map) {
    return NissanProgrammingOperation(
      ecuType: map['ecuType'] ?? '',
      operation: map['operation'] ?? '',
      parameters: map['parameters'] ?? {},
      requiresConsultMode: map['requiresConsultMode'] ?? true,
      estimatedTimeMinutes: map['estimatedTimeMinutes'] ?? 6,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ecuType': ecuType,
      'operation': operation,
      'parameters': parameters,
      'requiresConsultMode': requiresConsultMode,
      'estimatedTimeMinutes': estimatedTimeMinutes,
    };
  }
}