# OBD-II Diagnostics and Programming Tool

Do not download Code zip just use the releases download. Code is not tested yet.

A comprehensive cross-platform OBD-II diagnostics and programming tool built with Flutter, supporting iOS, macOS, Android, Linux, Windows, and ARM-based devices.

## Features

### 🚗 Comprehensive OBD-II Support
- **Real-time diagnostics**: Monitor engine RPM, vehicle speed, coolant temperature, and more
- **Diagnostic Trouble Codes (DTCs)**: Scan, read, and clear error codes
- **Live data streaming**: Continuous monitoring of vehicle parameters
- **Custom commands**: Send custom OBD-II commands for advanced diagnostics
- **Protocol support**: Automatic protocol detection for various OBD-II adapters
- **Vehicle-specific diagnostics**: Tailored diagnostics for specific makes and models with manufacturer PIDs

### 🔧 Advanced ECU Programming
- **ECU discovery**: Automatic detection of programmable control modules
- **Multiple programming modes**: Flash programming, calibration updates, coding, and adaptation
- **Safety features**: Automatic backup creation, progress monitoring, and error recovery
- **Multi-ECU support**: Engine, transmission, body, hybrid, and other control modules
- **Professional-grade tools**: Security access, verification, and comprehensive logging

### ☁️ Cloud Sync and Backup
- **Multi-provider support**: Firebase, AWS, Azure, Google Cloud, and custom endpoints
- **Automatic synchronization**: Scheduled sync with configurable intervals
- **Data encryption**: AES-256 encryption for all cloud data
- **Backup management**: Create, restore, and manage diagnostic data backups
- **Selective sync**: Choose which data types to synchronize

### 🌍 Multi-Language Support
- **Internationalization**: Complete UI translation support
- **Multiple languages**: English, Spanish, French, with framework for additional languages
- **Native font support**: Proper rendering for all supported languages
- **Dynamic switching**: Change language without app restart
- **Extensible framework**: Easy addition of new languages

### 📱 Cross-Platform Compatibility
- **Mobile**: iOS (iPhone/iPad) and Android
- **Desktop**: macOS, Windows, and Linux
- **ARM support**: Apple Silicon Macs, Raspberry Pi, and other ARM devices
- **Responsive design**: Adaptive UI for different screen sizes and form factors

### 🎨 Modern User Interface
- **Material Design 3**: Native look and feel on all platforms
- **Dark/Light themes**: System-aware theme switching
- **Responsive layouts**: Optimized for mobile, tablet, and desktop
- **Platform-specific adaptations**: Navigation patterns that feel native
- **Custom dashboards**: Personalized widget arrangements and layouts

### 🔌 Multiple Connection Types
- **Bluetooth**: ELM327 and compatible adapters
- **WiFi**: Network-enabled OBD-II devices
- **USB/Serial**: Direct wired connections on desktop platforms
- **Web compatibility**: Network-based connections for web platform
- **Auto-discovery**: Automatic scanning and device detection

### 📊 Enhanced Data Management and Visualization
- **Advanced charting**: Real-time line, bar, area, and gauge charts
- **Data logging**: Comprehensive session-based data recording
- **Export functionality**: CSV, JSON, and compressed archive exports
- **Custom dashboards**: User-configurable widget layouts and configurations
- **Historical analysis**: Data trends and statistical insights

## Supported Platforms

| Platform | Status | Architecture Support |
|----------|--------|---------------------|
| Android | ✅ Supported | ARM64, ARM32 |
| iOS | ✅ Supported | ARM64 |
| macOS | ✅ Supported | Intel x64, Apple Silicon (ARM64) |
| Windows | ✅ Supported | x64, ARM64 |
| Linux | ✅ Supported | x64, ARM64, ARM32 |
| Web | ✅ Supported | N/A |

## Getting Started

### Prerequisites

- **Flutter SDK 3.0.0 or higher** - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- Platform-specific development tools:
  - **Android**: Android Studio with Android SDK (API level 21+)
  - **iOS**: Xcode 14+ (macOS only)
  - **Desktop**: Platform-specific build tools
    - **Windows**: Visual Studio 2022 with C++ desktop development
    - **macOS**: Xcode with command line tools
    - **Linux**: Required development packages (see [Flutter Linux setup](https://docs.flutter.dev/get-started/install/linux))

### Installation and Dependency Setup

1. **Verify Flutter installation**:
   ```bash
   flutter doctor
   ```
   Ensure all required dependencies are installed and configured.

2. **Clone the repository**:
   ```bash
   git clone https://github.com/THETECHYSASQUATCH/new-obd2-tool.git
   cd new-obd2-tool
   ```

3. **Install project dependencies**:
   ```bash
   flutter pub get
   ```
   This will:
   - Download all required packages
   - Generate `pubspec.lock` for reproducible builds
   - Set up platform-specific configurations

4. **Verify setup**:
   ```bash
   flutter analyze          # Check for code issues
   flutter test             # Run unit and widget tests
   ```

5. **Run the app**:
   ```bash
   # For mobile development
   flutter run
   
   # For specific platforms
   flutter run -d android
   flutter run -d ios
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

### Dependency Management

For detailed information about managing dependencies, see [DEPENDENCIES.md](DEPENDENCIES.md).

**Quick commands:**
```bash
# Check for outdated dependencies
flutter pub outdated

# Update dependencies safely
./scripts/update_deps.sh interactive

# Add a new dependency
flutter pub add package_name

# Remove a dependency
flutter pub remove package_name
```

### Building for Production

#### Web Platform
```bash
# Run in development mode
flutter run -d chrome

# Build for production
flutter build web --release

# Deploy to web server
# Copy build/web/ contents to your web server
```

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Desktop Platforms
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Usage

### Connecting to an OBD-II Device

1. **Bluetooth (Mobile)**:
   - Ensure Bluetooth is enabled
   - Pair your ELM327 adapter with your device
   - Launch the app and navigate to the Connection tab
   - Select your device from the list and connect

2. **WiFi (All Platforms)**:
   - Connect to your OBD-II adapter's WiFi network
   - Use the default IP address (usually 192.168.4.1) or scan for devices
   - Connect through the app

3. **USB/Serial (Desktop)**:
   - Connect your OBD-II adapter via USB
   - Select the appropriate COM port or device path
   - Configure baud rate if necessary (default: 38400)

### Performing Diagnostics

1. **Live Data**: View real-time engine parameters on the dashboard
2. **Scan DTCs**: Check for diagnostic trouble codes
3. **Clear Codes**: Reset stored error codes (use with caution)
4. **Custom Commands**: Send specific OBD-II PIDs for advanced diagnostics

## Architecture

The application follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/     # App-wide constants
│   ├── services/      # Core services (OBD communication)
│   └── utils/         # Utility functions
├── features/
│   ├── dashboard/     # Main dashboard feature
│   ├── diagnostics/   # Diagnostic features
│   ├── settings/      # App settings
│   └── history/       # Diagnostic history
└── shared/
    ├── models/        # Data models
    ├── providers/     # State management (Riverpod)
    └── widgets/       # Reusable UI components
```

### Key Technologies

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management and dependency injection
- **ResponsiveFramework**: Responsive design utilities
- **SharedPreferences**: Local data persistence
- **flutter_bluetooth_serial**: Bluetooth communication
- **Platform channels**: Native platform integration

## Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Categories

- **Unit Tests**: Core business logic and data models
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end testing on devices

## Platform-Specific Considerations

### Android
- **Permissions**: Bluetooth, location, and storage permissions are handled automatically
- **USB OTG**: Support for USB OBD-II adapters on compatible devices
- **Background processing**: Maintains connections when app is backgrounded

### iOS
- **MFi Support**: Compatible with Made for iPhone/iPad OBD-II adapters
- **Background modes**: Maintains Bluetooth connections in background
- **Privacy**: All required usage descriptions are included

### Desktop Platforms
- **Serial ports**: Direct access to COM ports and USB devices
- **Native integration**: Platform-specific file dialogs and system integration
- **Window management**: Resizable windows with responsive layouts

### ARM Devices
- **Raspberry Pi**: Full Linux desktop support
- **Apple Silicon**: Native ARM64 support on M1/M2 Macs
- **ARM64 Windows**: Support for ARM-based Windows devices

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Style

The project follows Dart/Flutter coding conventions:
- Use `dart format` for code formatting
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Maintain test coverage above 80%

## Troubleshooting

### Common Issues

#### Bluetooth Connection Problems
- Ensure the OBD-II adapter is properly paired
- Check that location permissions are granted (iOS/Android)
- Verify the adapter is plugged into the vehicle's OBD-II port
- Try resetting the adapter (unplug for 10 seconds)

#### USB/Serial Connection Issues
- Check device permissions on Linux (`sudo usermod -a -G dialout $USER`)
- Verify correct COM port selection on Windows
- Ensure no other applications are using the serial port

#### Build Issues
- Run `flutter clean` and `flutter pub get`
- Check Flutter version compatibility
- Verify platform-specific dependencies are installed

### Getting Help

- Check the [Issues](https://github.com/THETECHYSASQUATCH/new-obd2-tool/issues) for known problems
- Create a new issue with detailed information
- Join our community discussions

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter Team](https://flutter.dev/) for the amazing cross-platform framework
- [ELM Electronics](https://www.elmelectronics.com/) for OBD-II interface specifications
- The open-source community for various dependencies and inspiration

## Roadmap

### Version 1.3 (Current)
- [x] Advanced AI-powered diagnostics
- [x] Predictive maintenance alerts
- [x] Integration with vehicle telematics
- [x] Professional shop management features

### Version 1.2 (Previous)
- [x] Vehicle-specific diagnostic protocols
- [x] ECU programming capabilities
- [x] Cloud sync and backup
- [x] Multi-language support

### Version 1.1 (Previous)
- [x] Advanced graphing and data visualization
- [x] Custom dashboard widgets
- [x] Data logging and export improvements
- [x] Web platform support

---

**Disclaimer**: This tool is for diagnostic purposes only. Always consult professional mechanics for serious vehicle issues. Use caution when clearing diagnostic codes as this may affect vehicle emissions compliance.