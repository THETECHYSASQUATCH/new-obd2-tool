# Additional language files for multi-language support

## German (Deutsch)
- File path: `assets/data/strings/app_strings_de.json`
- Native name: Deutsch
- Status: Framework ready, translation needed

## Chinese (中文)  
- File path: `assets/data/strings/app_strings_zh.json`
- Native name: 中文
- Status: Framework ready, translation needed

## Japanese (日本語)
- File path: `assets/data/strings/app_strings_ja.json`  
- Native name: 日本語
- Status: Framework ready, translation needed

The localization service is designed to automatically fall back to English if a specific language file is not found, making it easy to add new languages incrementally.

## Adding a New Language

1. Create a new JSON file: `assets/data/strings/app_strings_{language_code}.json`
2. Copy the structure from `app_strings_en.json` (the original file)
3. Translate all string values while keeping the keys unchanged
4. Add the language to `LanguageConfig.supportedLanguages` in `language_config.dart`
5. Update the `pubspec.yaml` assets section if needed (already included with `assets/data/strings/`)

The application will automatically detect and load the new language option.