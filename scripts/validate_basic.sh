#!/bin/bash

# OBD-II Diagnostics Tool - Dependency Validation (No Flutter Required)
# Basic validation of pubspec.yaml and dependency files

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

# Validate pubspec.yaml exists and basic structure
validate_pubspec_basic() {
    log_info "Validating pubspec.yaml structure..."
    
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml not found"
        return 1
    fi
    
    local issues=0
    
    # Check for required fields
    if ! grep -q "^name:" pubspec.yaml; then
        log_error "Missing 'name' field in pubspec.yaml"
        ((issues++))
    fi
    
    if ! grep -q "^version:" pubspec.yaml; then
        log_error "Missing 'version' field in pubspec.yaml"
        ((issues++))
    fi
    
    if ! grep -q "^dependencies:" pubspec.yaml; then
        log_error "Missing 'dependencies' section in pubspec.yaml"
        ((issues++))
    fi
    
    if ! grep -q "^environment:" pubspec.yaml; then
        log_error "Missing 'environment' section in pubspec.yaml"
        ((issues++))
    fi
    
    # Check for tabs (should use spaces)
    if grep -q $'\t' pubspec.yaml; then
        log_warning "Found tabs in pubspec.yaml - should use spaces for indentation"
        ((issues++))
    fi
    
    # Check for proper YAML format
    if ! python3 -c "import yaml; yaml.safe_load(open('pubspec.yaml'))" 2>/dev/null; then
        log_error "pubspec.yaml is not valid YAML format"
        ((issues++))
    fi
    
    if [ $issues -eq 0 ]; then
        log_success "pubspec.yaml structure is valid"
    else
        log_warning "Found $issues issues in pubspec.yaml"
    fi
    
    return $issues
}

# Check dependency management files
check_dependency_files() {
    log_info "Checking dependency management files..."
    
    local files_missing=0
    
    # Essential files
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml missing"
        ((files_missing++))
    else
        log_success "pubspec.yaml found"
    fi
    
    # Check if pubspec.lock should exist
    if [ ! -f "pubspec.lock" ]; then
        log_warning "pubspec.lock missing - run 'flutter pub get' to generate"
        log_info "This file should be committed for reproducible builds"
    else
        log_success "pubspec.lock found"
    fi
    
    # Documentation files
    if [ ! -f "DEPENDENCIES.md" ]; then
        log_warning "DEPENDENCIES.md missing - dependency documentation not found"
    else
        log_success "DEPENDENCIES.md found"
    fi
    
    # Script files
    if [ ! -f "scripts/update_deps.sh" ]; then
        log_warning "Dependency update script missing"
    else
        log_success "Dependency management scripts found"
    fi
    
    return $files_missing
}

# Basic dependency analysis (without Flutter)
analyze_dependencies() {
    log_info "Analyzing dependencies in pubspec.yaml..."
    
    # Count dependencies
    local dep_count=$(grep -A100 "^dependencies:" pubspec.yaml | grep -B100 "^dev_dependencies:" | grep -E "^[[:space:]]*[a-zA-Z]" | grep -v "^dependencies:" | wc -l | tr -d ' ')
    local dev_dep_count=$(grep -A100 "^dev_dependencies:" pubspec.yaml | grep -E "^[[:space:]]*[a-zA-Z]" | wc -l | tr -d ' ')
    
    log_info "Runtime dependencies: $dep_count"
    log_info "Development dependencies: $dev_dep_count"
    
    # Check for common issues
    local warnings=0
    
    # Check for exact version pinning (might be too restrictive)
    if grep -E "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+$" pubspec.yaml > /dev/null; then
        log_warning "Found exact version constraints - consider using caret (^) constraints"
        ((warnings++))
    fi
    
    # Check for git dependencies (might be unstable)
    if grep -A1 "git:" pubspec.yaml > /dev/null; then
        log_warning "Found git dependencies - ensure they are stable"
        ((warnings++))
    fi
    
    # Check for path dependencies (for local development)
    if grep -A1 "path:" pubspec.yaml > /dev/null; then
        log_info "Found path dependencies - ensure these are for development only"
    fi
    
    if [ $warnings -eq 0 ]; then
        log_success "Dependency configuration looks good"
    else
        log_warning "Found $warnings potential dependency issues"
    fi
}

# Check project structure for dependency-related files
check_project_structure() {
    log_info "Checking project structure..."
    
    # Essential directories
    local missing_dirs=0
    
    if [ ! -d "lib" ]; then
        log_error "lib/ directory missing"
        ((missing_dirs++))
    else
        log_success "lib/ directory found"
    fi
    
    if [ ! -d "test" ]; then
        log_warning "test/ directory missing - testing setup recommended"
    else
        log_success "test/ directory found"
    fi
    
    # Platform directories (optional but expected for multi-platform app)
    local platform_count=0
    for platform in android ios windows macos linux web; do
        if [ -d "$platform" ]; then
            ((platform_count++))
        fi
    done
    
    log_info "Platform support detected: $platform_count platforms"
    
    # Check for build artifacts that should be ignored
    if [ -d "build" ]; then
        log_warning "build/ directory present - should be in .gitignore"
    fi
    
    if [ -d ".dart_tool" ]; then
        log_warning ".dart_tool/ directory present - should be in .gitignore"
    fi
    
    return $missing_dirs
}

# Generate validation report
generate_validation_report() {
    local report_file="dependency_validation_$(date +%Y%m%d_%H%M%S).txt"
    
    log_info "Generating validation report: $report_file"
    
    {
        echo "# Dependency Validation Report"
        echo "Generated: $(date)"
        echo ""
        echo "## Project Information"
        if [ -f "pubspec.yaml" ]; then
            echo "Name: $(grep "^name:" pubspec.yaml | cut -d':' -f2 | tr -d ' ')"
            echo "Version: $(grep "^version:" pubspec.yaml | cut -d':' -f2 | tr -d ' ')"
        fi
        echo ""
        echo "## File Status"
        echo "- pubspec.yaml: $([ -f pubspec.yaml ] && echo "✓ Present" || echo "✗ Missing")"
        echo "- pubspec.lock: $([ -f pubspec.lock ] && echo "✓ Present" || echo "⚠ Missing")"
        echo "- DEPENDENCIES.md: $([ -f DEPENDENCIES.md ] && echo "✓ Present" || echo "⚠ Missing")"
        echo "- Scripts: $([ -f scripts/update_deps.sh ] && echo "✓ Present" || echo "⚠ Missing")"
        echo ""
        echo "## Dependency Count"
        if [ -f "pubspec.yaml" ]; then
            local deps=$(grep -A100 "^dependencies:" pubspec.yaml | grep -B100 "^dev_dependencies:" | grep -E "^[[:space:]]*[a-zA-Z]" | grep -v "^dependencies:" | wc -l | tr -d ' ')
            local dev_deps=$(grep -A100 "^dev_dependencies:" pubspec.yaml | grep -E "^[[:space:]]*[a-zA-Z]" | wc -l | tr -d ' ')
            echo "Runtime: $deps"
            echo "Development: $dev_deps"
        fi
        echo ""
        echo "## Validation Summary"
        echo "Run './scripts/validate_basic.sh' for detailed validation"
    } > "$report_file"
    
    log_success "Report saved: $report_file"
}

# Show usage
show_usage() {
    echo "OBD-II Diagnostics Tool - Basic Dependency Validation"
    echo "Validates dependency files without requiring Flutter installation"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  validate      Validate pubspec.yaml structure"
    echo "  files         Check dependency management files"
    echo "  analyze       Analyze dependencies (basic)"
    echo "  structure     Check project structure"
    echo "  report        Generate validation report"
    echo "  all           Run all validations"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 all        # Run complete validation"
    echo "  $0 validate   # Just validate pubspec.yaml"
    echo "  $0 files      # Check for required files"
}

# Run all validations
run_all_validations() {
    log_info "Running complete dependency validation..."
    echo ""
    
    local total_issues=0
    
    validate_pubspec_basic
    total_issues=$((total_issues + $?))
    echo ""
    
    check_dependency_files
    total_issues=$((total_issues + $?))
    echo ""
    
    analyze_dependencies
    echo ""
    
    check_project_structure
    total_issues=$((total_issues + $?))
    echo ""
    
    if [ $total_issues -eq 0 ]; then
        log_success "All validations passed!"
    else
        log_warning "Found $total_issues issues that need attention"
    fi
    
    log_info "For comprehensive dependency management, install Flutter and use:"
    log_info "  ./scripts/update_deps.sh"
    log_info "  ./scripts/check_dep.sh"
}

# Main function
main() {
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
    
    case "${1:-all}" in
        "validate")
            validate_pubspec_basic
            ;;
        "files")
            check_dependency_files
            ;;
        "analyze")
            analyze_dependencies
            ;;
        "structure")
            check_project_structure
            ;;
        "report")
            generate_validation_report
            ;;
        "all")
            run_all_validations
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

main "$@"