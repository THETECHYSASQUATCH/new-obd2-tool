import 'dart:convert';

class VehicleInfo {
  final String make;
  final String model;
  final int year;
  final String? trim;
  final String? engineType;
  final String? transmissionType;
  final String? fuelType;
  final String? vin;
  final List<String> supportedProtocols;
  final Map<String, dynamic> specifications;
  final List<String> knownIssues;
  final Map<String, dynamic> metadata;

  const VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    this.trim,
    this.engineType,
    this.transmissionType,
    this.fuelType,
    this.vin,
    this.supportedProtocols = const [],
    this.specifications = const {},
    this.knownIssues = const [],
    this.metadata = const {},
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      trim: json['trim'] as String?,
      engineType: json['engineType'] as String?,
      transmissionType: json['transmissionType'] as String?,
      fuelType: json['fuelType'] as String?,
      vin: json['vin'] as String?,
      supportedProtocols: List<String>.from(json['supportedProtocols'] ?? []),
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      knownIssues: List<String>.from(json['knownIssues'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'trim': trim,
      'engineType': engineType,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'vin': vin,
      'supportedProtocols': supportedProtocols,
      'specifications': specifications,
      'knownIssues': knownIssues,
      'metadata': metadata,
    };
  }

  VehicleInfo copyWith({
    String? make,
    String? model,
    int? year,
    String? trim,
    String? engineType,
    String? transmissionType,
    String? fuelType,
    String? vin,
    List<String>? supportedProtocols,
    Map<String, dynamic>? specifications,
    List<String>? knownIssues,
    Map<String, dynamic>? metadata,
  }) {
    return VehicleInfo(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      trim: trim ?? this.trim,
      engineType: engineType ?? this.engineType,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      vin: vin ?? this.vin,
      supportedProtocols: supportedProtocols ?? this.supportedProtocols,
      specifications: specifications ?? this.specifications,
      knownIssues: knownIssues ?? this.knownIssues,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleInfo &&
        other.make == make &&
        other.model == model &&
        other.year == year &&
        other.vin == vin;
  }

  @override
  int get hashCode => Object.hash(make, model, year, vin);

  @override
  String toString() {
    return 'VehicleInfo(make: $make, model: $model, year: $year)';
  }

  String get displayName => '$year $make $model${trim != null ? ' $trim' : ''}';
}

class VehicleDatabase {
  final Map<String, List<VehicleInfo>> vehiclesByMake;
  final DateTime lastUpdated;
  final String version;

  const VehicleDatabase({
    required this.vehiclesByMake,
    required this.lastUpdated,
    this.version = '1.0.0',
  });

  factory VehicleDatabase.fromJson(Map<String, dynamic> json) {
    final vehiclesByMake = <String, List<VehicleInfo>>{};
    final vehiclesData = json['vehiclesByMake'] as Map<String, dynamic>? ?? {};
    
    for (final entry in vehiclesData.entries) {
      final vehicles = (entry.value as List<dynamic>)
          .map((v) => VehicleInfo.fromJson(v as Map<String, dynamic>))
          .toList();
      vehiclesByMake[entry.key] = vehicles;
    }

    return VehicleDatabase(
      vehiclesByMake: vehiclesByMake,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      version: json['version'] as String? ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    final vehiclesByMakeJson = <String, dynamic>{};
    for (final entry in vehiclesByMake.entries) {
      vehiclesByMakeJson[entry.key] = entry.value.map((v) => v.toJson()).toList();
    }

    return {
      'vehiclesByMake': vehiclesByMakeJson,
      'lastUpdated': lastUpdated.toIso8601String(),
      'version': version,
    };
  }

  List<String> get availableMakes => vehiclesByMake.keys.toList()..sort();

  List<VehicleInfo> getVehiclesByMake(String make) {
    return vehiclesByMake[make] ?? [];
  }

  List<VehicleInfo> searchVehicles(String query) {
    final results = <VehicleInfo>[];
    final lowerQuery = query.toLowerCase();
    
    for (final vehicles in vehiclesByMake.values) {
      for (final vehicle in vehicles) {
        if (vehicle.make.toLowerCase().contains(lowerQuery) ||
            vehicle.model.toLowerCase().contains(lowerQuery) ||
            vehicle.year.toString().contains(lowerQuery)) {
          results.add(vehicle);
        }
      }
    }
    
    return results;
  }
}