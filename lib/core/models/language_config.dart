import 'dart:convert';

class LanguageConfig {
  final String languageCode;
  final String displayName;
  final String nativeName;
  final bool isRtl;
  final bool isEnabled;
  final String? fontFamily;
  final Map<String, dynamic> metadata;

  const LanguageConfig({
    required this.languageCode,
    required this.displayName,
    required this.nativeName,
    this.isRtl = false,
    this.isEnabled = true,
    this.fontFamily,
    this.metadata = const {},
  });

  factory LanguageConfig.fromJson(Map<String, dynamic> json) {
    return LanguageConfig(
      languageCode: json['languageCode'] as String,
      displayName: json['displayName'] as String,
      nativeName: json['nativeName'] as String,
      isRtl: json['isRtl'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      fontFamily: json['fontFamily'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'displayName': displayName,
      'nativeName': nativeName,
      'isRtl': isRtl,
      'isEnabled': isEnabled,
      'fontFamily': fontFamily,
      'metadata': metadata,
    };
  }

  LanguageConfig copyWith({
    String? languageCode,
    String? displayName,
    String? nativeName,
    bool? isRtl,
    bool? isEnabled,
    String? fontFamily,
    Map<String, dynamic>? metadata,
  }) {
    return LanguageConfig(
      languageCode: languageCode ?? this.languageCode,
      displayName: displayName ?? this.displayName,
      nativeName: nativeName ?? this.nativeName,
      isRtl: isRtl ?? this.isRtl,
      isEnabled: isEnabled ?? this.isEnabled,
      fontFamily: fontFamily ?? this.fontFamily,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageConfig && other.languageCode == languageCode;
  }

  @override
  int get hashCode => languageCode.hashCode;

  @override
  String toString() {
    return 'LanguageConfig(languageCode: $languageCode, displayName: $displayName)';
  }
}

class SupportedLanguages {
  static const List<LanguageConfig> languages = [
    LanguageConfig(
      languageCode: 'en',
      displayName: 'English',
      nativeName: 'English',
    ),
    LanguageConfig(
      languageCode: 'es',
      displayName: 'Spanish',
      nativeName: 'Español',
    ),
    LanguageConfig(
      languageCode: 'fr',
      displayName: 'French',
      nativeName: 'Français',
    ),
    LanguageConfig(
      languageCode: 'de',
      displayName: 'German',
      nativeName: 'Deutsch',
    ),
    LanguageConfig(
      languageCode: 'zh',
      displayName: 'Chinese',
      nativeName: '中文',
    ),
  ];

  static LanguageConfig? getByCode(String code) {
    try {
      return languages.firstWhere((lang) => lang.languageCode == code);
    } catch (e) {
      return null;
    }
  }

  static bool isSupported(String code) {
    return getByCode(code) != null;
  }
}