// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) => VehicleInfo(
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
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