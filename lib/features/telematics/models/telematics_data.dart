import 'dart:convert';
import 'dart:math';

class TelematicsData {
  final String id;
  final String vehicleId;
  final DateTime timestamp;
  final GpsLocation location;
  final VehicleMetrics metrics;
  final DriverBehavior? driverBehavior;
  final Map<String, dynamic> rawData;
  final String providerId;
  final DataQuality quality;

  const TelematicsData({
    required this.id,
    required this.vehicleId,
    required this.timestamp,
    required this.location,
    required this.metrics,
    this.driverBehavior,
    this.rawData = const {},
    required this.providerId,
    this.quality = DataQuality.good,
  });

  factory TelematicsData.fromJson(Map<String, dynamic> json) {
    return TelematicsData(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: GpsLocation.fromJson(json['location']),
      metrics: VehicleMetrics.fromJson(json['metrics']),
      driverBehavior: json['driverBehavior'] != null
          ? DriverBehavior.fromJson(json['driverBehavior'])
          : null,
      rawData: json['rawData'] as Map<String, dynamic>? ?? {},
      providerId: json['providerId'] as String,
      quality: DataQuality.values.byName(json['quality'] ?? 'good'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'timestamp': timestamp.toIso8601String(),
      'location': location.toJson(),
      'metrics': metrics.toJson(),
      'driverBehavior': driverBehavior?.toJson(),
      'rawData': rawData,
      'providerId': providerId,
      'quality': quality.name,
    };
  }

  TelematicsData copyWith({
    String? id,
    String? vehicleId,
    DateTime? timestamp,
    GpsLocation? location,
    VehicleMetrics? metrics,
    DriverBehavior? driverBehavior,
    Map<String, dynamic>? rawData,
    String? providerId,
    DataQuality? quality,
  }) {
    return TelematicsData(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      metrics: metrics ?? this.metrics,
      driverBehavior: driverBehavior ?? this.driverBehavior,
      rawData: rawData ?? this.rawData,
      providerId: providerId ?? this.providerId,
      quality: quality ?? this.quality,
    );
  }

  /// Check if data is fresh (within last 5 minutes)
  bool get isFresh {
    final age = DateTime.now().difference(timestamp);
    return age.inMinutes <= 5;
  }

  /// Get data age in human readable format
  String get ageDescription {
    final age = DateTime.now().difference(timestamp);
    if (age.inMinutes < 1) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    if (age.inHours < 24) return '${age.inHours}h ago';
    return '${age.inDays}d ago';
  }
}

class GpsLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final DateTime timestamp;

  const GpsLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.timestamp,
  });

  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  GpsLocation copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? heading,
    double? speed,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return GpsLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Get formatted coordinates string
  String get coordinatesString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Check if location has high accuracy (< 10 meters)
  bool get hasHighAccuracy => accuracy != null && accuracy! < 10.0;

  /// Calculate distance to another location (in meters)
  double distanceTo(GpsLocation other) {
    // Haversine formula implementation
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = latitude * (3.14159265359 / 180.0);
    final double lat2Rad = other.latitude * (3.14159265359 / 180.0);
    final double deltaLatRad = (other.latitude - latitude) * (3.14159265359 / 180.0);
    final double deltaLngRad = (other.longitude - longitude) * (3.14159265359 / 180.0);

    final double a = 
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }
}

class VehicleMetrics {
  final double? speed; // mph or km/h
  final double? engineRpm;
  final double? fuelLevel; // percentage
  final double? engineTemperature; // Fahrenheit or Celsius
  final double? oilPressure; // psi or bar
  final double? batteryVoltage;
  final int? odometer; // miles or km
  final bool? engineRunning;
  final bool? ignitionOn;
  final Map<String, dynamic> diagnosticCodes;

  const VehicleMetrics({
    this.speed,
    this.engineRpm,
    this.fuelLevel,
    this.engineTemperature,
    this.oilPressure,
    this.batteryVoltage,
    this.odometer,
    this.engineRunning,
    this.ignitionOn,
    this.diagnosticCodes = const {},
  });

  factory VehicleMetrics.fromJson(Map<String, dynamic> json) {
    return VehicleMetrics(
      speed: (json['speed'] as num?)?.toDouble(),
      engineRpm: (json['engineRpm'] as num?)?.toDouble(),
      fuelLevel: (json['fuelLevel'] as num?)?.toDouble(),
      engineTemperature: (json['engineTemperature'] as num?)?.toDouble(),
      oilPressure: (json['oilPressure'] as num?)?.toDouble(),
      batteryVoltage: (json['batteryVoltage'] as num?)?.toDouble(),
      odometer: json['odometer'] as int?,
      engineRunning: json['engineRunning'] as bool?,
      ignitionOn: json['ignitionOn'] as bool?,
      diagnosticCodes: json['diagnosticCodes'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
      'engineRpm': engineRpm,
      'fuelLevel': fuelLevel,
      'engineTemperature': engineTemperature,
      'oilPressure': oilPressure,
      'batteryVoltage': batteryVoltage,
      'odometer': odometer,
      'engineRunning': engineRunning,
      'ignitionOn': ignitionOn,
      'diagnosticCodes': diagnosticCodes,
    };
  }

  VehicleMetrics copyWith({
    double? speed,
    double? engineRpm,
    double? fuelLevel,
    double? engineTemperature,
    double? oilPressure,
    double? batteryVoltage,
    int? odometer,
    bool? engineRunning,
    bool? ignitionOn,
    Map<String, dynamic>? diagnosticCodes,
  }) {
    return VehicleMetrics(
      speed: speed ?? this.speed,
      engineRpm: engineRpm ?? this.engineRpm,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      engineTemperature: engineTemperature ?? this.engineTemperature,
      oilPressure: oilPressure ?? this.oilPressure,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      odometer: odometer ?? this.odometer,
      engineRunning: engineRunning ?? this.engineRunning,
      ignitionOn: ignitionOn ?? this.ignitionOn,
      diagnosticCodes: diagnosticCodes ?? this.diagnosticCodes,
    );
  }

  /// Check if vehicle is currently in motion
  bool get isMoving => speed != null && speed! > 0;

  /// Check if engine temperature is in normal range (180-220°F)
  bool get engineTempNormal {
    if (engineTemperature == null) return true;
    return engineTemperature! >= 180 && engineTemperature! <= 220;
  }

  /// Check if fuel level is low (< 15%)
  bool get fuelLevelLow {
    if (fuelLevel == null) return false;
    return fuelLevel! < 15;
  }

  /// Check if battery voltage is low (< 12V)
  bool get batteryVoltageLow {
    if (batteryVoltage == null) return false;
    return batteryVoltage! < 12.0;
  }

  /// Get overall health status
  VehicleHealthStatus get healthStatus {
    final List<bool> issues = [
      !engineTempNormal,
      fuelLevelLow,
      batteryVoltageLow,
      diagnosticCodes.isNotEmpty,
    ];

    final int issueCount = issues.where((issue) => issue).length;
    
    if (issueCount == 0) return VehicleHealthStatus.excellent;
    if (issueCount == 1) return VehicleHealthStatus.good;
    if (issueCount == 2) return VehicleHealthStatus.fair;
    return VehicleHealthStatus.poor;
  }
}

class DriverBehavior {
  final double? accelerationScore; // 0-100
  final double? brakingScore; // 0-100
  final double? corneringScore; // 0-100
  final double? speedingScore; // 0-100
  final double? overallScore; // 0-100
  final int? hardAccelerations;
  final int? hardBraking;
  final int? hardCornering;
  final int? speedingEvents;
  final Duration? idleTime;
  final double? fuelEfficiency; // mpg or l/100km

  const DriverBehavior({
    this.accelerationScore,
    this.brakingScore,
    this.corneringScore,
    this.speedingScore,
    this.overallScore,
    this.hardAccelerations,
    this.hardBraking,
    this.hardCornering,
    this.speedingEvents,
    this.idleTime,
    this.fuelEfficiency,
  });

  factory DriverBehavior.fromJson(Map<String, dynamic> json) {
    return DriverBehavior(
      accelerationScore: (json['accelerationScore'] as num?)?.toDouble(),
      brakingScore: (json['brakingScore'] as num?)?.toDouble(),
      corneringScore: (json['corneringScore'] as num?)?.toDouble(),
      speedingScore: (json['speedingScore'] as num?)?.toDouble(),
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      hardAccelerations: json['hardAccelerations'] as int?,
      hardBraking: json['hardBraking'] as int?,
      hardCornering: json['hardCornering'] as int?,
      speedingEvents: json['speedingEvents'] as int?,
      idleTime: json['idleTimeMinutes'] != null
          ? Duration(minutes: json['idleTimeMinutes'] as int)
          : null,
      fuelEfficiency: (json['fuelEfficiency'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accelerationScore': accelerationScore,
      'brakingScore': brakingScore,
      'corneringScore': corneringScore,
      'speedingScore': speedingScore,
      'overallScore': overallScore,
      'hardAccelerations': hardAccelerations,
      'hardBraking': hardBraking,
      'hardCornering': hardCornering,
      'speedingEvents': speedingEvents,
      'idleTimeMinutes': idleTime?.inMinutes,
      'fuelEfficiency': fuelEfficiency,
    };
  }

  DriverBehavior copyWith({
    double? accelerationScore,
    double? brakingScore,
    double? corneringScore,
    double? speedingScore,
    double? overallScore,
    int? hardAccelerations,
    int? hardBraking,
    int? hardCornering,
    int? speedingEvents,
    Duration? idleTime,
    double? fuelEfficiency,
  }) {
    return DriverBehavior(
      accelerationScore: accelerationScore ?? this.accelerationScore,
      brakingScore: brakingScore ?? this.brakingScore,
      corneringScore: corneringScore ?? this.corneringScore,
      speedingScore: speedingScore ?? this.speedingScore,
      overallScore: overallScore ?? this.overallScore,
      hardAccelerations: hardAccelerations ?? this.hardAccelerations,
      hardBraking: hardBraking ?? this.hardBraking,
      hardCornering: hardCornering ?? this.hardCornering,
      speedingEvents: speedingEvents ?? this.speedingEvents,
      idleTime: idleTime ?? this.idleTime,
      fuelEfficiency: fuelEfficiency ?? this.fuelEfficiency,
    );
  }

  /// Get driving grade based on overall score
  DrivingGrade get drivingGrade {
    if (overallScore == null) return DrivingGrade.unknown;
    if (overallScore! >= 90) return DrivingGrade.excellent;
    if (overallScore! >= 80) return DrivingGrade.good;
    if (overallScore! >= 70) return DrivingGrade.fair;
    return DrivingGrade.poor;
  }

  /// Check if driver behavior is concerning
  bool get hasConcerns {
    return (hardAccelerations != null && hardAccelerations! > 5) ||
           (hardBraking != null && hardBraking! > 5) ||
           (speedingEvents != null && speedingEvents! > 3) ||
           (overallScore != null && overallScore! < 70);
  }
}

class TelematicsProvider {
  final String id;
  final String name;
  final String description;
  final ProviderType type;
  final Map<String, dynamic> configuration;
  final TelematicsConnectionStatus connectionStatus;
  final DateTime? lastSync;
  final List<String> supportedFeatures;
  final Map<String, dynamic> apiCredentials;

  const TelematicsProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.configuration = const {},
    this.connectionStatus = TelematicsConnectionStatus.disconnected,
    this.lastSync,
    this.supportedFeatures = const [],
    this.apiCredentials = const {},
  });

  factory TelematicsProvider.fromJson(Map<String, dynamic> json) {
    return TelematicsProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ProviderType.values.byName(json['type']),
      configuration: json['configuration'] as Map<String, dynamic>? ?? {},
      connectionStatus: TelematicsConnectionStatus.values.byName(json['connectionStatus'] ?? 'disconnected'),
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
      supportedFeatures: List<String>.from(json['supportedFeatures'] ?? []),
      apiCredentials: json['apiCredentials'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'configuration': configuration,
      'connectionStatus': connectionStatus.name,
      'lastSync': lastSync?.toIso8601String(),
      'supportedFeatures': supportedFeatures,
      'apiCredentials': apiCredentials,
    };
  }

  TelematicsProvider copyWith({
    String? id,
    String? name,
    String? description,
    ProviderType? type,
    Map<String, dynamic>? configuration,
    TelematicsConnectionStatus? connectionStatus,
    DateTime? lastSync,
    List<String>? supportedFeatures,
    Map<String, dynamic>? apiCredentials,
  }) {
    return TelematicsProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      configuration: configuration ?? this.configuration,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastSync: lastSync ?? this.lastSync,
      supportedFeatures: supportedFeatures ?? this.supportedFeatures,
      apiCredentials: apiCredentials ?? this.apiCredentials,
    );
  }

  /// Check if provider is currently connected
  bool get isConnected => connectionStatus == TelematicsConnectionStatus.connected;

  /// Get time since last sync
  Duration? get timeSinceLastSync {
    if (lastSync == null) return null;
    return DateTime.now().difference(lastSync!);
  }
}

enum DataQuality {
  excellent,
  good,
  fair,
  poor,
}

enum VehicleHealthStatus {
  excellent,
  good,
  fair,
  poor,
}

enum DrivingGrade {
  excellent,
  good,
  fair,
  poor,
  unknown,
}

enum ProviderType {
  gps,
  obd,
  fleet,
  insurance,
  hybrid,
}

enum TelematicsConnectionStatus {
  connected,
  connecting,
  disconnected,
  error,
}

// Extension methods for better enum usage
extension DataQualityExtension on DataQuality {
  String get displayName {
    switch (this) {
      case DataQuality.excellent:
        return 'Excellent';
      case DataQuality.good:
        return 'Good';
      case DataQuality.fair:
        return 'Fair';
      case DataQuality.poor:
        return 'Poor';
    }
  }

  double get scoreValue {
    switch (this) {
      case DataQuality.excellent:
        return 1.0;
      case DataQuality.good:
        return 0.8;
      case DataQuality.fair:
        return 0.6;
      case DataQuality.poor:
        return 0.4;
    }
  }
}

extension VehicleHealthStatusExtension on VehicleHealthStatus {
  String get displayName {
    switch (this) {
      case VehicleHealthStatus.excellent:
        return 'Excellent';
      case VehicleHealthStatus.good:
        return 'Good';
      case VehicleHealthStatus.fair:
        return 'Fair';
      case VehicleHealthStatus.poor:
        return 'Poor';
    }
  }
}

extension DrivingGradeExtension on DrivingGrade {
  String get displayName {
    switch (this) {
      case DrivingGrade.excellent:
        return 'Excellent';
      case DrivingGrade.good:
        return 'Good';
      case DrivingGrade.fair:
        return 'Fair';
      case DrivingGrade.poor:
        return 'Poor';
      case DrivingGrade.unknown:
        return 'Unknown';
    }
  }

  String get letterGrade {
    switch (this) {
      case DrivingGrade.excellent:
        return 'A';
      case DrivingGrade.good:
        return 'B';
      case DrivingGrade.fair:
        return 'C';
      case DrivingGrade.poor:
        return 'D';
      case DrivingGrade.unknown:
        return '?';
    }
  }
}