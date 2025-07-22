# Contributing to OBD-II Diagnostics Tool

Thank you for your interest in contributing to the OBD-II Diagnostics Tool! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Git
- Platform-specific development tools:
  - **Android**: Android Studio with Android SDK
  - **iOS**: Xcode 14+ (macOS only)  
  - **Desktop**: Platform-specific build tools

### Setting Up the Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/new-obd2-tool.git
   cd new-obd2-tool
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

## Development Guidelines

### Code Style

We follow the official Dart and Flutter style guidelines:

- Use `dart format` to format your code
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistency with existing code

### Architecture

The project follows a clean architecture pattern:

```
lib/
├── core/          # Core business logic and services
├── features/      # Feature-specific code
└── shared/        # Shared components and utilities
```

### Platform-Specific Considerations

When contributing platform-specific code:

#### Mobile (iOS/Android)
- Use appropriate permissions and platform checks
- Test on both iOS and Android devices
- Consider different screen sizes and orientations
- Follow platform-specific UI guidelines

#### Desktop (Windows/macOS/Linux)
- Ensure proper window sizing and management
- Test keyboard shortcuts and accessibility
- Consider different DPI scaling factors
- Handle file system permissions appropriately

#### ARM Devices
- Test on ARM-based devices when possible
- Ensure compatibility with different ARM architectures
- Consider performance implications

### Testing

All contributions should include appropriate tests:

#### Unit Tests
- Test business logic and data models
- Aim for 80%+ code coverage
- Use meaningful test descriptions

```dart
test('should parse RPM response correctly', () {
  // Test implementation
});
```

#### Widget Tests
- Test UI components in isolation
- Verify user interactions
- Test different states (loading, error, success)

```dart
testWidgets('should display loading state when value is null', (tester) async {
  // Test implementation
});
```

#### Integration Tests
- Test complete user workflows
- Verify platform-specific functionality
- Test on actual devices when possible

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/unit/obd_response_test.dart

# Run tests with coverage
flutter test --coverage
```

## Contribution Workflow

### 1. Choose an Issue

- Look for issues labeled `good first issue` for beginners
- Check existing issues or create a new one for discussion
- Comment on the issue to indicate you're working on it

### 2. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes

- Write clean, well-documented code
- Follow the existing code style
- Add tests for new functionality
- Update documentation if needed

### 4. Test Your Changes

```bash
# Run tests
flutter test

# Test on multiple platforms
flutter run -d android
flutter run -d ios
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### 5. Commit Your Changes

Use clear, descriptive commit messages:

```bash
git commit -m "Add support for custom OBD-II commands

- Implement command validation
- Add command history
- Update UI to show command results
- Add tests for command parsing"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Create a pull request with:
- Clear description of changes
- Link to related issues
- Screenshots for UI changes
- Platform testing information

## Types of Contributions

### Bug Fixes
- Fix existing functionality
- Include reproduction steps
- Add regression tests

### New Features
- Discuss in an issue first
- Follow existing patterns
- Include comprehensive tests
- Update documentation

### Documentation
- Improve README or other docs
- Add code comments
- Create tutorials or guides

### Performance Improvements
- Profile before and after changes
- Measure impact on different platforms
- Consider battery usage on mobile

### Platform Support
- Add support for new platforms
- Improve existing platform integrations
- Fix platform-specific bugs

## OBD-II Specific Guidelines

### Adding New PIDs
When adding support for new OBD-II Parameter IDs:

1. Add the PID to `AppConstants.standardPids`
2. Implement parsing logic in `OBDResponse._parseResponse()`
3. Add unit tests for the new PID
4. Update documentation

### Connection Types
When adding new connection types:

1. Add to the `ConnectionType` enum
2. Implement in platform-specific services
3. Add UI support in connection widgets
4. Test on target platforms

### Error Handling
- Use appropriate error types
- Provide user-friendly error messages
- Log errors for debugging
- Handle network timeouts gracefully

## Review Process

All contributions go through code review:

1. **Automated checks** run on pull requests
2. **Maintainer review** for code quality and architecture
3. **Platform testing** to ensure cross-platform compatibility
4. **Documentation review** for completeness

## Community Guidelines

- Be respectful and inclusive
- Help others learn and contribute
- Provide constructive feedback
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md)

## Getting Help

If you need help:

- Check existing issues and documentation
- Ask in the GitHub Discussions
- Reach out to maintainers
- Join our community chat (link in README)

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Annual contributor highlights

Thank you for contributing to the OBD-II Diagnostics Tool!