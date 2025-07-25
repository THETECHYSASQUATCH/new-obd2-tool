import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/models/language_config.dart';
import '../../../shared/models/vehicle_info.dart';
import '../../../shared/models/cloud_sync.dart';

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends ConsumerState<AdvancedSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'settings.language'.tr, icon: const Icon(Icons.language)),
            Tab(text: 'Vehicle', icon: const Icon(Icons.directions_car)),
            Tab(text: 'Cloud Sync', icon: const Icon(Icons.cloud)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LanguageSettingsTab(),
          _VehicleSettingsTab(),
          _CloudSyncSettingsTab(),
        ],
      ),
    );
  }
}

class _LanguageSettingsTab extends ConsumerWidget {
  const _LanguageSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings.language'.tr,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select your preferred language for the application interface.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...LanguageConfig.supportedLanguages.map((language) {
                  return RadioListTile<LanguageConfig>(
                    title: Row(
                      children: [
                        // In a real app, you'd have flag icons here
                        const Icon(Icons.flag, size: 20),
                        const SizedBox(width: 8),
                        Text(language.nativeName),
                        const SizedBox(width: 8),
                        Text(
                          '(${language.name})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    value: language,
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        languageNotifier.setLanguage(value);
                      }
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleSettingsTab extends ConsumerStatefulWidget {
  const _VehicleSettingsTab();

  @override
  ConsumerState<_VehicleSettingsTab> createState() => _VehicleSettingsTabState();
}

class _VehicleSettingsTabState extends ConsumerState<_VehicleSettingsTab> {
  String? selectedMake;
  String? selectedModel;
  int? selectedYear;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final availableMakes = ref.watch(availableMakesProvider);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (selectedVehicle != null) ...[
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Current Vehicle'),
                    subtitle: Text(selectedVehicle.displayName),
                    trailing: TextButton(
                      onPressed: () {
                        ref.read(selectedVehicleProvider.notifier).setVehicle(null);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const Divider(),
                ],
                Text(
                  'Select Vehicle',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Make',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMake,
                  items: availableMakes.map((make) {
                    return DropdownMenuItem(value: make, child: Text(make));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMake = value;
                      selectedModel = null;
                      selectedYear = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedMake != null) ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedModel,
                    items: _getModelsForMake(selectedMake!).map((model) {
                      return DropdownMenuItem(value: model, child: Text(model));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedModel = value;
                        selectedYear = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (selectedModel != null) ...[
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedYear,
                    items: _getYearsForMakeModel(selectedMake!, selectedModel!).map((year) {
                      return DropdownMenuItem(value: year, child: Text(year.toString()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (selectedMake != null && selectedModel != null && selectedYear != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final vehicle = VehicleInfo(
                          make: selectedMake!,
                          model: selectedModel!,
                          year: selectedYear!,
                        );
                        ref.read(selectedVehicleProvider.notifier).setVehicle(vehicle);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Vehicle selected: ${vehicle.displayName}')),
                        );
                      },
                      child: const Text('Select Vehicle'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getModelsForMake(String make) {
    // In a real implementation, this would use the vehicle service
    switch (make) {
      case 'Toyota':
        return ['Camry', 'Prius', 'Corolla', 'RAV4'];
      case 'Ford':
        return ['F-150', 'Mustang', 'Explorer', 'Focus'];
      case 'Honda':
        return ['Civic', 'Accord', 'CR-V', 'Pilot'];
      case 'BMW':
        return ['3 Series', '5 Series', 'X3', 'X5'];
      case 'Mercedes-Benz':
        return ['C-Class', 'E-Class', 'GLC', 'GLE'];
      default:
        return ['OBD-II Vehicle'];
    }
  }

  List<int> _getYearsForMakeModel(String make, String model) {
    // Generate years from 2000 to current year + 1
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1999, (index) => currentYear + 1 - index);
  }
}

class _CloudSyncSettingsTab extends ConsumerStatefulWidget {
  const _CloudSyncSettingsTab();

  @override
  ConsumerState<_CloudSyncSettingsTab> createState() => _CloudSyncSettingsTabState();
}

class _CloudSyncSettingsTabState extends ConsumerState<_CloudSyncSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _apiKeyController = TextEditingController();
  
  CloudProvider _selectedProvider = CloudProvider.firebase;
  bool _autoSync = true;
  int _syncInterval = 30;
  bool _syncOnlyOnWifi = true;
  bool _compressData = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final settings = ref.read(cloudSyncSettingsProvider);
    if (settings?.cloudConfig != null) {
      final config = settings!.cloudConfig!;
      _endpointController.text = config.endpoint;
      _apiKeyController.text = config.apiKey;
      _selectedProvider = config.provider;
      _autoSync = config.autoSync;
      _syncInterval = config.syncIntervalMinutes;
      _syncOnlyOnWifi = config.syncOnlyOnWifi;
      _compressData = config.compressData;
    }
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSettings = ref.watch(cloudSyncSettingsProvider);
    final isConfigured = ref.watch(cloudConfiguredProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isConfigured ? Icons.cloud_done : Icons.cloud_off,
                      color: isConfigured ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cloud Sync Configuration',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Cloud Sync'),
                  subtitle: const Text('Backup and sync diagnostic data to the cloud'),
                  value: currentSettings?.enabled ?? false,
                  onChanged: (value) {
                    if (value && !isConfigured) {
                      _showConfigurationDialog();
                    } else {
                      _updateSettings(enabled: value);
                    }
                  },
                ),
                if (isConfigured) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Cloud Configuration'),
                    subtitle: Text('Provider: ${_selectedProvider.name}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showConfigurationDialog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Create Backup'),
                    subtitle: const Text('Manually backup diagnostic data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _createBackup,
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Sync Now'),
                    subtitle: const Text('Start manual synchronization'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _startSync,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showConfigurationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloud Configuration'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CloudProvider>(
                  decoration: const InputDecoration(labelText: 'Provider'),
                  value: _selectedProvider,
                  items: CloudProvider.values.map((provider) {
                    return DropdownMenuItem(
                      value: provider,
                      child: Text(provider.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedProvider = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endpointController,
                  decoration: const InputDecoration(labelText: 'Endpoint URL'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Auto Sync'),
                  value: _autoSync,
                  onChanged: (value) => setState(() => _autoSync = value),
                ),
                if (_autoSync) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _syncInterval.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Sync Interval (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _syncInterval = int.tryParse(value) ?? 30;
                    },
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('WiFi Only'),
                  subtitle: const Text('Sync only when connected to WiFi'),
                  value: _syncOnlyOnWifi,
                  onChanged: (value) => setState(() => _syncOnlyOnWifi = value),
                ),
                SwitchListTile(
                  title: const Text('Compress Data'),
                  subtitle: const Text('Reduce data usage with compression'),
                  value: _compressData,
                  onChanged: (value) => setState(() => _compressData = value),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveConfiguration,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveConfiguration() {
    if (_formKey.currentState?.validate() ?? false) {
      final config = CloudConfig(
        provider: _selectedProvider,
        endpoint: _endpointController.text,
        apiKey: _apiKeyController.text,
        autoSync: _autoSync,
        syncIntervalMinutes: _syncInterval,
        syncOnlyOnWifi: _syncOnlyOnWifi,
        compressData: _compressData,
      );

      final settings = CloudSyncSettings(
        enabled: true,
        cloudConfig: config,
      );

      ref.read(cloudSyncSettingsProvider.notifier).updateSettings(settings);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud configuration saved')),
      );
    }
  }

  void _updateSettings({bool? enabled}) {
    final currentSettings = ref.read(cloudSyncSettingsProvider);
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(enabled: enabled);
      ref.read(cloudSyncSettingsProvider.notifier).updateSettings(updatedSettings);
    }
  }

  void _createBackup() {
    // TODO: Implement backup creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating backup...')),
    );
  }

  void _startSync() {
    // TODO: Implement manual sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting sync...')),
    );
  }
}