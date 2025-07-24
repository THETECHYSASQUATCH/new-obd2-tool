#!/bin/bash
# macOS Setup Script for OBD-II Diagnostics Tool
# TODO: Integrate with main build system and add error handling

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚗 OBD-II Diagnostics Tool - macOS Setup${NC}"
echo "=============================================="
echo ""

# Check macOS version
macos_version=$(sw_vers -productVersion)
echo -e "${BLUE}Detected macOS version: $macos_version${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}✅ Homebrew already installed${NC}"
fi

# Update Homebrew
echo -e "${BLUE}Updating Homebrew...${NC}"
brew update

# Install USB-Serial drivers
echo -e "${BLUE}Installing USB-Serial drivers...${NC}"

# FTDI VCP Drivers
if ! brew list --cask ftdi-vcp-driver &> /dev/null; then
    echo "Installing FTDI VCP drivers..."
    brew install --cask ftdi-vcp-driver
else
    echo -e "${GREEN}✅ FTDI drivers already installed${NC}"
fi

# Prolific PL2303 Drivers
if ! brew list --cask prolific-pl2303-driver &> /dev/null; then
    echo "Installing Prolific PL2303 drivers..."
    brew install --cask prolific-pl2303-driver
else
    echo -e "${GREEN}✅ Prolific drivers already installed${NC}"
fi

# Silicon Labs VCP Drivers
if ! brew list --cask silicon-labs-vcp-driver &> /dev/null; then
    echo "Installing Silicon Labs VCP drivers..."
    brew install --cask silicon-labs-vcp-driver
else
    echo -e "${GREEN}✅ Silicon Labs drivers already installed${NC}"
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter not found${NC}"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install/macos"
    echo ""
    echo "Quick install with Homebrew:"
    echo "  brew install --cask flutter"
    echo ""
else
    flutter_version=$(flutter --version | head -n 1)
    echo -e "${GREEN}✅ $flutter_version${NC}"
fi

# Check Xcode installation
if xcode-select -p &> /dev/null; then
    xcode_version=$(xcodebuild -version | head -n 1)
    echo -e "${GREEN}✅ $xcode_version${NC}"
else
    echo -e "${YELLOW}⚠️  Xcode not found or not properly configured${NC}"
    echo "Please install Xcode from the Mac App Store and run:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
fi

# Install development tools
echo -e "${BLUE}Installing development tools...${NC}"
brew_tools=(
    "git"
    "curl"
    "unzip"
    "cocoapods"
)

for tool in "${brew_tools[@]}"; do
    if ! brew list "$tool" &> /dev/null; then
        echo "Installing $tool..."
        brew install "$tool"
    else
        echo -e "${GREEN}✅ $tool already installed${NC}"
    fi
done

# Check iOS Simulator
if xcrun simctl list devices | grep -q "iOS"; then
    echo -e "${GREEN}✅ iOS Simulator available${NC}"
else
    echo -e "${YELLOW}⚠️  iOS Simulator not found${NC}"
    echo "Please install iOS Simulator from Xcode"
fi

echo ""
echo -e "${GREEN}🎉 macOS setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Restart your Mac to ensure all drivers are loaded"
echo "2. Connect your OBD-II adapter"
echo "3. Run the OBD-II Diagnostics Tool"
echo ""
echo "If you encounter any issues:"
echo "- Check System Preferences > Security & Privacy for driver approval"
echo "- Verify your OBD-II adapter is detected in System Information > USB"
echo "- Check the troubleshooting guide in docs/platform-support/"
echo ""
echo -e "${BLUE}Happy diagnosing! 🔧${NC}"