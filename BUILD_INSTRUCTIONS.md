# Build and Setup Instructions

## Prerequisites

This project requires Flutter SDK to be installed. Please ensure you have:
- **Flutter 3.16.0 or later**
- **Dart 3.8.0 or later** (required for compatibility with json_serializable and other modern packages)

To check your versions:
```bash
flutter --version
dart --version
```

## Initial Setup

After cloning this repository and checking out this branch, run the following commands to set up the project:

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code Files

This project uses code generation for JSON serialization and other generated code. Run the build runner to generate all necessary `.g.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Note:** We now use `dart run build_runner` instead of the deprecated `flutter pub run build_runner` for better compatibility with Dart 3.8.0+.

### 3. Clean and Rebuild (if needed)

If you encounter any build issues after the initial setup, try cleaning and rebuilding:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## What Was Fixed

This PR addresses major build failures by:

1. **Updated Dart SDK Requirements**: Updated minimum Dart SDK version to 3.8.0 to resolve compatibility warnings with `json_serializable` and other modern packages.

2. **Implemented Custom IconData JsonConverter**: Added proper IconData serialization support in `lib/core/converters/icon_data_converter.dart` with:
   - Complete IconData property handling (codePoint, fontFamily, fontPackage, matchTextDirection)
   - Backward compatibility with simple integer-based serialization
   - Comprehensive documentation and usage examples

3. **Updated Build Commands**: Replaced deprecated `flutter pub run build_runner` with the modern `dart run build_runner` approach throughout the documentation.

4. **Added Missing Model Files**: Created placeholder implementations for all missing model classes in `lib/core/models/`:
   - `language_config.dart` - Language configuration settings
   - `vehicle_info.dart` - Vehicle information and database structures
   - `ecu_programming.dart` - ECU programming session management
   - `cloud_sync.dart` - Cloud synchronization settings and sessions
   - `obd_response.dart` - OBD response parsing and data structures
   - `ai_diagnostic_result.dart` - Export reference to existing AI diagnostic models

5. **Fixed Import Issues**: Added `dart:math` import to `telematics_data.dart` to resolve missing mathematical function errors.

6. **Updated Dependencies**: Added missing `syncfusion_flutter_gauges` dependency to support Syncfusion gauge widgets.

7. **Maintained Compatibility**: All changes are backward compatible with Flutter 3.16.0+ and existing CI/CD scripts.

## Next Steps

- The placeholder model files should be populated with proper data structures as development continues
- Run the build_runner command whenever you modify any `@JsonSerializable()` annotated classes: `dart run build_runner build`: `dart run build_runner build`
- Test the application to ensure all features work correctly with the new model structures
- The new IconData converter provides better serialization support for UI configurations

## Troubleshooting

### Version Requirements
Ensure your development environment meets the minimum requirements:
- **Flutter SDK**: 3.16.0 or later
- **Dart SDK**: 3.8.0 or later

### Common Build Issues

#### 1. Dart Version Compatibility Warnings
If you see warnings about Dart version compatibility with `json_serializable` or other packages:
```bash
# Update to Dart 3.8.0+ and run:
dart --version  # Should show 3.8.0 or later
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 2. Build Runner Issues
If code generation fails:
```bash
# Clean and regenerate all files
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 3. IconData Serialization Errors
If you encounter errors related to IconData serialization:
- Ensure you're using the `@IconDataConverter()` annotation for IconData fields
- Check that you've imported `'../../core/converters/icon_data_converter.dart'`
- Regenerate code with `dart run build_runner build --delete-conflicting-outputs`

#### 4. General Build Errors
If you encounter other build errors:
1. Ensure all dependencies are installed: `flutter pub get`
2. Clean and regenerate files: `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs`
3. Check that your Flutter SDK version meets the minimum requirements (3.16.0+)
4. Verify that all import paths are correct in your IDE
5. Restart your IDE after generating new code files

#### 5. CI/CD Compatibility
For CI/CD systems, update build scripts to use:
- `dart run build_runner build` instead of `flutter pub run build_runner build`
- Ensure Dart 3.8.0+ is available in the build environment

## Generated Files

The following files will be automatically generated by build_runner:
- `*.g.dart` files for JSON serialization
- Any other code generation outputs specified in the project configuration

These files should not be manually edited and are excluded from version control.