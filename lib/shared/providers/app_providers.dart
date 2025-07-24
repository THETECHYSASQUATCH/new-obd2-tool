import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/obd_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/connection_config.dart';
import '../models/obd_response.dart';

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