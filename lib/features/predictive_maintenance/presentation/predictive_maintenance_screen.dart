import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../shared/widgets/responsive_layout.dart';
import '../models/maintenance_alert.dart';
import '../models/maintenance_schedule.dart';

class PredictiveMaintenanceScreen extends ConsumerStatefulWidget {
  const PredictiveMaintenanceScreen({super.key});

  @override
  ConsumerState<PredictiveMaintenanceScreen> createState() => _PredictiveMaintenanceScreenState();
}

class _PredictiveMaintenanceScreenState extends ConsumerState<PredictiveMaintenanceScreen> {
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
        title: const Text('Predictive Maintenance'),
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
        title: const Text('Predictive Maintenance'),
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
                  title: const Text('Predictive Maintenance'),
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
          _buildActiveAlertsCard(),
          const SizedBox(height: 16),
          _buildMaintenanceScheduleCard(),
          const SizedBox(height: 16),
          _buildPredictionsCard(),
          const SizedBox(height: 16),
          _buildMaintenanceHistoryCard(),
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
                Icon(MdiIcons.wrench, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Maintenance Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI-powered predictive maintenance monitoring tracks vehicle parameters and predicts potential maintenance requirements before issues occur.',
            ),
            const SizedBox(height: 16),
            _buildMaintenanceMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Active Alerts',
            '3',
            Icons.warning,
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Upcoming Services',
            '2',
            Icons.schedule,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            'Health Score',
            '92%',
            Icons.health_and_safety,
            Colors.green,
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

  Widget _buildActiveAlertsCard() {
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
                  'Active Alerts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    // View all alerts
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAlert(
              'Oil Change Due',
              'Based on driving patterns, oil change recommended in 5-7 days',
              MaintenancePriority.high,
              '7 days',
            ),
            _buildAlert(
              'Air Filter Check',
              'Decreased efficiency detected, inspection recommended',
              MaintenancePriority.medium,
              '14 days',
            ),
            _buildAlert(
              'Brake Inspection',
              'Wear patterns suggest inspection in next 30 days',
              MaintenancePriority.low,
              '30 days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(String title, String description, MaintenancePriority priority, String timeframe) {
    Color priorityColor = priority == MaintenancePriority.high ? Colors.red :
                         priority == MaintenancePriority.medium ? Colors.orange : Colors.blue;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(Icons.warning, color: priorityColor),
        title: Text(title),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(priority.name.toUpperCase()),
              backgroundColor: priorityColor.withOpacity(0.1),
              labelStyle: TextStyle(color: priorityColor, fontSize: 10),
            ),
            Text(
              timeframe,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () {
          _showAlertDetails(title, description, priority);
        },
      ),
    );
  }

  Widget _buildMaintenanceScheduleCard() {
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
                  'Maintenance Schedule',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Update schedule
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScheduleItem(
              'Oil Change',
              'Every 5,000 miles or 6 months',
              'Last: 2,500 miles ago',
              Icons.opacity,
              Colors.orange,
            ),
            _buildScheduleItem(
              'Brake Inspection',
              'Every 12,000 miles or 12 months',
              'Last: 8,000 miles ago',
              Icons.disc_full,
              Colors.blue,
            ),
            _buildScheduleItem(
              'Air Filter',
              'Every 15,000 miles or 12 months',
              'Last: 10,000 miles ago',
              Icons.air,
              Colors.green,
            ),
            _buildScheduleItem(
              'Transmission Service',
              'Every 30,000 miles or 24 months',
              'Last: 15,000 miles ago',
              Icons.settings,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String service, String interval, String lastService, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(service),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(interval),
          Text(lastService, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // Show service options
        },
      ),
    );
  }

  Widget _buildPredictionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Predictions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildPrediction(
              'Engine Performance',
              'Stable performance expected for next 6 months',
              Icons.timeline,
              Colors.green,
              95,
            ),
            _buildPrediction(
              'Transmission Health',
              'Minor wear detected, service recommended in 3 months',
              Icons.trending_down,
              Colors.orange,
              78,
            ),
            _buildPrediction(
              'Brake System',
              'Current wear rate suggests replacement in 8 months',
              Icons.trending_flat,
              Colors.blue,
              85,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrediction(String system, String prediction, IconData icon, Color color, int confidence) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      system,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$confidence% confidence',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  prediction,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: confidence / 100,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryCard() {
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
                  'Recent Maintenance',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    // View full history
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Full History'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              'Oil Change',
              '2 weeks ago',
              'Synthetic 5W-30, Filter replaced',
              Icons.check_circle,
              Colors.green,
            ),
            _buildHistoryItem(
              'Tire Rotation',
              '1 month ago',
              'All tires rotated, pressure checked',
              Icons.check_circle,
              Colors.green,
            ),
            _buildHistoryItem(
              'Brake Inspection',
              '3 months ago',
              'Pads at 40%, rotors good',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String service, String date, String details, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(service),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: Theme.of(context).textTheme.bodySmall),
          Text(details),
        ],
      ),
      onTap: () {
        // Show service details
      },
    );
  }

  void _showAlertDetails(String title, String description, MaintenancePriority priority) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Priority: '),
                Chip(
                  label: Text(priority.name.toUpperCase()),
                  backgroundColor: (priority == MaintenancePriority.high ? Colors.red :
                                   priority == MaintenancePriority.medium ? Colors.orange : Colors.blue)
                                   .withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Schedule maintenance
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
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