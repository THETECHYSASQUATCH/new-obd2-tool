import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/obd_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/services/ecu_programming_service.dart';
import '../../core/services/cloud_sync_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/connection_config.dart';
import '../models/obd_response.dart';
import '../models/language_config.dart';
import '../models/vehicle_info.dart';
import '../models/ecu_programming.dart';
import '../models/cloud_sync.dart';

// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageConfig>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<LanguageConfig> {
  static const String _keyLanguage = 'selected_language';
  
  LanguageNotifier() : super(LanguageConfig.supportedLanguages.first) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_keyLanguage) ?? 'en';
      final language = LanguageConfig.fromCode(languageCode) ?? 
                      LanguageConfig.supportedLanguages.first;
      
      state = language;
      await LocalizationService.initialize(language.code);
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> setLanguage(LanguageConfig language) async {
    try {
      state = language;
      await LocalizationService.switchLanguage(language.code);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, language.code);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  List<LanguageConfig> get supportedLanguages => LanguageConfig.supportedLanguages;
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(AppConstants.keyThemeMode) ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyThemeMode, theme.index);
  }
}

// OBD Service provider
final obdServiceProvider = Provider<OBDService>((ref) {
  return OBDService();
});

// Connection status provider
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final obdService = ref.watch(obdServiceProvider);
  return obdService.connectionStatus;
});

// OBD data stream provider
final obdDataStreamProvider = StreamProvider<OBDResponse>((ref) {
  final obdService = ref.watch(obdServiceProvider);
  return obdService.dataStream;
});

// Current connection config provider
final currentConnectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionConfig?>((ref) {
  return ConnectionNotifier(ref);
});

class ConnectionNotifier extends StateNotifier<ConnectionConfig?> {
  final Ref ref;

  ConnectionNotifier(this.ref) : super(null) {
    _loadLastConnection();
  }

  Future<void> _loadLastConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectionJson = prefs.getString(AppConstants.keyLastConnection);
      if (connectionJson != null) {
        // In a real app, you'd parse the JSON here
        // For now, we'll keep it null
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setConnection(ConnectionConfig config) async {
    state = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyLastConnection, 
      config.toJson().toString(),
    );
  }

  void clearConnection() {
    state = null;
  }
}

// Available devices provider
final availableDevicesProvider = FutureProvider<List<String>>((ref) async {
  final obdService = ref.read(obdServiceProvider);
  return await obdService.scanForDevices();
});

// Live data providers for specific parameters
final engineRpmProvider = StateNotifierProvider<LiveDataNotifier<double>, double?>((ref) {
  return LiveDataNotifier<double>(ref, '010C');
});

final vehicleSpeedProvider = StateNotifierProvider<LiveDataNotifier<double>, double?>((ref) {
  return LiveDataNotifier<double>(ref, '010D');
});

final coolantTempProvider = StateNotifierProvider<LiveDataNotifier<double>, double?>((ref) {
  return LiveDataNotifier<double>(ref, '0105');
});

final engineLoadProvider = StateNotifierProvider<LiveDataNotifier<double>, double?>((ref) {
  return LiveDataNotifier<double>(ref, '0104');
});

class LiveDataNotifier<T> extends StateNotifier<T?> {
  final Ref ref;
  final String pid;

  LiveDataNotifier(this.ref, this.pid) : super(null) {
    _listenToDataStream();
  }

  void _listenToDataStream() {
    ref.listen(obdDataStreamProvider, (previous, next) {
      next.when(
        data: (response) {
          if (response.command == pid && !response.isError) {
            final value = response.parsedData?['value'];
            if (value is T) {
              state = value;
            }
          }
        },
        loading: () {},
        error: (error, stackTrace) {},
      );
    });
  }

  Future<void> requestUpdate() async {
    try {
      final obdService = ref.read(obdServiceProvider);
      if (obdService.isConnected) {
        await obdService.sendCommand(pid);
      }
    } catch (e) {
      // Handle error
    }
  }
}

// Diagnostic history provider
final diagnosticHistoryProvider = StateNotifierProvider<DiagnosticHistoryNotifier, List<OBDResponse>>((ref) {
  return DiagnosticHistoryNotifier();
});

class DiagnosticHistoryNotifier extends StateNotifier<List<OBDResponse>> {
  DiagnosticHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(AppConstants.keyDiagnosticHistory);
      if (historyJson != null) {
        // In a real app, you'd parse the JSON list here
        // For now, we'll keep it empty
      }
    } catch (e) {
      // Handle error
    }
  }

  void addResponse(OBDResponse response) {
    state = [response, ...state];
    _saveHistory();
  }

  void clearHistory() {
    state = [];
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = state.take(100).map((e) => e.toJson().toString()).toList();
      await prefs.setStringList(
        AppConstants.keyDiagnosticHistory, 
        historyJson,
      );
    } catch (e) {
      // Handle error
    }
  }
}

// Connection action provider
final connectionActionsProvider = Provider<ConnectionActions>((ref) {
  return ConnectionActions(ref);
});

class ConnectionActions {
  final Ref ref;

  ConnectionActions(this.ref);

  Future<bool> connect(ConnectionConfig config) async {
    try {
      final obdService = ref.read(obdServiceProvider);
      final success = await obdService.connect(config);
      if (success) {
        ref.read(currentConnectionProvider.notifier).setConnection(config);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      final obdService = ref.read(obdServiceProvider);
      await obdService.disconnect();
      ref.read(currentConnectionProvider.notifier).clearConnection();
    } catch (e) {
      // Handle error
    }
  }

  Future<OBDResponse> sendCommand(String command) async {
    final obdService = ref.read(obdServiceProvider);
    final response = await obdService.sendCommand(command);
    ref.read(diagnosticHistoryProvider.notifier).addResponse(response);
    return response;
  }
}

// Vehicle selection providers
final selectedVehicleProvider = StateNotifierProvider<SelectedVehicleNotifier, VehicleInfo?>((ref) {
  return SelectedVehicleNotifier();
});

class SelectedVehicleNotifier extends StateNotifier<VehicleInfo?> {
  static const String _keySelectedVehicle = 'selected_vehicle';

  SelectedVehicleNotifier() : super(null) {
    _loadSelectedVehicle();
  }

  Future<void> _loadSelectedVehicle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehicleJson = prefs.getString(_keySelectedVehicle);
      if (vehicleJson != null) {
        // In a real implementation, parse the vehicle from JSON
        // For now, we'll set it to null
      }
    } catch (e) {
      debugPrint('Error loading selected vehicle: $e');
    }
  }

  Future<void> setVehicle(VehicleInfo? vehicle) async {
    state = vehicle;
    VehicleService.setSelectedVehicle(vehicle);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (vehicle != null) {
        await prefs.setString(_keySelectedVehicle, vehicle.toJson().toString());
      } else {
        await prefs.remove(_keySelectedVehicle);
      }
    } catch (e) {
      debugPrint('Error saving selected vehicle: $e');
    }
  }
}

// Vehicle service providers
final vehicleDatabaseProvider = FutureProvider<VehicleDatabase?>((ref) async {
  await VehicleService.initialize();
  return VehicleService.database;
});

final availableMakesProvider = Provider<List<String>>((ref) {
  return VehicleService.getAvailableMakes();
});

// ECU Programming providers
final discoveredEcusProvider = StateNotifierProvider<DiscoveredEcusNotifier, List<EcuInfo>>((ref) {
  return DiscoveredEcusNotifier();
});

class DiscoveredEcusNotifier extends StateNotifier<List<EcuInfo>> {
  DiscoveredEcusNotifier() : super([]);

  Future<void> discoverEcus() async {
    try {
      final ecus = await EcuProgrammingService.discoverEcus();
      state = ecus;
    } catch (e) {
      debugPrint('Error discovering ECUs: $e');
      state = [];
    }
  }

  void clearEcus() {
    state = [];
  }
}

final programmingSessionsProvider = StreamProvider<ProgrammingSession>((ref) {
  return EcuProgrammingService.sessionStream;
});

final activeSessionsProvider = Provider<List<ProgrammingSession>>((ref) {
  return EcuProgrammingService.getActiveSessions();
});

// Cloud sync providers
final cloudSyncSettingsProvider = StateNotifierProvider<CloudSyncSettingsNotifier, CloudSyncSettings?>((ref) {
  return CloudSyncSettingsNotifier();
});

class CloudSyncSettingsNotifier extends StateNotifier<CloudSyncSettings?> {
  CloudSyncSettingsNotifier() : super(null) {
    _loadSettings();
  }

  void _loadSettings() {
    state = CloudSyncService.settings;
  }

  Future<void> updateSettings(CloudSyncSettings settings) async {
    await CloudSyncService.configure(settings);
    state = settings;
  }
}

final syncSessionProvider = StreamProvider<SyncSession>((ref) {
  return CloudSyncService.syncStream;
});

final cloudConfiguredProvider = Provider<bool>((ref) {
  return CloudSyncService.isConfigured;
});

// Service initialization provider
final servicesInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    await Future.wait([
      VehicleService.initialize(),
      EcuProgrammingService.initialize(),
      CloudSyncService.initialize(),
    ]);
    return true;
  } catch (e) {
    debugPrint('Error initializing services: $e');
    return false;
  }
});