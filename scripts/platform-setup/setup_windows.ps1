# Windows Setup Script for OBD-II Diagnostics Tool
# Run this script as Administrator in PowerShell
# TODO: Add chocolatey integration and automated driver installation

param(
    [switch]$SkipDrivers,
    [switch]$Quiet
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorText {
    param([string]$Text, [string]$Color)
    Write-Host "$Color$Text$Reset"
}

Write-ColorText "🚗 OBD-II Diagnostics Tool - Windows Setup" $Blue
Write-ColorText "===========================================" $Blue
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-ColorText "❌ This script must be run as Administrator" $Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

# Get Windows version
$osVersion = [System.Environment]::OSVersion.Version
$osName = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
Write-ColorText "Detected: $osName" $Blue
Write-ColorText "Version: $($osVersion.Major).$($osVersion.Minor).$($osVersion.Build)" $Blue

# Check Windows version compatibility
if ($osVersion.Major -lt 10) {
    Write-ColorText "⚠️  Windows 10 or later is recommended" $Yellow
}

# Check architecture
$arch = $env:PROCESSOR_ARCHITECTURE
Write-ColorText "Architecture: $arch" $Blue

# Install Chocolatey if not present
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-ColorText "Installing Chocolatey package manager..." $Blue
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-ColorText "✅ Chocolatey installed successfully" $Green
    }
    catch {
        Write-ColorText "❌ Failed to install Chocolatey: $_" $Red
        Write-Host "Please install Chocolatey manually from https://chocolatey.org/"
    }
} else {
    Write-ColorText "✅ Chocolatey already installed" $Green
}

# Install essential development tools
Write-ColorText "Installing development tools..." $Blue
$tools = @("git", "7zip", "vcredist140", "vcredist2019")

foreach ($tool in $tools) {
    try {
        if (!(choco list --local-only $tool | Select-String $tool)) {
            Write-Host "Installing $tool..."
            choco install $tool -y --no-progress
        } else {
            Write-ColorText "✅ $tool already installed" $Green
        }
    }
    catch {
        Write-ColorText "⚠️  Failed to install $tool" $Yellow
    }
}

# Check Visual Studio installation
Write-ColorText "Checking Visual Studio installation..." $Blue
$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022"
$vsBuildTools = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools"

if ((Test-Path $vsPath) -or (Test-Path $vsBuildTools)) {
    Write-ColorText "✅ Visual Studio 2022 detected" $Green
} else {
    Write-ColorText "⚠️  Visual Studio 2022 not found" $Yellow
    Write-Host "Please install Visual Studio 2022 with C++ desktop development workload"
    Write-Host "Download from: https://visualstudio.microsoft.com/downloads/"
    Write-Host ""
    Write-Host "Minimum required components:"
    Write-Host "- MSVC v143 C++ build tools"
    Write-Host "- Windows 10/11 SDK"
    Write-Host "- CMake tools for Visual Studio"
}

# Check Flutter installation
Write-ColorText "Checking Flutter installation..." $Blue
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-ColorText "✅ $flutterVersion" $Green
    
    if (!$Quiet) {
        Write-ColorText "Running Flutter doctor..." $Blue
        flutter doctor
    }
} else {
    Write-ColorText "⚠️  Flutter not found" $Yellow
    Write-Host ""
    Write-Host "To install Flutter:"
    Write-Host "1. Download from https://docs.flutter.dev/get-started/install/windows"
    Write-Host "2. Extract to C:\flutter"
    Write-Host "3. Add C:\flutter\bin to your PATH"
    Write-Host ""
    Write-Host "Or install with Chocolatey:"
    Write-Host "  choco install flutter"
}

# USB-Serial driver installation
if (!$SkipDrivers) {
    Write-ColorText "Setting up USB-Serial drivers..." $Blue
    Write-Host ""
    Write-ColorText "⚠️  USB-Serial drivers must be installed manually:" $Yellow
    Write-Host ""
    Write-Host "1. FTDI VCP Drivers (most common):"
    Write-Host "   Download: https://ftdichip.com/drivers/vcp-drivers/"
    Write-Host "   - Supports FT232R, FT232H, FT2232, FT4232 chips"
    Write-Host ""
    Write-Host "2. Prolific PL2303 Drivers:"
    Write-Host "   Download: http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=225"
    Write-Host "   - For PL2303 USB-Serial adapters"
    Write-Host ""
    Write-Host "3. Silicon Labs CP210x Drivers:"
    Write-Host "   Download: https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers"
    Write-Host "   - For CP2102, CP2104, CP2108, CP2109 chips"
    Write-Host ""
    Write-Host "4. CH340/CH341 Drivers (for cheap adapters):"
    Write-Host "   Download: http://www.wch-ic.com/downloads/CH341SER_ZIP.html"
    Write-Host ""
    
    $installDrivers = Read-Host "Open driver download pages? (y/N)"
    if ($installDrivers -eq "y" -or $installDrivers -eq "Y") {
        Start-Process "https://ftdichip.com/drivers/vcp-drivers/"
        Start-Process "http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=225"
        Start-Process "https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers"
    }
}

# Windows Defender exclusion for development
Write-ColorText "Setting up Windows Defender exclusions..." $Blue
try {
    # Exclude Flutter installation directory
    if (Test-Path "C:\flutter") {
        Add-MpPreference -ExclusionPath "C:\flutter" -ErrorAction SilentlyContinue
        Write-ColorText "✅ Added C:\flutter to Windows Defender exclusions" $Green
    }
    
    # Exclude common development directories
    $exclusions = @("C:\src", "C:\dev", "$env:USERPROFILE\dev", "$env:USERPROFILE\Documents\Flutter")
    foreach ($path in $exclusions) {
        if (Test-Path $path) {
            Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
        }
    }
} catch {
    Write-ColorText "⚠️  Could not add Windows Defender exclusions (requires admin privileges)" $Yellow
}

# Registry optimizations for development
Write-ColorText "Applying development optimizations..." $Blue
try {
    # Disable Windows Search indexing for development directories
    $searchKey = "HKLM:\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\DefaultRules"
    if (Test-Path $searchKey) {
        # Add exclusions for common development file patterns
        reg add "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\DefaultRules" /v "*\.dart" /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\DefaultRules" /v "*\.lock" /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\DefaultRules" /v "pubspec.yaml" /t REG_DWORD /d 0 /f | Out-Null
    }
    
    Write-ColorText "✅ Applied development optimizations" $Green
} catch {
    Write-ColorText "⚠️  Could not apply some optimizations" $Yellow
}

# Check Windows features
Write-ColorText "Checking Windows features..." $Blue

# Check if Developer Mode is enabled
$devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
if ($devMode.AllowDevelopmentWithoutDevLicense -eq 1) {
    Write-ColorText "✅ Developer Mode is enabled" $Green
} else {
    Write-ColorText "⚠️  Developer Mode is not enabled" $Yellow
    Write-Host "To enable Developer Mode:"
    Write-Host "1. Open Settings > Update & Security > For developers"
    Write-Host "2. Select 'Developer mode'"
}

Write-Host ""
Write-ColorText "🎉 Windows setup completed!" $Green
Write-Host ""
Write-ColorText "Next steps:" $Blue
Write-Host "1. Install USB-Serial drivers for your OBD-II adapter"
Write-Host "2. Connect your OBD-II adapter and verify it appears in Device Manager"
Write-Host "3. Enable Developer Mode in Windows Settings"
Write-Host "4. Install Flutter if not already installed"
Write-Host "5. Run the OBD-II Diagnostics Tool"
Write-Host ""
Write-ColorText "Troubleshooting:" $Blue
Write-Host "- Check Device Manager for USB-Serial devices"
Write-Host "- Verify COM port assignment (usually COM3, COM4, etc.)"
Write-Host "- Test with Device Manager > Ports (COM & LPT)"
Write-Host "- Use 'wmic path win32_pnpentity' to list all devices"
Write-Host ""
Write-ColorText "Happy diagnosing! 🔧" $Blue