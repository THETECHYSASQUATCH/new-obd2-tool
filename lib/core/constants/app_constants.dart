class AppConstants {
  static const String appName = 'OBD-II Diagnostics Tool';
  static const String appVersion = '1.2.0';
  static const String appDescription = 'Cross-platform OBD-II diagnostics and programming tool';
  
  // OBD-II Protocol Constants
  static const int obdDefaultBaudRate = 38400;
  static const int obdTimeoutMs = 5000;
  static const String obdInitCommand = 'ATZ';
  static const String obdEchoOffCommand = 'ATE0';
  static const String obdProtocolAutoCommand = 'ATSP0';
  
  // Standard OBD-II PIDs with enhanced metadata
  static const Map<String, Map<String, dynamic>> standardPids = {
    '0100': {'name': 'PIDs supported [01-20]', 'unit': '', 'category': 'System', 'displayOrder': 0, 'canDisplay': false},
    '0101': {'name': 'Monitor status since DTCs cleared', 'unit': '', 'category': 'System', 'displayOrder': 1, 'canDisplay': false},
    '0102': {'name': 'Freeze DTC', 'unit': '', 'category': 'System', 'displayOrder': 2, 'canDisplay': false},
    '0103': {'name': 'Fuel system status', 'unit': '', 'category': 'Fuel', 'displayOrder': 3, 'canDisplay': true},
    '0104': {'name': 'Calculated engine load', 'unit': '%', 'category': 'Engine', 'displayOrder': 4, 'canDisplay': true, 'minValue': 0, 'maxValue': 100},
    '0105': {'name': 'Engine coolant temperature', 'unit': '°C', 'category': 'Engine', 'displayOrder': 5, 'canDisplay': true, 'minValue': -40, 'maxValue': 215},
    '0106': {'name': 'Short term fuel trim—Bank 1', 'unit': '%', 'category': 'Fuel', 'displayOrder': 6, 'canDisplay': true, 'minValue': -100, 'maxValue': 99.2},
    '0107': {'name': 'Long term fuel trim—Bank 1', 'unit': '%', 'category': 'Fuel', 'displayOrder': 7, 'canDisplay': true, 'minValue': -100, 'maxValue': 99.2},
    '0108': {'name': 'Short term fuel trim—Bank 2', 'unit': '%', 'category': 'Fuel', 'displayOrder': 8, 'canDisplay': true, 'minValue': -100, 'maxValue': 99.2},
    '0109': {'name': 'Long term fuel trim—Bank 2', 'unit': '%', 'category': 'Fuel', 'displayOrder': 9, 'canDisplay': true, 'minValue': -100, 'maxValue': 99.2},
    '010A': {'name': 'Fuel pressure', 'unit': 'kPa', 'category': 'Fuel', 'displayOrder': 10, 'canDisplay': true, 'minValue': 0, 'maxValue': 765},
    '010B': {'name': 'Intake manifold absolute pressure', 'unit': 'kPa', 'category': 'Engine', 'displayOrder': 11, 'canDisplay': true, 'minValue': 0, 'maxValue': 255},
    '010C': {'name': 'Engine RPM', 'unit': 'RPM', 'category': 'Engine', 'displayOrder': 12, 'canDisplay': true, 'minValue': 0, 'maxValue': 16383.75},
    '010D': {'name': 'Vehicle speed', 'unit': 'km/h', 'category': 'Vehicle', 'displayOrder': 13, 'canDisplay': true, 'minValue': 0, 'maxValue': 255},
    '010E': {'name': 'Timing advance', 'unit': '°', 'category': 'Engine', 'displayOrder': 14, 'canDisplay': true, 'minValue': -64, 'maxValue': 63.5},
    '010F': {'name': 'Intake air temperature', 'unit': '°C', 'category': 'Engine', 'displayOrder': 15, 'canDisplay': true, 'minValue': -40, 'maxValue': 215},
    '0110': {'name': 'MAF air flow rate', 'unit': 'g/s', 'category': 'Engine', 'displayOrder': 16, 'canDisplay': true, 'minValue': 0, 'maxValue': 655.35},
    '0111': {'name': 'Throttle position', 'unit': '%', 'category': 'Engine', 'displayOrder': 17, 'canDisplay': true, 'minValue': 0, 'maxValue': 100},
    // TODO: Add more PIDs as needed for comprehensive vehicle diagnostics
    '0112': {'name': 'Secondary air status', 'unit': '', 'category': 'Emissions', 'displayOrder': 18, 'canDisplay': true},
    '0113': {'name': 'Oxygen sensors present', 'unit': '', 'category': 'Emissions', 'displayOrder': 19, 'canDisplay': false},
    '0114': {'name': 'Oxygen sensor 1 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 20, 'canDisplay': true},
    '0115': {'name': 'Oxygen sensor 2 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 21, 'canDisplay': true},
    '0116': {'name': 'Oxygen sensor 3 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 22, 'canDisplay': true},
    '0117': {'name': 'Oxygen sensor 4 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 23, 'canDisplay': true},
    '0118': {'name': 'Oxygen sensor 5 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 24, 'canDisplay': true},
    '0119': {'name': 'Oxygen sensor 6 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 25, 'canDisplay': true},
    '011A': {'name': 'Oxygen sensor 7 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 26, 'canDisplay': true},
    '011B': {'name': 'Oxygen sensor 8 (voltage, trim)', 'unit': 'V, %', 'category': 'Emissions', 'displayOrder': 27, 'canDisplay': true},
    '011C': {'name': 'OBD standards this vehicle conforms to', 'unit': '', 'category': 'System', 'displayOrder': 28, 'canDisplay': false},
    '011D': {'name': 'Oxygen sensors present (4 banks)', 'unit': '', 'category': 'Emissions', 'displayOrder': 29, 'canDisplay': false},
    '011E': {'name': 'Auxiliary input status', 'unit': '', 'category': 'System', 'displayOrder': 30, 'canDisplay': true},
    '011F': {'name': 'Run time since engine start', 'unit': 's', 'category': 'Engine', 'displayOrder': 31, 'canDisplay': true, 'minValue': 0, 'maxValue': 65535},
  };

  // Legacy support - simple map of PID to name
  static Map<String, String> get pidNames => 
      standardPids.map((key, value) => MapEntry(key, value['name'] as String));
  
  // Error codes
  static const Map<String, String> dtcCategories = {
    'P0': 'Powertrain - Generic',
    'P1': 'Powertrain - Manufacturer Specific',
    'P2': 'Powertrain - Generic',
    'P3': 'Powertrain - Manufacturer Specific',
    'B0': 'Body - Generic',
    'B1': 'Body - Manufacturer Specific',
    'B2': 'Body - Generic',
    'B3': 'Body - Manufacturer Specific',
    'C0': 'Chassis - Generic',
    'C1': 'Chassis - Manufacturer Specific',
    'C2': 'Chassis - Generic',
    'C3': 'Chassis - Manufacturer Specific',
    'U0': 'Network - Generic',
    'U1': 'Network - Manufacturer Specific',
    'U2': 'Network - Generic',
    'U3': 'Network - Manufacturer Specific',
  };
  
  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLastConnection = 'last_connection';
  static const String keyConnectionHistory = 'connection_history';
  static const String keyDiagnosticHistory = 'diagnostic_history';
  // TODO: Add security features - encrypt sensitive connection data
  static const String keyConnectionProfiles = 'connection_profiles_encrypted';
  static const String keySelectedPids = 'selected_pids_for_display';
  static const String keyPidUpdateInterval = 'pid_update_interval_ms';
  static const String keyAppSettings = 'app_settings';
  
  // Platform-specific settings
  static const double mobileMaxWidth = 450;
  static const double tabletMaxWidth = 800;
  static const double desktopMaxWidth = 1920;
  
  // TODO: Security and validation constants for future implementation
  static const int maxConnectionNameLength = 50;
  static const int maxAddressLength = 100;
  static const int minUpdateInterval = 500; // milliseconds
  static const int maxUpdateInterval = 10000; // milliseconds
  static const List<int> validBaudRates = [9600, 19200, 38400, 57600, 115200];
}