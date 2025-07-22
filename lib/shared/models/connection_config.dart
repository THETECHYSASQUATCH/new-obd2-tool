import '../services/obd_service.dart';

class ConnectionConfig {
  final ConnectionType type;
  final String name;
  final String address;
  final int? baudRate;
  final String? port;
  
  const ConnectionConfig({
    required this.type,
    required this.name,
    required this.address,
    this.baudRate,
    this.port,
  });
  
  factory ConnectionConfig.bluetooth({
    required String name,
    required String address,
  }) {
    return ConnectionConfig(
      type: ConnectionType.bluetooth,
      name: name,
      address: address,
    );
  }
  
  factory ConnectionConfig.serial({
    required String port,
    int baudRate = 38400,
  }) {
    return ConnectionConfig(
      type: ConnectionType.serial,
      name: 'Serial $port',
      address: port,
      baudRate: baudRate,
      port: port,
    );
  }
  
  factory ConnectionConfig.wifi({
    required String name,
    required String address,
  }) {
    return ConnectionConfig(
      type: ConnectionType.wifi,
      name: name,
      address: address,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'address': address,
      'baudRate': baudRate,
      'port': port,
    };
  }
  
  factory ConnectionConfig.fromJson(Map<String, dynamic> json) {
    return ConnectionConfig(
      type: ConnectionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConnectionType.bluetooth,
      ),
      name: json['name'],
      address: json['address'],
      baudRate: json['baudRate'],
      port: json['port'],
    );
  }
  
  @override
  String toString() {
    return 'ConnectionConfig(type: $type, name: $name, address: $address)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionConfig &&
        other.type == type &&
        other.name == name &&
        other.address == address &&
        other.baudRate == baudRate &&
        other.port == port;
  }
  
  @override
  int get hashCode {
    return type.hashCode ^
        name.hashCode ^
        address.hashCode ^
        baudRate.hashCode ^
        port.hashCode;
  }
}