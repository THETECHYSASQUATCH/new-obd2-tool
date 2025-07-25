import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_obd2_tool/shared/widgets/custom_dashboard_widget.dart';
import 'package:new_obd2_tool/shared/widgets/advanced_data_visualization_widget.dart';
import 'package:new_obd2_tool/shared/models/pid_config.dart';

void main() {
  group('CustomDashboardWidget', () {
    late DashboardWidgetConfig testConfig;

    setUp(() {
      testConfig = DashboardWidgetConfig(
        id: 'test-widget',
        title: 'Test Widget',
        widgetType: DashboardWidgetType.liveData,
        pidConfigs: [
          PidDisplayConfig(
            pid: '010C',
            displayName: 'Engine RPM',
            unit: 'RPM',
            category: 'Engine',
            minValue: 0,
            maxValue: 8000,
            isEnabled: true,
            displayOrder: 1,
          ),
        ],
      );
    });

    testWidgets('should display live data widget when type is liveData', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: testConfig),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.text('Reading...'), findsOneWidget); // Since no data provider is mocked
    });

    testWidgets('should display chart widget when type is chart', (tester) async {
      final chartConfig = testConfig.copyWith(
        widgetType: DashboardWidgetType.chart,
        chartType: DataVisualizationType.line,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: chartConfig),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      // Chart widget should be present
      expect(find.byType(AdvancedDataVisualizationWidget), findsOneWidget);
    });

    testWidgets('should display gauge widget when type is gauge', (tester) async {
      final gaugeConfig = testConfig.copyWith(
        widgetType: DashboardWidgetType.gauge,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: gaugeConfig),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.byType(AdvancedDataVisualizationWidget), findsOneWidget);
    });

    testWidgets('should display summary widget when type is summary', (tester) async {
      final summaryConfig = testConfig.copyWith(
        widgetType: DashboardWidgetType.summary,
        pidConfigs: [
          PidDisplayConfig(
            pid: '010C',
            displayName: 'Engine RPM',
            unit: 'RPM',
            category: 'Engine',
            isEnabled: true,
            displayOrder: 1,
          ),
          PidDisplayConfig(
            pid: '0105',
            displayName: 'Coolant Temp',
            unit: '°C',
            category: 'Engine',
            isEnabled: true,
            displayOrder: 2,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: summaryConfig),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.text('Engine RPM'), findsOneWidget);
      expect(find.text('Coolant Temp'), findsOneWidget);
    });

    testWidgets('should display quick actions widget when type is quickActions', (tester) async {
      final quickActionsConfig = testConfig.copyWith(
        widgetType: DashboardWidgetType.quickActions,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: quickActionsConfig),
            ),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.text('Scan DTCs'), findsOneWidget);
      expect(find.text('Clear DTCs'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('should show edit and delete buttons when in edit mode', (tester) async {
      bool editCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(
                config: testConfig,
                isEditing: true,
                onEdit: () => editCalled = true,
                onDelete: () => deleteCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // Test edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      expect(editCalled, true);

      // Test delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(deleteCalled, true);
    });

    testWidgets('should not show edit and delete buttons when not in edit mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(
                config: testConfig,
                isEditing: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('should display error widget when no PIDs configured for data widgets', (tester) async {
      final emptyConfig = testConfig.copyWith(
        pidConfigs: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: emptyConfig),
            ),
          ),
        ),
      );

      expect(find.text('Widget Error'), findsOneWidget);
      expect(find.text('No PIDs configured'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should execute quick actions correctly', (tester) async {
      final quickActionsConfig = testConfig.copyWith(
        widgetType: DashboardWidgetType.quickActions,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomDashboardWidget(config: quickActionsConfig),
            ),
          ),
        ),
      );

      // Test scan DTCs action
      await tester.tap(find.text('Scan DTCs'));
      await tester.pump();

      // Should show snackbar (in a real test, you'd verify the snackbar content)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('DashboardWidgetConfig', () {
    test('should serialize to and from JSON correctly', () {
      final config = DashboardWidgetConfig(
        id: 'test-widget',
        title: 'Test Widget',
        widgetType: DashboardWidgetType.chart,
        pidConfigs: [
          PidDisplayConfig(
            pid: '010C',
            displayName: 'Engine RPM',
            unit: 'RPM',
            category: 'Engine',
            isEnabled: true,
            displayOrder: 1,
          ),
        ],
        gridWidth: 2,
        gridHeight: 2,
        accentColor: Colors.blue.value,
        showProgressBar: true,
        showLegend: false,
        chartType: DataVisualizationType.line,
        customSettings: {'test': 'value'},
      );

      final json = config.toJson();
      final recreated = DashboardWidgetConfig.fromJson(json);

      expect(recreated.id, 'test-widget');
      expect(recreated.title, 'Test Widget');
      expect(recreated.widgetType, DashboardWidgetType.chart);
      expect(recreated.pidConfigs.length, 1);
      expect(recreated.pidConfigs.first.pid, '010C');
      expect(recreated.gridWidth, 2);
      expect(recreated.gridHeight, 2);
      expect(recreated.accentColor, Colors.blue.value);
      expect(recreated.showProgressBar, true);
      expect(recreated.showLegend, false);
      expect(recreated.chartType, DataVisualizationType.line);
      expect(recreated.customSettings['test'], 'value');
    });

    test('should create copy with updated properties', () {
      final original = DashboardWidgetConfig(
        id: 'test-widget',
        title: 'Original Title',
        widgetType: DashboardWidgetType.liveData,
        showProgressBar: true,
      );

      final copy = original.copyWith(
        title: 'Updated Title',
        showProgressBar: false,
      );

      expect(copy.id, 'test-widget'); // Unchanged
      expect(copy.title, 'Updated Title'); // Changed
      expect(copy.widgetType, DashboardWidgetType.liveData); // Unchanged
      expect(copy.showProgressBar, false); // Changed
    });
  });

  group('QuickAction', () {
    test('should serialize to and from JSON correctly', () {
      final action = QuickAction(
        id: 'scan_dtcs',
        label: 'Scan DTCs',
        icon: Icons.search,
        action: QuickActionType.scanDtcs,
        parameters: {'timeout': 5000},
      );

      final json = action.toJson();
      final recreated = QuickAction.fromJson(json);

      expect(recreated.id, 'scan_dtcs');
      expect(recreated.label, 'Scan DTCs');
      expect(recreated.icon.codePoint, Icons.search.codePoint);
      expect(recreated.action, QuickActionType.scanDtcs);
      expect(recreated.parameters['timeout'], 5000);
    });
  });

  group('DashboardWidgetType', () {
    test('should have all expected values', () {
      expect(DashboardWidgetType.values.length, 5);
      expect(DashboardWidgetType.values, contains(DashboardWidgetType.liveData));
      expect(DashboardWidgetType.values, contains(DashboardWidgetType.chart));
      expect(DashboardWidgetType.values, contains(DashboardWidgetType.gauge));
      expect(DashboardWidgetType.values, contains(DashboardWidgetType.summary));
      expect(DashboardWidgetType.values, contains(DashboardWidgetType.quickActions));
    });
  });

  group('QuickActionType', () {
    test('should have all expected values', () {
      expect(QuickActionType.values.length, 5);
      expect(QuickActionType.values, contains(QuickActionType.scanDtcs));
      expect(QuickActionType.values, contains(QuickActionType.clearDtcs));
      expect(QuickActionType.values, contains(QuickActionType.refreshData));
      expect(QuickActionType.values, contains(QuickActionType.exportData));
      expect(QuickActionType.values, contains(QuickActionType.customCommand));
    });
  });
}