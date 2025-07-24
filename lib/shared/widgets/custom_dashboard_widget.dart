import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/pid_config.dart';
import 'advanced_data_visualization_widget.dart';
import 'live_data_widget.dart';
import '../providers/app_providers.dart';

part 'custom_dashboard_widget.g.dart';

/// Customizable dashboard widget that can display various types of OBD-II data
/// Supports different widget types, layouts, and user configuration
class CustomDashboardWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditing;

  const CustomDashboardWidget({
    super.key,
    required this.config,
    this.onEdit,
    this.onDelete,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: isEditing 
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildWidgetContent(context, ref),
        ),
        if (isEditing) ...[
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      color: Colors.white,
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                const SizedBox(width: 4),
                if (onDelete != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      color: Colors.white,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWidgetContent(BuildContext context, WidgetRef ref) {
    switch (config.widgetType) {
      case DashboardWidgetType.liveData:
        return _buildLiveDataWidget(context, ref);
      case DashboardWidgetType.chart:
        return _buildChartWidget(context, ref);
      case DashboardWidgetType.gauge:
        return _buildGaugeWidget(context, ref);
      case DashboardWidgetType.summary:
        return _buildSummaryWidget(context, ref);
      case DashboardWidgetType.quickActions:
        return _buildQuickActionsWidget(context, ref);
      default:
        return _buildErrorWidget(context, 'Unknown widget type');
    }
  }

  Widget _buildLiveDataWidget(BuildContext context, WidgetRef ref) {
    if (config.pidConfigs.isEmpty) {
      return _buildErrorWidget(context, 'No PIDs configured');
    }

    final pidConfig = config.pidConfigs.first;
    final provider = _getProviderForPid(pidConfig.pid);

    return LiveDataWidget(
      title: config.title ?? pidConfig.displayName,
      provider: provider,
      unit: pidConfig.unit,
      minValue: pidConfig.minValue,
      maxValue: pidConfig.maxValue,
      pidConfig: pidConfig,
      showProgressBar: config.showProgressBar,
      accentColor: config.accentColor != null 
          ? Color(config.accentColor!) 
          : null,
    );
  }

  Widget _buildChartWidget(BuildContext context, WidgetRef ref) {
    if (config.pidConfigs.isEmpty) {
      return _buildErrorWidget(context, 'No PIDs configured for chart');
    }

    final pidConfig = config.pidConfigs.first;
    final provider = _getProviderForPid(pidConfig.pid);
    final currentValue = ref.watch(provider);

    // TODO: In a real implementation, you'd get historical data from a provider
    final historicalData = _getMockHistoricalData(currentValue);

    return AdvancedDataVisualizationWidget(
      title: config.title ?? pidConfig.displayName,
      unit: pidConfig.unit,
      minValue: pidConfig.minValue,
      maxValue: pidConfig.maxValue,
      visualizationType: config.chartType ?? DataVisualizationType.line,
      historicalData: historicalData,
      currentValue: currentValue,
      accentColor: config.accentColor != null 
          ? Color(config.accentColor!) 
          : null,
      showLegend: config.showLegend,
    );
  }

  Widget _buildGaugeWidget(BuildContext context, WidgetRef ref) {
    if (config.pidConfigs.isEmpty) {
      return _buildErrorWidget(context, 'No PIDs configured for gauge');
    }

    final pidConfig = config.pidConfigs.first;
    final provider = _getProviderForPid(pidConfig.pid);
    final currentValue = ref.watch(provider);

    return AdvancedDataVisualizationWidget(
      title: config.title ?? pidConfig.displayName,
      unit: pidConfig.unit,
      minValue: pidConfig.minValue,
      maxValue: pidConfig.maxValue,
      visualizationType: DataVisualizationType.gauge,
      currentValue: currentValue,
      accentColor: config.accentColor != null 
          ? Color(config.accentColor!) 
          : null,
    );
  }

  Widget _buildSummaryWidget(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.title ?? 'Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: config.pidConfigs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final pidConfig = config.pidConfigs[index];
                  final provider = _getProviderForPid(pidConfig.pid);
                  final value = ref.watch(provider);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pidConfig.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        value != null 
                            ? '${_formatValue(value)} ${pidConfig.unit}'
                            : '--',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: value != null 
                              ? _getValueColor(context, value, pidConfig)
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsWidget(BuildContext context, WidgetRef ref) {
    final actions = config.quickActions ?? _getDefaultQuickActions();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.title ?? 'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return ElevatedButton.icon(
                    onPressed: () => _executeQuickAction(context, ref, action),
                    icon: Icon(action.icon),
                    label: Text(
                      action.label,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Widget Error',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  StateNotifierProvider<dynamic, double?> _getProviderForPid(String pid) {
    // TODO: In a real implementation, this would be more dynamic
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
        return engineRpmProvider; // Fallback
    }
  }

  List<double> _getMockHistoricalData(double? currentValue) {
    if (currentValue == null) return [];
    
    // Generate mock historical data based on current value
    final data = <double>[];
    final baseValue = currentValue;
    
    for (int i = 0; i < 20; i++) {
      final variance = (i % 3 == 0) ? 0.1 : 0.05;
      final value = baseValue + (baseValue * variance * (i % 2 == 0 ? 1 : -1));
      data.add(value.clamp(0, double.infinity));
    }
    
    return data;
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  Color _getValueColor(BuildContext context, double value, PidDisplayConfig pidConfig) {
    if (pidConfig.minValue != null && pidConfig.maxValue != null) {
      final normalizedValue = (value - pidConfig.minValue!) / (pidConfig.maxValue! - pidConfig.minValue!);
      if (normalizedValue <= 0.6) return Colors.green;
      if (normalizedValue <= 0.8) return Colors.orange;
      return Colors.red;
    }
    return Theme.of(context).primaryColor;
  }

  List<QuickAction> _getDefaultQuickActions() {
    return [
      QuickAction(
        id: 'scan_dtcs',
        label: 'Scan DTCs',
        icon: Icons.search,
        action: QuickActionType.scanDtcs,
      ),
      QuickAction(
        id: 'clear_dtcs',
        label: 'Clear DTCs',
        icon: Icons.clear,
        action: QuickActionType.clearDtcs,
      ),
      QuickAction(
        id: 'refresh_data',
        label: 'Refresh',
        icon: Icons.refresh,
        action: QuickActionType.refreshData,
      ),
      QuickAction(
        id: 'export_data',
        label: 'Export',
        icon: Icons.download,
        action: QuickActionType.exportData,
      ),
    ];
  }

  void _executeQuickAction(BuildContext context, WidgetRef ref, QuickAction action) {
    switch (action.action) {
      case QuickActionType.scanDtcs:
        _showSnackBar(context, 'Scanning for DTCs...');
        // TODO: Implement DTC scanning
        break;
      case QuickActionType.clearDtcs:
        _showSnackBar(context, 'Clearing DTCs...');
        // TODO: Implement DTC clearing
        break;
      case QuickActionType.refreshData:
        _showSnackBar(context, 'Refreshing data...');
        // TODO: Implement data refresh
        break;
      case QuickActionType.exportData:
        _showSnackBar(context, 'Exporting data...');
        // TODO: Implement data export
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Configuration for a custom dashboard widget
@JsonSerializable()
class DashboardWidgetConfig {
  final String id;
  final String? title;
  final DashboardWidgetType widgetType;
  final List<PidDisplayConfig> pidConfigs;
  final int gridWidth;
  final int gridHeight;
  final int? accentColor;
  final bool showProgressBar;
  final bool showLegend;
  final DataVisualizationType? chartType;
  final List<QuickAction>? quickActions;
  final Map<String, dynamic> customSettings;

  const DashboardWidgetConfig({
    required this.id,
    this.title,
    required this.widgetType,
    this.pidConfigs = const [],
    this.gridWidth = 1,
    this.gridHeight = 1,
    this.accentColor,
    this.showProgressBar = true,
    this.showLegend = true,
    this.chartType,
    this.quickActions,
    this.customSettings = const {},
  });

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardWidgetConfigToJson(this);

  DashboardWidgetConfig copyWith({
    String? id,
    String? title,
    DashboardWidgetType? widgetType,
    List<PidDisplayConfig>? pidConfigs,
    int? gridWidth,
    int? gridHeight,
    int? accentColor,
    bool? showProgressBar,
    bool? showLegend,
    DataVisualizationType? chartType,
    List<QuickAction>? quickActions,
    Map<String, dynamic>? customSettings,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      widgetType: widgetType ?? this.widgetType,
      pidConfigs: pidConfigs ?? this.pidConfigs,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      accentColor: accentColor ?? this.accentColor,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      showLegend: showLegend ?? this.showLegend,
      chartType: chartType ?? this.chartType,
      quickActions: quickActions ?? this.quickActions,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

/// Quick action configuration
@JsonSerializable()
class QuickAction {
  final String id;
  final String label;
  final IconData icon;
  final QuickActionType action;
  final Map<String, dynamic> parameters;

  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.action,
    this.parameters = const {},
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) =>
      _$QuickActionFromJson(json);

  Map<String, dynamic> toJson() => _$QuickActionToJson(this);
}

enum DashboardWidgetType {
  liveData,
  chart,
  gauge,
  summary,
  quickActions,
}

enum QuickActionType {
  scanDtcs,
  clearDtcs,
  refreshData,
  exportData,
  customCommand,
}