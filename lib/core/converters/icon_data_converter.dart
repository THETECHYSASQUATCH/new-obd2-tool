import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Custom JsonConverter for IconData serialization/deserialization
/// 
/// This converter handles the complete IconData properties including:
/// - codePoint: The Unicode code point for the icon
/// - fontFamily: The font family (defaults to 'MaterialIcons')
/// - fontPackage: The package containing the font (optional)
/// - matchTextDirection: Whether the icon should be mirrored for RTL text
/// 
/// Example usage in a model class:
/// ```dart
/// @JsonSerializable()
/// class MyModel {
///   @IconDataConverter()
///   final IconData icon;
///   
///   MyModel({required this.icon});
///   
///   factory MyModel.fromJson(Map<String, dynamic> json) => 
///       _$MyModelFromJson(json);
///   Map<String, dynamic> toJson() => _$MyModelToJson(this);
/// }
/// ```
class IconDataConverter implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'] as int,
      fontFamily: json['fontFamily'] as String? ?? 'MaterialIcons',
      fontPackage: json['fontPackage'] as String?,
      matchTextDirection: json['matchTextDirection'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily ?? 'MaterialIcons',
      if (icon.fontPackage != null) 'fontPackage': icon.fontPackage,
      'matchTextDirection': icon.matchTextDirection,
    };
  }
}

/// Simplified IconData converter that only stores the codePoint for backward compatibility
/// Use this for legacy models that were using the simple int approach
class SimpleIconDataConverter implements JsonConverter<IconData, int> {
  const SimpleIconDataConverter();

  @override
  IconData fromJson(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  @override
  int toJson(IconData icon) {
    return icon.codePoint;
  }
}