import 'dart:convert';

class CloudSyncSettings {
  final bool enabled;
  final CloudConfig? cloudConfig;
  final SyncFrequency syncFrequency;
  final bool autoSync;
  final bool syncOnCellular;
  final List<String> syncTypes;
  final Map<String, dynamic> metadata;

  const CloudSyncSettings({
    this.enabled = false,
    this.cloudConfig,
    this.syncFrequency = SyncFrequency.daily,
    this.autoSync = false,
    this.syncOnCellular = false,
    this.syncTypes = const [],
    this.metadata = const {},
  });

  factory CloudSyncSettings.fromJson(Map<String, dynamic> json) {
    return CloudSyncSettings(
      enabled: json['enabled'] as bool? ?? false,
      cloudConfig: json['cloudConfig'] != null
          ? CloudConfig.fromJson(json['cloudConfig'] as Map<String, dynamic>)
          : null,
      syncFrequency: SyncFrequency.values.byName(json['syncFrequency'] ?? 'daily'),
      autoSync: json['autoSync'] as bool? ?? false,
      syncOnCellular: json['syncOnCellular'] as bool? ?? false,
      syncTypes: List<String>.from(json['syncTypes'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'cloudConfig': cloudConfig?.toJson(),
      'syncFrequency': syncFrequency.name,
      'autoSync': autoSync,
      'syncOnCellular': syncOnCellular,
      'syncTypes': syncTypes,
      'metadata': metadata,
    };
  }

  CloudSyncSettings copyWith({
    bool? enabled,
    CloudConfig? cloudConfig,
    SyncFrequency? syncFrequency,
    bool? autoSync,
    bool? syncOnCellular,
    List<String>? syncTypes,
    Map<String, dynamic>? metadata,
  }) {
    return CloudSyncSettings(
      enabled: enabled ?? this.enabled,
      cloudConfig: cloudConfig ?? this.cloudConfig,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      autoSync: autoSync ?? this.autoSync,
      syncOnCellular: syncOnCellular ?? this.syncOnCellular,
      syncTypes: syncTypes ?? this.syncTypes,
      metadata: metadata ?? this.metadata,
    );
  }
}

class CloudConfig {
  final CloudProvider provider;
  final String? apiKey;
  final String? bucketName;
  final String? region;
  final String? endpoint;
  final Map<String, String> credentials;
  final bool encryptionEnabled;
  final String? encryptionKey;

  const CloudConfig({
    required this.provider,
    this.apiKey,
    this.bucketName,
    this.region,
    this.endpoint,
    this.credentials = const {},
    this.encryptionEnabled = true,
    this.encryptionKey,
  });

  factory CloudConfig.fromJson(Map<String, dynamic> json) {
    return CloudConfig(
      provider: CloudProvider.values.byName(json['provider']),
      apiKey: json['apiKey'] as String?,
      bucketName: json['bucketName'] as String?,
      region: json['region'] as String?,
      endpoint: json['endpoint'] as String?,
      credentials: Map<String, String>.from(json['credentials'] ?? {}),
      encryptionEnabled: json['encryptionEnabled'] as bool? ?? true,
      encryptionKey: json['encryptionKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'apiKey': apiKey,
      'bucketName': bucketName,
      'region': region,
      'endpoint': endpoint,
      'credentials': credentials,
      'encryptionEnabled': encryptionEnabled,
      'encryptionKey': encryptionKey,
    };
  }

  CloudConfig copyWith({
    CloudProvider? provider,
    String? apiKey,
    String? bucketName,
    String? region,
    String? endpoint,
    Map<String, String>? credentials,
    bool? encryptionEnabled,
    String? encryptionKey,
  }) {
    return CloudConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      bucketName: bucketName ?? this.bucketName,
      region: region ?? this.region,
      endpoint: endpoint ?? this.endpoint,
      credentials: credentials ?? this.credentials,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }
}

class SyncSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SyncStatus status;
  final SyncDirection direction;
  final List<SyncItem> items;
  final int totalItems;
  final int completedItems;
  final int failedItems;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const SyncSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.direction,
    this.items = const [],
    this.totalItems = 0,
    this.completedItems = 0,
    this.failedItems = 0,
    this.errorMessage,
    this.metadata = const {},
  });

  factory SyncSession.fromJson(Map<String, dynamic> json) {
    return SyncSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      status: SyncStatus.values.byName(json['status']),
      direction: SyncDirection.values.byName(json['direction']),
      items: (json['items'] as List<dynamic>?)
          ?.map((i) => SyncItem.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      totalItems: json['totalItems'] as int? ?? 0,
      completedItems: json['completedItems'] as int? ?? 0,
      failedItems: json['failedItems'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.name,
      'direction': direction.name,
      'items': items.map((i) => i.toJson()).toList(),
      'totalItems': totalItems,
      'completedItems': completedItems,
      'failedItems': failedItems,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  double get progress {
    if (totalItems == 0) return 0.0;
    return completedItems / totalItems;
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => status == SyncStatus.inProgress;
  bool get isCompleted => status == SyncStatus.completed;
  bool get hasErrors => failedItems > 0 || status == SyncStatus.error;
}

class SyncItem {
  final String id;
  final String type;
  final String name;
  final SyncItemStatus status;
  final DateTime? syncTime;
  final int? size;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const SyncItem({
    required this.id,
    required this.type,
    required this.name,
    this.status = SyncItemStatus.pending,
    this.syncTime,
    this.size,
    this.errorMessage,
    this.metadata = const {},
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      status: SyncItemStatus.values.byName(json['status'] ?? 'pending'),
      syncTime: json['syncTime'] != null 
          ? DateTime.parse(json['syncTime'] as String) 
          : null,
      size: json['size'] as int?,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'status': status.name,
      'syncTime': syncTime?.toIso8601String(),
      'size': size,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }
}

enum CloudProvider {
  aws,
  azure,
  googleCloud,
  dropbox,
  custom,
}

enum SyncFrequency {
  manual,
  realtime,
  hourly,
  daily,
  weekly,
  monthly,
}

enum SyncStatus {
  pending,
  inProgress,
  completed,
  error,
  cancelled,
  paused,
}

enum SyncDirection {
  upload,
  download,
  bidirectional,
}

enum SyncItemStatus {
  pending,
  inProgress,
  completed,
  error,
  skipped,
}

extension CloudProviderExtension on CloudProvider {
  String get displayName {
    switch (this) {
      case CloudProvider.aws:
        return 'Amazon S3';
      case CloudProvider.azure:
        return 'Azure Blob Storage';
      case CloudProvider.googleCloud:
        return 'Google Cloud Storage';
      case CloudProvider.dropbox:
        return 'Dropbox';
      case CloudProvider.custom:
        return 'Custom Provider';
    }
  }
}

extension SyncFrequencyExtension on SyncFrequency {
  String get displayName {
    switch (this) {
      case SyncFrequency.manual:
        return 'Manual';
      case SyncFrequency.realtime:
        return 'Real-time';
      case SyncFrequency.hourly:
        return 'Hourly';
      case SyncFrequency.daily:
        return 'Daily';
      case SyncFrequency.weekly:
        return 'Weekly';
      case SyncFrequency.monthly:
        return 'Monthly';
    }
  }
}