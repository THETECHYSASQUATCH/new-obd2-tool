import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import '../../shared/models/cloud_sync.dart';
import '../../shared/models/obd_response.dart';
import 'secure_storage_service.dart';

class CloudSyncService {
  static const String _settingsKey = 'cloud_sync_settings';
  static final StreamController<SyncSession> _syncController = 
      StreamController<SyncSession>.broadcast();
  
  static CloudSyncSettings? _settings;
  static SyncSession? _currentSession;
  static Timer? _autoSyncTimer;

  static Stream<SyncSession> get syncStream => _syncController.stream;
  static CloudSyncSettings? get settings => _settings;
  static SyncSession? get currentSession => _currentSession;
  static bool get isConfigured => _settings?.enabled == true && _settings?.cloudConfig != null;

  /// Initialize the cloud sync service
  static Future<void> initialize() async {
    try {
      await _loadSettings();
      if (_settings?.enabled == true && _settings?.cloudConfig?.autoSync == true) {
        _startAutoSync();
      }
      debugPrint('Cloud Sync Service initialized');
    } catch (e) {
      debugPrint('Error initializing Cloud Sync Service: $e');
    }
  }

  /// Configure cloud sync settings
  static Future<void> configure(CloudSyncSettings settings) async {
    _settings = settings;
    await _saveSettings();
    
    if (settings.enabled && settings.cloudConfig?.autoSync == true) {
      _startAutoSync();
    } else {
      _stopAutoSync();
    }
    
    debugPrint('Cloud sync configured: ${settings.enabled}');
  }

  /// Test cloud connection
  static Future<bool> testConnection(CloudConfig config) async {
    try {
      final response = await http.get(
        Uri.parse('${config.endpoint}/health'),
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  /// Start manual sync
  static Future<SyncSession> startSync({List<String>? dataTypes}) async {
    if (!isConfigured) {
      throw Exception('Cloud sync not configured');
    }

    if (_currentSession?.status == SyncStatus.syncing) {
      throw Exception('Sync already in progress');
    }

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentSession = SyncSession(
      id: sessionId,
      startTime: DateTime.now(),
      status: SyncStatus.syncing,
    );

    _syncController.add(_currentSession!);

    // Start sync process asynchronously
    _runSyncSession(dataTypes ?? _settings!.syncDataTypes);

    return _currentSession!;
  }

  /// Create backup
  static Future<BackupMetadata> createBackup({
    String? name,
    List<String>? dataTypes,
    String? description,
  }) async {
    if (!isConfigured) {
      throw Exception('Cloud sync not configured');
    }

    final backupId = DateTime.now().millisecondsSinceEpoch.toString();
    final backupName = name ?? 'Backup_${DateTime.now().toIso8601String()}';
    final includedTypes = dataTypes ?? _settings!.syncDataTypes;

    // Collect data to backup
    final backupData = await _collectDataForBackup(includedTypes);
    
    // Compress if enabled
    List<int> finalData;
    if (_settings!.cloudConfig!.compressData) {
      final encoder = GZipEncoder();
      finalData = encoder.encode(utf8.encode(jsonEncode(backupData)));
    } else {
      finalData = utf8.encode(jsonEncode(backupData));
    }

    // Calculate checksum
    final checksum = sha256.convert(finalData).toString();

    // Upload to cloud
    await _uploadToCloud('backups/$backupId.json', finalData);

    final metadata = BackupMetadata(
      id: backupId,
      name: backupName,
      createdAt: DateTime.now(),
      size: finalData.length,
      checksum: checksum,
      includedDataTypes: includedTypes,
      description: description,
    );

    // Save metadata
    await _uploadToCloud('backups/$backupId.meta.json', 
                        utf8.encode(jsonEncode(metadata.toJson())));

    debugPrint('Backup created: $backupName (${metadata.sizeFormatted})');
    return metadata;
  }

  /// Restore from backup
  static Future<void> restoreFromBackup(String backupId) async {
    if (!isConfigured) {
      throw Exception('Cloud sync not configured');
    }

    try {
      // Download metadata
      final metadataData = await _downloadFromCloud('backups/$backupId.meta.json');
      final metadata = BackupMetadata.fromJson(
        jsonDecode(utf8.decode(metadataData)) as Map<String, dynamic>
      );

      // Download backup data
      final backupData = await _downloadFromCloud('backups/$backupId.json');
      
      // Decompress if needed
      List<int> finalData;
      if (_settings!.cloudConfig!.compressData) {
        final decoder = GZipDecoder();
        finalData = decoder.decodeBytes(backupData);
      } else {
        finalData = backupData;
      }

      // Verify checksum
      final checksum = sha256.convert(_settings!.cloudConfig!.compressData ? backupData : finalData).toString();
      if (checksum != metadata.checksum) {
        throw Exception('Backup data integrity check failed');
      }

      // Parse and restore data
      final restoredData = jsonDecode(utf8.decode(finalData)) as Map<String, dynamic>;
      await _restoreData(restoredData, metadata.includedDataTypes);

      debugPrint('Backup restored successfully: ${metadata.name}');
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  /// Get available backups
  static Future<List<BackupMetadata>> getAvailableBackups() async {
    if (!isConfigured) {
      throw Exception('Cloud sync not configured');
    }

    try {
      // In a real implementation, this would list files from cloud storage
      // For now, return empty list
      return [];
    } catch (e) {
      debugPrint('Error getting backups: $e');
      return [];
    }
  }

  /// Delete backup
  static Future<void> deleteBackup(String backupId) async {
    if (!isConfigured) {
      throw Exception('Cloud sync not configured');
    }

    try {
      await _deleteFromCloud('backups/$backupId.json');
      await _deleteFromCloud('backups/$backupId.meta.json');
      debugPrint('Backup deleted: $backupId');
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      rethrow;
    }
  }

  /// Clean old backups
  static Future<void> cleanOldBackups() async {
    if (!isConfigured) return;

    final maxAge = _settings!.maxBackupAgeDays;
    final cutoffDate = DateTime.now().subtract(Duration(days: maxAge));
    
    final backups = await getAvailableBackups();
    final oldBackups = backups.where((backup) => backup.createdAt.isBefore(cutoffDate));
    
    for (final backup in oldBackups) {
      try {
        await deleteBackup(backup.id);
        debugPrint('Deleted old backup: ${backup.name}');
      } catch (e) {
        debugPrint('Error deleting old backup ${backup.name}: $e');
      }
    }
  }

  static Future<void> _runSyncSession(List<String> dataTypes) async {
    if (_currentSession == null) return;

    try {
      // Collect data to sync
      final dataToSync = await _collectDataForSync(dataTypes);
      
      _currentSession = _currentSession!.copyWith(
        totalItems: dataToSync.length,
      );
      _syncController.add(_currentSession!);

      final syncedIds = <String>[];
      final failedIds = <String>[];

      // Sync each data item
      for (final data in dataToSync) {
        try {
          await _syncDataItem(data);
          syncedIds.add(data.id);
          
          _currentSession = _currentSession!.copyWith(
            syncedItems: syncedIds.length,
            syncedDataIds: syncedIds,
          );
          _syncController.add(_currentSession!);
        } catch (e) {
          failedIds.add(data.id);
          
          _currentSession = _currentSession!.copyWith(
            failedItems: failedIds.length,
            failedDataIds: failedIds,
          );
          _syncController.add(_currentSession!);
        }
      }

      // Complete session
      _currentSession = _currentSession!.copyWith(
        status: SyncStatus.completed,
        endTime: DateTime.now(),
      );
      _syncController.add(_currentSession!);

      debugPrint('Sync completed: ${syncedIds.length} synced, ${failedIds.length} failed');

    } catch (e) {
      _currentSession = _currentSession!.copyWith(
        status: SyncStatus.error,
        endTime: DateTime.now(),
        errorMessage: e.toString(),
      );
      _syncController.add(_currentSession!);
      debugPrint('Sync failed: $e');
    }
  }

  static Future<List<SyncData>> _collectDataForSync(List<String> dataTypes) async {
    final data = <SyncData>[];
    
    // In a real implementation, collect actual data based on types
    // For now, return empty list
    
    return data;
  }

  static Future<Map<String, dynamic>> _collectDataForBackup(List<String> dataTypes) async {
    final backupData = <String, dynamic>{};
    
    // In a real implementation, collect actual data based on types
    backupData['timestamp'] = DateTime.now().toIso8601String();
    backupData['dataTypes'] = dataTypes;
    backupData['version'] = '1.0';
    
    return backupData;
  }

  static Future<void> _syncDataItem(SyncData data) async {
    // Simulate sync operation
    await Future.delayed(const Duration(milliseconds: 500));
    
    final jsonData = jsonEncode(data.toJson());
    await _uploadToCloud('data/${data.type}/${data.id}.json', utf8.encode(jsonData));
  }

  static Future<void> _restoreData(Map<String, dynamic> data, List<String> dataTypes) async {
    // In a real implementation, restore the actual data
    debugPrint('Restoring data types: $dataTypes');
  }

  static Future<void> _uploadToCloud(String path, List<int> data) async {
    // Simulate cloud upload
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_settings?.cloudConfig == null) {
      throw Exception('Cloud configuration not available');
    }
    
    // In a real implementation, upload to actual cloud service
    debugPrint('Uploaded to cloud: $path (${data.length} bytes)');
  }

  static Future<List<int>> _downloadFromCloud(String path) async {
    // Simulate cloud download
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_settings?.cloudConfig == null) {
      throw Exception('Cloud configuration not available');
    }
    
    // In a real implementation, download from actual cloud service
    debugPrint('Downloaded from cloud: $path');
    return utf8.encode('{}'); // Empty JSON as placeholder
  }

  static Future<void> _deleteFromCloud(String path) async {
    // Simulate cloud deletion
    await Future.delayed(const Duration(milliseconds: 100));
    
    debugPrint('Deleted from cloud: $path');
  }

  static Future<void> _loadSettings() async {
    try {
      final preferences = await SecureStorageService.loadUserPreferences();
      if (preferences.containsKey(_settingsKey)) {
        final settingsData = preferences[_settingsKey];
        if (settingsData is Map<String, dynamic>) {
          _settings = CloudSyncSettings.fromJson(settingsData);
        }
      }
    } catch (e) {
      debugPrint('Error loading cloud sync settings: $e');
      _settings = const CloudSyncSettings();
    }
  }

  static Future<void> _saveSettings() async {
    if (_settings != null) {
      try {
        final preferences = await SecureStorageService.loadUserPreferences();
        preferences[_settingsKey] = _settings!.toJson();
        await SecureStorageService.saveUserPreferences(preferences);
      } catch (e) {
        debugPrint('Error saving cloud sync settings: $e');
      }
    }
  }

  static void _startAutoSync() {
    _stopAutoSync();
    
    if (_settings?.cloudConfig?.syncIntervalMinutes != null) {
      final interval = Duration(minutes: _settings!.cloudConfig!.syncIntervalMinutes);
      
      _autoSyncTimer = Timer.periodic(interval, (timer) {
        if (isConfigured && _currentSession?.status != SyncStatus.syncing) {
          debugPrint('Starting automatic sync');
          startSync().catchError((e) {
            debugPrint('Auto-sync failed: $e');
          });
        }
      });
    }
  }

  static void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  static void dispose() {
    _stopAutoSync();
    _syncController.close();
  }
}