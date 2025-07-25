import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../core/services/ai_diagnostics_service.dart';
import '../models/ai_diagnostic_result.dart';

class AIDiagnosticsScreen extends ConsumerStatefulWidget {
  const AIDiagnosticsScreen({super.key});

  @override
  ConsumerState<AIDiagnosticsScreen> createState() => _AIDiagnosticsScreenState();
}

class _AIDiagnosticsScreenState extends ConsumerState<AIDiagnosticsScreen> {
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
        title: const Text('AI Diagnostics'),
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
        title: const Text('AI Diagnostics'),
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
          // Navigation sidebar (optional)
          const SizedBox(width: 200, child: _NavigationSidebar()),
          // Main content
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: const Text('AI-Powered Diagnostics'),
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
          _buildAIDiagnosticCard(),
          const SizedBox(height: 16),
          _buildInsightsCard(),
          const SizedBox(height: 16),
          _buildRecommendationsCard(),
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
                Icon(MdiIcons.brain, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'AI Diagnostic Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Advanced machine learning algorithms analyze your vehicle data to provide detailed insights and identify potential issues before they become problems.',
            ),
            const SizedBox(height: 16),
            _buildAnalysisStatusRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisStatusRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusItem(
            'Data Points Analyzed',
            '1,247',
            Icons.analytics,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatusItem(
            'Patterns Detected',
            '5',
            Icons.pattern,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatusItem(
            'Risk Level',
            'Low',
            Icons.security,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
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

  Widget _buildAIDiagnosticCard() {
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
                  'Real-time Analysis',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Analysis'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(value: 0.85),
            const SizedBox(height: 8),
            const Text('AI Analysis: 85% Complete'),
            const SizedBox(height: 16),
            _buildAnalysisResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Column(
      children: [
        _buildAnalysisResult(
          'Engine Performance',
          'Optimal',
          Icons.check_circle,
          Colors.green,
          'No anomalies detected in engine parameters',
        ),
        _buildAnalysisResult(
          'Transmission Health',
          'Good',
          Icons.warning,
          Colors.orange,
          'Minor wear patterns detected, monitor closely',
        ),
        _buildAnalysisResult(
          'Emissions System',
          'Excellent',
          Icons.check_circle,
          Colors.green,
          'All emissions components functioning optimally',
        ),
      ],
    );
  }

  Widget _buildAnalysisResult(String system, String status, IconData icon, Color color, String description) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(system),
      subtitle: Text(description),
      trailing: Chip(
        label: Text(status),
        backgroundColor: color.withOpacity(0.1),
        labelStyle: TextStyle(color: color),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Insights',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInsight(
              'Fuel Efficiency',
              'Your driving patterns suggest a 12% improvement in fuel efficiency over the past month.',
              Icons.local_gas_station,
              Colors.green,
            ),
            _buildInsight(
              'Maintenance Timing',
              'Based on current usage patterns, your next oil change should be scheduled in 2-3 weeks.',
              Icons.build,
              Colors.blue,
            ),
            _buildInsight(
              'Performance Trend',
              'Engine performance has been consistently stable with slight improvement in response time.',
              Icons.trending_up,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsight(String title, String description, IconData icon, Color color) {
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Recommendations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildRecommendation(
              'Check Air Filter',
              'Medium Priority',
              'AI detected decreased airflow efficiency. Consider replacing air filter.',
              Colors.orange,
            ),
            _buildRecommendation(
              'Optimize Driving Style',
              'Low Priority',
              'Small adjustments to acceleration patterns could improve fuel economy by 5%.',
              Colors.blue,
            ),
            _buildRecommendation(
              'Schedule Inspection',
              'High Priority',
              'Unusual vibration patterns detected. Professional inspection recommended.',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(String title, String priority, String description, Color priorityColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(Icons.lightbulb, color: priorityColor),
        title: Text(title),
        subtitle: Text(description),
        trailing: Chip(
          label: Text(priority),
          backgroundColor: priorityColor.withOpacity(0.1),
          labelStyle: TextStyle(color: priorityColor, fontSize: 12),
        ),
        onTap: () {
          // Handle recommendation tap
        },
      ),
    );
  }

  void _runAnalysis() {
    // Trigger AI analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Analysis started...'),
        duration: Duration(seconds: 2),
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
            selected: true,
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Maintenance'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/predictive-maintenance'),
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