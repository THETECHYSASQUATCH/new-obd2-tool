import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    
    // Adaptive grid based on platform
    final crossAxisCount = isDesktop ? 4 : 2;
    final childAspectRatio = isDesktop ? 1.5 : 1.2;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: _buildQuickActions(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.error_outline,
        title: 'Read DTCs',
        subtitle: 'Diagnostic trouble codes',
        color: Colors.red,
        onTap: () => _handleAction(context, 'read_dtcs'),
      ),
      _QuickAction(
        icon: Icons.clear,
        title: 'Clear DTCs',
        subtitle: 'Clear error codes',
        color: Colors.orange,
        onTap: () => _handleAction(context, 'clear_dtcs'),
      ),
      _QuickAction(
        icon: Icons.show_chart,
        title: 'Live Data',
        subtitle: 'Real-time monitoring',
        color: Colors.blue,
        onTap: () => _handleAction(context, 'live_data'),
      ),
      _QuickAction(
        icon: Icons.speed,
        title: 'Performance',
        subtitle: 'Engine performance',
        color: Colors.green,
        onTap: () => _handleAction(context, 'performance'),
      ),
      _QuickAction(
        icon: Icons.info_outline,
        title: 'Vehicle Info',
        subtitle: 'VIN and details',
        color: Colors.purple,
        onTap: () => _handleAction(context, 'vehicle_info'),
      ),
      _QuickAction(
        icon: Icons.build,
        title: 'Programming',
        subtitle: 'ECU programming',
        color: Colors.teal,
        onTap: () => _handleAction(context, 'programming'),
      ),
    ];

    return actions;
  }

  void _handleAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}