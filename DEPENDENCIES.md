# Dependency Management Guide

This document provides comprehensive guidance on managing dependencies for the OBD-II Diagnostics Tool Flutter project.

## Overview

The project uses Flutter's `pubspec.yaml` for dependency management, which supports:
- Runtime dependencies (for the application)
- Development dependencies (for testing and tooling)
- Platform-specific dependencies
- Asset management

## Dependency Files

### `pubspec.yaml`
The main dependency configuration file that defines:
- Project metadata (name, version, description)
- Flutter and Dart SDK constraints
- Runtime dependencies
- Development dependencies
- Asset declarations
- Platform-specific configurations

### `pubspec.lock`
The lockfile that ensures reproducible builds by:
- Locking exact versions of all dependencies and transitive dependencies
- Recording dependency resolution state
- **Should be committed** to version control for applications (unlike packages)
- Generated automatically when running `flutter pub get`

### `.dart_tool/package_config.json`
Generated file containing package resolution information (should not be committed).

## Setting Up Dependencies

### Initial Setup

1. **Install Flutter SDK** (version 3.0.0 or higher):
   - Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install)
   - Verify installation: `flutter doctor`

2. **Clone and setup the project**:
   ```bash
   git clone https://github.com/THETECHYSASQUATCH/new-obd2-tool.git
   cd new-obd2-tool
   flutter pub get
   ```

3. **Verify setup**:
   ```bash
   flutter doctor
   flutter analyze
   flutter test
   ```

### Platform-Specific Setup

#### Android Development
- **Android Studio** or **Visual Studio Code** with Flutter extension
- **Android SDK** (API level 21+)
- **Java Development Kit** (JDK 11+)

#### iOS Development (macOS only)
- **Xcode** (14.0+)
- **iOS Simulator** or physical iOS device
- **CocoaPods** (installed via `brew install cocoapods`)

#### Desktop Development
- **Windows**: Visual Studio 2022 with C++ desktop development workload
- **macOS**: Xcode with command line tools
- **Linux**: Required packages vary by distribution (see Flutter docs)

## Core Dependencies

### UI and Framework
- `flutter`: Core Flutter framework
- `cupertino_icons`: iOS-style icons
- `material_design_icons_flutter`: Material Design icon set

### Communication
- `flutter_bluetooth_serial`: Bluetooth communication for mobile
- `serial_port_win32`: Serial port communication on Windows
- `http`: HTTP networking
- `dio`: Advanced HTTP client with interceptors

### State Management
- `provider`: Simple state management
- `riverpod` & `flutter_riverpod`: Advanced state management and dependency injection

### Data Persistence
- `shared_preferences`: Key-value storage
- `sqflite`: SQLite database
- `path`: File path utilities
- `path_provider`: Platform-specific paths

### Platform Integration
- `device_info_plus`: Device information
- `package_info_plus`: App package information
- `permission_handler`: Runtime permissions
- `file_picker`: File selection dialogs

### UI/UX Enhancement
- `fl_chart`: Charting library
- `syncfusion_flutter_charts`: Advanced charts
- `responsive_framework`: Responsive design
- `flutter_screenutil`: Screen size adaptation

### Development and Testing
- `flutter_test`: Testing framework
- `flutter_lints`: Dart/Flutter linting rules
- `integration_test`: Integration testing
- `mockito`: Mocking for tests
- `build_runner`: Code generation

## Dependency Management Commands

### Basic Commands

```bash
# Install dependencies
flutter pub get

# Update dependencies (respecting version constraints)
flutter pub upgrade

# Update a specific dependency
flutter pub upgrade package_name

# Add a new dependency
flutter pub add package_name

# Add a development dependency
flutter pub add --dev package_name

# Remove a dependency
flutter pub remove package_name

# Check for outdated dependencies
flutter pub outdated

# Clean and reinstall dependencies
flutter clean && flutter pub get
```

### Advanced Commands

```bash
# Get dependency tree
flutter pub deps

# Analyze dependency conflicts
flutter pub deps --style=compact

# Download dependencies without running scripts
flutter pub get --offline

# Force refresh dependency cache
flutter pub cache repair

# Verify pubspec.yaml format
flutter pub pub publish --dry-run
```

## Updating Dependencies

### Regular Updates

1. **Check for updates**:
   ```bash
   flutter pub outdated
   ```

2. **Review changelog** for each dependency to understand breaking changes

3. **Update incrementally**:
   ```bash
   # Update non-breaking changes first
   flutter pub upgrade --major-versions
   
   # Test after each update
   flutter test
   flutter analyze
   ```

4. **Update pubspec.yaml constraints** if needed:
   ```yaml
   dependencies:
     package_name: ^2.0.0  # Updated from ^1.0.0
   ```

### Major Version Updates

1. **Create a feature branch** for the update
2. **Update one major dependency at a time**
3. **Read migration guides** for breaking changes
4. **Update code** to handle API changes
5. **Run full test suite** including integration tests
6. **Test on all target platforms**

### Security Updates

1. **Monitor security advisories**:
   - [pub.dev security advisories](https://pub.dev/security-advisories)
   - GitHub Dependabot alerts
   - Flutter security announcements

2. **Prioritize security updates**:
   ```bash
   # Check for security issues
   flutter pub audit
   
   # Update vulnerable packages immediately
   flutter pub upgrade package_name
   ```

## Dependency Constraints

### Version Constraints

```yaml
dependencies:
  # Exact version (not recommended for most cases)
  package_name: 1.2.3
  
  # Compatible version (recommended)
  package_name: ^1.2.3  # >=1.2.3 <2.0.0
  
  # Compatible version range
  package_name: '>=1.2.3 <1.3.0'
  
  # Git dependency
  package_name:
    git:
      url: https://github.com/user/repo.git
      ref: main
  
  # Path dependency (for local development)
  package_name:
    path: ../local_package
```

### SDK Constraints

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'  # Dart SDK
  flutter: ">=3.0.0"     # Flutter SDK
```

## Platform-Specific Dependencies

### Conditional Dependencies

```yaml
dependencies:
  # Universal dependency
  http: ^1.1.2
  
  # Platform-specific dependencies
  flutter_bluetooth_serial: ^0.4.0  # Mobile only
  serial_port_win32: ^0.2.2         # Windows only

dependency_overrides:
  # Override specific platform issues
  package_name: 1.2.3
```

### Platform Channels

Some dependencies require platform-specific implementations:
- Bluetooth communication (different per platform)
- Serial port access (desktop vs mobile)
- File system permissions (varies by platform)

## Troubleshooting

### Common Issues

#### Version Conflicts
```bash
# Clear pub cache
flutter pub cache clean

# Remove pubspec.lock and reinstall
rm pubspec.lock
flutter pub get
```

#### Platform-Specific Build Issues
```bash
# Clean platform-specific builds
flutter clean

# Rebuild platform-specific files
flutter pub get
cd ios && pod install && cd ..  # iOS only
```

#### Dependency Resolution Failures
```bash
# Check for conflicts
flutter pub deps

# Use dependency overrides if needed
# Add to pubspec.yaml:
dependency_overrides:
  problematic_package: 1.2.3
```

### Debug Commands

```bash
# Verbose dependency resolution
flutter pub get --verbose

# Analyze dependency tree
flutter pub deps --style=compact

# Check for unused dependencies
flutter pub deps --json | grep -E "\"(direct|dev)\""
```

## Best Practices

### Version Management
1. **Use semantic versioning** for your own packages
2. **Pin major versions** but allow minor/patch updates
3. **Test updates** in a separate branch
4. **Update regularly** to avoid large gaps

### Security
1. **Monitor vulnerabilities** regularly
2. **Update dependencies** promptly for security fixes
3. **Audit dependencies** before releases
4. **Avoid dependencies with security issues**

### Performance
1. **Minimize dependency count** when possible
2. **Use tree shaking** to reduce bundle size
3. **Profile app performance** after updates
4. **Consider dependency size** for mobile builds

### Development
1. **Use dev dependencies** for testing/tooling only
2. **Document custom dependencies** and their purpose
3. **Keep pubspec.yaml organized** with comments
4. **Commit pubspec.lock** for reproducible builds

## Automated Dependency Management

### GitHub Actions Integration

The project includes automated dependency checking in `.github/workflows/ci-cd.yml`:

- Dependency vulnerability scanning
- Automated dependency updates (via Dependabot)
- Build testing with updated dependencies

### Dependency Bot Configuration

Create `.github/dependabot.yml` for automated updates:

```yaml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    reviewers:
      - "maintainer-username"
```

## Scripts and Tools

### Dependency Update Script

The project includes a `scripts/update_deps.sh` script for semi-automated updates:

```bash
# Run dependency update workflow
./scripts/update_deps.sh

# Check specific dependency
./scripts/check_dep.sh package_name
```

### Custom Tools

- **Dependency checker**: Validates pubspec.yaml format
- **Security scanner**: Checks for known vulnerabilities
- **Update helper**: Assists with major version updates

## Resources

### Documentation
- [Flutter Package Management](https://docs.flutter.dev/development/packages-and-plugins/using-packages)
- [Dart Package Versioning](https://dart.dev/tools/pub/versioning)
- [pub.dev Package Site](https://pub.dev/)

### Tools
- [pub.dev](https://pub.dev/) - Official package repository
- [Flutter Package of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU1quF6ny8oFHJ2gBdrYN_AK)
- [Dependency Tracking Tools](https://pub.dev/packages?q=dependency+audit)

### Community
- [Flutter Community](https://flutter.dev/community)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Flutter Discord](https://github.com/flutter/flutter/wiki/Chat)

---

**Note**: Always test dependency updates thoroughly across all target platforms before deploying to production.