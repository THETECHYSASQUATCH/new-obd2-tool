import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/vehicle_info.dart';

class VehicleService {
  static VehicleDatabase? _database;
  static VehicleInfo? _selectedVehicle;

  static VehicleDatabase? get database => _database;
  static VehicleInfo? get selectedVehicle => _selectedVehicle;

  /// Initialize the vehicle database from JSON
  static Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/vehicle_database.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _database = VehicleDatabase.fromJson(json);
      debugPrint('Vehicle database loaded with ${_database!.availableMakes.length} manufacturers');
    } catch (e) {
      debugPrint('Error loading vehicle database: $e');
      // Create minimal fallback database
      _database = const VehicleDatabase(
        vehiclesByMake: {
          'Generic': [
            VehicleInfo(
              make: 'Generic',
              model: 'OBD-II Vehicle',
              year: 2023,
              supportedProtocols: ['ISO9141-2', 'KWP2000', 'CAN'],
            ),
          ],
        },
        manufacturerConfigs: {},
      );
    }
  }

  /// Set the selected vehicle for diagnostics
  static void setSelectedVehicle(VehicleInfo? vehicle) {
    _selectedVehicle = vehicle;
    debugPrint('Selected vehicle: ${vehicle?.displayName ?? 'None'}');
  }

  /// Get manufacturer-specific PIDs for the selected vehicle
  static Map<String, String> getManufacturerPids() {
    if (_selectedVehicle == null || _database == null) return {};
    
    final config = _database!.getManufacturerConfig(_selectedVehicle!.make);
    return config?.customPids ?? {};
  }

  /// Get preferred OBD protocols for the selected vehicle
  static List<String> getPreferredProtocols() {
    if (_selectedVehicle == null) return ['ISO9141-2', 'KWP2000', 'CAN'];
    
    final config = _database?.getManufacturerConfig(_selectedVehicle!.make);
    return config?.preferredProtocols ?? _selectedVehicle!.supportedProtocols;
  }

  /// Get manufacturer-specific DTC descriptions
  static String? getDTCDescription(String dtcCode) {
    if (_selectedVehicle == null || _database == null) return null;
    
    final config = _database!.getManufacturerConfig(_selectedVehicle!.make);
    return config?.dtcLookup[dtcCode];
  }

  /// Check if ECU programming is supported for the selected vehicle
  static bool isEcuProgrammingSupported() {
    if (_selectedVehicle == null || _database == null) return false;
    
    final config = _database!.getManufacturerConfig(_selectedVehicle!.make);
    return config?.ecuProgrammingSupport != null;
  }

  /// Get ECU programming configuration
  static Map<String, dynamic>? getEcuProgrammingConfig() {
    if (_selectedVehicle == null || _database == null) return null;
    
    final config = _database!.getManufacturerConfig(_selectedVehicle!.make);
    return config?.ecuProgrammingSupport;
  }

  /// Search vehicles by make, model, or year
  static List<VehicleInfo> searchVehicles(String query) {
    if (_database == null || query.isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    final results = <VehicleInfo>[];
    
    for (final vehicles in _database!.vehiclesByMake.values) {
      for (final vehicle in vehicles) {
        if (vehicle.make.toLowerCase().contains(queryLower) ||
            vehicle.model.toLowerCase().contains(queryLower) ||
            vehicle.year.toString().contains(query) ||
            vehicle.displayName.toLowerCase().contains(queryLower)) {
          results.add(vehicle);
        }
      }
    }
    
    return results;
  }

  /// Get all vehicles for a specific make
  static List<VehicleInfo> getVehiclesForMake(String make) {
    return _database?.getModelsForMake(make) ?? [];
  }

  /// Get all available makes
  static List<String> getAvailableMakes() {
    return _database?.availableMakes ?? [];
  }

  /// Get models for a specific make
  static List<String> getModelsForMake(String make) {
    final vehicles = getVehiclesForMake(make);
    return vehicles.map((v) => v.model).toSet().toList()..sort();
  }

  /// Get years for a specific make and model
  static List<int> getYearsForMakeModel(String make, String model) {
    return _database?.getYearsForMakeModel(make, model) ?? [];
  }
}