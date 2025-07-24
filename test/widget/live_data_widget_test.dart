import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_obd2_tool/shared/widgets/live_data_widget.dart';
import 'package:new_obd2_tool/shared/providers/app_providers.dart';

void main() {
  group('LiveDataWidget', () {
    testWidgets('should display loading state when value is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LiveDataWidget(
                title: 'Engine RPM',
                provider: engineRpmProvider,
                unit: 'RPM',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine RPM'), findsOneWidget);
      expect(find.text('Reading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display value when data is available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            engineRpmProvider.overrideWith((ref) => MockLiveDataNotifier(1500.0)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LiveDataWidget(
                title: 'Engine RPM',
                provider: engineRpmProvider,
                unit: 'RPM',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine RPM'), findsOneWidget);
      expect(find.text('1500'), findsOneWidget);
      expect(find.text('RPM'), findsOneWidget);
    });

    testWidgets('should display refresh button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LiveDataWidget(
                title: 'Engine RPM',
                provider: engineRpmProvider,
                unit: 'RPM',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      // Tap the refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      
      // Should not throw any errors
    });

    testWidgets('should show progress bar when min/max values are provided', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            engineRpmProvider.overrideWith((ref) => MockLiveDataNotifier(3000.0)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LiveDataWidget(
                title: 'Engine RPM',
                provider: engineRpmProvider,
                unit: 'RPM',
                minValue: 0,
                maxValue: 8000,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('8000'), findsOneWidget);
    });

    testWidgets('should format decimal values correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coolantTempProvider.overrideWith((ref) => MockLiveDataNotifier(87.5)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LiveDataWidget(
                title: 'Coolant Temp',
                provider: coolantTempProvider,
                unit: '°C',
              ),
            ),
          ),
        ),
      );

      expect(find.text('87.5'), findsOneWidget);
    });

    testWidgets('should format integer values correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleSpeedProvider.overrideWith((ref) => MockLiveDataNotifier(60.0)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LiveDataWidget(
                title: 'Vehicle Speed',
                provider: vehicleSpeedProvider,
                unit: 'km/h',
              ),
            ),
          ),
        ),
      );

      expect(find.text('60'), findsOneWidget);
    });
  });
}

class MockLiveDataNotifier extends StateNotifier<double?> {
  MockLiveDataNotifier(double? initialState) : super(initialState);

  Future<void> requestUpdate() async {
    // Mock implementation
  }
}