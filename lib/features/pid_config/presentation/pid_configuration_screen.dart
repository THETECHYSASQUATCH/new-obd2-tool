// TODO: PID Configuration feature module for user-customizable live data display
// This module provides the UI and logic for users to configure which PIDs to display

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../shared/models/pid_config.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';

class PidConfigurationScreen extends ConsumerStatefulWidget {
  const PidConfigurationScreen({super.key});

  @override
  ConsumerState<PidConfigurationScreen> createState() => _PidConfigurationScreenState();
}

class _PidConfigurationScreenState extends ConsumerState<PidConfigurationScreen> {
  late PidDisplayProfile _currentProfile;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load current profile from provider
    _currentProfile = PidDisplayProfile.createDefault();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PID Configuration'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveConfiguration,
              child: const Text('Save'),
            ),
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildCategoryTabs(),
            const SizedBox(height: 20),
            _buildPidList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCustomPidDialog,
        tooltip: 'Add custom PID',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentProfile.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_currentProfile.description.isNotEmpty)
                        Text(
                          _currentProfile.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _editProfileInfo,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit profile info',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text('${_currentProfile.enabledPids.length} enabled'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                Chip(
                  label: Text('${_currentProfile.pidConfigs.length} total'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
                if (_currentProfile.isDefault)
                  const Chip(
                    label: Text('Default'),
                    backgroundColor: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = _currentProfile.pidsByCategory;
    
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: categories.keys.map((category) => Tab(text: category)).toList(),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: categories.entries.map((entry) {
                return _buildCategoryPidList(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPidList(String category, List<PidDisplayConfig> pids) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: pids.length,
      itemBuilder: (context, index) {
        final pidConfig = pids[index];
        return _buildPidConfigTile(pidConfig);
      },
    );
  }

  Widget _buildPidList() {
    final enabledPids = _currentProfile.enabledPids;
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Display Order',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: enabledPids.length,
            itemBuilder: (context, index) {
              final pidConfig = enabledPids[index];
              return _buildReorderablePidTile(pidConfig, index);
            },
            onReorder: _reorderPids,
          ),
        ],
      ),
    );
  }

  Widget _buildPidConfigTile(PidDisplayConfig pidConfig) {
    return ListTile(
      key: ValueKey(pidConfig.pid),
      leading: Switch(
        value: pidConfig.isEnabled,
        onChanged: (enabled) => _updatePidConfig(pidConfig.copyWith(isEnabled: enabled)),
      ),
      title: Text(pidConfig.displayName),
      subtitle: Text('${pidConfig.pid} • ${pidConfig.unit}'),
      trailing: IconButton(
        onPressed: () => _editPidConfig(pidConfig),
        icon: const Icon(Icons.settings),
      ),
    );
  }

  Widget _buildReorderablePidTile(PidDisplayConfig pidConfig, int index) {
    return ListTile(
      key: ValueKey(pidConfig.pid),
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(pidConfig.displayName),
      subtitle: Text('${pidConfig.pid} • ${pidConfig.unit}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _editPidConfig(pidConfig),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _updatePidConfig(pidConfig.copyWith(isEnabled: false)),
            icon: const Icon(Icons.visibility_off),
          ),
        ],
      ),
    );
  }

  void _updatePidConfig(PidDisplayConfig newConfig) {
    setState(() {
      final index = _currentProfile.pidConfigs.indexWhere((p) => p.pid == newConfig.pid);
      if (index >= 0) {
        final updatedConfigs = List<PidDisplayConfig>.from(_currentProfile.pidConfigs);
        updatedConfigs[index] = newConfig;
        _currentProfile = _currentProfile.copyWith(
          pidConfigs: updatedConfigs,
          lastModified: DateTime.now(),
        );
        _hasChanges = true;
      }
    });
  }

  void _reorderPids(int oldIndex, int newIndex) {
    setState(() {
      final enabledPids = _currentProfile.enabledPids;
      if (oldIndex < newIndex) newIndex -= 1;
      
      final pidConfig = enabledPids.removeAt(oldIndex);
      enabledPids.insert(newIndex, pidConfig);
      
      // Update display orders
      for (int i = 0; i < enabledPids.length; i++) {
        _updatePidConfig(enabledPids[i].copyWith(displayOrder: i));
      }
      _hasChanges = true;
    });
  }

  void _editPidConfig(PidDisplayConfig pidConfig) {
    showDialog(
      context: context,
      builder: (context) => _PidConfigDialog(
        pidConfig: pidConfig,
        onSave: _updatePidConfig,
      ),
    );
  }

  void _editProfileInfo() {
    showDialog(
      context: context,
      builder: (context) => _ProfileInfoDialog(
        profile: _currentProfile,
        onSave: (name, description) {
          setState(() {
            _currentProfile = _currentProfile.copyWith(
              name: name,
              description: description,
              lastModified: DateTime.now(),
            );
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _showCustomPidDialog() {
    // TODO: Implement custom PID addition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom PID addition coming soon!')),
    );
  }

  void _saveConfiguration() async {
    try {
      // TODO: Save to secure storage via provider
      setState(() {
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save configuration: $e')),
      );
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all PID configurations to default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentProfile = PidDisplayProfile.createDefault();
                _hasChanges = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _PidConfigDialog extends StatefulWidget {
  final PidDisplayConfig pidConfig;
  final Function(PidDisplayConfig) onSave;

  const _PidConfigDialog({
    required this.pidConfig,
    required this.onSave,
  });

  @override
  State<_PidConfigDialog> createState() => _PidConfigDialogState();
}

class _PidConfigDialogState extends State<_PidConfigDialog> {
  late TextEditingController _nameController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late TextEditingController _intervalController;
  late bool _showProgressBar;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pidConfig.displayName);
    _minController = TextEditingController(text: widget.pidConfig.customMinValue?.toString() ?? '');
    _maxController = TextEditingController(text: widget.pidConfig.customMaxValue?.toString() ?? '');
    _intervalController = TextEditingController(text: widget.pidConfig.updateIntervalMs.toString());
    _showProgressBar = widget.pidConfig.showProgressBar;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure ${widget.pidConfig.pid}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    decoration: const InputDecoration(labelText: 'Min Value'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    decoration: const InputDecoration(labelText: 'Max Value'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _intervalController,
              decoration: const InputDecoration(labelText: 'Update Interval (ms)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Progress Bar'),
              value: _showProgressBar,
              onChanged: (value) => setState(() => _showProgressBar = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final updatedConfig = widget.pidConfig.copyWith(
      displayName: _nameController.text,
      customMinValue: double.tryParse(_minController.text),
      customMaxValue: double.tryParse(_maxController.text),
      updateIntervalMs: int.tryParse(_intervalController.text) ?? 1000,
      showProgressBar: _showProgressBar,
    );
    
    widget.onSave(updatedConfig);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _intervalController.dispose();
    super.dispose();
  }
}

class _ProfileInfoDialog extends StatefulWidget {
  final PidDisplayProfile profile;
  final Function(String, String) onSave;

  const _ProfileInfoDialog({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_ProfileInfoDialog> createState() => _ProfileInfoDialogState();
}

class _ProfileInfoDialogState extends State<_ProfileInfoDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _descriptionController = TextEditingController(text: widget.profile.description);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile Info'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Profile Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_nameController.text, _descriptionController.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}