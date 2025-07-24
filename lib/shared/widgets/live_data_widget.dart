// TODO: Enhanced live data widget with user-configurable PID support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pid_config.dart';
import '../providers/app_providers.dart';

class LiveDataWidget extends ConsumerWidget {
  final String title;
  final StateNotifierProvider<dynamic, double?> provider;
  final String unit;
  final double? minValue;
  final double? maxValue;
  // TODO: Enhanced widget properties for improved customization
  final PidDisplayConfig? pidConfig;
  final VoidCallback? onTap;
  final bool showProgressBar;
  final Color? accentColor;

  const LiveDataWidget({
    super.key,
    required this.title,
    required this.provider,
    required this.unit,
    this.minValue,
    this.maxValue,
    this.pidConfig,
    this.onTap,
    this.showProgressBar = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    final effectiveMinValue = pidConfig?.minValue ?? minValue;
    final effectiveMaxValue = pidConfig?.maxValue ?? maxValue;
    final effectiveShowProgress = pidConfig?.showProgressBar ?? showProgressBar;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pidConfig?.displayName ?? title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pidConfig != null)
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () {
                          // Request update for this specific parameter
                          ref.read(provider.notifier).requestUpdate();
                        },
                        tooltip: 'Refresh ${pidConfig?.displayName ?? title}',
                        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildValueDisplay(context, value),
              if (effectiveShowProgress && 
                  effectiveMinValue != null && 
                  effectiveMaxValue != null && 
                  value != null)
                ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(context, value!, effectiveMinValue!, effectiveMaxValue!),
                ],
              if (pidConfig != null)
                ...[
                  const SizedBox(height: 8),
                  _buildPidInfo(context),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueDisplay(BuildContext context, double? value) {
    if (value == null) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                accentColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Reading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _formatValue(value),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getValueColor(context, value),
            ),
          ),
          TextSpan(
            text: ' ${pidConfig?.unit ?? unit}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double value, double min, double max) {
    final normalizedValue = ((value - min) / (max - min)).clamp(0.0, 1.0);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: normalizedValue,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getValueColor(context, value),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatValue(min),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _formatValue(max),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPidInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            pidConfig!.pid,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          pidConfig!.category,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
        if (pidConfig!.updateIntervalMs != 1000) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.timer,
            size: 12,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${pidConfig!.updateIntervalMs}ms',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ],
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  Color _getValueColor(BuildContext context, double value) {
    if (accentColor != null) return accentColor!;
    
    // TODO: Enhanced color coding based on PID type and value ranges
    final category = pidConfig?.category ?? '';
    
    if (category == 'Engine') {
      // Engine parameters
      if (title.contains('RPM')) {
        if (value > 6000) return Colors.red;
        if (value > 4000) return Colors.orange;
        return Colors.green;
      } else if (title.contains('Load')) {
        if (value > 80) return Colors.red;
        if (value > 60) return Colors.orange;
        return Colors.green;
      } else if (title.contains('Temp')) {
        if (value > 100) return Colors.red;
        if (value > 90) return Colors.orange;
        return Colors.green;
      }
    } else if (category == 'Vehicle') {
      // Vehicle parameters
      if (title.contains('Speed')) {
        if (value > 120) return Colors.red;
        if (value > 80) return Colors.orange;
        return Colors.green;
      }
    } else if (category == 'Fuel') {
      // Fuel system parameters
      if (title.contains('trim')) {
        final absValue = value.abs();
        if (absValue > 20) return Colors.red;
        if (absValue > 10) return Colors.orange;
        return Colors.green;
      }
    } else if (category == 'Emissions') {
      // Emissions parameters
      return Colors.blue;
    }
    
    // Fallback to original logic for backward compatibility
    if (title.contains('RPM')) {
      if (value > 6000) return Colors.red;
      if (value > 4000) return Colors.orange;
      return Colors.green;
    } else if (title.contains('Speed')) {
      if (value > 120) return Colors.red;
      if (value > 80) return Colors.orange;
      return Colors.green;
    } else if (title.contains('Temp')) {
      if (value > 100) return Colors.red;
      if (value > 90) return Colors.orange;
      return Colors.green;
    } else if (title.contains('Load')) {
      if (value > 80) return Colors.red;
      if (value > 60) return Colors.orange;
      return Colors.green;
    }
    
    return Theme.of(context).primaryColor;
  }
}

/// TODO: Configurable live data grid widget for dashboard display
class ConfigurableLiveDataGrid extends ConsumerWidget {
  final List<PidDisplayConfig> pidConfigs;
  final int crossAxisCount;
  final double childAspectRatio;

  const ConfigurableLiveDataGrid({
    super.key,
    required this.pidConfigs,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledConfigs = pidConfigs.where((config) => config.isEnabled).toList();
    enabledConfigs.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (enabledConfigs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No PIDs configured',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure PIDs to display live data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: enabledConfigs.length,
      itemBuilder: (context, index) {
        final config = enabledConfigs[index];
        // TODO: Create provider for each PID dynamically
        return LiveDataWidget(
          title: config.displayName,
          provider: _getProviderForPid(config.pid),
          unit: config.unit,
          minValue: config.minValue,
          maxValue: config.maxValue,
          pidConfig: config,
          showProgressBar: config.showProgressBar,
        );
      },
    );
  }

  // TODO: Implement dynamic provider creation for configured PIDs
  StateNotifierProvider<dynamic, double?> _getProviderForPid(String pid) {
    // This should dynamically create or return existing providers for PIDs
    // For now, returning a placeholder - needs implementation in providers
    switch (pid) {
      case '010C':
        return engineRpmProvider;
      case '010D':
        return vehicleSpeedProvider;
      case '0105':
        return coolantTempProvider;
      case '0104':
        return engineLoadProvider;
      default:
        // TODO: Create dynamic providers for other PIDs
        return engineRpmProvider; // Placeholder
    }
  }
}