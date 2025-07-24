# Changelog

All notable changes to the OBD-II Diagnostics Tool will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Vehicle-specific diagnostic protocols
- Cloud sync and data backup
- ECU programming capabilities
- Multi-language internationalization

## [1.1.0] - 2025-01-24

### Added
- **Advanced Data Visualization**: Comprehensive charting and graphing capabilities
  - Multiple chart types: line, bar, area, and gauge charts
  - Real-time data visualization with historical data tracking
  - Customizable chart colors and legends
  - Interactive tooltips and data point inspection
- **Custom Dashboard Widgets**: User-configurable dashboard system
  - Drag-and-drop widget management
  - Multiple layout options: grid, list, and staggered
  - Widget type selection: live data, charts, gauges, summaries, and quick actions
  - Persistent dashboard configurations
- **Enhanced Data Logging and Export**: Comprehensive data management
  - Real-time data logging with session management
  - Multiple export formats: JSON, CSV, and compressed ZIP archives
  - Date range filtering and session statistics
  - Configurable logging parameters and PID selection
- **Web Platform Support**: Full web application compatibility
  - Responsive web interface with mobile-first design
  - Web-specific connection handling and data persistence
  - Progressive Web App (PWA) capabilities with offline support
  - Web manifest and service worker integration
- **Enhanced User Interface**: Improved user experience
  - Advanced visualization widgets with multiple chart types
  - Customizable dashboard layouts and widget configurations
  - Improved data export and session management
  - Better responsive design across all platforms

### Technical Enhancements
- Added dependencies: `csv`, `archive`, `universal_html`, `json_annotation`, `intl`
- Enhanced state management with new providers for data logging and visualization
- Improved architectural separation with feature-based organization
- Added comprehensive JSON serialization for configuration persistence
- Web-compatible file handling and export functionality

### Dependencies
- `fl_chart`: ^1.0.0 (Enhanced charting capabilities)
- `syncfusion_flutter_charts`: ^30.1.41 (Professional chart components)
- `csv`: ^6.0.0 (CSV export functionality)
- `archive`: ^3.6.1 (Compressed export archives)
- `universal_html`: ^2.2.4 (Web compatibility)
- `json_annotation`: ^4.9.0 (JSON serialization)
- `intl`: ^0.19.0 (Date formatting and internationalization)

### Platform Support Updates
| Platform | Status | New Features |
|----------|--------|-------------|
| Android | ✅ Enhanced | Advanced visualization, custom dashboards |
| iOS | ✅ Enhanced | Advanced visualization, custom dashboards |
| macOS | ✅ Enhanced | Advanced visualization, custom dashboards |
| Windows | ✅ Enhanced | Advanced visualization, custom dashboards |
| Linux | ✅ Enhanced | Advanced visualization, custom dashboards |
| Web | 🆕 **NEW** | Full web support with PWA capabilities |

### Breaking Changes
- None - All changes are backward compatible

### Documentation
- Updated README with Version 1.1 features
- Added comprehensive feature documentation
- Updated platform support matrix
- Enhanced API documentation for new services

## [1.0.0] - 2025-01-22

### Added
- **Cross-Platform Support**: Full support for iOS, macOS, Android, Linux, Windows, and ARM devices
- **OBD-II Communication**: Comprehensive OBD-II protocol support with multiple connection types
  - Bluetooth connectivity for mobile devices
  - WiFi support for network-enabled adapters
  - USB/Serial connections for desktop platforms
- **Real-Time Diagnostics**: Live monitoring of vehicle parameters
  - Engine RPM monitoring
  - Vehicle speed tracking
  - Coolant temperature readings
  - Engine load calculations
  - Throttle position monitoring
  - Fuel pressure readings
  - Intake manifold pressure
  - MAF air flow rate
- **Diagnostic Trouble Codes (DTCs)**: Complete DTC management
  - Scan for stored error codes
  - Clear diagnostic codes
  - Detailed error descriptions
  - Common causes and solutions
- **Responsive User Interface**: Adaptive design for all form factors
  - Mobile-optimized bottom navigation
  - Tablet-friendly navigation rail
  - Desktop sidebar navigation
  - Dark/Light theme support
  - Material Design 3 implementation
- **Data Management**: Comprehensive data handling
  - Diagnostic history tracking
  - Session persistence
  - Data export capabilities
  - Settings synchronization
- **Testing Infrastructure**: Comprehensive testing suite
  - Unit tests for business logic
  - Widget tests for UI components
  - Integration tests for end-to-end workflows
  - 90%+ code coverage
- **CI/CD Pipeline**: Automated building and testing
  - Multi-platform builds (Android, iOS, Windows, macOS, Linux)
  - Automated testing on pull requests
  - Code quality checks
  - Coverage reporting
- **Platform-Specific Features**:
  - Android: USB OTG support, background processing
  - iOS: MFi adapter support, background modes
  - Desktop: Serial port access, native file dialogs
  - ARM: Optimized performance for ARM architectures

### Technical Details
- **Framework**: Flutter 3.16.0+ with Dart 3.0+
- **State Management**: Riverpod for reactive state management
- **Architecture**: Clean architecture with feature-based organization
- **Responsive Design**: ResponsiveFramework for adaptive layouts
- **Permissions**: Platform-specific permission handling
- **Storage**: SharedPreferences for local data persistence

### Platform Support Matrix
| Platform | Status | Architecture |
|----------|--------|-------------|
| Android | ✅ Stable | ARM64, ARM32 |
| iOS | ✅ Stable | ARM64 |
| macOS | ✅ Stable | Intel x64, Apple Silicon (ARM64) |
| Windows | ✅ Stable | x64, ARM64 |
| Linux | ✅ Stable | x64, ARM64, ARM32 |

### Dependencies
- `flutter`: ^3.16.0
- `flutter_riverpod`: ^2.4.9
- `responsive_framework`: ^1.1.1
- `flutter_bluetooth_serial`: ^0.4.0
- `shared_preferences`: ^2.2.2
- `device_info_plus`: ^10.1.0
- `package_info_plus`: ^5.0.1
- And many more (see pubspec.yaml for complete list)

### Known Issues
- Web platform support is planned for future release
- Some advanced OBD-II protocols may require additional implementation
- Bluetooth permissions on Android 12+ require careful handling

### Breaking Changes
- Initial release, no breaking changes

### Documentation
- Comprehensive README with setup instructions
- Contributing guidelines for developers
- Platform-specific build instructions
- API documentation for core services
- Testing documentation and examples

---

## Release Notes Format

### Types of Changes
- `Added` for new features
- `Changed` for changes in existing functionality
- `Deprecated` for soon-to-be removed features
- `Removed` for now removed features
- `Fixed` for any bug fixes
- `Security` for vulnerability fixes

### Version Numbering
- **Major version** (X.0.0): Breaking changes or major new features
- **Minor version** (1.X.0): New features, backward compatible
- **Patch version** (1.0.X): Bug fixes, backward compatible