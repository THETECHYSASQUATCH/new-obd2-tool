// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_dashboard_widget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardWidgetConfig _$DashboardWidgetConfigFromJson(
  Map<String, dynamic> json,
) => DashboardWidgetConfig(
  id: json['id'] as String,
  title: json['title'] as String?,
  widgetType: $enumDecode(_$DashboardWidgetTypeEnumMap, json['widgetType']),
  pidConfigs:
      (json['pidConfigs'] as List<dynamic>?)
          ?.map((e) => PidDisplayConfig.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  gridWidth: (json['gridWidth'] as num?)?.toInt() ?? 1,
  gridHeight: (json['gridHeight'] as num?)?.toInt() ?? 1,
  accentColor: (json['accentColor'] as num?)?.toInt(),
  showProgressBar: json['showProgressBar'] as bool? ?? true,
  showLegend: json['showLegend'] as bool? ?? true,
  chartType: $enumDecodeNullable(
    _$DataVisualizationTypeEnumMap,
    json['chartType'],
  ),
  quickActions: (json['quickActions'] as List<dynamic>?)
      ?.map((e) => QuickAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  customSettings: json['customSettings'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$DashboardWidgetConfigToJson(
  DashboardWidgetConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'widgetType': _$DashboardWidgetTypeEnumMap[instance.widgetType]!,
  'pidConfigs': instance.pidConfigs,
  'gridWidth': instance.gridWidth,
  'gridHeight': instance.gridHeight,
  'accentColor': instance.accentColor,
  'showProgressBar': instance.showProgressBar,
  'showLegend': instance.showLegend,
  'chartType': _$DataVisualizationTypeEnumMap[instance.chartType],
  'quickActions': instance.quickActions,
  'customSettings': instance.customSettings,
};

const _$DashboardWidgetTypeEnumMap = {
  DashboardWidgetType.liveData: 'liveData',
  DashboardWidgetType.chart: 'chart',
  DashboardWidgetType.gauge: 'gauge',
  DashboardWidgetType.summary: 'summary',
  DashboardWidgetType.quickActions: 'quickActions',
};

const _$DataVisualizationTypeEnumMap = {
  DataVisualizationType.gauge: 'gauge',
  DataVisualizationType.line: 'line',
  DataVisualizationType.bar: 'bar',
  DataVisualizationType.area: 'area',
};

QuickAction _$QuickActionFromJson(Map<String, dynamic> json) => QuickAction(
  id: json['id'] as String,
  label: json['label'] as String,
  icon: const IconDataConverter().fromJson(
    json['icon'] as Map<String, dynamic>,
  ),
  action: $enumDecode(_$QuickActionTypeEnumMap, json['action']),
  parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$QuickActionToJson(QuickAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': const IconDataConverter().toJson(instance.icon),
      'action': _$QuickActionTypeEnumMap[instance.action]!,
      'parameters': instance.parameters,
    };

const _$QuickActionTypeEnumMap = {
  QuickActionType.scanDtcs: 'scanDtcs',
  QuickActionType.clearDtcs: 'clearDtcs',
  QuickActionType.refreshData: 'refreshData',
  QuickActionType.exportData: 'exportData',
  QuickActionType.customCommand: 'customCommand',
};
