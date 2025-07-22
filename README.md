# OBD-II Diagnostics and Programming Tool

A comprehensive, cross-platform OBD-II diagnostics and programming tool built with Flutter. This application provides professional-grade vehicle diagnostics capabilities across iOS, Android, Windows, macOS, Linux, and ARM-based devices.

## 🌟 Features

### Cross-Platform Compatibility
- **Mobile**: iOS 12.0+ and Android 6.0+ (API 23+)
- **Desktop**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)
- **ARM Support**: Native support for Apple Silicon, Raspberry Pi, and other ARM64 devices
- **Unified Codebase**: Single Flutter codebase for all platforms

### OBD-II Communication
- **Multiple Connection Types**: Bluetooth, USB, WiFi, and Serial adapters
- **Protocol Support**: CAN-BUS, ISO 9141-2, KWP2000, J1850 VPW/PWM
- **Real-time Data**: Live monitoring of engine parameters and sensor data
- **Diagnostic Codes**: Read, clear, and analyze DTCs with detailed descriptions

### Professional Features
- **Vehicle Information**: VIN decoding, make/model identification, ECU details
- **System Testing**: O2 sensor, catalyst, EVAP system tests
- **ECU Programming**: Advanced ECU flashing and adaptation reset capabilities
- **Data Export**: Save diagnostic sessions and generate reports

### Adaptive UI
- **Responsive Design**: Optimized layouts for different screen sizes and orientations
- **Platform-Specific UI**: Native feel on each platform (Material Design, Cupertino, Fluent)
- **Dark/Light Themes**: System-aware theming with manual override options

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK**: Version 3.0.0 or higher
   ```bash
   flutter --version
   ```

2. **Platform-Specific Requirements**:
   - **Android**: Android Studio, Android SDK
   - **iOS**: Xcode 14.0+, iOS Developer Account (for device testing)
   - **Windows**: Visual Studio 2022 with C++ support
   - **macOS**: Xcode Command Line Tools
   - **Linux**: GTK 3.0, build essentials

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

3. **Check platform setup**:
   ```bash
   flutter doctor
   ```

### Building for Different Platforms

#### Android
```bash
# Debug build
flutter run -d android

# Release APK
flutter build apk --release

# Release Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Debug build (requires iOS device or simulator)
flutter run -d ios

# Release build
flutter build ios --release

# Create IPA (requires proper signing)
flutter build ipa --release
```

#### Windows
```bash
# Debug build
flutter run -d windows

# Release build
flutter build windows --release
```

#### macOS
```bash
# Debug build
flutter run -d macos

# Release build
flutter build macos --release
```

#### Linux
```bash
# Debug build
flutter run -d linux

# Release build
flutter build linux --release
```

#### Web
```bash
# Debug build
flutter run -d web-server

# Release build
flutter build web --release
```

## 🔧 Configuration

### Platform-Specific Setup

#### Android Permissions
The app automatically requests the following permissions:
- Bluetooth and Bluetooth LE
- Location (for Bluetooth scanning)
- USB device access
- Network access (for WiFi adapters)

#### iOS Permissions
Configure in `ios/Runner/Info.plist`:
- NSBluetoothAlwaysUsageDescription
- NSLocationWhenInUseUsageDescription

#### Desktop Permissions
- **Windows**: Requires administrator privileges for certain USB operations
- **Linux**: User must be in `dialout` group for serial port access
- **macOS**: May require privacy permissions for Bluetooth access

### OBD-II Adapter Configuration

#### Supported Adapters
1. **ELM327-based adapters** (Bluetooth, USB, WiFi)
2. **OBDLink series** (ScanTool.net)
3. **UniCarScan adapters**
4. **Generic ISO 15765-4 (CAN) adapters**

#### Connection Setup
1. **Bluetooth**: Pair adapter with device first
2. **USB**: Install appropriate drivers if needed
3. **WiFi**: Connect to adapter's WiFi network (usually `OBDII` or similar)
4. **Serial**: Ensure proper baud rate (typically 38400 or 115200)

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Platform-Specific Testing
```bash
# Test on specific platform
flutter test --platform android
flutter test --platform ios
flutter test --platform windows
```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── src/
│   ├── models/                  # Data models
│   │   └── obd_models.dart
│   ├── services/                # Business logic
│   │   ├── obd_service.dart     # OBD-II communication
│   │   └── platform_service.dart # Platform abstractions
│   └── ui/                      # User interface
│       ├── app.dart             # Main app widget
│       ├── screens/             # Application screens
│       └── widgets/             # Reusable widgets
```

### State Management
- **Riverpod**: For dependency injection and state management
- **Provider Pattern**: Clean separation of concerns
- **Reactive Streams**: Real-time data updates

### Cross-Platform Strategy
- **Single Codebase**: Shared business logic across all platforms
- **Platform Channels**: Native functionality where needed
- **Adaptive Widgets**: Platform-appropriate UI components
- **Responsive Design**: Flexible layouts for different screen sizes

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes following our coding standards
4. Run tests: `flutter test`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Platform-Specific Contributions
- **Android/iOS**: Implement native Bluetooth/USB communication
- **Desktop**: Add advanced serial port handling
- **All Platforms**: Improve OBD-II protocol support

### Code Style Guidelines
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation for public APIs
- Write tests for new features

## 📊 Roadmap

### Phase 1: Foundation ✅
- [x] Cross-platform Flutter setup
- [x] Basic UI framework with adaptive design
- [x] Core OBD-II service architecture
- [x] Platform-specific configurations
- [x] Comprehensive testing suite

### Phase 2: Core Features (In Progress)
- [ ] Bluetooth communication implementation
- [ ] USB serial communication
- [ ] Real DTC reading and clearing
- [ ] Live data streaming
- [ ] Vehicle information retrieval

### Phase 3: Advanced Features
- [ ] WiFi adapter support
- [ ] Advanced diagnostic procedures
- [ ] ECU programming capabilities
- [ ] Data logging and export
- [ ] Multi-language support

### Phase 4: Professional Features
- [ ] Custom diagnostic procedures
- [ ] Fleet management tools
- [ ] Cloud synchronization
- [ ] Professional reporting
- [ ] Technician collaboration tools

## 📱 Platform-Specific Features

### Mobile (iOS/Android)
- Touch-optimized interface
- Background Bluetooth scanning
- Share diagnostic reports
- GPS location tagging

### Desktop (Windows/macOS/Linux)
- Multi-window support
- Advanced keyboard shortcuts
- File system integration
- Professional workflow tools

### ARM Devices
- Optimized performance for Raspberry Pi
- Apple Silicon native support
- Low-power operation modes
- Embedded system integration

## 🔒 Security & Privacy

- **Local Data**: All diagnostic data stored locally by default
- **No Telemetry**: No usage tracking or data collection
- **Open Source**: Full source code available for security review
- **Secure Communication**: Encrypted communication with adapters where supported

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues
- **Connection Problems**: Check adapter compatibility and drivers
- **Permission Errors**: Ensure proper platform permissions granted
- **Build Issues**: Run `flutter clean` and `flutter pub get`

### Getting Help
- **Documentation**: Check this README and inline code documentation
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join community discussions for help and feature requests

### Professional Support
For commercial licensing, custom development, or professional support, please contact the maintainers.

---

**Made with ❤️ using Flutter for cross-platform excellence**