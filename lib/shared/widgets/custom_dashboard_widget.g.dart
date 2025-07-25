// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_dashboard_widget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardWidgetConfig _$DashboardWidgetConfigFromJson(
        Map<String, dynamic> json) =>
    DashboardWidgetConfig(
      id: json['id'] as String,
      title: json['title'] as String?,
      widgetType:
          $enumDecode(_$DashboardWidgetTypeEnumMap, json['widgetType']),
      pidConfigs: (json['pidConfigs'] as List<dynamic>?)
              ?.map((e) => PidDisplayConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      gridWidth: json['gridWidth'] as int? ?? 1,
      gridHeight: json['gridHeight'] as int? ?? 1,
      accentColor: json['accentColor'] as int?,
      showProgressBar: json['showProgressBar'] as bool? ?? true,
      showLegend: json['showLegend'] as bool? ?? true,
      chartType: $enumDecodeNullable(
          _$DataVisualizationTypeEnumMap, json['chartType']),
      quickActions: (json['quickActions'] as List<dynamic>?)
          ?.map((e) => QuickAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      customSettings: json['customSettings'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$DashboardWidgetConfigToJson(
        DashboardWidgetConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'widgetType': _$DashboardWidgetTypeEnumMap[instance.widgetType]!,
      'pidConfigs': instance.pidConfigs.map((e) => e.toJson()).toList(),
      'gridWidth': instance.gridWidth,
      'gridHeight': instance.gridHeight,
      'accentColor': instance.accentColor,
      'showProgressBar': instance.showProgressBar,
      'showLegend': instance.showLegend,
      'chartType': _$DataVisualizationTypeEnumMap[instance.chartType],
      'quickActions': instance.quickActions?.map((e) => e.toJson()).toList(),
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
};

QuickAction _$QuickActionFromJson(Map<String, dynamic> json) => QuickAction(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      action: $enumDecode(_$QuickActionTypeEnumMap, json['action']),
      parameters: json['parameters'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$QuickActionToJson(QuickAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': instance.icon.codePoint,
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

T $enumDecode<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

T? $enumDecodeNullable<T>(
  Map<T, Object> enumValues,
  dynamic source, {
  T? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return $enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}