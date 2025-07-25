// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecu_programming.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EcuInfo _$EcuInfoFromJson(Map<String, dynamic> json) => EcuInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$EcuTypeEnumMap, json['type']),
  address: json['address'] as String,
  partNumber: json['partNumber'] as String?,
  softwareVersion: json['softwareVersion'] as String?,
  hardwareVersion: json['hardwareVersion'] as String?,
  programmingSupported: json['programmingSupported'] as bool? ?? false,
  supportedModes:
      (json['supportedModes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ProgrammingModeEnumMap, e))
          .toList() ??
      const [],
);

Map<String, dynamic> _$EcuInfoToJson(EcuInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$EcuTypeEnumMap[instance.type]!,
  'address': instance.address,
  'partNumber': instance.partNumber,
  'softwareVersion': instance.softwareVersion,
  'hardwareVersion': instance.hardwareVersion,
  'programmingSupported': instance.programmingSupported,
  'supportedModes': instance.supportedModes
      .map((e) => _$ProgrammingModeEnumMap[e]!)
      .toList(),
};

const _$EcuTypeEnumMap = {
  EcuType.engine: 'engine',
  EcuType.transmission: 'transmission',
  EcuType.abs: 'abs',
  EcuType.airbag: 'airbag',
  EcuType.body: 'body',
  EcuType.climate: 'climate',
  EcuType.infotainment: 'infotainment',
  EcuType.hybrid: 'hybrid',
  EcuType.other: 'other',
};

const _$ProgrammingModeEnumMap = {
  ProgrammingMode.flash: 'flash',
  ProgrammingMode.calibration: 'calibration',
  ProgrammingMode.adaptation: 'adaptation',
  ProgrammingMode.coding: 'coding',
  ProgrammingMode.configuration: 'configuration',
};

ProgrammingSession _$ProgrammingSessionFromJson(Map<String, dynamic> json) =>
    ProgrammingSession(
      id: json['id'] as String,
      ecuId: json['ecuId'] as String,
      mode: $enumDecode(_$ProgrammingModeEnumMap, json['mode']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status: $enumDecode(_$ProgrammingStatusEnumMap, json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      filePath: json['filePath'] as String?,
      backupPath: json['backupPath'] as String?,
      errorMessage: json['errorMessage'] as String?,
      log:
          (json['log'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$ProgrammingSessionToJson(ProgrammingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ecuId': instance.ecuId,
      'mode': _$ProgrammingModeEnumMap[instance.mode]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$ProgrammingStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'filePath': instance.filePath,
      'backupPath': instance.backupPath,
      'errorMessage': instance.errorMessage,
      'log': instance.log,
    };

const _$ProgrammingStatusEnumMap = {
  ProgrammingStatus.idle: 'idle',
  ProgrammingStatus.connecting: 'connecting',
  ProgrammingStatus.authenticating: 'authenticating',
  ProgrammingStatus.reading: 'reading',
  ProgrammingStatus.erasing: 'erasing',
  ProgrammingStatus.programming: 'programming',
  ProgrammingStatus.verifying: 'verifying',
  ProgrammingStatus.completed: 'completed',
  ProgrammingStatus.error: 'error',
  ProgrammingStatus.cancelled: 'cancelled',
};

ProgrammingFile _$ProgrammingFileFromJson(Map<String, dynamic> json) =>
    ProgrammingFile(
      path: json['path'] as String,
      name: json['name'] as String,
      checksum: json['checksum'] as String,
      size: (json['size'] as num).toInt(),
      description: json['description'] as String?,
      version: json['version'] as String?,
      compatibleEcus:
          (json['compatibleEcus'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProgrammingFileToJson(ProgrammingFile instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'checksum': instance.checksum,
      'size': instance.size,
      'description': instance.description,
      'version': instance.version,
      'compatibleEcus': instance.compatibleEcus,
      'createdAt': instance.createdAt.toIso8601String(),
    };

SecurityAccess _$SecurityAccessFromJson(Map<String, dynamic> json) =>
    SecurityAccess(
      seed: json['seed'] as String,
      key: json['key'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isValid: json['isValid'] as bool,
    );

Map<String, dynamic> _$SecurityAccessToJson(SecurityAccess instance) =>
    <String, dynamic>{
      'seed': instance.seed,
      'key': instance.key,
      'timestamp': instance.timestamp.toIso8601String(),
      'isValid': instance.isValid,
    };
