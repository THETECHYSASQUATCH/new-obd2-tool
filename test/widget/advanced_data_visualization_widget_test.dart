import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_obd2_tool/shared/widgets/advanced_data_visualization_widget.dart';

void main() {
  group('AdvancedDataVisualizationWidget', () {
    testWidgets('should display gauge chart when visualization type is gauge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine RPM',
                unit: 'RPM',
                minValue: 0,
                maxValue: 8000,
                visualizationType: DataVisualizationType.gauge,
                currentValue: 3000,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine RPM'), findsOneWidget);
      expect(find.text('3000'), findsOneWidget);
      expect(find.text('RPM'), findsOneWidget);
    });

    testWidgets('should display line chart when visualization type is line', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Vehicle Speed',
                unit: 'km/h',
                minValue: 0,
                maxValue: 200,
                visualizationType: DataVisualizationType.line,
                historicalData: [60, 65, 70, 68, 72],
                currentValue: 70,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Vehicle Speed'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('km/h'), findsOneWidget);
    });

    testWidgets('should display no data message when historical data is empty for line chart', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Vehicle Speed',
                unit: 'km/h',
                visualizationType: DataVisualizationType.line,
                historicalData: [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Vehicle Speed'), findsOneWidget);
      expect(find.text('No historical data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('should display bar chart when visualization type is bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine Load',
                unit: '%',
                minValue: 0,
                maxValue: 100,
                visualizationType: DataVisualizationType.bar,
                historicalData: [20, 25, 30, 28, 32],
                currentValue: 30,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine Load'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('should display area chart when visualization type is area', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Coolant Temperature',
                unit: '°C',
                minValue: -40,
                maxValue: 215,
                visualizationType: DataVisualizationType.area,
                historicalData: [80, 85, 90, 88, 92],
                currentValue: 90,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Coolant Temperature'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('°C'), findsOneWidget);
    });

    testWidgets('should show legend when showLegend is true and currentValue is provided', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine RPM',
                unit: 'RPM',
                minValue: 0,
                maxValue: 8000,
                visualizationType: DataVisualizationType.gauge,
                currentValue: 3000,
                showLegend: true,
                historicalData: [2500, 2800, 3000, 3200, 2900],
              ),
            ),
          ),
        ),
      );

      // Should find legend items
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
      expect(find.text('Avg'), findsOneWidget);
    });

    testWidgets('should not show legend when showLegend is false', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine RPM',
                unit: 'RPM',
                minValue: 0,
                maxValue: 8000,
                visualizationType: DataVisualizationType.gauge,
                currentValue: 3000,
                showLegend: false,
              ),
            ),
          ),
        ),
      );

      // Should not find legend items
      expect(find.text('Current'), findsNothing);
      expect(find.text('Min'), findsNothing);
      expect(find.text('Max'), findsNothing);
      expect(find.text('Avg'), findsNothing);
    });

    testWidgets('should display menu button for visualization type switching', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine RPM',
                unit: 'RPM',
                visualizationType: DataVisualizationType.gauge,
                currentValue: 3000,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      
      // Tap the menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      // Should show visualization type options
      expect(find.text('Gauge'), findsOneWidget);
      expect(find.text('Line Chart'), findsOneWidget);
      expect(find.text('Bar Chart'), findsOneWidget);
      expect(find.text('Area Chart'), findsOneWidget);
    });

    testWidgets('should format values correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Integer value
                  AdvancedDataVisualizationWidget(
                    title: 'Integer Value',
                    unit: 'units',
                    visualizationType: DataVisualizationType.gauge,
                    currentValue: 1500.0,
                  ),
                  // Decimal value
                  AdvancedDataVisualizationWidget(
                    title: 'Decimal Value',
                    unit: 'units',
                    visualizationType: DataVisualizationType.gauge,
                    currentValue: 87.5,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('1500'), findsOneWidget); // Integer display
      expect(find.text('87.5'), findsOneWidget); // Decimal display
    });

    testWidgets('should apply custom accent color', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine RPM',
                unit: 'RPM',
                visualizationType: DataVisualizationType.gauge,
                currentValue: 3000,
                accentColor: Colors.red,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine RPM'), findsOneWidget);
      expect(find.text('3000'), findsOneWidget);
      
      // The color application would be tested through widget inspection
      // in a more comprehensive test environment
    });

    testWidgets('should handle null current value gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AdvancedDataVisualizationWidget(
                title: 'Engine RPM',
                unit: 'RPM',
                visualizationType: DataVisualizationType.gauge,
                currentValue: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine RPM'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('DataVisualizationType', () {
    test('should have all expected values', () {
      expect(DataVisualizationType.values.length, 4);
      expect(DataVisualizationType.values, contains(DataVisualizationType.gauge));
      expect(DataVisualizationType.values, contains(DataVisualizationType.line));
      expect(DataVisualizationType.values, contains(DataVisualizationType.bar));
      expect(DataVisualizationType.values, contains(DataVisualizationType.area));
    });
  });
}