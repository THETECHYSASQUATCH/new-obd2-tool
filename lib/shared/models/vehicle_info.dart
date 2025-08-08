import 'package:json_annotation/json_annotation.dart';

part 'vehicle_info.g.dart';

@JsonSerializable()
class VehicleInfo {
  final String make;
  final String model;
  final int year;
  final String? trim;
  final String? engine;
  final String? transmission;
  final List<String> supportedProtocols;
  final Map<String, dynamic>? manufacturerSpecificPids;
  final Map<String, String>? ecuMappings;

  // Getter for compatibility with core model
  String? get engineType => engine;

  const VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    this.trim,
    this.engine,
    this.transmission,
    this.supportedProtocols = const ['ISO9141-2', 'KWP2000', 'CAN'],
    this.manufacturerSpecificPids,
    this.ecuMappings,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => 
      _$VehicleInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleInfoToJson(this);

  String get displayName => '$year $make $model${trim != null ? ' $trim' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleInfo &&
      runtimeType == other.runtimeType &&
      make == other.make &&
      model == other.model &&
      year == other.year &&
      trim == other.trim;

  @override
  int get hashCode => make.hashCode ^ model.hashCode ^ year.hashCode ^ trim.hashCode;

  @override
  String toString() => displayName;
}

@JsonSerializable()
class VehicleDatabase {
  final Map<String, List<VehicleInfo>> vehiclesByMake;
  final Map<String, VehicleManufacturerConfig> manufacturerConfigs;

  const VehicleDatabase({
    required this.vehiclesByMake,
    required this.manufacturerConfigs,
  });

  factory VehicleDatabase.fromJson(Map<String, dynamic> json) => 
      _$VehicleDatabaseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleDatabaseToJson(this);

  List<String> get availableMakes => vehiclesByMake.keys.toList()..sort();

  List<VehicleInfo> getModelsForMake(String make) =>
      vehiclesByMake[make] ?? [];

  List<int> getYearsForMakeModel(String make, String model) {
    final vehicles = getModelsForMake(make)
        .where((v) => v.model == model)
        .map((v) => v.year)
        .toSet()
        .toList();
    vehicles.sort((a, b) => b.compareTo(a)); // Most recent first
    return vehicles;
  }

  VehicleInfo? findVehicle(String make, String model, int year, {String? trim}) {
    return getModelsForMake(make).firstWhere(
      (v) => v.model == model && v.year == year && (trim == null || v.trim == trim),
      orElse: () => VehicleInfo(make: make, model: model, year: year, trim: trim),
    );
  }

  VehicleManufacturerConfig? getManufacturerConfig(String make) =>
      manufacturerConfigs[make];
}

@JsonSerializable()
class VehicleManufacturerConfig {
  final String name;
  final List<String> preferredProtocols;
  final Map<String, String> customPids;
  final Map<String, String> dtcLookup;
  final Map<String, dynamic>? ecuProgrammingSupport;

  const VehicleManufacturerConfig({
    required this.name,
    required this.preferredProtocols,
    required this.customPids,
    required this.dtcLookup,
    this.ecuProgrammingSupport,
  });

  factory VehicleManufacturerConfig.fromJson(Map<String, dynamic> json) => 
      _$VehicleManufacturerConfigFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleManufacturerConfigToJson(this);
}