/// GM-specific data models

class GMLiveData {
  final bool? afmCylinderDeactivation;
  final double? transmissionAdaptivePressure;
  final Map<String, dynamic>? dfmDynamicFuelManagement;
  final Map<String, dynamic>? magneticRideControl;
  final Map<String, dynamic>? z51PerformanceData;
  final String? fourWdStatus;
  final Map<String, dynamic>? trailerBrakeController;
  final Map<String, dynamic>? superCruiseStatus;
  final double? airSuspensionHeight;
  final double? superchargerBoostPressure;
  final bool? launchControlStatus;
  final Map<String, dynamic>? trackModeData;
  final Map<String, dynamic>? carbonFiberBedData;
  final Map<String, dynamic>? multiProTailgateStatus;
  final Map<String, dynamic>? at4OffRoadData;
  final double? fuelManagementEfficiency;
  final double? suspensionPerformanceScore;
  final double? superCruiseReadiness;

  const GMLiveData({
    this.afmCylinderDeactivation,
    this.transmissionAdaptivePressure,
    this.dfmDynamicFuelManagement,
    this.magneticRideControl,
    this.z51PerformanceData,
    this.fourWdStatus,
    this.trailerBrakeController,
    this.superCruiseStatus,
    this.airSuspensionHeight,
    this.superchargerBoostPressure,
    this.launchControlStatus,
    this.trackModeData,
    this.carbonFiberBedData,
    this.multiProTailgateStatus,
    this.at4OffRoadData,
    this.fuelManagementEfficiency,
    this.suspensionPerformanceScore,
    this.superCruiseReadiness,
  });

  factory GMLiveData.fromMap(Map<String, dynamic> map) {
    return GMLiveData(
      afmCylinderDeactivation: map['AFM Cylinder Deactivation Status'],
      transmissionAdaptivePressure: map['Transmission Adaptive Pressure']?.toDouble(),
      dfmDynamicFuelManagement: map['DFM Dynamic Fuel Management'],
      magneticRideControl: map['Magnetic Ride Control Status'],
      z51PerformanceData: map['Z51 Performance Package Data'],
      fourWdStatus: map['4WD Transfer Case Status'],
      trailerBrakeController: map['Trailer Brake Controller'],
      superCruiseStatus: map['Super Cruise Status'],
      airSuspensionHeight: map['Air Suspension Height']?.toDouble(),
      superchargerBoostPressure: map['Supercharger Boost Pressure']?.toDouble(),
      launchControlStatus: map['Launch Control Status'],
      trackModeData: map['Track Mode Data'],
      carbonFiberBedData: map['Carbon Fiber Bed Data'],
      multiProTailgateStatus: map['MultiPro Tailgate Status'],
      at4OffRoadData: map['AT4 Off-Road Mode Data'],
      fuelManagementEfficiency: map['Fuel Management Efficiency']?.toDouble(),
      suspensionPerformanceScore: map['Suspension Performance Score']?.toDouble(),
      superCruiseReadiness: map['Super Cruise Readiness']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AFM Cylinder Deactivation Status': afmCylinderDeactivation,
      'Transmission Adaptive Pressure': transmissionAdaptivePressure,
      'DFM Dynamic Fuel Management': dfmDynamicFuelManagement,
      'Magnetic Ride Control Status': magneticRideControl,
      'Z51 Performance Package Data': z51PerformanceData,
      '4WD Transfer Case Status': fourWdStatus,
      'Trailer Brake Controller': trailerBrakeController,
      'Super Cruise Status': superCruiseStatus,
      'Air Suspension Height': airSuspensionHeight,
      'Supercharger Boost Pressure': superchargerBoostPressure,
      'Launch Control Status': launchControlStatus,
      'Track Mode Data': trackModeData,
      'Carbon Fiber Bed Data': carbonFiberBedData,
      'MultiPro Tailgate Status': multiProTailgateStatus,
      'AT4 Off-Road Mode Data': at4OffRoadData,
      'Fuel Management Efficiency': fuelManagementEfficiency,
      'Suspension Performance Score': suspensionPerformanceScore,
      'Super Cruise Readiness': superCruiseReadiness,
    };
  }
}

class GMServiceToolResult {
  final String toolName;
  final bool success;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? errorMessage;
  final String brand; // Chevrolet, Cadillac, GMC, etc.

  const GMServiceToolResult({
    required this.toolName,
    required this.success,
    required this.data,
    required this.timestamp,
    this.errorMessage,
    required this.brand,
  });

  factory GMServiceToolResult.success({
    required String toolName,
    required Map<String, dynamic> data,
    required String brand,
  }) {
    return GMServiceToolResult(
      toolName: toolName,
      success: true,
      data: data,
      timestamp: DateTime.now(),
      brand: brand,
    );
  }

  factory GMServiceToolResult.failure({
    required String toolName,
    required String errorMessage,
    required String brand,
  }) {
    return GMServiceToolResult(
      toolName: toolName,
      success: false,
      data: {},
      timestamp: DateTime.now(),
      errorMessage: errorMessage,
      brand: brand,
    );
  }
}

class GMProgrammingOperation {
  final String ecuType;
  final String operation;
  final Map<String, dynamic> parameters;
  final bool requiresSecurityAccess;
  final Duration estimatedDuration;
  final String brand;

  const GMProgrammingOperation({
    required this.ecuType,
    required this.operation,
    required this.parameters,
    this.requiresSecurityAccess = true,
    this.estimatedDuration = const Duration(minutes: 8),
    required this.brand,
  });

  static const List<String> supportedEcuTypes = [
    'ECM', 'TCM', 'BCM', 'SDM', 'EBCM', 'RCDLR'
  ];

  static const List<String> supportedOperations = [
    'flash', 'calibration', 'configuration', 'vin_write', 'reset'
  ];

  static const List<String> supportedBrands = [
    'Chevrolet', 'Cadillac', 'GMC', 'Buick'
  ];

  bool get isValid {
    return supportedEcuTypes.contains(ecuType) && 
           supportedOperations.contains(operation.toLowerCase()) &&
           supportedBrands.contains(brand);
  }
}

class GMBrandSpecificFeatures {
  final String brand;
  final List<String> availableTools;
  final List<String> specialFeatures;
  final Map<String, String> brandSpecificPids;

  const GMBrandSpecificFeatures({
    required this.brand,
    required this.availableTools,
    required this.specialFeatures,
    required this.brandSpecificPids,
  });

  static const Map<String, GMBrandSpecificFeatures> brandFeatures = {
    'Chevrolet': GMBrandSpecificFeatures(
      brand: 'Chevrolet',
      availableTools: [
        'AFM Disable',
        'DFM Calibration',
        'Performance Mode Setup',
        'Towing Package Configuration',
      ],
      specialFeatures: [
        'Active Fuel Management',
        'Dynamic Fuel Management',
        'Performance Data Recording',
        'Z51 Package Support',
      ],
      brandSpecificPids: {
        'GM01': 'AFM Cylinder Deactivation Status',
        'GM03': 'DFM Dynamic Fuel Management',
        'GM05': 'Z51 Performance Package Data',
      },
    ),
    'Cadillac': GMBrandSpecificFeatures(
      brand: 'Cadillac',
      availableTools: [
        'Super Cruise Update',
        'Magnetic Ride Calibration',
        'CUE System Configuration',
        'Night Vision Setup',
      ],
      specialFeatures: [
        'Super Cruise',
        'Magnetic Ride Control',
        'CUE Infotainment',
        'Night Vision',
        'Air Suspension',
      ],
      brandSpecificPids: {
        'GM08': 'Super Cruise Status',
        'GM09': 'Magnetic Ride Control',
        'GM10': 'Air Suspension Height',
        'GM11': 'Supercharger Boost Pressure',
      },
    ),
    'GMC': GMBrandSpecificFeatures(
      brand: 'GMC',
      availableTools: [
        'MultiPro Tailgate Service',
        'AT4 Off-Road Calibration',
        'ProGrade Trailering Setup',
        'Terrain Mode Configuration',
      ],
      specialFeatures: [
        'MultiPro Tailgate',
        'AT4 Off-Road Mode',
        'ProGrade Trailering',
        'Carbon Fiber Bed',
      ],
      brandSpecificPids: {
        'GM14': 'Carbon Fiber Bed Data',
        'GM15': 'MultiPro Tailgate Status',
        'GM16': 'AT4 Off-Road Mode Data',
      },
    ),
  };

  static GMBrandSpecificFeatures? getForBrand(String brand) {
    return brandFeatures[brand];
  }
}