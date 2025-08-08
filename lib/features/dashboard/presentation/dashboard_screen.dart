import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../core/services/obd_service.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/connection_widget.dart';
import '../../../shared/widgets/live_data_widget.dart';
import '../../../shared/widgets/diagnostic_widget.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../history/presentation/history_screen.dart';
// TODO: Import new feature modules for enhanced functionality
import '../../pid_config/presentation/pid_configuration_screen.dart';
import '../../connection_profiles/presentation/connection_profiles_screen.dart';
// Version 1.1 new features
import '../../data_export/presentation/data_export_screen.dart';
import '../../custom_dashboard/presentation/custom_dashboard_screen.dart';
// Version 1.3 new features
import '../../ai_diagnostics/presentation/ai_diagnostics_screen.dart';
import '../../predictive_maintenance/presentation/predictive_maintenance_screen.dart';
import '../../telematics/presentation/telematics_screen.dart';
import '../../shop_management/presentation/shop_management_screen.dart';
// Ford, GM, VW, and Nissan specific tools
import '../../ford_tools/presentation/ford_tools_screen.dart';
import '../../gm_tools/presentation/gm_tools_screen.dart';
import '../../vw_tools/presentation/vw_tools_screen.dart';
import '../../nissan_tools/presentation/nissan_tools_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    
    if (isMobile) {
      return _buildMobileLayout(connectionStatus);
    } else if (isTablet) {
      return _buildTabletLayout(connectionStatus);
    } else {
      return _buildDesktopLayout(connectionStatus);
    }
  }

  Widget _buildMobileLayout(AsyncValue<ConnectionStatus> connectionStatus) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD-II Diagnostics'),
        actions: [
          _buildConnectionStatusIcon(connectionStatus),
          // TODO: Add quick access to new features
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'custom_dashboard',
                child: ListTile(
                  leading: Icon(Icons.dashboard_customize),
                  title: Text('Custom Dashboard'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'data_export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Data Export'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'pid_config',
                child: ListTile(
                  leading: Icon(Icons.tune),
                  title: Text('Configure PIDs'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'connection_profiles',
                child: ListTile(
                  leading: Icon(Icons.wifi),
                  title: Text('Connection Profiles'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Diagnostics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(AsyncValue<ConnectionStatus> connectionStatus) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD-II Diagnostics Tool'),
        actions: [
          _buildConnectionStatusIcon(connectionStatus),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bluetooth),
                label: Text('Connect'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Diagnostics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              // TODO: Add navigation to new feature modules
              NavigationRailDestination(
                icon: Icon(Icons.tune),
                label: Text('PID Config'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildCurrentPage()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AsyncValue<ConnectionStatus> connectionStatus) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD-II Diagnostics and Programming Tool'),
        toolbarHeight: 70,
        actions: [
          _buildConnectionStatusIcon(connectionStatus),
          const SizedBox(width: 24),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListView(
              children: [
                _buildNavigationTile(0, Icons.dashboard, 'Dashboard'),
                _buildNavigationTile(1, Icons.bluetooth, 'Connection'),
                _buildNavigationTile(2, Icons.analytics, 'Diagnostics'),
                _buildNavigationTile(3, Icons.history, 'History'),
                _buildNavigationTile(4, Icons.settings, 'Settings'),
                // Version 1.3 new features
                const Divider(),
                _buildNavigationTile(9, MdiIcons.brain, 'AI Diagnostics'),
                _buildNavigationTile(10, Icons.build, 'Predictive Maintenance'),
                _buildNavigationTile(11, MdiIcons.satellite, 'Telematics'),
                _buildNavigationTile(12, Icons.store, 'Shop Management'),
                const Divider(),
                // Manufacturer-specific tools
                _buildNavigationTile(13, Icons.precision_manufacturing, 'Ford Tools'),
                _buildNavigationTile(14, Icons.car_repair, 'GM Tools'),
                _buildNavigationTile(15, Icons.engineering, 'VW Tools'),
                _buildNavigationTile(16, Icons.directions_car, 'Nissan Tools'),
                const Divider(),
                // Existing features
                _buildNavigationTile(5, Icons.tune, 'PID Config'),
                _buildNavigationTile(6, Icons.wifi, 'Profiles'),
                _buildNavigationTile(7, Icons.dashboard_customize, 'Custom Dashboard'),
                _buildNavigationTile(8, Icons.download, 'Data Export'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildCurrentPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      onTap: () => setState(() => _selectedIndex = index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildConnectionStatusIcon(AsyncValue<ConnectionStatus> connectionStatus) {
    return connectionStatus.when(
      data: (status) {
        switch (status) {
          case ConnectionStatus.connected:
            return const Icon(Icons.bluetooth_connected, color: Colors.green);
          case ConnectionStatus.connecting:
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          case ConnectionStatus.error:
            return const Icon(Icons.bluetooth_disabled, color: Colors.red);
          case ConnectionStatus.disconnected:
          default:
            return const Icon(Icons.bluetooth, color: Colors.grey);
        }
      },
      loading: () => const Icon(Icons.bluetooth, color: Colors.grey),
      error: (_, __) => const Icon(Icons.error, color: Colors.red),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ConnectionWidget();
      case 2:
        return const DiagnosticWidget();
      case 3:
        return const HistoryScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return const PidConfigurationScreen();
      case 6:
        return const ConnectionProfilesScreen();
      case 7:
        return const CustomDashboardScreen();
      case 8:
        return const DataExportScreen();
      // Version 1.3 new features
      case 9:
        return const AIDiagnosticsScreen();
      case 10:
        return const PredictiveMaintenanceScreen();
      case 11:
        return const TelematicsScreen();
      case 12:
        return const ShopManagementScreen();
      // Manufacturer-specific tools
      case 13:
        return const FordToolsScreen();
      case 14:
        return const GMToolsScreen();
      case 15:
        return const VWToolsScreen();
      case 16:
        return const NissanToolsScreen();
      default:
        return const DashboardPage();
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'custom_dashboard':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomDashboardScreen()),
        );
        break;
      case 'data_export':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DataExportScreen()),
        );
        break;
      case 'pid_config':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PidConfigurationScreen()),
        );
        break;
      case 'connection_profiles':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnectionProfilesScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, connectionStatus),
          const SizedBox(height: 20),
          _buildLiveDataSection(context, isMobile),
          const SizedBox(height: 20),
          _buildQuickActionsSection(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AsyncValue<ConnectionStatus> connectionStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to OBD-II Diagnostics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cross-platform diagnostic tool for all your vehicle needs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            connectionStatus.when(
              data: (status) => _buildStatusChip(status),
              loading: () => const Chip(label: Text('Loading...')),
              error: (_, __) => const Chip(
                label: Text('Error'),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ConnectionStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case ConnectionStatus.connected:
        color = Colors.green;
        text = 'Connected';
        break;
      case ConnectionStatus.connecting:
        color = Colors.orange;
        text = 'Connecting...';
        break;
      case ConnectionStatus.error:
        color = Colors.red;
        text = 'Error';
        break;
      case ConnectionStatus.disconnected:
      default:
        color = Colors.grey;
        text = 'Disconnected';
        break;
    }
    
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
    );
  }

  Widget _buildLiveDataSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Vehicle Data',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Enhanced visualization with charts and real-time monitoring',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                children: [
                  LiveDataWidget(title: 'Engine RPM', provider: engineRpmProvider, unit: 'RPM'),
                  SizedBox(height: 12),
                  LiveDataWidget(title: 'Vehicle Speed', provider: vehicleSpeedProvider, unit: 'km/h'),
                  SizedBox(height: 12),
                  LiveDataWidget(title: 'Coolant Temp', provider: coolantTempProvider, unit: '°C'),
                  SizedBox(height: 12),
                  LiveDataWidget(title: 'Engine Load', provider: engineLoadProvider, unit: '%'),
                ],
              )
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 250,
                    child: LiveDataWidget(title: 'Engine RPM', provider: engineRpmProvider, unit: 'RPM'),
                  ),
                  SizedBox(
                    width: 250,
                    child: LiveDataWidget(title: 'Vehicle Speed', provider: vehicleSpeedProvider, unit: 'km/h'),
                  ),
                  SizedBox(
                    width: 250,
                    child: LiveDataWidget(title: 'Coolant Temp', provider: coolantTempProvider, unit: '°C'),
                  ),
                  SizedBox(
                    width: 250,
                    child: LiveDataWidget(title: 'Engine Load', provider: engineLoadProvider, unit: '%'),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _QuickActionButton(
                    icon: Icons.search,
                    title: 'Scan for DTCs',
                    subtitle: 'Check diagnostic trouble codes',
                    actionKind: QuickActionKind.scanDtcs,
                  ),
                  SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.clear,
                    title: 'Clear DTCs',
                    subtitle: 'Clear stored error codes',
                    actionKind: QuickActionKind.clearDtcs,
                  ),
                  SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.refresh,
                    title: 'Reset ECU',
                    subtitle: 'Reset engine control unit',
                    actionKind: QuickActionKind.resetEcu,
                  ),
                ],
              )
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 300,
                    child: _QuickActionButton(
                      icon: Icons.search,
                      title: 'Scan for DTCs',
                      subtitle: 'Check diagnostic trouble codes',
                      actionKind: QuickActionKind.scanDtcs,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: _QuickActionButton(
                      icon: Icons.clear,
                      title: 'Clear DTCs',
                      subtitle: 'Clear stored error codes',
                      actionKind: QuickActionKind.clearDtcs,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: _QuickActionButton(
                      icon: Icons.refresh,
                      title: 'Reset ECU',
                      subtitle: 'Reset engine control unit',
                      actionKind: QuickActionKind.resetEcu,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

enum QuickActionKind {
  scanDtcs,
  clearDtcs,
  resetEcu,
}

class _QuickActionButton extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final QuickActionKind actionKind;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionKind,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => _executeAction(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeAction(BuildContext context, WidgetRef ref) async {
    final obdService = ref.read(obdServiceProvider);
    final connectionStatus = ref.read(connectionStatusProvider);
    
    // Check connection status
    final isConnected = connectionStatus.value == ConnectionStatus.connected;
    if (!isConnected) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please connect to an OBD device first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      switch (actionKind) {
        case QuickActionKind.scanDtcs:
          await _scanDtcs(context, obdService);
          break;
        case QuickActionKind.clearDtcs:
          await _clearDtcs(context, obdService);
          break;
        case QuickActionKind.resetEcu:
          await _resetEcu(context, obdService);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scanDtcs(BuildContext context, OBDService obdService) async {
    if (!context.mounted) return;
    
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning for DTCs...')),
    );

    try {
      final response = await obdService.sendCommand('03');
      
      if (context.mounted) {
        if (response.isSuccess) {
          final dtcs = response.parsedData['dtcs'] as List<String>?;
          if (dtcs != null && dtcs.isNotEmpty) {
            _showDtcResults(context, dtcs);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No DTCs found'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to scan DTCs: ${response.errorMessage ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DTC scan failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearDtcs(BuildContext context, OBDService obdService) async {
    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear DTCs'),
        content: const Text('Are you sure you want to clear all diagnostic trouble codes? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear DTCs'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clearing DTCs...')),
    );

    try {
      final response = await obdService.sendCommand('04');
      
      if (context.mounted) {
        if (response.isSuccess) {
          final cleared = response.parsedData['cleared'] as bool? ?? false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cleared ? 'DTCs cleared successfully' : 'Failed to clear DTCs'),
              backgroundColor: cleared ? Colors.green : Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear DTCs: ${response.errorMessage ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DTC clear failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetEcu(BuildContext context, OBDService obdService) async {
    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset ECU'),
        content: const Text('Are you sure you want to reset the adapter and reinitialize? This will reset the connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resetting adapter...')),
    );

    try {
      await obdService.resetAdapterAndReinit();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adapter reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDtcResults(BuildContext context, List<String> dtcs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Found ${dtcs.length} DTC${dtcs.length == 1 ? '' : 's'}'),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dtcs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(dtcs[index]),
                dense: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}