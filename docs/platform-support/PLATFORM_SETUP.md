# Platform-Specific Setup and Driver Installation Guide

This document provides comprehensive installation instructions and driver requirements for running the OBD-II Diagnostics Tool on all supported platforms.

## Table of Contents

- [macOS Support](#macos-support)
- [Linux Support](#linux-support)
- [Windows Support](#windows-support)
- [Android Support](#android-support)
- [Driver Installation](#driver-installation)
- [Troubleshooting](#troubleshooting)

---

## macOS Support

### Intel x64 and Apple Silicon (ARM64)

#### Prerequisites
- macOS 10.14 or later
- Xcode 12.0 or later (for development)
- Flutter SDK 3.16.0 or later

#### Required Drivers

**Bluetooth OBD Adapters:**
- Built-in Bluetooth support (no additional drivers needed)
- Requires location permissions for Bluetooth device discovery

**USB/Serial OBD Adapters:**
```bash
# Install FTDI drivers (most common USB-Serial chips)
brew install --cask ftdi-vcp-driver

# Install Prolific drivers (PL2303 chips)
brew install --cask prolific-pl2303-driver

# Install Silicon Labs drivers (CP210x chips)
brew install --cask silicon-labs-vcp-driver
```

#### Setup Script
```bash
#!/bin/bash
# Run this script to set up macOS dependencies
# TODO: Integrate with main build system

echo "Setting up macOS OBD-II Tool dependencies..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install USB-Serial drivers
echo "Installing USB-Serial drivers..."
brew install --cask ftdi-vcp-driver
brew install --cask prolific-pl2303-driver
brew install --cask silicon-labs-vcp-driver

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Please install Flutter from https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi

echo "✅ macOS setup complete!"
echo "Note: You may need to restart your Mac for driver changes to take effect."
```

#### Permissions
Add to `macos/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to OBD-II adapters</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to connect to OBD-II adapters</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required for Bluetooth device discovery</string>
```

---

## Linux Support

### x64, ARM64, and ARM32 (Raspberry Pi)

#### Prerequisites
- Ubuntu 18.04+, Debian 10+, or equivalent
- GTK 3.0 development libraries
- Flutter SDK 3.16.0 or later

#### Required Packages
```bash
# Essential development tools
sudo apt-get update
sudo apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    build-essential

# GTK development libraries
sudo apt-get install -y \
    libgtk-3-dev \
    libblkid-dev \
    liblzma-dev \
    libjsoncpp-dev \
    cmake \
    ninja-build \
    pkg-config

# USB-Serial support
sudo apt-get install -y \
    udev \
    dialout \
    plugdev

# Bluetooth support
sudo apt-get install -y \
    bluetooth \
    bluez \
    bluez-tools \
    rfkill
```

#### USB-Serial Device Permissions
```bash
# Add user to dialout group for serial port access
sudo usermod -a -G dialout $USER

# Create udev rules for OBD-II adapters
sudo tee /etc/udev/rules.d/99-obd2-adapters.rules > /dev/null << 'EOF'
# FTDI-based adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666", GROUP="dialout"

# Prolific PL2303-based adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", MODE="0666", GROUP="dialout"

# Silicon Labs CP210x-based adapters
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"

# Generic USB-Serial converters
SUBSYSTEM=="tty", ATTRS{interface}=="*USB*Serial*", MODE="0666", GROUP="dialout"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### Setup Script
```bash
#!/bin/bash
# Linux setup script for OBD-II Tool
# TODO: Add distribution detection and package manager support

echo "Setting up Linux OBD-II Tool dependencies..."

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot detect Linux distribution"
    exit 1
fi

case $DISTRO in
    ubuntu|debian)
        sudo apt-get update
        sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa build-essential
        sudo apt-get install -y libgtk-3-dev libblkid-dev liblzma-dev libjsoncpp-dev cmake ninja-build pkg-config
        sudo apt-get install -y udev bluetooth bluez bluez-tools rfkill
        ;;
    fedora|centos|rhel)
        sudo dnf install -y curl git unzip xz zip mesa-libGLU-devel gcc-c++ make
        sudo dnf install -y gtk3-devel libblkid-devel xz-devel jsoncpp-devel cmake ninja-build pkgconfig
        sudo dnf install -y systemd-udev bluez bluez-tools rfkill
        ;;
    arch)
        sudo pacman -S --noconfirm curl git unzip xz zip glu base-devel
        sudo pacman -S --noconfirm gtk3 util-linux xz jsoncpp cmake ninja pkgconf
        sudo pacman -S --noconfirm systemd bluez bluez-utils rfkill
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        echo "Please install dependencies manually"
        exit 1
        ;;
esac

# Add user to dialout group
sudo usermod -a -G dialout $USER

# Set up udev rules
sudo tee /etc/udev/rules.d/99-obd2-adapters.rules > /dev/null << 'EOF'
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{interface}=="*USB*Serial*", MODE="0666", GROUP="dialout"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

echo "✅ Linux setup complete!"
echo "⚠️  Please log out and back in for group changes to take effect."
```

---

## Windows Support

### x64 and ARM64

#### Prerequisites
- Windows 10 version 1903 or later
- Visual Studio 2022 with C++ desktop development workload
- Flutter SDK 3.16.0 or later

#### Required Drivers

**USB-Serial Drivers:**
1. **FTDI Drivers** (most common):
   - Download from: https://ftdichip.com/drivers/vcp-drivers/
   - Supports FT232, FT2232, FT4232 chips

2. **Prolific PL2303 Drivers**:
   - Download from: http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=225
   - For PL2303 USB-Serial adapters

3. **Silicon Labs CP210x Drivers**:
   - Download from: https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers
   - For CP2102, CP2104, CP2108 chips

#### Setup Script (PowerShell)
```powershell
# Windows setup script for OBD-II Tool
# Run as Administrator
# TODO: Add chocolatey package management support

Write-Host "Setting up Windows OBD-II Tool dependencies..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script must be run as Administrator" -ForegroundColor Red
    exit 1
}

# Install Chocolatey if not present
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install Git and other tools
Write-Host "Installing development tools..." -ForegroundColor Yellow
choco install -y git
choco install -y 7zip
choco install -y vcredist140

# Check Visual Studio installation
$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022"
if (!(Test-Path $vsPath)) {
    Write-Host "⚠️  Visual Studio 2022 not found. Please install Visual Studio 2022 with C++ desktop development workload." -ForegroundColor Yellow
    Write-Host "Download from: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Cyan
}

# Check Flutter installation
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  Flutter not found. Please install Flutter from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
}

Write-Host "✅ Windows setup complete!" -ForegroundColor Green
Write-Host "⚠️  Please install USB-Serial drivers manually from device manufacturers:" -ForegroundColor Yellow
Write-Host "   - FTDI: https://ftdichip.com/drivers/vcp-drivers/" -ForegroundColor Cyan
Write-Host "   - Prolific: http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=225" -ForegroundColor Cyan
Write-Host "   - Silicon Labs: https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers" -ForegroundColor Cyan
```

#### Registry Entries for Common Issues
```reg
Windows Registry Editor Version 5.00

; Fix USB-Serial enumeration issues
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\usbser]
"DisplayName"="USB Serial Driver"
"Start"=dword:00000003
"Type"=dword:00000001

; Increase COM port timeout
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Serial]
"Start"=dword:00000001
```

---

## Android Support

### ARM64 and ARM32

#### Prerequisites
- Android 5.0 (API level 21) or later
- Google Play Services (for location services)

#### Permissions Required
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Bluetooth permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />

<!-- Location permissions (required for Bluetooth device discovery) -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- Storage permissions -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- USB OTG support -->
<uses-feature android:name="android.hardware.usb.host" android:required="false" />
<uses-permission android:name="android.permission.USB_PERMISSION" />

<!-- Network permissions for WiFi OBD adapters -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

#### USB OTG Setup
For USB OBD adapters on Android:
1. Device must support USB OTG (most modern Android devices do)
2. Use a USB OTG adapter cable
3. Install a terminal app to verify USB-Serial communication

---

## Driver Installation

### Automatic Driver Detection
The app includes automatic driver detection and installation assistance:

```dart
// TODO: Implement automatic driver detection service
class DriverDetectionService {
  static Future<List<String>> detectMissingDrivers() async {
    // Platform-specific driver detection logic
  }
  
  static Future<void> installDriver(String driverName) async {
    // Automated driver installation where possible
  }
}
```

### Manual Driver Installation

#### Common OBD-II Adapter Chips:
1. **FTDI FT232RL/FT232R** - Most reliable, wide compatibility
2. **Prolific PL2303** - Common in cheap adapters, driver issues on newer Windows
3. **Silicon Labs CP2102/CP2104** - Good reliability, auto-install on most systems
4. **CH340/CH341** - Very cheap, may require manual driver installation

#### Recommended Adapters:
- **FTDI-based**: Most compatible, premium price
- **Silicon Labs-based**: Good balance of cost and reliability
- **Bluetooth**: ELM327 v2.1 or higher for best compatibility

---

## Troubleshooting

### Common Issues

#### macOS
```bash
# Permission denied accessing USB device
sudo chmod 666 /dev/tty.usbserial-*

# Bluetooth not working
sudo killall bluetoothd
sudo launchctl start system/com.apple.bluetoothd
```

#### Linux
```bash
# User not in dialout group
sudo usermod -a -G dialout $USER
# Then logout and login again

# USB device not recognized
sudo dmesg | grep tty
lsusb  # Check if device is detected

# Bluetooth service not running
sudo systemctl start bluetooth
sudo systemctl enable bluetooth
```

#### Windows
```cmd
REM Check device manager for unknown devices
devmgmt.msc

REM List COM ports
wmic path win32_pnpentity where "caption like '%(COM%'" get caption,creationclassname /format:table

REM Reset USB drivers
pnputil /enum-drivers
```

#### Android
- Enable Developer Options and USB Debugging
- Check USB OTG functionality with a USB flash drive
- Verify Bluetooth is enabled and location services are on
- Grant all required permissions in app settings

### Getting Help

If you encounter issues:
1. Check the device manager/system logs
2. Verify the adapter works with other OBD software
3. Test with a known working vehicle
4. Check the GitHub issues for similar problems
5. Create a new issue with detailed system information

---

**Note**: This documentation is continuously updated. Check the latest version at:
https://github.com/THETECHYSASQUATCH/new-obd2-tool/tree/main/docs/platform-support