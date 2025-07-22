import 'package:flutter/foundation.dart';

/// Represents an OBD-II device/adapter
class OBDDevice {
  final String id;
  final String name;
  final String address;
  final OBDConnectionType type;
  final bool isConnected;
  final int? rssi; // Signal strength for Bluetooth devices

  const OBDDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.isConnected = false,
    this.rssi,
  });

  OBDDevice copyWith({
    String? id,
    String? name,
    String? address,
    OBDConnectionType? type,
    bool? isConnected,
    int? rssi,
  }) {
    return OBDDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  String toString() {
    return 'OBDDevice{id: $id, name: $name, address: $address, type: $type, isConnected: $isConnected}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OBDDevice &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        type.hashCode;
  }
}

/// Types of OBD-II connections supported
enum OBDConnectionType {
  bluetooth('Bluetooth'),
  wifi('WiFi'),
  usb('USB'),
  serial('Serial');

  const OBDConnectionType(this.displayName);
  final String displayName;
}

/// Represents a Diagnostic Trouble Code (DTC)
class DiagnosticTroubleCode {
  final String code;
  final String description;
  final DTCStatus status;
  final DTCSeverity severity;
  final DateTime? detectedAt;
  final String? freezeFrameData;

  const DiagnosticTroubleCode({
    required this.code,
    required this.description,
    required this.status,
    required this.severity,
    this.detectedAt,
    this.freezeFrameData,
  });

  @override
  String toString() {
    return 'DTC{code: $code, description: $description, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticTroubleCode && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

/// Status of a diagnostic trouble code
enum DTCStatus {
  active('Active'),
  pending('Pending'),
  permanent('Permanent'),
  cleared('Cleared');

  const DTCStatus(this.displayName);
  final String displayName;
}

/// Severity levels for diagnostic trouble codes
enum DTCSeverity {
  critical('Critical'),
  major('Major'),
  minor('Minor'),
  info('Information');

  const DTCSeverity(this.displayName);
  final String displayName;
}

/// Represents vehicle information retrieved from OBD-II
class VehicleInfo {
  final String? vin;
  final String? make;
  final String? model;
  final int? year;
  final String? engine;
  final OBDProtocol? protocol;
  final Map<String, String> ecuInfo;

  const VehicleInfo({
    this.vin,
    this.make,
    this.model,
    this.year,
    this.engine,
    this.protocol,
    this.ecuInfo = const {},
  });

  VehicleInfo copyWith({
    String? vin,
    String? make,
    String? model,
    int? year,
    String? engine,
    OBDProtocol? protocol,
    Map<String, String>? ecuInfo,
  }) {
    return VehicleInfo(
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      engine: engine ?? this.engine,
      protocol: protocol ?? this.protocol,
      ecuInfo: ecuInfo ?? this.ecuInfo,
    );
  }

  @override
  String toString() {
    return 'VehicleInfo{vin: $vin, make: $make, model: $model, year: $year}';
  }
}

/// OBD-II protocols supported
enum OBDProtocol {
  iso9141('ISO 9141-2'),
  kwp2000('KWP2000'),
  canBus('CAN-BUS'),
  j1850VPW('J1850 VPW'),
  j1850PWM('J1850 PWM');

  const OBDProtocol(this.displayName);
  final String displayName;
}

/// Represents live data from vehicle sensors
class LiveDataPoint {
  final String pid;
  final String name;
  final dynamic value;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final DateTime timestamp;

  const LiveDataPoint({
    required this.pid,
    required this.name,
    required this.value,
    required this.unit,
    this.minValue,
    this.maxValue,
    required this.timestamp,
  });

  double get normalizedValue {
    if (minValue == null || maxValue == null) return 0.0;
    final numValue = value is num ? (value as num).toDouble() : 0.0;
    return (numValue - minValue!) / (maxValue! - minValue!);
  }

  @override
  String toString() {
    return 'LiveDataPoint{pid: $pid, name: $name, value: $value, unit: $unit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiveDataPoint && other.pid == pid;
  }

  @override
  int get hashCode => pid.hashCode;
}