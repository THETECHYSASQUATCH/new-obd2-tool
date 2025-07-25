import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../shared/widgets/responsive_layout.dart';
import '../models/telematics_data.dart';

class TelematicsScreen extends ConsumerStatefulWidget {
  const TelematicsScreen({super.key});

  @override
  ConsumerState<TelematicsScreen> createState() => _TelematicsScreenState();
}

class _TelematicsScreenState extends ConsumerState<TelematicsScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      tabletBody: _buildTabletLayout(),
      desktopBody: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Telematics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Telematics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 200, child: _NavigationSidebar()),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Vehicle Telematics Integration'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildRealTimeDataCard(),
          const SizedBox(height: 16),
          _buildTelematicsProvidersCard(),
          const SizedBox(height: 16),
          _buildDataStreamsCard(),
          const SizedBox(height: 16),
          _buildIntegrationStatusCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.satellite, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Telematics Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Real-time vehicle data integration from telematics providers enables enhanced diagnostics, fleet management, and predictive analytics.',
            ),
            const SizedBox(height: 16),
            _buildTelematicsMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildTelematicsMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Connected Vehicles',
            '24',
            Icons.directions_car,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Active Streams',
            '18',
            Icons.stream,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Data Points/Min',
            '1,247',
            Icons.data_usage,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRealTimeDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Real-Time Vehicle Data',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVehicleDataList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDataList() {
    return Column(
      children: [
        _buildDataTile(
          'Engine RPM',
          '2,450',
          'rpm',
          Icons.speed,
          Colors.blue,
          isHealthy: true,
        ),
        _buildDataTile(
          'Vehicle Speed',
          '65',
          'mph',
          Icons.speedometer,
          Colors.green,
          isHealthy: true,
        ),
        _buildDataTile(
          'Fuel Level',
          '78',
          '%',
          Icons.local_gas_station,
          Colors.green,
          isHealthy: true,
        ),
        _buildDataTile(
          'Engine Temperature',
          '195',
          '°F',
          Icons.thermostat,
          Colors.orange,
          isHealthy: false,
        ),
        _buildDataTile(
          'GPS Location',
          '40.7128, -74.0060',
          'lat/lng',
          Icons.location_on,
          Colors.blue,
          isHealthy: true,
        ),
      ],
    );
  }

  Widget _buildDataTile(String parameter, String value, String unit, IconData icon, Color color, {bool isHealthy = true}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(parameter),
      subtitle: Text('$value $unit'),
      trailing: Icon(
        isHealthy ? Icons.check_circle : Icons.warning,
        color: isHealthy ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildTelematicsProvidersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connected Providers',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildProviderTile(
              'Geotab',
              'Fleet management and GPS tracking',
              TelematicsProviderStatus.connected,
              '156 vehicles',
            ),
            _buildProviderTile(
              'Verizon Connect',
              'Vehicle tracking and driver behavior',
              TelematicsProviderStatus.connected,
              '89 vehicles',
            ),
            _buildProviderTile(
              'Samsara',
              'IoT fleet management platform',
              TelematicsProviderStatus.connecting,
              '42 vehicles',
            ),
            _buildProviderTile(
              'Fleet Complete',
              'GPS tracking and asset management',
              TelematicsProviderStatus.disconnected,
              '0 vehicles',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderTile(String name, String description, TelematicsProviderStatus status, String vehicleCount) {
    Color statusColor = status == TelematicsProviderStatus.connected ? Colors.green :
                       status == TelematicsProviderStatus.connecting ? Colors.orange : Colors.red;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(MdiIcons.satellite, color: statusColor),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            Text(vehicleCount, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(status.name.toUpperCase()),
              backgroundColor: statusColor.withOpacity(0.1),
              labelStyle: TextStyle(color: statusColor, fontSize: 10),
            ),
          ],
        ),
        onTap: () => _showProviderDetails(name),
      ),
    );
  }

  Widget _buildDataStreamsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Data Streams',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDataStreamTile(
              'GPS Tracking',
              'Real-time location data',
              'Every 30 seconds',
              Icons.location_on,
              Colors.blue,
              isActive: true,
            ),
            _buildDataStreamTile(
              'Engine Diagnostics',
              'OBD-II parameter monitoring',
              'Every 5 seconds',
              Icons.build,
              Colors.green,
              isActive: true,
            ),
            _buildDataStreamTile(
              'Driver Behavior',
              'Acceleration, braking, cornering',
              'Continuous',
              Icons.person,
              Colors.orange,
              isActive: true,
            ),
            _buildDataStreamTile(
              'Fuel Consumption',
              'Real-time fuel usage tracking',
              'Every minute',
              Icons.local_gas_station,
              Colors.purple,
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataStreamTile(String name, String description, String frequency, IconData icon, Color color, {bool isActive = true}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          Text('Frequency: $frequency', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: Switch(
        value: isActive,
        onChanged: (value) {
          // Toggle stream
        },
      ),
    );
  }

  Widget _buildIntegrationStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integration Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'API Connections',
              'All systems operational',
              Icons.api,
              Colors.green,
            ),
            _buildStatusItem(
              'Data Quality',
              '98.5% accuracy rate',
              Icons.high_quality,
              Colors.green,
            ),
            _buildStatusItem(
              'Latency',
              'Average 2.3 seconds',
              Icons.timer,
              Colors.blue,
            ),
            _buildStatusItem(
              'Error Rate',
              '0.02% in last 24 hours',
              Icons.error_outline,
              Colors.green,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _configureIntegration,
                    icon: const Icon(Icons.settings),
                    label: const Text('Configure'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _viewLogs,
                    icon: const Icon(Icons.list),
                    label: const Text('View Logs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing telematics data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showProviderDetails(String providerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$providerName Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: $providerName'),
            const SizedBox(height: 8),
            const Text('Status: Connected'),
            const SizedBox(height: 8),
            const Text('Last sync: 2 minutes ago'),
            const SizedBox(height: 8),
            const Text('Data quality: 98.5%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Configure provider
            },
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  void _configureIntegration() {
    // Navigate to integration configuration
  }

  void _viewLogs() {
    // Navigate to logs view
  }
}

class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          ListTile(
            leading: Icon(MdiIcons.brain),
            title: const Text('AI Diagnostics'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/ai-diagnostics'),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Maintenance'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/predictive-maintenance'),
          ),
          ListTile(
            leading: Icon(MdiIcons.satellite),
            title: const Text('Telematics'),
            selected: true,
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Shop Management'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/shop-management'),
          ),
        ],
      ),
    );
  }
}

enum TelematicsProviderStatus {
  connected,
  connecting,
  disconnected,
  error,
}