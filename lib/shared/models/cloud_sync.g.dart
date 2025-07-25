// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudConfig _$CloudConfigFromJson(Map<String, dynamic> json) => CloudConfig(
  provider: $enumDecode(_$CloudProviderEnumMap, json['provider']),
  endpoint: json['endpoint'] as String,
  apiKey: json['apiKey'] as String,
  region: json['region'] as String?,
  autoSync: json['autoSync'] as bool? ?? true,
  syncIntervalMinutes: (json['syncIntervalMinutes'] as num?)?.toInt() ?? 30,
  syncOnlyOnWifi: json['syncOnlyOnWifi'] as bool? ?? true,
  compressData: json['compressData'] as bool? ?? true,
);

Map<String, dynamic> _$CloudConfigToJson(CloudConfig instance) =>
    <String, dynamic>{
      'provider': _$CloudProviderEnumMap[instance.provider]!,
      'endpoint': instance.endpoint,
      'apiKey': instance.apiKey,
      'region': instance.region,
      'autoSync': instance.autoSync,
      'syncIntervalMinutes': instance.syncIntervalMinutes,
      'syncOnlyOnWifi': instance.syncOnlyOnWifi,
      'compressData': instance.compressData,
    };

const _$CloudProviderEnumMap = {
  CloudProvider.firebase: 'firebase',
  CloudProvider.aws: 'aws',
  CloudProvider.azure: 'azure',
  CloudProvider.googleCloud: 'googleCloud',
  CloudProvider.custom: 'custom',
};

SyncData _$SyncDataFromJson(Map<String, dynamic> json) => SyncData(
  id: json['id'] as String,
  type: json['type'] as String,
  data: json['data'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  modifiedAt: DateTime.parse(json['modifiedAt'] as String),
  deviceId: json['deviceId'] as String?,
  checksum: json['checksum'] as String,
);

Map<String, dynamic> _$SyncDataToJson(SyncData instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'data': instance.data,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'deviceId': instance.deviceId,
  'checksum': instance.checksum,
};

SyncSession _$SyncSessionFromJson(Map<String, dynamic> json) => SyncSession(
  id: json['id'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$SyncStatusEnumMap, json['status']),
  totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
  syncedItems: (json['syncedItems'] as num?)?.toInt() ?? 0,
  failedItems: (json['failedItems'] as num?)?.toInt() ?? 0,
  errorMessage: json['errorMessage'] as String?,
  syncedDataIds:
      (json['syncedDataIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  failedDataIds:
      (json['failedDataIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$SyncSessionToJson(SyncSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$SyncStatusEnumMap[instance.status]!,
      'totalItems': instance.totalItems,
      'syncedItems': instance.syncedItems,
      'failedItems': instance.failedItems,
      'errorMessage': instance.errorMessage,
      'syncedDataIds': instance.syncedDataIds,
      'failedDataIds': instance.failedDataIds,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.idle: 'idle',
  SyncStatus.syncing: 'syncing',
  SyncStatus.completed: 'completed',
  SyncStatus.error: 'error',
  SyncStatus.paused: 'paused',
};

CloudSyncSettings _$CloudSyncSettingsFromJson(Map<String, dynamic> json) =>
    CloudSyncSettings(
      enabled: json['enabled'] as bool? ?? false,
      cloudConfig: json['cloudConfig'] == null
          ? null
          : CloudConfig.fromJson(json['cloudConfig'] as Map<String, dynamic>),
      syncDataTypes:
          (json['syncDataTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['diagnostic_session', 'vehicle_data'],
      autoBackup: json['autoBackup'] as bool? ?? true,
      maxBackupAgeDays: (json['maxBackupAgeDays'] as num?)?.toInt() ?? 30,
      notifyOnSync: json['notifyOnSync'] as bool? ?? true,
      notifyOnError: json['notifyOnError'] as bool? ?? true,
    );

Map<String, dynamic> _$CloudSyncSettingsToJson(CloudSyncSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'cloudConfig': instance.cloudConfig,
      'syncDataTypes': instance.syncDataTypes,
      'autoBackup': instance.autoBackup,
      'maxBackupAgeDays': instance.maxBackupAgeDays,
      'notifyOnSync': instance.notifyOnSync,
      'notifyOnError': instance.notifyOnError,
    };

BackupMetadata _$BackupMetadataFromJson(Map<String, dynamic> json) =>
    BackupMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      size: (json['size'] as num).toInt(),
      checksum: json['checksum'] as String,
      includedDataTypes: (json['includedDataTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BackupMetadataToJson(BackupMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'size': instance.size,
      'checksum': instance.checksum,
      'includedDataTypes': instance.includedDataTypes,
      'description': instance.description,
      'metadata': instance.metadata,
    };
