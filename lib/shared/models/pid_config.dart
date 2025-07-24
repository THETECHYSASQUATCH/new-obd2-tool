// TODO: Enhanced PID configuration model for user-customizable live data display
// This file provides models for managing which PIDs to display and how to display them

import '../../core/constants/app_constants.dart';

/// Configuration for a single PID display
class PidDisplayConfig {
  final String pid;
  final String displayName;
  final bool isEnabled;
  final int displayOrder;
  final bool showProgressBar;
  final double? customMinValue;
  final double? customMaxValue;
  final int updateIntervalMs;
  
  const PidDisplayConfig({
    required this.pid,
    required this.displayName,
    this.isEnabled = true,
    this.displayOrder = 0,
    this.showProgressBar = true,
    this.customMinValue,
    this.customMaxValue,
    this.updateIntervalMs = 1000,
  });
  
  /// Get PID metadata from constants
  Map<String, dynamic>? get pidMetadata => AppConstants.standardPids[pid];
  
  /// Get display unit for this PID
  String get unit => pidMetadata?['unit'] ?? '';
  
  /// Get category for this PID
  String get category => pidMetadata?['category'] ?? 'Unknown';
  
  /// Check if this PID can be displayed as live data
  bool get canDisplay => pidMetadata?['canDisplay'] ?? false;
  
  /// Get effective min value (custom or default)
  double? get minValue => customMinValue ?? pidMetadata?['minValue'];
  
  /// Get effective max value (custom or default)
  double? get maxValue => customMaxValue ?? pidMetadata?['maxValue'];
  
  /// Create a copy with updated values
  PidDisplayConfig copyWith({
    String? displayName,
    bool? isEnabled,
    int? displayOrder,
    bool? showProgressBar,
    double? customMinValue,
    double? customMaxValue,
    int? updateIntervalMs,
  }) {
    return PidDisplayConfig(
      pid: pid,
      displayName: displayName ?? this.displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      displayOrder: displayOrder ?? this.displayOrder,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      customMinValue: customMinValue ?? this.customMinValue,
      customMaxValue: customMaxValue ?? this.customMaxValue,
      updateIntervalMs: updateIntervalMs ?? this.updateIntervalMs,
    );
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'displayName': displayName,
      'isEnabled': isEnabled,
      'displayOrder': displayOrder,
      'showProgressBar': showProgressBar,
      'customMinValue': customMinValue,
      'customMaxValue': customMaxValue,
      'updateIntervalMs': updateIntervalMs,
    };
  }
  
  /// Create from JSON
  factory PidDisplayConfig.fromJson(Map<String, dynamic> json) {
    return PidDisplayConfig(
      pid: json['pid'] as String,
      displayName: json['displayName'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      showProgressBar: json['showProgressBar'] as bool? ?? true,
      customMinValue: json['customMinValue'] as double?,
      customMaxValue: json['customMaxValue'] as double?,
      updateIntervalMs: json['updateIntervalMs'] as int? ?? 1000,
    );
  }
  
  /// Create default configuration from PID
  factory PidDisplayConfig.fromPid(String pid) {
    final metadata = AppConstants.standardPids[pid];
    return PidDisplayConfig(
      pid: pid,
      displayName: metadata?['name'] ?? 'Unknown PID $pid',
      displayOrder: metadata?['displayOrder'] ?? 999,
    );
  }
  
  @override
  String toString() {
    return 'PidDisplayConfig(pid: $pid, name: $displayName, enabled: $isEnabled)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PidDisplayConfig && other.pid == pid;
  }
  
  @override
  int get hashCode => pid.hashCode;
}

/// Collection of PID display configurations
class PidDisplayProfile {
  final String name;
  final String description;
  final List<PidDisplayConfig> pidConfigs;
  final DateTime lastModified;
  final bool isDefault;
  
  const PidDisplayProfile({
    required this.name,
    this.description = '',
    required this.pidConfigs,
    required this.lastModified,
    this.isDefault = false,
  });
  
  /// Get enabled PIDs sorted by display order
  List<PidDisplayConfig> get enabledPids {
    final enabled = pidConfigs.where((config) => config.isEnabled).toList();
    enabled.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return enabled;
  }
  
  /// Get PIDs grouped by category
  Map<String, List<PidDisplayConfig>> get pidsByCategory {
    final Map<String, List<PidDisplayConfig>> grouped = {};
    for (final config in pidConfigs) {
      final category = config.category;
      grouped.putIfAbsent(category, () => []).add(config);
    }
    return grouped;
  }
  
  /// Create a copy with updated values
  PidDisplayProfile copyWith({
    String? name,
    String? description,
    List<PidDisplayConfig>? pidConfigs,
    DateTime? lastModified,
    bool? isDefault,
  }) {
    return PidDisplayProfile(
      name: name ?? this.name,
      description: description ?? this.description,
      pidConfigs: pidConfigs ?? this.pidConfigs,
      lastModified: lastModified ?? this.lastModified,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'pidConfigs': pidConfigs.map((config) => config.toJson()).toList(),
      'lastModified': lastModified.toIso8601String(),
      'isDefault': isDefault,
    };
  }
  
  /// Create from JSON
  factory PidDisplayProfile.fromJson(Map<String, dynamic> json) {
    return PidDisplayProfile(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      pidConfigs: (json['pidConfigs'] as List<dynamic>)
          .map((config) => PidDisplayConfig.fromJson(config as Map<String, dynamic>))
          .toList(),
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
  
  /// Create default profile with commonly used PIDs
  factory PidDisplayProfile.createDefault() {
    return PidDisplayProfile(
      name: 'Default Dashboard',
      description: 'Standard engine and vehicle parameters',
      isDefault: true,
      lastModified: DateTime.now(),
      pidConfigs: [
        PidDisplayConfig.fromPid('010C'), // Engine RPM
        PidDisplayConfig.fromPid('010D'), // Vehicle Speed
        PidDisplayConfig.fromPid('0105'), // Coolant Temperature
        PidDisplayConfig.fromPid('0104'), // Engine Load
        PidDisplayConfig.fromPid('010F'), // Intake Air Temperature
        PidDisplayConfig.fromPid('0111'), // Throttle Position
        PidDisplayConfig.fromPid('010A'), // Fuel Pressure
        PidDisplayConfig.fromPid('010B'), // Manifold Pressure
      ],
    );
  }
  
  @override
  String toString() {
    return 'PidDisplayProfile(name: $name, pids: ${pidConfigs.length})';
  }
}