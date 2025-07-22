import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlatformInfo(context),
          const SizedBox(height: 24),
          _buildThemeSettings(context),
          const SizedBox(height: 24),
          _buildConnectionSettings(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildPlatformInfo(BuildContext context) {
    final platform = _getCurrentPlatform();
    final architecture = _getCurrentArchitecture();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Platform', platform),
            _buildInfoRow('Architecture', architecture),
            _buildInfoRow('Cross-Platform Support', 'Enabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('System default'),
              trailing: PopupMenuButton<AdaptiveThemeMode>(
                onSelected: (mode) {
                  AdaptiveTheme.of(context).setThemeMode(mode);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: AdaptiveThemeMode.light,
                    child: Text('Light'),
                  ),
                  const PopupMenuItem(
                    value: AdaptiveThemeMode.dark,
                    child: Text('Dark'),
                  ),
                  const PopupMenuItem(
                    value: AdaptiveThemeMode.system,
                    child: Text('System'),
                  ),
                ],
                child: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Auto-connect'),
              subtitle: const Text('Automatically connect to known devices'),
              value: true,
              onChanged: (value) {
                // TODO: Implement auto-connect setting
              },
            ),
            SwitchListTile(
              title: const Text('Background scanning'),
              subtitle: const Text('Keep scanning for OBD-II devices'),
              value: false,
              onChanged: (value) {
                // TODO: Implement background scanning setting
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build', '1'),
            _buildInfoRow('Cross-Platform', 'Flutter Framework'),
            const SizedBox(height: 12),
            const Text(
              'A professional OBD-II diagnostics and programming tool designed for cross-platform compatibility across iOS, Android, Windows, macOS, Linux, and ARM-based devices.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getCurrentPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
      default:
        return 'Web';
    }
  }

  String _getCurrentArchitecture() {
    // This is simplified - in a real app you'd use platform channels
    // to get the actual architecture information
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return 'ARM64';
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'x64/ARM64';
      case TargetPlatform.macOS:
        return 'ARM64 (Apple Silicon)';
      default:
        return 'Cross-Platform';
    }
  }
}