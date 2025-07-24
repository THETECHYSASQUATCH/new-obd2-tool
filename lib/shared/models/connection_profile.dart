// TODO: Enhanced connection profile model with security features
// This file provides models for managing and securely storing connection profiles

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../../core/services/obd_service.dart';
import '../../core/constants/app_constants.dart';

/// Enhanced connection configuration with profile management
class ConnectionProfile {
  final String id;
  final String name;
  final String description;
  final ConnectionType type;
  final String address;
  final int? baudRate;
  final String? port;
  final Map<String, String> customParameters;
  final DateTime createdAt;
  final DateTime lastUsed;
  final bool isSecure;
  final String? encryptionKey; // TODO: Implement proper key management
  
  const ConnectionProfile({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.address,
    this.baudRate,
    this.port,
    this.customParameters = const {},
    required this.createdAt,
    required this.lastUsed,
    this.isSecure = false,
    this.encryptionKey,
  });
  
  /// Validate connection profile data
  List<String> validate() {
    final errors = <String>[];
    
    // Name validation
    if (name.trim().isEmpty) {
      errors.add('Profile name cannot be empty');
    }
    if (name.length > AppConstants.maxConnectionNameLength) {
      errors.add('Profile name too long (max ${AppConstants.maxConnectionNameLength} characters)');
    }
    
    // Address validation
    if (address.trim().isEmpty) {
      errors.add('Address/hostname cannot be empty');
    }
    if (address.length > AppConstants.maxAddressLength) {
      errors.add('Address too long (max ${AppConstants.maxAddressLength} characters)');
    }
    
    // Type-specific validation
    switch (type) {
      case ConnectionType.bluetooth:
        if (!_isValidBluetoothAddress(address)) {
          errors.add('Invalid Bluetooth address format (expected XX:XX:XX:XX:XX:XX)');
        }
        break;
      case ConnectionType.wifi:
        if (!_isValidIPAddress(address) && !_isValidHostname(address)) {
          errors.add('Invalid WiFi address (expected IP address or hostname)');
        }
        break;
      case ConnectionType.serial:
      case ConnectionType.usb:
        if (port == null || port!.trim().isEmpty) {
          errors.add('Serial/USB port must be specified');
        }
        if (baudRate != null && !AppConstants.validBaudRates.contains(baudRate)) {
          errors.add('Invalid baud rate (allowed: ${AppConstants.validBaudRates.join(', ')})');
        }
        break;
    }
    
    return errors;
  }
  
  /// Check if Bluetooth address format is valid
  bool _isValidBluetoothAddress(String address) {
    final btPattern = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return btPattern.hasMatch(address);
  }
  
  /// Check if IP address format is valid
  bool _isValidIPAddress(String address) {
    final ipPattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipPattern.hasMatch(address)) return false;
    
    final parts = address.split('.');
    return parts.every((part) => int.tryParse(part) != null && int.parse(part) <= 255);
  }
  
  /// Check if hostname format is valid
  bool _isValidHostname(String hostname) {
    final hostnamePattern = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');
    return hostnamePattern.hasMatch(hostname);
  }
  
  /// Convert to ConnectionConfig for OBD service
  ConnectionConfig toConnectionConfig() {
    switch (type) {
      case ConnectionType.bluetooth:
        return ConnectionConfig.bluetooth(name: name, address: address);
      case ConnectionType.wifi:
        return ConnectionConfig.wifi(name: name, address: address);
      case ConnectionType.serial:
      case ConnectionType.usb:
        return ConnectionConfig.serial(port: port ?? address, baudRate: baudRate ?? 38400);
    }
  }
  
  /// Create a copy with updated values
  ConnectionProfile copyWith({
    String? name,
    String? description,
    ConnectionType? type,
    String? address,
    int? baudRate,
    String? port,
    Map<String, String>? customParameters,
    DateTime? lastUsed,
    bool? isSecure,
    String? encryptionKey,
  }) {
    return ConnectionProfile(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      address: address ?? this.address,
      baudRate: baudRate ?? this.baudRate,
      port: port ?? this.port,
      customParameters: customParameters ?? this.customParameters,
      createdAt: createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isSecure: isSecure ?? this.isSecure,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }
  
  /// Convert to JSON for storage (with basic security measures)
  Map<String, dynamic> toJson({bool includeSecrets = false}) {
    final json = {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'address': address,
      'baudRate': baudRate,
      'port': port,
      'customParameters': customParameters,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'isSecure': isSecure,
    };
    
    // TODO: Implement proper encryption for sensitive data
    if (includeSecrets && encryptionKey != null) {
      json['encryptionKey'] = encryptionKey;
    }
    
    return json;
  }
  
  /// Create from JSON
  factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: ConnectionType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => ConnectionType.bluetooth,
      ),
      address: json['address'] as String,
      baudRate: json['baudRate'] as int?,
      port: json['port'] as String?,
      customParameters: Map<String, String>.from(json['customParameters'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      isSecure: json['isSecure'] as bool? ?? false,
      encryptionKey: json['encryptionKey'] as String?,
    );
  }
  
  /// Create a new profile with generated ID
  factory ConnectionProfile.create({
    required String name,
    String description = '',
    required ConnectionType type,
    required String address,
    int? baudRate,
    String? port,
    Map<String, String> customParameters = const {},
    bool isSecure = false,
  }) {
    final now = DateTime.now();
    return ConnectionProfile(
      id: _generateId(),
      name: name,
      description: description,
      type: type,
      address: address,
      baudRate: baudRate,
      port: port,
      customParameters: customParameters,
      createdAt: now,
      lastUsed: now,
      isSecure: isSecure,
    );
  }
  
  /// Generate a unique ID for the profile
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = List.generate(8, (i) => timestamp.toString().codeUnitAt(i % timestamp.toString().length));
    final bytes = Uint8List.fromList([...timestamp.toString().codeUnits, ...random]);
    return sha256.convert(bytes).toString().substring(0, 16);
  }
  
  @override
  String toString() {
    return 'ConnectionProfile(id: $id, name: $name, type: $type)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionProfile && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Quick connection preset for common OBD adapter types
class ConnectionPreset {
  final String name;
  final String description;
  final ConnectionType type;
  final Map<String, dynamic> defaultSettings;
  final List<String> supportedProtocols;
  
  const ConnectionPreset({
    required this.name,
    required this.description,
    required this.type,
    required this.defaultSettings,
    this.supportedProtocols = const [],
  });
  
  /// Create connection profile from preset
  ConnectionProfile createProfile({
    required String profileName,
    required String address,
    String? port,
    Map<String, String> customParams = const {},
  }) {
    return ConnectionProfile.create(
      name: profileName,
      description: 'Created from $name preset',
      type: type,
      address: address,
      baudRate: defaultSettings['baudRate'] as int?,
      port: port,
      customParameters: {...defaultSettings.map((k, v) => MapEntry(k, v.toString())), ...customParams},
    );
  }
  
  /// Common OBD adapter presets
  static const List<ConnectionPreset> commonPresets = [
    ConnectionPreset(
      name: 'ELM327 Bluetooth',
      description: 'Standard ELM327 Bluetooth adapter',
      type: ConnectionType.bluetooth,
      defaultSettings: {'baudRate': 38400, 'timeout': 5000},
      supportedProtocols: ['ISO 9141-2', 'ISO 14230-4 KWP', 'SAE J1850 PWM', 'SAE J1850 VPW', 'ISO 15765-4 CAN'],
    ),
    ConnectionPreset(
      name: 'WiFi OBD (ESP32)',
      description: 'ESP32-based WiFi OBD adapter',
      type: ConnectionType.wifi,
      defaultSettings: {'port': 35000, 'timeout': 3000},
      supportedProtocols: ['ISO 15765-4 CAN'],
    ),
    ConnectionPreset(
      name: 'USB Serial OBD',
      description: 'USB to serial OBD adapter',
      type: ConnectionType.serial,
      defaultSettings: {'baudRate': 115200, 'timeout': 2000},
      supportedProtocols: ['ISO 15765-4 CAN', 'ISO 9141-2'],
    ),
  ];
}