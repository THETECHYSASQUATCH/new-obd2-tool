#!/bin/bash
# Installation script for OBD-II Diagnostics Tool

set -e

echo "OBD-II Diagnostics and Programming Tool Setup"
echo "============================================="

# Check Python version
python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
required_version="3.7"

if ! python3 -c "import sys; exit(0 if sys.version_info >= (3,7) else 1)" 2>/dev/null; then
    echo "Error: Python 3.7 or higher is required"
    echo "Current version: $(python3 --version)"
    exit 1
fi

echo "✓ Python version check passed"

# Install pip if not available
if ! command -v pip3 &> /dev/null; then
    echo "Installing pip..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
fi

echo "✓ pip is available"

# Install system dependencies for tkinter (Linux)
if command -v apt-get &> /dev/null; then
    echo "Installing system dependencies..."
    sudo apt-get install -y python3-tk
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

echo "✓ Dependencies installed"

# Make scripts executable
chmod +x main.py
chmod +x demo.py

echo "✓ Scripts made executable"

# Run basic tests
echo "Running basic functionality tests..."
python3 tests/test_basic.py

echo ""
echo "Installation completed successfully!"
echo ""
echo "Usage:"
echo "  ./main.py --help          # Show help"
echo "  python3 demo.py           # Run demo"
echo "  ./main.py                 # Start GUI (requires display)"
echo "  ./main.py --port /dev/ttyUSB0  # Start with specific port"
echo ""
echo "For GUI usage, ensure you have a display available."
echo "For headless systems, GUI functionality will not be available."