import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-specific configurations
  await _initializePlatformConfigurations();
  
  runApp(
    ProviderScope(
      child: OBD2DiagnosticsApp(),
    ),
  );
}

Future<void> _initializePlatformConfigurations() async {
  // Platform-specific initialization will be handled here
  // This includes setting up permissions, Bluetooth configurations, etc.
  
  if (defaultTargetPlatform == TargetPlatform.android) {
    // Android-specific initialization
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    // iOS-specific initialization
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.linux ||
             defaultTargetPlatform == TargetPlatform.macOS) {
    // Desktop-specific initialization
  }
}