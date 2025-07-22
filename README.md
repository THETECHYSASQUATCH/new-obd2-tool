# OBD-II Diagnostics and Programming Tool

A comprehensive cross-platform OBD-II diagnostics and programming tool built with Flutter, supporting iOS, macOS, Android, Linux, Windows, and ARM-based devices.

## Features

### 🚗 Comprehensive OBD-II Support
- **Real-time diagnostics**: Monitor engine RPM, vehicle speed, coolant temperature, and more
- **Diagnostic Trouble Codes (DTCs)**: Scan, read, and clear error codes
- **Live data streaming**: Continuous monitoring of vehicle parameters
- **Custom commands**: Send custom OBD-II commands for advanced diagnostics
- **Protocol support**: Automatic protocol detection for various OBD-II adapters

### 📱 Cross-Platform Compatibility
- **Mobile**: iOS (iPhone/iPad) and Android
- **Desktop**: macOS, Windows, and Linux
- **ARM support**: Apple Silicon Macs, Raspberry Pi, and other ARM devices
- **Responsive design**: Adaptive UI for different screen sizes and form factors

### 🔌 Multiple Connection Types
- **Bluetooth**: ELM327 and compatible adapters
- **WiFi**: Network-enabled OBD-II devices
- **USB/Serial**: Direct wired connections on desktop platforms
- **Auto-discovery**: Automatic scanning and device detection

### 🎨 Modern User Interface
- **Material Design 3**: Native look and feel on all platforms
- **Dark/Light themes**: System-aware theme switching
- **Responsive layouts**: Optimized for mobile, tablet, and desktop
- **Platform-specific adaptations**: Navigation patterns that feel native

### 📊 Data Management
- **History tracking**: Store and review diagnostic sessions
- **Data export**: Export diagnostic data for analysis
- **Settings persistence**: Remember connection preferences
- **Real-time charts**: Visualize live vehicle data

## Supported Platforms

| Platform | Status | Architecture Support |
|----------|--------|---------------------|
| Android | ✅ Supported | ARM64, ARM32 |
| iOS | ✅ Supported | ARM64 |
| macOS | ✅ Supported | Intel x64, Apple Silicon (ARM64) |
| Windows | ✅ Supported | x64, ARM64 |
| Linux | ✅ Supported | x64, ARM64, ARM32 |
| Web | 🚧 Planned | N/A |

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Platform-specific development tools:
  - **Android**: Android Studio with Android SDK
  - **iOS**: Xcode 14+ (macOS only)
  - **Desktop**: Platform-specific build tools

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/THETECHYSASQUATCH/new-obd2-tool.git
   cd new-obd2-tool
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For mobile development
   flutter run
   
   # For specific platforms
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

### Building for Production

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

### Version 1.1 (Planned)
- [ ] Advanced graphing and data visualization
- [ ] Custom dashboard widgets
- [ ] Data logging and export improvements
- [ ] Web platform support

### Version 1.2 (Future)
- [ ] Vehicle-specific diagnostic protocols
- [ ] ECU programming capabilities
- [ ] Cloud sync and backup
- [ ] Multi-language support

---

**Disclaimer**: This tool is for diagnostic purposes only. Always consult professional mechanics for serious vehicle issues. Use caution when clearing diagnostic codes as this may affect vehicle emissions compliance.