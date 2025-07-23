#!/bin/bash

# OBD-II Diagnostics Tool - Dependency Checker Script
# Validates and analyzes individual dependencies

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

# Check if Flutter is available
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
}

# Check specific dependency information
check_dependency() {
    local package_name=$1
    
    if [ -z "$package_name" ]; then
        log_error "Package name is required"
        exit 1
    fi
    
    log_info "Checking dependency: $package_name"
    
    # Check if package exists in pubspec.yaml
    if grep -q "^[[:space:]]*$package_name:" pubspec.yaml; then
        local current_version=$(grep "^[[:space:]]*$package_name:" pubspec.yaml | cut -d':' -f2 | tr -d ' ')
        log_info "Current constraint: $current_version"
    else
        log_warning "Package not found in pubspec.yaml"
    fi
    
    # Check in pubspec.lock if it exists
    if [ -f pubspec.lock ]; then
        if grep -q "^[[:space:]]*$package_name:" pubspec.lock; then
            local locked_version=$(grep -A1 "^[[:space:]]*$package_name:" pubspec.lock | grep "version:" | cut -d':' -f2 | tr -d ' "')
            log_info "Locked version: $locked_version"
        else
            log_warning "Package not found in pubspec.lock"
        fi
    else
        log_warning "pubspec.lock not found - run 'flutter pub get' first"
    fi
    
    # Show dependency tree for this package
    log_info "Dependency tree for $package_name:"
    flutter pub deps --style=compact | grep -E "(^$package_name|->.*$package_name)" || log_warning "No dependency information found"
}

# Validate pubspec.yaml format
validate_pubspec() {
    log_info "Validating pubspec.yaml format..."
    
    # Check for common issues
    local issues=0
    
    # Check for proper indentation
    if grep -q $'\t' pubspec.yaml; then
        log_warning "Found tabs in pubspec.yaml - should use spaces"
        ((issues++))
    fi
    
    # Check for version constraint format
    if grep -E "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]*[0-9]" pubspec.yaml | grep -v "\^" | grep -v ">=" | grep -v "<" > /dev/null; then
        log_warning "Found exact version constraints - consider using caret constraints (^)"
        ((issues++))
    fi
    
    # Check for missing SDK constraints
    if ! grep -q "sdk:" pubspec.yaml; then
        log_error "Missing SDK constraints in environment section"
        ((issues++))
    fi
    
    # Check for missing flutter constraint
    if ! grep -q "flutter:" pubspec.yaml; then
        log_error "Missing Flutter constraint in environment section"
        ((issues++))
    fi
    
    if [ $issues -eq 0 ]; then
        log_success "pubspec.yaml format looks good"
    else
        log_warning "Found $issues potential issues in pubspec.yaml"
    fi
    
    # Try to parse with pub
    log_info "Validating with Flutter pub..."
    flutter pub deps > /dev/null 2>&1 && log_success "pubspec.yaml is valid" || log_error "pubspec.yaml has errors"
}

# Check for unused dependencies
check_unused() {
    log_info "Checking for potentially unused dependencies..."
    
    # Get list of dependencies
    local deps=$(grep -E "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*:" pubspec.yaml | grep -v "flutter:" | grep -v "sdk:" | cut -d':' -f1 | tr -d ' ')
    
    local unused_count=0
    
    for dep in $deps; do
        # Skip known exceptions
        case $dep in
            "cupertino_icons"|"flutter_launcher_icons"|"flutter_lints")
                continue
                ;;
        esac
        
        # Check if dependency is imported in Dart files
        if ! find lib -name "*.dart" -exec grep -l "import.*$dep" {} \; > /dev/null 2>&1; then
            # Also check for usage without import (like platform plugins)
            if ! find lib -name "*.dart" -exec grep -l "$dep" {} \; > /dev/null 2>&1; then
                log_warning "Potentially unused dependency: $dep"
                ((unused_count++))
            fi
        fi
    done
    
    if [ $unused_count -eq 0 ]; then
        log_success "No obviously unused dependencies found"
    else
        log_info "Found $unused_count potentially unused dependencies"
        log_info "Note: Some dependencies may be used indirectly or by platform code"
    fi
}

# Check for security issues (basic check)
check_security() {
    log_info "Performing basic security checks..."
    
    # Check for known problematic packages or versions
    # This is a basic check - more comprehensive tools should be used for production
    
    local security_issues=0
    
    # Check for very old versions that might have security issues
    if grep -E "flutter_bluetooth_serial.*0\.[0-3]\." pubspec.yaml; then
        log_warning "flutter_bluetooth_serial version might have security issues - consider updating"
        ((security_issues++))
    fi
    
    # Check for development dependencies in production dependencies
    if grep -A100 "^dependencies:" pubspec.yaml | grep -B100 "^dev_dependencies:" | grep -E "(test|mock|debug)" | grep -v "^dev_dependencies:"; then
        log_warning "Development-related packages found in production dependencies"
        ((security_issues++))
    fi
    
    if [ $security_issues -eq 0 ]; then
        log_success "No obvious security issues found"
    else
        log_warning "Found $security_issues potential security concerns"
    fi
    
    log_info "For comprehensive security analysis, check:"
    log_info "- https://pub.dev/security-advisories"
    log_info "- GitHub security advisories for your dependencies"
}

# Generate dependency summary
generate_summary() {
    log_info "Generating dependency summary..."
    
    echo ""
    echo "=== DEPENDENCY SUMMARY ==="
    echo "Project: $(grep "^name:" pubspec.yaml | cut -d':' -f2 | tr -d ' ')"
    echo "Version: $(grep "^version:" pubspec.yaml | cut -d':' -f2 | tr -d ' ')"
    echo "Date: $(date)"
    echo ""
    
    echo "--- Runtime Dependencies ---"
    grep -A100 "^dependencies:" pubspec.yaml | grep -B100 "^dev_dependencies:" | grep -E "^[[:space:]]*[a-zA-Z]" | grep -v "^dependencies:" | wc -l | xargs echo "Count:"
    grep -A100 "^dependencies:" pubspec.yaml | grep -B100 "^dev_dependencies:" | grep -E "^[[:space:]]*[a-zA-Z]" | grep -v "^dependencies:"
    
    echo ""
    echo "--- Development Dependencies ---"
    grep -A100 "^dev_dependencies:" pubspec.yaml | grep -E "^[[:space:]]*[a-zA-Z]" | wc -l | xargs echo "Count:"
    grep -A100 "^dev_dependencies:" pubspec.yaml | grep -E "^[[:space:]]*[a-zA-Z]"
    
    echo ""
    echo "--- Platform Support ---"
    if [ -d "android" ]; then echo "✓ Android"; fi
    if [ -d "ios" ]; then echo "✓ iOS"; fi
    if [ -d "macos" ]; then echo "✓ macOS"; fi
    if [ -d "windows" ]; then echo "✓ Windows"; fi
    if [ -d "linux" ]; then echo "✓ Linux"; fi
    if [ -d "web" ]; then echo "✓ Web"; fi
    
    echo ""
    echo "=== END SUMMARY ==="
}

# Show usage
show_usage() {
    echo "OBD-II Diagnostics Tool - Dependency Checker"
    echo ""
    echo "Usage: $0 [command] [package_name]"
    echo ""
    echo "Commands:"
    echo "  check <package>    Check specific dependency information"
    echo "  validate          Validate pubspec.yaml format"
    echo "  unused            Check for potentially unused dependencies"
    echo "  security          Perform basic security checks"
    echo "  summary           Generate dependency summary"
    echo "  all               Run all checks"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check http                # Check http dependency"
    echo "  $0 validate                  # Validate pubspec.yaml"
    echo "  $0 all                       # Run all checks"
}

# Run all checks
run_all_checks() {
    log_info "Running comprehensive dependency analysis..."
    echo ""
    
    validate_pubspec
    echo ""
    
    check_unused
    echo ""
    
    check_security
    echo ""
    
    generate_summary
    
    log_success "Dependency analysis complete"
}

# Main function
main() {
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
    
    check_flutter
    
    case "${1:-help}" in
        "check")
            if [ -z "$2" ]; then
                log_error "Package name required for check command"
                show_usage
                exit 1
            fi
            check_dependency "$2"
            ;;
        "validate")
            validate_pubspec
            ;;
        "unused")
            check_unused
            ;;
        "security")
            check_security
            ;;
        "summary")
            generate_summary
            ;;
        "all")
            run_all_checks
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

main "$@"