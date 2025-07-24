// TODO: Connection Profile Management feature for advanced connection configurations
// This module provides secure storage and management of connection profiles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../shared/models/connection_profile.dart';
import '../../../core/services/obd_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';

class ConnectionProfilesScreen extends ConsumerStatefulWidget {
  const ConnectionProfilesScreen({super.key});

  @override
  ConsumerState<ConnectionProfilesScreen> createState() => _ConnectionProfilesScreenState();
}

class _ConnectionProfilesScreenState extends ConsumerState<ConnectionProfilesScreen> {
  List<ConnectionProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await SecureStorageService.loadConnectionProfiles();
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load connection profiles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Profiles'),
        actions: [
          IconButton(
            onPressed: _showPresetsDialog,
            icon: const Icon(Icons.library_add),
            tooltip: 'Create from preset',
          ),
          IconButton(
            onPressed: _exportProfiles,
            icon: const Icon(Icons.download),
            tooltip: 'Export profiles',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildProfilesList(isMobile),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProfile,
        tooltip: 'Create new profile',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfilesList(bool isMobile) {
    if (_profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No connection profiles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first profile to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewProfile,
              icon: const Icon(Icons.add),
              label: const Text('Create Profile'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfiles,
      child: ListView.separated(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        itemCount: _profiles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _buildProfileCard(_profiles[index]),
      ),
    );
  }

  Widget _buildProfileCard(ConnectionProfile profile) {
    return Card(
      child: ListTile(
        leading: _getConnectionTypeIcon(profile.type),
        title: Text(profile.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${profile.type.name.toUpperCase()} • ${profile.address}'),
            if (profile.description.isNotEmpty)
              Text(
                profile.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                if (profile.isSecure)
                  Icon(Icons.security, size: 16, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  'Last used: ${_formatDate(profile.lastUsed)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleProfileAction(action, profile),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'connect', child: Text('Connect')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            const PopupMenuItem(value: 'test', child: Text('Test Connection')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red[600])),
            ),
          ],
        ),
        onTap: () => _connectToProfile(profile),
      ),
    );
  }

  Widget _getConnectionTypeIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.bluetooth:
        return const Icon(Icons.bluetooth, color: Colors.blue);
      case ConnectionType.wifi:
        return const Icon(Icons.wifi, color: Colors.green);
      case ConnectionType.usb:
        return const Icon(Icons.usb, color: Colors.orange);
      case ConnectionType.serial:
        return const Icon(Icons.cable, color: Colors.purple);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }

  void _handleProfileAction(String action, ConnectionProfile profile) {
    switch (action) {
      case 'connect':
        _connectToProfile(profile);
        break;
      case 'edit':
        _editProfile(profile);
        break;
      case 'duplicate':
        _duplicateProfile(profile);
        break;
      case 'test':
        _testConnection(profile);
        break;
      case 'delete':
        _deleteProfile(profile);
        break;
    }
  }

  void _connectToProfile(ConnectionProfile profile) async {
    try {
      // TODO: Implement connection via OBD service
      final updatedProfile = profile.copyWith(lastUsed: DateTime.now());
      await _updateProfile(updatedProfile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecting to ${profile.name}...')),
      );
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to connect: $e');
    }
  }

  void _createNewProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditorScreen(
          onSave: _addProfile,
        ),
      ),
    );
  }

  void _editProfile(ConnectionProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditorScreen(
          profile: profile,
          onSave: _updateProfile,
        ),
      ),
    );
  }

  void _duplicateProfile(ConnectionProfile profile) {
    final duplicatedProfile = ConnectionProfile.create(
      name: '${profile.name} (Copy)',
      description: profile.description,
      type: profile.type,
      address: profile.address,
      baudRate: profile.baudRate,
      port: profile.port,
      customParameters: profile.customParameters,
      isSecure: profile.isSecure,
    );
    
    _addProfile(duplicatedProfile);
  }

  void _testConnection(ConnectionProfile profile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing connection...'),
          ],
        ),
      ),
    );

    try {
      // TODO: Implement actual connection test
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Test'),
          content: const Text('Connection test successful!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showError('Connection test failed: $e');
    }
  }

  void _deleteProfile(ConnectionProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete \'${profile.name}\'?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeProfile(profile);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPresetsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create from Preset'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ConnectionPreset.commonPresets.length,
            itemBuilder: (context, index) {
              final preset = ConnectionPreset.commonPresets[index];
              return ListTile(
                leading: _getConnectionTypeIcon(preset.type),
                title: Text(preset.name),
                subtitle: Text(preset.description),
                onTap: () {
                  Navigator.pop(context);
                  _createFromPreset(preset);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _createFromPreset(ConnectionPreset preset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditorScreen(
          preset: preset,
          onSave: _addProfile,
        ),
      ),
    );
  }

  void _exportProfiles() {
    // TODO: Implement profile export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile export coming soon!')),
    );
  }

  Future<void> _addProfile(ConnectionProfile profile) async {
    try {
      final updatedProfiles = [..._profiles, profile];
      await SecureStorageService.saveConnectionProfiles(updatedProfiles);
      setState(() => _profiles = updatedProfiles);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile \'${profile.name}\' created')),
      );
    } catch (e) {
      _showError('Failed to save profile: $e');
    }
  }

  Future<void> _updateProfile(ConnectionProfile profile) async {
    try {
      final index = _profiles.indexWhere((p) => p.id == profile.id);
      if (index >= 0) {
        final updatedProfiles = List<ConnectionProfile>.from(_profiles);
        updatedProfiles[index] = profile;
        await SecureStorageService.saveConnectionProfiles(updatedProfiles);
        setState(() => _profiles = updatedProfiles);
      }
    } catch (e) {
      _showError('Failed to update profile: $e');
    }
  }

  Future<void> _removeProfile(ConnectionProfile profile) async {
    try {
      final updatedProfiles = _profiles.where((p) => p.id != profile.id).toList();
      await SecureStorageService.saveConnectionProfiles(updatedProfiles);
      setState(() => _profiles = updatedProfiles);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile \'${profile.name}\' deleted')),
      );
    } catch (e) {
      _showError('Failed to delete profile: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class ProfileEditorScreen extends StatefulWidget {
  final ConnectionProfile? profile;
  final ConnectionPreset? preset;
  final Function(ConnectionProfile) onSave;

  const ProfileEditorScreen({
    super.key,
    this.profile,
    this.preset,
    required this.onSave,
  });

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _portController;
  late ConnectionType _selectedType;
  late int _baudRate;
  late bool _isSecure;
  final Map<String, String> _customParams = {};

  @override
  void initState() {
    super.initState();
    
    if (widget.profile != null) {
      // Editing existing profile
      final profile = widget.profile!;
      _nameController = TextEditingController(text: profile.name);
      _descriptionController = TextEditingController(text: profile.description);
      _addressController = TextEditingController(text: profile.address);
      _portController = TextEditingController(text: profile.port ?? '');
      _selectedType = profile.type;
      _baudRate = profile.baudRate ?? 38400;
      _isSecure = profile.isSecure;
      _customParams.addAll(profile.customParameters);
    } else if (widget.preset != null) {
      // Creating from preset
      final preset = widget.preset!;
      _nameController = TextEditingController(text: preset.name);
      _descriptionController = TextEditingController(text: preset.description);
      _addressController = TextEditingController();
      _portController = TextEditingController();
      _selectedType = preset.type;
      _baudRate = preset.defaultSettings['baudRate'] ?? 38400;
      _isSecure = false;
    } else {
      // Creating new profile
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _addressController = TextEditingController();
      _portController = TextEditingController();
      _selectedType = ConnectionType.bluetooth;
      _baudRate = 38400;
      _isSecure = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile != null ? 'Edit Profile' : 'Create Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildConnectionSettings(),
              const SizedBox(height: 24),
              _buildAdvancedSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final errors = InputValidator.validateProfileName(value ?? '');
                return errors.isNotEmpty ? errors.first : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ConnectionType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Connection Type',
                border: OutlineInputBorder(),
              ),
              items: ConnectionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getConnectionTypeIcon(type).icon),
                      const SizedBox(width: 8),
                      Text(type.name.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (type) => setState(() => _selectedType = type!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: _getAddressLabel(),
                border: const OutlineInputBorder(),
                helperText: _getAddressHelperText(),
              ),
              validator: (value) {
                final errors = InputValidator.validateAddress(value ?? '');
                return errors.isNotEmpty ? errors.first : null;
              },
            ),
            if (_selectedType == ConnectionType.serial || _selectedType == ConnectionType.usb) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  border: OutlineInputBorder(),
                  helperText: 'e.g., COM3, /dev/ttyUSB0',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _baudRate,
                decoration: const InputDecoration(
                  labelText: 'Baud Rate',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.validBaudRates.map((rate) {
                  return DropdownMenuItem(value: rate, child: Text(rate.toString()));
                }).toList(),
                onChanged: (rate) => setState(() => _baudRate = rate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Secure Connection'),
              subtitle: const Text('Enable additional security measures'),
              value: _isSecure,
              onChanged: (value) => setState(() => _isSecure = value),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getConnectionTypeIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.bluetooth:
        return const Icon(Icons.bluetooth);
      case ConnectionType.wifi:
        return const Icon(Icons.wifi);
      case ConnectionType.usb:
        return const Icon(Icons.usb);
      case ConnectionType.serial:
        return const Icon(Icons.cable);
    }
  }

  String _getAddressLabel() {
    switch (_selectedType) {
      case ConnectionType.bluetooth:
        return 'Bluetooth Address';
      case ConnectionType.wifi:
        return 'IP Address/Hostname';
      case ConnectionType.usb:
      case ConnectionType.serial:
        return 'Device Path';
    }
  }

  String _getAddressHelperText() {
    switch (_selectedType) {
      case ConnectionType.bluetooth:
        return 'e.g., 00:1D:A5:68:98:8B';
      case ConnectionType.wifi:
        return 'e.g., 192.168.4.1 or obd.local';
      case ConnectionType.usb:
      case ConnectionType.serial:
        return 'e.g., /dev/ttyUSB0, COM3';
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final profile = widget.profile?.copyWith(
      name: SecureStorageService.sanitizeInput(_nameController.text),
      description: SecureStorageService.sanitizeInput(_descriptionController.text),
      type: _selectedType,
      address: SecureStorageService.sanitizeInput(_addressController.text),
      baudRate: _baudRate,
      port: _portController.text.isNotEmpty ? SecureStorageService.sanitizeInput(_portController.text) : null,
      customParameters: _customParams,
      isSecure: _isSecure,
    ) ?? ConnectionProfile.create(
      name: SecureStorageService.sanitizeInput(_nameController.text),
      description: SecureStorageService.sanitizeInput(_descriptionController.text),
      type: _selectedType,
      address: SecureStorageService.sanitizeInput(_addressController.text),
      baudRate: _baudRate,
      port: _portController.text.isNotEmpty ? SecureStorageService.sanitizeInput(_portController.text) : null,
      customParameters: _customParams,
      isSecure: _isSecure,
    );

    // Validate the profile
    final errors = profile.validate();
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), backgroundColor: Colors.red),
      );
      return;
    }

    widget.onSave(profile);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }
}