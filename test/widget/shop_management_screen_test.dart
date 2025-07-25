import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_obd2_tool/features/shop_management/presentation/shop_management_screen.dart';

void main() {
  group('Shop Management Screen', () {
    testWidgets('should display shop management title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      expect(find.text('Shop Management'), findsOneWidget);
      expect(find.text('Professional Shop Management'), findsOneWidget);
    });

    testWidgets('should display all main tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Work Orders'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
    });

    testWidgets('should display overview metrics on first tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      // Should be on overview tab by default
      expect(find.text('Shop Overview'), findsOneWidget);
      expect(find.text('Active Work Orders'), findsOneWidget);
      expect(find.text('Total Customers'), findsOneWidget);
      expect(find.text('Monthly Revenue'), findsOneWidget);
      expect(find.text('Low Stock Items'), findsOneWidget);
    });

    testWidgets('should switch to customers tab when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      // Tap on customers tab
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();

      expect(find.text('Customer Management'), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);
    });

    testWidgets('should switch to work orders tab when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      // Tap on work orders tab
      await tester.tap(find.text('Work Orders'));
      await tester.pumpAndSettle();

      expect(find.text('Work Orders'), findsWidgets);
      expect(find.text('New Work Order'), findsOneWidget);
    });

    testWidgets('should switch to inventory tab when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      // Tap on inventory tab
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      expect(find.text('Inventory Management'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('should show add customer dialog when button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      // Go to customers tab and tap add customer
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Add Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Add Customer'), findsWidgets);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('should show new work order dialog when button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      // Go to work orders tab and tap new work order
      await tester.tap(find.text('Work Orders'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('New Work Order'));
      await tester.pumpAndSettle();

      expect(find.text('New Work Order'), findsWidgets);
      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Vehicle'), findsOneWidget);
      expect(find.text('Service Description'), findsOneWidget);
    });

    testWidgets('should display quick actions on overview tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('New Work Order'), findsWidgets);
      expect(find.text('Add Customer'), findsWidgets);
      expect(find.text('Create Invoice'), findsOneWidget);
      expect(find.text('Check Inventory'), findsOneWidget);
    });

    testWidgets('should display recent activity on overview tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopManagementScreen(),
          ),
        ),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });
  });
}