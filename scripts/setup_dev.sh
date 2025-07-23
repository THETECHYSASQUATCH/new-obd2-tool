#!/bin/bash

# OBD-II Diagnostics Tool - Development Environment Setup Script
# This script helps new contributors set up their development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if we're in the right directory
check_project_directory() {
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Not in the project root directory (pubspec.yaml not found)"
        log_info "Please run this script from the project root directory"
        exit 1
    fi
    
    local project_name=$(grep "^name:" pubspec.yaml | cut -d':' -f2 | tr -d ' ')
    if [ "$project_name" = "obd2_diagnostics_tool" ]; then
        log_success "Found OBD-II Diagnostics Tool project"
    else
        log_warning "Project name doesn't match expected value"
    fi
}

# Check Flutter installation
check_flutter() {
    log_info "Checking Flutter installation..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        log_info "Please install Flutter from: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    local flutter_version=$(flutter --version | head -n 1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
    log_success "Flutter $flutter_version found"
    
    # Check version requirement
    if ! flutter --version | grep -E "(3\.[0-9]+\.[0-9]+|[4-9]\.[0-9]+\.[0-9]+)" > /dev/null; then
        log_warning "Flutter version 3.0.0 or higher is required"
        log_info "Current version: $flutter_version"
        log_info "Please update Flutter: flutter upgrade"
    fi
}

# Run Flutter doctor
run_flutter_doctor() {
    log_info "Running Flutter doctor to check setup..."
    flutter doctor
    
    # Check if there are any issues
    if flutter doctor | grep -q "✗\|!"; then
        log_warning "Flutter doctor found some issues"
        log_info "Please resolve the issues above before continuing"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "Flutter doctor passed all checks"
    fi
}

# Install project dependencies
install_dependencies() {
    log_info "Installing project dependencies..."
    
    # Clean any existing build artifacts
    if [ -d "build" ] || [ -d ".dart_tool" ]; then
        log_info "Cleaning existing build artifacts..."
        flutter clean
    fi
    
    # Install dependencies
    flutter pub get
    
    # Check if pubspec.lock was created
    if [ -f "pubspec.lock" ]; then
        log_success "Dependencies installed and pubspec.lock created"
    else
        log_error "pubspec.lock was not created - there may be dependency issues"
        exit 1
    fi
}

# Verify project setup
verify_setup() {
    log_info "Verifying project setup..."
    
    # Run analysis
    log_info "Running code analysis..."
    if flutter analyze > /dev/null 2>&1; then
        log_success "Code analysis passed"
    else
        log_warning "Code analysis found issues"
        flutter analyze
    fi
    
    # Run tests
    log_info "Running tests..."
    if flutter test > /dev/null 2>&1; then
        log_success "Tests passed"
    else
        log_warning "Some tests failed"
        log_info "Run 'flutter test' for details"
    fi
}

# Platform-specific setup instructions
show_platform_instructions() {
    log_info "Platform-specific setup instructions:"
    
    echo ""
    echo "=== Android Development ==="
    echo "- Install Android Studio with Android SDK (API level 21+)"
    echo "- Accept Android licenses: flutter doctor --android-licenses"
    echo "- Connect an Android device or start an emulator"
    echo "- Test: flutter run -d android"
    
    echo ""
    echo "=== iOS Development (macOS only) ==="
    echo "- Install Xcode 14+ from the Mac App Store"
    echo "- Install iOS Simulator or connect an iOS device"
    echo "- Run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo "- Test: flutter run -d ios"
    
    echo ""
    echo "=== Desktop Development ==="
    echo "- Windows: Install Visual Studio 2022 with C++ desktop development"
    echo "- macOS: Xcode command line tools (xcode-select --install)"
    echo "- Linux: Install required packages (see Flutter Linux setup docs)"
    echo "- Test: flutter run -d windows/macos/linux"
}

# Show next steps
show_next_steps() {
    echo ""
    echo "=== Next Steps ==="
    echo ""
    echo "1. Read the documentation:"
    echo "   - README.md - Project overview and usage"
    echo "   - CONTRIBUTING.md - Development guidelines"
    echo "   - DEPENDENCIES.md - Dependency management"
    echo ""
    echo "2. Try running the app:"
    echo "   flutter run"
    echo ""
    echo "3. Explore the codebase:"
    echo "   - lib/ - Main application code"
    echo "   - test/ - Unit and widget tests"
    echo "   - android/ios/ - Platform-specific code"
    echo ""
    echo "4. Make your first contribution:"
    echo "   - Look for 'good first issue' labels"
    echo "   - Follow the contribution workflow in CONTRIBUTING.md"
    echo ""
    echo "5. Useful development commands:"
    echo "   - flutter analyze - Code analysis"
    echo "   - flutter test - Run tests"
    echo "   - ./scripts/update_deps.sh check - Check dependencies"
    echo "   - ./scripts/check_dep.sh all - Comprehensive dependency analysis"
}

# Main setup function
main() {
    echo "🚗 OBD-II Diagnostics Tool - Development Setup"
    echo "=============================================="
    echo ""
    
    check_project_directory
    check_flutter
    run_flutter_doctor
    install_dependencies
    verify_setup
    show_platform_instructions
    show_next_steps
    
    echo ""
    log_success "Development environment setup complete!"
    log_info "Happy coding! 🎉"
}

# Show usage if help requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "OBD-II Diagnostics Tool - Development Setup Script"
    echo ""
    echo "This script sets up the development environment for new contributors."
    echo ""
    echo "Usage: $0"
    echo ""
    echo "The script will:"
    echo "- Check Flutter installation and version"
    echo "- Run Flutter doctor to verify setup"
    echo "- Install project dependencies"
    echo "- Verify the project setup with analysis and tests"
    echo "- Provide platform-specific setup instructions"
    echo ""
    exit 0
fi

# Run main setup
main