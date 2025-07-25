#!/bin/bash

# GNU Privacy Guard (GPG) Build Script for Linux
# Automates configuration, compilation, and installation of GPG using autotools

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_DIR="$(pwd)/build"
PREFIX="$BUILD_DIR/usr/local"
GPG_VERSION="2.4.3"
GPG_URL="https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${GPG_VERSION}.tar.bz2"
SOURCE_DIR="gnupg-${GPG_VERSION}"

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
    exit 1
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check build dependencies
check_dependencies() {
    log_info "Checking build dependencies..."
    
    local missing_deps=()
    
    # Essential build tools
    if ! command_exists gcc; then missing_deps+=("gcc"); fi
    if ! command_exists make; then missing_deps+=("make"); fi
    if ! command_exists autoconf; then missing_deps+=("autoconf"); fi
    if ! command_exists automake; then missing_deps+=("automake"); fi
    if ! command_exists libtool; then missing_deps+=("libtool"); fi
    if ! command_exists pkg-config; then missing_deps+=("pkg-config"); fi
    if ! command_exists wget || ! command_exists curl; then missing_deps+=("wget or curl"); fi
    if ! command_exists tar; then missing_deps+=("tar"); fi
    if ! command_exists bzip2; then missing_deps+=("bzip2"); fi
    
    # Check for development headers (approximation)
    if ! ldconfig -p | grep -q libgpg-error; then missing_deps+=("libgpg-error-dev"); fi
    if ! ldconfig -p | grep -q libgcrypt; then missing_deps+=("libgcrypt-dev"); fi
    if ! ldconfig -p | grep -q libassuan; then missing_deps+=("libassuan-dev"); fi
    if ! ldconfig -p | grep -q libksba; then missing_deps+=("libksba-dev"); fi
    if ! ldconfig -p | grep -q libnpth; then missing_deps+=("libnpth-dev"); fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install them using:"
        log_info "sudo apt-get install build-essential autoconf automake libtool pkg-config libgpg-error-dev libgcrypt-dev libassuan-dev libksba-dev libnpth-dev wget bzip2"
        return 1
    fi
    
    log_success "All dependencies are satisfied"
    return 0
}

# Function to download GPG source
download_source() {
    log_info "Downloading GPG source code..."
    
    if [ -d "$SOURCE_DIR" ]; then
        log_warning "Source directory $SOURCE_DIR already exists, skipping download"
        return 0
    fi
    
    if command_exists wget; then
        wget "$GPG_URL" -O "gnupg-${GPG_VERSION}.tar.bz2"
    elif command_exists curl; then
        curl -L "$GPG_URL" -o "gnupg-${GPG_VERSION}.tar.bz2"
    else
        log_error "Neither wget nor curl found. Cannot download source."
        return 1
    fi
    
    log_info "Extracting source code..."
    tar -xjf "gnupg-${GPG_VERSION}.tar.bz2"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "Failed to extract source code"
        return 1
    fi
    
    log_success "Source code downloaded and extracted"
}

# Function to configure GPG
configure_gpg() {
    log_info "Configuring GPG build..."
    
    cd "$SOURCE_DIR"
    
    # Run autogen.sh if it exists
    if [ -f "autogen.sh" ]; then
        log_info "Running autogen.sh..."
        ./autogen.sh
    fi
    
    # Configure with local prefix
    log_info "Running configure with prefix: $PREFIX"
    ./configure \
        --prefix="$PREFIX" \
        --enable-maintainer-mode \
        --disable-doc \
        --disable-gpg-is-gpg2 \
        --enable-gpg2-is-gpg \
        --enable-gpgtar \
        --enable-wks-tools
    
    log_success "Configuration completed"
}

# Function to build GPG
build_gpg() {
    log_info "Building GPG..."
    
    # Determine number of CPU cores for parallel build
    local cores=$(nproc 2>/dev/null || echo "4")
    log_info "Building with $cores parallel jobs..."
    
    make -j"$cores"
    
    log_success "Build completed"
}

# Function to install GPG
install_gpg() {
    log_info "Installing GPG to $PREFIX..."
    
    # Create build directory structure
    mkdir -p "$BUILD_DIR"
    
    # Install to our local prefix
    make install DESTDIR=""
    
    log_success "Installation completed"
    
    # Create convenience symlinks in build directory
    log_info "Creating convenience scripts..."
    
    cat > "$BUILD_DIR/gpg-env.sh" << EOF
#!/bin/bash
# Environment setup for locally built GPG
export PATH="$PREFIX/bin:\$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:\$LD_LIBRARY_PATH"
export MANPATH="$PREFIX/share/man:\$MANPATH"

echo "GPG environment configured. GPG binary location: $PREFIX/bin/gpg"
echo "Run 'gpg --version' to verify installation"
EOF
    
    chmod +x "$BUILD_DIR/gpg-env.sh"
    
    log_info "Created environment setup script: $BUILD_DIR/gpg-env.sh"
    log_info "Source this script to use the locally built GPG:"
    log_info "source $BUILD_DIR/gpg-env.sh"
}

# Function to run tests
run_tests() {
    log_info "Running GPG tests..."
    
    if make check; then
        log_success "All tests passed"
    else
        log_warning "Some tests failed, but GPG should still be usable"
    fi
}

# Function to display build summary
show_summary() {
    log_success "GPG build completed successfully!"
    echo
    log_info "Build Summary:"
    log_info "  Source: $SOURCE_DIR"
    log_info "  Install prefix: $PREFIX"
    log_info "  Build directory: $BUILD_DIR"
    echo
    log_info "To use the built GPG:"
    log_info "  1. Source the environment: source $BUILD_DIR/gpg-env.sh"
    log_info "  2. Run GPG: gpg --version"
    echo
    log_info "GPG binaries installed in: $PREFIX/bin/"
    if [ -f "$PREFIX/bin/gpg" ]; then
        log_info "GPG version: $($PREFIX/bin/gpg --version | head -n1)"
    fi
}

# Function to clean build artifacts
clean() {
    log_info "Cleaning build artifacts..."
    
    if [ -d "$SOURCE_DIR" ]; then
        rm -rf "$SOURCE_DIR"
    fi
    
    if [ -f "gnupg-${GPG_VERSION}.tar.bz2" ]; then
        rm -f "gnupg-${GPG_VERSION}.tar.bz2"
    fi
    
    log_success "Cleanup completed"
}

# Main function
main() {
    local action="${1:-build}"
    
    case "$action" in
        "build")
            log_info "Starting GPG build process..."
            check_dependencies
            download_source
            configure_gpg
            build_gpg
            install_gpg
            run_tests
            show_summary
            ;;
        "clean")
            clean
            ;;
        "check-deps")
            check_dependencies
            ;;
        *)
            echo "Usage: $0 [build|clean|check-deps]"
            echo "  build      - Full build process (default)"
            echo "  clean      - Clean build artifacts"
            echo "  check-deps - Check build dependencies"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"