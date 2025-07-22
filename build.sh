#!/bin/bash

# OBD-II Diagnostics Tool Build Script
# Supports building for all platforms with proper error handling and logging

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    local flutter_version=$(flutter --version | head -n 1)
    log_info "Using $flutter_version"
}

# Clean and get dependencies
setup_project() {
    log_info "Setting up project..."
    flutter clean
    flutter pub get
    log_success "Project setup complete"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    flutter test --coverage
    log_success "Tests completed"
}

# Run code analysis
run_analysis() {
    log_info "Running code analysis..."
    dart analyze
    log_success "Code analysis completed"
}

# Format code
format_code() {
    log_info "Formatting code..."
    dart format .
    log_success "Code formatting completed"
}

# Build for Android
build_android() {
    log_info "Building for Android..."
    
    # Build APK
    flutter build apk --release
    log_success "APK build completed"
    
    # Build App Bundle
    flutter build appbundle --release
    log_success "App Bundle build completed"
    
    log_info "Android builds located in:"
    echo "  - APK: build/app/outputs/flutter-apk/app-release.apk"
    echo "  - AAB: build/app/outputs/bundle/release/app-release.aab"
}

# Build for iOS
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "iOS builds are only supported on macOS"
        return 1
    fi
    
    log_info "Building for iOS..."
    flutter build ios --release --no-codesign
    log_success "iOS build completed"
    log_info "iOS build located in: build/ios/iphoneos/Runner.app"
}

# Build for macOS
build_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "macOS builds are only supported on macOS"
        return 1
    fi
    
    log_info "Building for macOS..."
    flutter build macos --release
    log_success "macOS build completed"
    log_info "macOS build located in: build/macos/Build/Products/Release/"
}

# Build for Windows
build_windows() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        log_info "Building for Windows..."
        flutter build windows --release
        log_success "Windows build completed"
        log_info "Windows build located in: build/windows/runner/Release/"
    else
        log_warning "Windows builds are typically done on Windows systems"
    fi
}

# Build for Linux
build_linux() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_info "Building for Linux..."
        flutter build linux --release
        log_success "Linux build completed"
        log_info "Linux build located in: build/linux/x64/release/bundle/"
    else
        log_warning "Linux builds are typically done on Linux systems"
    fi
}

# Build for all platforms
build_all() {
    log_info "Building for all supported platforms..."
    
    # Mobile platforms
    build_android
    build_ios
    
    # Desktop platforms
    build_macos
    build_windows
    build_linux
    
    log_success "All builds completed!"
}

# Generate icons (requires flutter_launcher_icons)
generate_icons() {
    log_info "Generating app icons..."
    if flutter pub deps | grep -q "flutter_launcher_icons"; then
        flutter pub run flutter_launcher_icons:main
        log_success "Icons generated"
    else
        log_warning "flutter_launcher_icons not found in dependencies"
    fi
}

# Create release package
package_release() {
    local version=$(grep "version:" pubspec.yaml | sed 's/version: //')
    local release_dir="release-$version"
    
    log_info "Packaging release $version..."
    
    mkdir -p "$release_dir"
    
    # Copy builds if they exist
    [[ -f "build/app/outputs/flutter-apk/app-release.apk" ]] && cp "build/app/outputs/flutter-apk/app-release.apk" "$release_dir/obd2-diagnostics-android.apk"
    [[ -f "build/app/outputs/bundle/release/app-release.aab" ]] && cp "build/app/outputs/bundle/release/app-release.aab" "$release_dir/obd2-diagnostics-android.aab"
    [[ -d "build/ios/iphoneos/Runner.app" ]] && cp -r "build/ios/iphoneos/Runner.app" "$release_dir/obd2-diagnostics-ios.app"
    [[ -d "build/macos/Build/Products/Release" ]] && cp -r "build/macos/Build/Products/Release"/* "$release_dir/"
    [[ -d "build/windows/runner/Release" ]] && cp -r "build/windows/runner/Release" "$release_dir/obd2-diagnostics-windows"
    [[ -d "build/linux/x64/release/bundle" ]] && cp -r "build/linux/x64/release/bundle" "$release_dir/obd2-diagnostics-linux"
    
    # Copy documentation
    cp README.md CHANGELOG.md LICENSE "$release_dir/"
    
    log_success "Release packaged in $release_dir/"
}

# Show usage information
show_usage() {
    echo "OBD-II Diagnostics Tool Build Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup          Clean and setup project dependencies"
    echo "  test           Run all tests with coverage"
    echo "  analyze        Run code analysis"
    echo "  format         Format code"
    echo "  android        Build for Android (APK and AAB)"
    echo "  ios            Build for iOS"
    echo "  macos          Build for macOS"
    echo "  windows        Build for Windows"
    echo "  linux          Build for Linux"
    echo "  all            Build for all platforms"
    echo "  icons          Generate app icons"
    echo "  package        Package release builds"
    echo "  full           Run complete build process (setup, test, analyze, build all)"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 android      # Build Android APK and AAB"
    echo "  $0 full         # Complete build process"
    echo "  $0 test         # Run tests only"
}

# Full build process
full_build() {
    log_info "Starting full build process..."
    setup_project
    format_code
    run_analysis
    run_tests
    build_all
    package_release
    log_success "Full build process completed!"
}

# Main script logic
main() {
    check_flutter
    
    case "${1:-help}" in
        "setup")
            setup_project
            ;;
        "test")
            run_tests
            ;;
        "analyze")
            run_analysis
            ;;
        "format")
            format_code
            ;;
        "android")
            build_android
            ;;
        "ios")
            build_ios
            ;;
        "macos")
            build_macos
            ;;
        "windows")
            build_windows
            ;;
        "linux")
            build_linux
            ;;
        "all")
            build_all
            ;;
        "icons")
            generate_icons
            ;;
        "package")
            package_release
            ;;
        "full")
            full_build
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function with all arguments
main "$@"