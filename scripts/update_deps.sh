#!/bin/bash

# OBD-II Diagnostics Tool - Dependency Update Script
# This script helps maintain and update project dependencies safely

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

# Check if Flutter is available
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        log_info "Please install Flutter: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    local flutter_version=$(flutter --version | head -n 1)
    log_info "Using $flutter_version"
}

# Backup current state
backup_current_state() {
    log_info "Creating backup of current dependency state..."
    cp pubspec.yaml pubspec.yaml.backup
    if [ -f pubspec.lock ]; then
        cp pubspec.lock pubspec.lock.backup
        log_success "Backed up pubspec.yaml and pubspec.lock"
    else
        log_warning "pubspec.lock not found - will be created during update"
        log_success "Backed up pubspec.yaml"
    fi
}

# Restore from backup
restore_backup() {
    log_warning "Restoring from backup..."
    mv pubspec.yaml.backup pubspec.yaml
    if [ -f pubspec.lock.backup ]; then
        mv pubspec.lock.backup pubspec.lock
    fi
    flutter pub get
    log_success "Restored from backup"
}

# Clean up backup files
cleanup_backup() {
    rm -f pubspec.yaml.backup pubspec.lock.backup
    log_info "Cleaned up backup files"
}

# Check for outdated dependencies
check_outdated() {
    log_info "Checking for outdated dependencies..."
    flutter pub outdated
}

# Update dependencies with safety checks
update_dependencies() {
    local update_type=${1:-"minor"}
    
    log_info "Updating dependencies (type: $update_type)..."
    
    case $update_type in
        "patch")
            # Only patch updates
            flutter pub upgrade --no-major-versions --no-minor-versions
            ;;
        "minor")
            # Minor and patch updates (default)
            flutter pub upgrade --no-major-versions
            ;;
        "major")
            # All updates including major versions
            log_warning "Performing major version updates - this may introduce breaking changes"
            flutter pub upgrade --major-versions
            ;;
        *)
            log_error "Invalid update type: $update_type"
            log_info "Valid types: patch, minor, major"
            exit 1
            ;;
    esac
    
    log_success "Dependencies updated"
}

# Add a new dependency
add_dependency() {
    local package_name=$1
    local is_dev_dep=${2:-false}
    
    if [ -z "$package_name" ]; then
        log_error "Package name is required"
        exit 1
    fi
    
    log_info "Adding dependency: $package_name"
    
    if [ "$is_dev_dep" = true ]; then
        flutter pub add --dev "$package_name"
        log_success "Added development dependency: $package_name"
    else
        flutter pub add "$package_name"
        log_success "Added dependency: $package_name"
    fi
}

# Remove a dependency
remove_dependency() {
    local package_name=$1
    
    if [ -z "$package_name" ]; then
        log_error "Package name is required"
        exit 1
    fi
    
    log_info "Removing dependency: $package_name"
    flutter pub remove "$package_name"
    log_success "Removed dependency: $package_name"
}

# Run tests after dependency changes
run_tests() {
    log_info "Running tests to verify dependency changes..."
    
    # Run analysis
    log_info "Running dart analyze..."
    dart analyze
    
    # Run tests
    log_info "Running flutter test..."
    flutter test
    
    log_success "All tests passed"
}

# Check for security vulnerabilities
security_audit() {
    log_info "Checking for security vulnerabilities..."
    
    # Note: flutter pub audit is not available yet, but this is a placeholder
    # for when it becomes available or for alternative tools
    
    log_info "Manual security check required:"
    log_info "1. Check https://pub.dev/security-advisories"
    log_info "2. Review dependency changelogs"
    log_info "3. Check GitHub security advisories"
    
    # For now, check outdated packages which might have security fixes
    flutter pub outdated
}

# Generate dependency report
generate_report() {
    local report_file="dependency_report_$(date +%Y%m%d_%H%M%S).txt"
    
    log_info "Generating dependency report: $report_file"
    
    {
        echo "# Dependency Report - $(date)"
        echo "## Flutter Version"
        flutter --version
        echo ""
        echo "## Project Dependencies"
        flutter pub deps --style=compact
        echo ""
        echo "## Outdated Dependencies"
        flutter pub outdated
        echo ""
        echo "## pubspec.yaml"
        cat pubspec.yaml
    } > "$report_file"
    
    log_success "Report generated: $report_file"
}

# Interactive update workflow
interactive_update() {
    log_info "Starting interactive dependency update workflow..."
    
    # Show current state
    log_info "Current dependency status:"
    flutter pub outdated
    
    echo ""
    read -p "Continue with dependency updates? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Update cancelled"
        exit 0
    fi
    
    # Backup current state
    backup_current_state
    
    # Choose update type
    echo ""
    echo "Select update type:"
    echo "1) Patch updates only (safest)"
    echo "2) Minor and patch updates (recommended)"
    echo "3) Major version updates (review breaking changes)"
    read -p "Choice (1-3): " -n 1 -r
    echo
    
    case $REPLY in
        1) update_type="patch" ;;
        2) update_type="minor" ;;
        3) update_type="major" ;;
        *) 
            log_error "Invalid choice"
            restore_backup
            exit 1
            ;;
    esac
    
    # Perform update
    if update_dependencies "$update_type"; then
        log_success "Dependencies updated successfully"
        
        # Run tests
        if run_tests; then
            log_success "All tests passed - update completed successfully"
            cleanup_backup
        else
            log_error "Tests failed - restoring backup"
            restore_backup
            exit 1
        fi
    else
        log_error "Dependency update failed - restoring backup"
        restore_backup
        exit 1
    fi
}

# Show usage information
show_usage() {
    echo "OBD-II Diagnostics Tool - Dependency Management Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  check              Check for outdated dependencies"
    echo "  update [type]      Update dependencies (patch|minor|major)"
    echo "  add <package>      Add a new dependency"
    echo "  add-dev <package>  Add a new development dependency"
    echo "  remove <package>   Remove a dependency"
    echo "  test               Run tests after dependency changes"
    echo "  audit              Check for security vulnerabilities"
    echo "  report             Generate dependency report"
    echo "  interactive        Run interactive update workflow"
    echo "  restore            Restore from backup (if available)"
    echo "  clean              Clean and reinstall dependencies"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check                    # Check outdated dependencies"
    echo "  $0 update minor            # Update minor versions only"
    echo "  $0 add http                # Add http dependency"
    echo "  $0 add-dev mockito         # Add mockito as dev dependency"
    echo "  $0 interactive             # Interactive update workflow"
}

# Clean and reinstall dependencies
clean_deps() {
    log_info "Cleaning and reinstalling dependencies..."
    flutter clean
    flutter pub get
    log_success "Dependencies cleaned and reinstalled"
}

# Main script logic
main() {
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
    
    check_flutter
    
    case "${1:-help}" in
        "check")
            check_outdated
            ;;
        "update")
            backup_current_state
            if update_dependencies "${2:-minor}" && run_tests; then
                cleanup_backup
            else
                restore_backup
                exit 1
            fi
            ;;
        "add")
            if [ -z "$2" ]; then
                log_error "Package name required"
                show_usage
                exit 1
            fi
            add_dependency "$2" false
            ;;
        "add-dev")
            if [ -z "$2" ]; then
                log_error "Package name required"
                show_usage
                exit 1
            fi
            add_dependency "$2" true
            ;;
        "remove")
            if [ -z "$2" ]; then
                log_error "Package name required"
                show_usage
                exit 1
            fi
            remove_dependency "$2"
            ;;
        "test")
            run_tests
            ;;
        "audit")
            security_audit
            ;;
        "report")
            generate_report
            ;;
        "interactive")
            interactive_update
            ;;
        "restore")
            if [ -f "pubspec.yaml.backup" ]; then
                restore_backup
            else
                log_error "No backup files found"
                exit 1
            fi
            ;;
        "clean")
            clean_deps
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function with all arguments
main "$@"