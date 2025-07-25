class LanguageConfig {
  final String code;
  final String name;
  final String nativeName;
  final String flagAsset;

  const LanguageConfig({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagAsset,
  });

  static const List<LanguageConfig> supportedLanguages = [
    LanguageConfig(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagAsset: 'assets/icons/flags/en.png',
    ),
    LanguageConfig(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flagAsset: 'assets/icons/flags/es.png',
    ),
    LanguageConfig(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flagAsset: 'assets/icons/flags/fr.png',
    ),
    LanguageConfig(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flagAsset: 'assets/icons/flags/de.png',
    ),
    LanguageConfig(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flagAsset: 'assets/icons/flags/zh.png',
    ),
    LanguageConfig(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flagAsset: 'assets/icons/flags/ja.png',
    ),
  ];

  static LanguageConfig? fromCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nativeName': nativeName,
    'flagAsset': flagAsset,
  };

  factory LanguageConfig.fromJson(Map<String, dynamic> json) => LanguageConfig(
    code: json['code'],
    name: json['name'],
    nativeName: json['nativeName'],
    flagAsset: json['flagAsset'],
  );
}