#!/bin/bash
# Linux Setup Script for OBD-II Diagnostics Tool
# TODO: Add more distribution support and package manager detection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚗 OBD-II Diagnostics Tool - Linux Setup${NC}"
echo "==========================================="
echo ""

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    DISTRO_VERSION=$VERSION_ID
    echo -e "${BLUE}Detected: $PRETTY_NAME${NC}"
else
    echo -e "${RED}❌ Cannot detect Linux distribution${NC}"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
echo -e "${BLUE}Architecture: $ARCH${NC}"

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    UPDATE_CMD="sudo apt-get update"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="sudo dnf makecache"
    INSTALL_CMD="sudo dnf install -y"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    UPDATE_CMD="sudo yum makecache"
    INSTALL_CMD="sudo yum install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    UPDATE_CMD="sudo pacman -Sy"
    INSTALL_CMD="sudo pacman -S --noconfirm"
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
    UPDATE_CMD="sudo zypper refresh"
    INSTALL_CMD="sudo zypper install -y"
else
    echo -e "${RED}❌ Unsupported package manager${NC}"
    echo "Please install dependencies manually or use a supported distribution"
    exit 1
fi

echo -e "${BLUE}Package manager: $PKG_MANAGER${NC}"

# Update package database
echo -e "${BLUE}Updating package database...${NC}"
eval $UPDATE_CMD

# Install base dependencies based on distribution
echo -e "${BLUE}Installing base dependencies...${NC}"

case $PKG_MANAGER in
    apt)
        $INSTALL_CMD \
            curl \
            git \
            unzip \
            xz-utils \
            zip \
            libglu1-mesa \
            build-essential \
            libgtk-3-dev \
            libblkid-dev \
            liblzma-dev \
            libjsoncpp-dev \
            cmake \
            ninja-build \
            pkg-config \
            udev \
            bluetooth \
            bluez \
            bluez-tools \
            rfkill
        ;;
    dnf|yum)
        $INSTALL_CMD \
            curl \
            git \
            unzip \
            xz \
            zip \
            mesa-libGLU-devel \
            gcc-c++ \
            make \
            gtk3-devel \
            libblkid-devel \
            xz-devel \
            jsoncpp-devel \
            cmake \
            ninja-build \
            pkgconfig \
            systemd-udev \
            bluez \
            bluez-tools \
            rfkill
        ;;
    pacman)
        $INSTALL_CMD \
            curl \
            git \
            unzip \
            xz \
            zip \
            glu \
            base-devel \
            gtk3 \
            util-linux \
            xz \
            jsoncpp \
            cmake \
            ninja \
            pkgconf \
            systemd \
            bluez \
            bluez-utils \
            rfkill
        ;;
    zypper)
        $INSTALL_CMD \
            curl \
            git \
            unzip \
            xz \
            zip \
            glu-devel \
            gcc-c++ \
            make \
            gtk3-devel \
            libblkid-devel \
            xz-devel \
            libjsoncpp-devel \
            cmake \
            ninja \
            pkg-config \
            systemd-udev \
            bluez \
            bluez-tools \
            rfkill
        ;;
esac

# Add user to dialout group for serial port access
echo -e "${BLUE}Setting up USB-Serial permissions...${NC}"
if groups $USER | grep -q dialout; then
    echo -e "${GREEN}✅ User already in dialout group${NC}"
else
    echo "Adding user to dialout group..."
    sudo usermod -a -G dialout $USER
    echo -e "${YELLOW}⚠️  Please log out and back in for group changes to take effect${NC}"
fi

# Create udev rules for OBD-II adapters
echo -e "${BLUE}Setting up udev rules for OBD-II adapters...${NC}"
sudo tee /etc/udev/rules.d/99-obd2-adapters.rules > /dev/null << 'EOF'
# FTDI-based adapters (FT232, FT2232, etc.)
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="dialout"

# Prolific PL2303-based adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", MODE="0666", GROUP="dialout"

# Silicon Labs CP210x-based adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea70", MODE="0666", GROUP="dialout"

# CH340/CH341-based adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5523", MODE="0666", GROUP="dialout"

# Generic USB-Serial converters
SUBSYSTEM=="tty", ATTRS{interface}=="*USB*Serial*", MODE="0666", GROUP="dialout"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Enable and start Bluetooth service
echo -e "${BLUE}Setting up Bluetooth...${NC}"
if systemctl is-active --quiet bluetooth; then
    echo -e "${GREEN}✅ Bluetooth service is running${NC}"
else
    echo "Starting Bluetooth service..."
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
fi

# Check Flutter installation
echo -e "${BLUE}Checking Flutter installation...${NC}"
if command -v flutter &> /dev/null; then
    flutter_version=$(flutter --version | head -n 1)
    echo -e "${GREEN}✅ $flutter_version${NC}"
    
    # Run Flutter doctor
    echo -e "${BLUE}Running Flutter doctor...${NC}"
    flutter doctor
else
    echo -e "${YELLOW}⚠️  Flutter not found${NC}"
    echo ""
    echo "To install Flutter:"
    echo "1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/linux"
    echo "2. Extract to /opt/flutter or ~/flutter"
    echo "3. Add to PATH in ~/.bashrc or ~/.zshrc:"
    echo "   export PATH=\"\$PATH:/opt/flutter/bin\""
    echo ""
    echo "Or use snap (Ubuntu):"
    echo "   sudo snap install flutter --classic"
fi

# Check for additional platform-specific setup
case $ARCH in
    aarch64|arm64)
        echo -e "${BLUE}ARM64 detected - checking additional requirements...${NC}"
        # TODO: Add ARM64-specific setup if needed
        ;;
    armv7l|armhf)
        echo -e "${BLUE}ARM32 detected - Raspberry Pi setup...${NC}"
        # Enable GPU memory split for better performance
        if [ -f /boot/config.txt ]; then
            if ! grep -q "gpu_mem=64" /boot/config.txt; then
                echo "gpu_mem=64" | sudo tee -a /boot/config.txt
                echo -e "${YELLOW}⚠️  GPU memory split updated. Reboot required.${NC}"
            fi
        fi
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Linux setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Log out and back in (or restart) for group changes to take effect"
echo "2. Connect your OBD-II adapter and check 'lsusb' or 'dmesg | tail'"
echo "3. Verify USB-Serial device appears as /dev/ttyUSB* or /dev/ttyACM*"
echo "4. Run the OBD-II Diagnostics Tool"
echo ""
echo "Troubleshooting:"
echo "- Check connected devices: lsusb"
echo "- Check serial devices: ls -la /dev/tty*"
echo "- Check kernel messages: dmesg | grep tty"
echo "- Test Bluetooth: bluetoothctl scan on"
echo ""
echo -e "${BLUE}Happy diagnosing! 🔧${NC}"