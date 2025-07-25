import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_constants.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/localization_service.dart';
import 'core/services/vehicle_service.dart';
import 'core/services/ecu_programming_service.dart';
import 'core/services/cloud_sync_service.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/settings/presentation/advanced_settings_screen.dart';
import 'features/ecu_programming/presentation/ecu_programming_screen.dart';
import 'features/ai_diagnostics/presentation/ai_diagnostics_screen.dart';
import 'features/predictive_maintenance/presentation/predictive_maintenance_screen.dart';
import 'features/telematics/presentation/telematics_screen.dart';
import 'features/shop_management/presentation/shop_management_screen.dart';
import 'shared/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-specific services
  await _initializeServices();
  
  runApp(
    const ProviderScope(
      child: OBD2DiagnosticsApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  try {
    // Initialize secure storage first
    await SecureStorageService.initialize();
    
    // Initialize localization with default language
    await LocalizationService.initialize('en');
    
    // Initialize other services
    await Future.wait([
      VehicleService.initialize(),
      EcuProgrammingService.initialize(),
      CloudSyncService.initialize(),
    ]);
    
    debugPrint('All services initialized successfully');
  } catch (e) {
    // Handle initialization errors gracefully
    debugPrint('Service initialization warning: $e');
  }
}

class OBD2DiagnosticsApp extends ConsumerWidget {
  const OBD2DiagnosticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12 Pro size as base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(context, false),
          darkTheme: _buildTheme(context, true),
          themeMode: ref.watch(themeProvider),
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
          routes: {
            '/': (context) => const DashboardScreen(),
            '/settings': (context) => const AdvancedSettingsScreen(),
            '/ecu-programming': (context) => const EcuProgrammingScreen(),
            '/ai-diagnostics': (context) => const AIDiagnosticsScreen(),
            '/predictive-maintenance': (context) => const PredictiveMaintenanceScreen(),
            '/telematics': (context) => const TelematicsScreen(),
            '/shop-management': (context) => const ShopManagementScreen(),
          },
          home: const DashboardScreen(),
        );
      },
    );
  }

  ThemeData _buildTheme(BuildContext context, bool isDark) {
    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF03DAC6),
            surface: Color(0xFF121212),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
          )
        : const ColorScheme.light(
            primary: Color(0xFF1976D2),
            secondary: Color(0xFF00BCD4),
            surface: Color(0xFFFFFFFF),
            background: Color(0xFFF5F5F5),
            error: Color(0xFFB00020),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}