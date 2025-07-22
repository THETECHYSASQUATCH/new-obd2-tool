class AppConstants {
  static const String appName = 'OBD-II Diagnostics Tool';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Cross-platform OBD-II diagnostics and programming tool';
  
  // OBD-II Protocol Constants
  static const int obdDefaultBaudRate = 38400;
  static const int obdTimeoutMs = 5000;
  static const String obdInitCommand = 'ATZ';
  static const String obdEchoOffCommand = 'ATE0';
  static const String obdProtocolAutoCommand = 'ATSP0';
  
  // Standard OBD-II PIDs
  static const Map<String, String> standardPids = {
    '0100': 'PIDs supported [01-20]',
    '0101': 'Monitor status since DTCs cleared',
    '0102': 'Freeze DTC',
    '0103': 'Fuel system status',
    '0104': 'Calculated engine load',
    '0105': 'Engine coolant temperature',
    '0106': 'Short term fuel trim—Bank 1',
    '0107': 'Long term fuel trim—Bank 1',
    '0108': 'Short term fuel trim—Bank 2',
    '0109': 'Long term fuel trim—Bank 2',
    '010A': 'Fuel pressure',
    '010B': 'Intake manifold absolute pressure',
    '010C': 'Engine RPM',
    '010D': 'Vehicle speed',
    '010E': 'Timing advance',
    '010F': 'Intake air temperature',
    '0110': 'MAF air flow rate',
    '0111': 'Throttle position',
  };
  
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
  
  // Platform-specific settings
  static const double mobileMaxWidth = 450;
  static const double tabletMaxWidth = 800;
  static const double desktopMaxWidth = 1920;
}