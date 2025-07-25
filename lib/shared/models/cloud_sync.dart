import 'package:json_annotation/json_annotation.dart';

part 'cloud_sync.g.dart';

enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
  paused
}

enum CloudProvider {
  firebase,
  aws,
  azure,
  googleCloud,
  custom
}

@JsonSerializable()
class CloudConfig {
  final CloudProvider provider;
  final String endpoint;
  final String apiKey;
  final String? region;
  final bool autoSync;
  final int syncIntervalMinutes;
  final bool syncOnlyOnWifi;
  final bool compressData;

  const CloudConfig({
    required this.provider,
    required this.endpoint,
    required this.apiKey,
    this.region,
    this.autoSync = true,
    this.syncIntervalMinutes = 30,
    this.syncOnlyOnWifi = true,
    this.compressData = true,
  });

  factory CloudConfig.fromJson(Map<String, dynamic> json) => 
      _$CloudConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CloudConfigToJson(this);
}

@JsonSerializable()
class SyncData {
  final String id;
  final String type; // 'diagnostic_session', 'vehicle_data', 'settings', etc.
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? deviceId;
  final String checksum;

  const SyncData({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.modifiedAt,
    this.deviceId,
    required this.checksum,
  });

  factory SyncData.fromJson(Map<String, dynamic> json) => 
      _$SyncDataFromJson(json);

  Map<String, dynamic> toJson() => _$SyncDataToJson(this);
}

@JsonSerializable()
class SyncSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SyncStatus status;
  final int totalItems;
  final int syncedItems;
  final int failedItems;
  final String? errorMessage;
  final List<String> syncedDataIds;
  final List<String> failedDataIds;

  const SyncSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.status,
    this.totalItems = 0,
    this.syncedItems = 0,
    this.failedItems = 0,
    this.errorMessage,
    this.syncedDataIds = const [],
    this.failedDataIds = const [],
  });

  factory SyncSession.fromJson(Map<String, dynamic> json) => 
      _$SyncSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SyncSessionToJson(this);

  SyncSession copyWith({
    SyncStatus? status,
    DateTime? endTime,
    int? totalItems,
    int? syncedItems,
    int? failedItems,
    String? errorMessage,
    List<String>? syncedDataIds,
    List<String>? failedDataIds,
  }) {
    return SyncSession(
      id: id,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalItems: totalItems ?? this.totalItems,
      syncedItems: syncedItems ?? this.syncedItems,
      failedItems: failedItems ?? this.failedItems,
      errorMessage: errorMessage ?? this.errorMessage,
      syncedDataIds: syncedDataIds ?? this.syncedDataIds,
      failedDataIds: failedDataIds ?? this.failedDataIds,
    );
  }

  double get progress => totalItems > 0 ? (syncedItems + failedItems) / totalItems : 0.0;
  bool get isCompleted => status == SyncStatus.completed || status == SyncStatus.error;
  Duration? get duration => endTime?.difference(startTime);
}

@JsonSerializable()
class CloudSyncSettings {
  final bool enabled;
  final CloudConfig? cloudConfig;
  final List<String> syncDataTypes;
  final bool autoBackup;
  final int maxBackupAgeDays;
  final bool notifyOnSync;
  final bool notifyOnError;

  const CloudSyncSettings({
    this.enabled = false,
    this.cloudConfig,
    this.syncDataTypes = const ['diagnostic_session', 'vehicle_data'],
    this.autoBackup = true,
    this.maxBackupAgeDays = 30,
    this.notifyOnSync = true,
    this.notifyOnError = true,
  });

  factory CloudSyncSettings.fromJson(Map<String, dynamic> json) => 
      _$CloudSyncSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$CloudSyncSettingsToJson(this);

  CloudSyncSettings copyWith({
    bool? enabled,
    CloudConfig? cloudConfig,
    List<String>? syncDataTypes,
    bool? autoBackup,
    int? maxBackupAgeDays,
    bool? notifyOnSync,
    bool? notifyOnError,
  }) {
    return CloudSyncSettings(
      enabled: enabled ?? this.enabled,
      cloudConfig: cloudConfig ?? this.cloudConfig,
      syncDataTypes: syncDataTypes ?? this.syncDataTypes,
      autoBackup: autoBackup ?? this.autoBackup,
      maxBackupAgeDays: maxBackupAgeDays ?? this.maxBackupAgeDays,
      notifyOnSync: notifyOnSync ?? this.notifyOnSync,
      notifyOnError: notifyOnError ?? this.notifyOnError,
    );
  }
}

@JsonSerializable()
class BackupMetadata {
  final String id;
  final String name;
  final DateTime createdAt;
  final int size;
  final String checksum;
  final List<String> includedDataTypes;
  final String? description;
  final Map<String, dynamic>? metadata;

  const BackupMetadata({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.size,
    required this.checksum,
    required this.includedDataTypes,
    this.description,
    this.metadata,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => 
      _$BackupMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$BackupMetadataToJson(this);

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}