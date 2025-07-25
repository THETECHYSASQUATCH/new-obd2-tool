// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) => VehicleInfo(
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      trim: json['trim'] as String?,
      engine: json['engine'] as String?,
      transmission: json['transmission'] as String?,
      supportedProtocols: (json['supportedProtocols'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['ISO9141-2', 'KWP2000', 'CAN'],
      manufacturerSpecificPids:
          json['manufacturerSpecificPids'] as Map<String, dynamic>?,
      ecuMappings: (json['ecuMappings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$VehicleInfoToJson(VehicleInfo instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'trim': instance.trim,
      'engine': instance.engine,
      'transmission': instance.transmission,
      'supportedProtocols': instance.supportedProtocols,
      'manufacturerSpecificPids': instance.manufacturerSpecificPids,
      'ecuMappings': instance.ecuMappings,
    };

VehicleDatabase _$VehicleDatabaseFromJson(Map<String, dynamic> json) =>
    VehicleDatabase(
      vehiclesByMake: (json['vehiclesByMake'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => VehicleInfo.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      manufacturerConfigs:
          (json['manufacturerConfigs'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, VehicleManufacturerConfig.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$VehicleDatabaseToJson(VehicleDatabase instance) =>
    <String, dynamic>{
      'vehiclesByMake': instance.vehiclesByMake,
      'manufacturerConfigs': instance.manufacturerConfigs,
    };

VehicleManufacturerConfig _$VehicleManufacturerConfigFromJson(
        Map<String, dynamic> json) =>
    VehicleManufacturerConfig(
      name: json['name'] as String,
      preferredProtocols: (json['preferredProtocols'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      customPids: Map<String, String>.from(json['customPids'] as Map),
      dtcLookup: Map<String, String>.from(json['dtcLookup'] as Map),
      ecuProgrammingSupport:
          json['ecuProgrammingSupport'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VehicleManufacturerConfigToJson(
        VehicleManufacturerConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'preferredProtocols': instance.preferredProtocols,
      'customPids': instance.customPids,
      'dtcLookup': instance.dtcLookup,
      'ecuProgrammingSupport': instance.ecuProgrammingSupport,
    };
