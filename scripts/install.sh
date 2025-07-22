#!/bin/bash

# Installation script for OBD-II Diagnostics and Programming Tool
# This script sets up the environment and installs dependencies

set -e  # Exit on any error

echo "OBD-II Diagnostics and Programming Tool - Installation Script"
echo "============================================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Python version
echo "Checking Python installation..."
if ! command_exists python3; then
    echo "Error: Python 3 is not installed"
    echo "Please install Python 3.8 or higher and try again"
    exit 1
fi

PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Found Python $PYTHON_VERSION"

# Check if Python version is sufficient
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 8 ]); then
    echo "Error: Python 3.8 or higher is required"
    echo "Current version: $PYTHON_VERSION"
    exit 1
fi

# Check if pip is installed
echo "Checking pip installation..."
if ! command_exists pip3; then
    echo "Error: pip3 is not installed"
    echo "Please install pip3 and try again"
    exit 1
fi

# Create virtual environment (optional but recommended)
echo "Setting up virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Virtual environment created"
else
    echo "Virtual environment already exists"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Install the package in development mode
echo "Installing OBD-II Tool in development mode..."
pip install -e .

# Install optional dependencies for development
echo "Installing development dependencies..."
pip install pytest pytest-cov flake8 || echo "Warning: Could not install all development dependencies"

# Check if pyserial is properly installed
echo "Checking serial communication support..."
python3 -c "import serial; print('pyserial installed successfully')" || {
    echo "Error: pyserial not properly installed"
    echo "Trying to install with system package manager..."
    
    # Try different package managers
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y python3-serial
    elif command_exists yum; then
        sudo yum install -y pyserial
    elif command_exists dnf; then
        sudo dnf install -y python3-pyserial
    elif command_exists pacman; then
        sudo pacman -S python-pyserial
    else
        echo "Could not install pyserial automatically"
        echo "Please install pyserial manually for your system"
    fi
}

# Check for optional Bluetooth support
echo "Checking Bluetooth support..."
python3 -c "import bluetooth; print('Bluetooth support available')" 2>/dev/null || {
    echo "Warning: Bluetooth support not available"
    echo "To enable Bluetooth support, install pybluez:"
    echo "  For Ubuntu/Debian: sudo apt-get install python3-bluez"
    echo "  For other systems: pip install pybluez"
}

# Set up udev rules for USB access (Linux only)
if [ "$(uname)" = "Linux" ]; then
    echo "Setting up USB device permissions (Linux)..."
    
    # Check if user is in dialout group
    if ! groups $USER | grep -q dialout; then
        echo "Adding user to dialout group for USB device access..."
        sudo usermod -a -G dialout $USER
        echo "Please log out and log back in for group changes to take effect"
    fi
    
    # Create udev rules for common OBD-II adapters
    UDEV_RULES="/etc/udev/rules.d/99-obd2-adapters.rules"
    if [ ! -f "$UDEV_RULES" ]; then
        echo "Creating udev rules for OBD-II adapters..."
        sudo tee "$UDEV_RULES" > /dev/null << 'EOF'
# OBD-II adapter udev rules
# ELM327 USB adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"

# Generic USB-to-serial adapters commonly used with ELM327
SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0557", ATTRS{idProduct}=="2008", MODE="0666", GROUP="dialout"
EOF
        sudo udevadm control --reload-rules
        echo "udev rules created"
    fi
fi

# Run tests to verify installation
echo "Running installation tests..."
python3 -m pytest tests/ -v || {
    echo "Warning: Some tests failed"
    echo "The installation may still be functional"
}

# Create desktop shortcut (optional)
create_desktop_shortcut() {
    if [ "$(uname)" = "Linux" ] && command_exists desktop-file-install; then
        DESKTOP_FILE="$HOME/.local/share/applications/obd2-tool.desktop"
        INSTALL_DIR=$(pwd)
        
        cat > "/tmp/obd2-tool.desktop" << EOF
[Desktop Entry]
Name=OBD-II Diagnostics Tool
Comment=OBD-II vehicle diagnostics and programming tool
Exec=$INSTALL_DIR/venv/bin/python $INSTALL_DIR/main.py
Icon=$INSTALL_DIR/icon.png
Terminal=false
Type=Application
Categories=Utility;Development;
StartupNotify=true
EOF
        
        mkdir -p "$HOME/.local/share/applications"
        cp "/tmp/obd2-tool.desktop" "$DESKTOP_FILE"
        chmod +x "$DESKTOP_FILE"
        echo "Desktop shortcut created at $DESKTOP_FILE"
    fi
}

# Ask user if they want to create desktop shortcut
if [ "$(uname)" = "Linux" ]; then
    read -p "Create desktop shortcut? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_desktop_shortcut
    fi
fi

echo ""
echo "Installation completed successfully!"
echo ""
echo "To run the OBD-II Tool:"
echo "  1. Activate virtual environment: source venv/bin/activate"
echo "  2. Run the application: python main.py"
echo ""
echo "Or use the build script:"
echo "  python scripts/build.py --test    # Run tests"
echo "  python scripts/build.py --build   # Build executable"
echo ""
echo "For troubleshooting, check the documentation in the README.md file"