import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/models/language_config.dart';

class LocalizationService {
  static const String _basePath = 'assets/data/strings';
  static Map<String, dynamic> _localizedStrings = {};
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  /// Initialize the localization service with a specific language
  static Future<void> initialize(String languageCode) async {
    _currentLanguage = languageCode;
    await _loadLanguage(languageCode);
  }

  /// Load language strings from JSON file
  static Future<void> _loadLanguage(String languageCode) async {
    try {
      String jsonString;
      
      // Try to load the specific language file first
      try {
        jsonString = await rootBundle.loadString('$_basePath/app_strings_$languageCode.json');
      } catch (e) {
        // Fall back to default English if specific language file doesn't exist
        debugPrint('Language file for $languageCode not found, falling back to English');
        jsonString = await rootBundle.loadString('assets/data/app_strings.json');
        _currentLanguage = 'en';
      }
      
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading language strings: $e');
      // If all else fails, use default empty map
      _localizedStrings = {};
    }
  }

  /// Get localized string by key path (e.g., 'navigation.dashboard')
  static String getString(String keyPath, {Map<String, String>? params}) {
    final keys = keyPath.split('.');
    dynamic current = _localizedStrings;
    
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        // Return key if not found for debugging
        return keyPath;
      }
    }
    
    String result = current?.toString() ?? keyPath;
    
    // Replace parameters if provided
    if (params != null) {
      params.forEach((key, value) {
        result = result.replaceAll('{$key}', value);
      });
    }
    
    return result;
  }

  /// Switch to a different language
  static Future<void> switchLanguage(String languageCode) async {
    if (languageCode != _currentLanguage) {
      await _loadLanguage(languageCode);
    }
  }

  /// Get all supported languages
  static List<LanguageConfig> getSupportedLanguages() {
    return LanguageConfig.supportedLanguages;
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String languageCode) {
    return LanguageConfig.supportedLanguages
        .any((lang) => lang.code == languageCode);
  }

  /// Get the current language configuration
  static LanguageConfig getCurrentLanguageConfig() {
    return LanguageConfig.fromCode(_currentLanguage) ?? 
           LanguageConfig.supportedLanguages.first;
  }
}

/// Extension to make localization easier to use in widgets
extension LocalizationExtension on String {
  String get tr => LocalizationService.getString(this);
  String trParams(Map<String, String> params) => 
      LocalizationService.getString(this, params: params);
}