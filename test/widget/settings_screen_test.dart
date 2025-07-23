import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd2_diagnostics_tool/features/settings/presentation/settings_screen.dart';

void main() {
  group('Settings Screen Dependencies', () {
    testWidgets('should import package_info_plus without conflicts', (tester) async {
      // This test verifies that our dependency conflict resolution is successful
      // by ensuring the SettingsScreen can be created without import errors
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsScreen(),
          ),
        ),
      );

      // The fact that we can pump the widget without exceptions means:
      // 1. package_info_plus imports successfully
      // 2. No dependency conflicts exist
      // 3. All required dependencies are resolved
      
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
    });

    testWidgets('should handle package info loading gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsScreen(),
          ),
        ),
      );

      // Initially should show loading text
      expect(find.text('Loading...'), findsOneWidget);

      // Allow some time for async operations
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should not throw any exceptions related to dependency conflicts
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render all settings sections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsScreen(),
          ),
        ),
      );

      // Verify all main sections are rendered
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Connection'), findsOneWidget);
      expect(find.text('Data & Storage'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      
      // Verify package_info_plus dependent features work
      expect(find.text('App Version'), findsOneWidget);
    });
  });
}