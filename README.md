# OBD-II Diagnostics and Programming Tool

A comprehensive, cross-platform tool for OBD-II vehicle diagnostics and programming operations.

## Features

### Core Functionality
- **Diagnostic Trouble Codes (DTCs)**: Read, clear, and manage current, pending, and permanent DTCs
- **Live Data Monitoring**: Real-time parameter monitoring with customizable displays
- **Vehicle Information**: VIN reading, ECU identification, and vehicle-specific data
- **Multiple Protocol Support**: CAN, ISO 9141-2, KWP2000, SAE J1850, and more

### Hardware Support
- **ELM327 Adapters**: Full support for ELM327-based OBD-II adapters
- **Connection Types**: USB/Serial, Bluetooth, and Wi-Fi connectivity
- **Auto-Detection**: Automatic adapter and protocol detection
- **Multiple Interfaces**: Support for various OBD-II interface hardware

### Programming Capabilities
- **ECU Programming**: Flash memory operations (read/write/verify)
- **Feature Management**: Enable/disable vehicle features and configurations
- **Calibration Management**: Backup, restore, and modify ECU calibrations
- **Security Access**: Advanced ECU access for programming operations

### User Interface
- **Cross-Platform GUI**: Built with Tkinter for Windows, Linux, and macOS
- **Tabbed Interface**: Organized tabs for different functions
- **Real-Time Updates**: Live data display with automatic refresh
- **Export Functions**: Save DTCs and data to files

### Plugin System
- **Extensible Architecture**: Plugin-based system for custom functionality
- **Custom PIDs**: Add support for manufacturer-specific parameters
- **Custom DTCs**: Extend DTC database with vehicle-specific codes
- **UI Extensions**: Add custom panels and interfaces

## Installation

### Quick Install (Linux/macOS)
```bash
git clone https://github.com/THETECHYSASQUATCH/new-obd2-tool.git
cd new-obd2-tool
chmod +x scripts/install.sh
./scripts/install.sh
```

### Manual Installation

#### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)

#### Install Dependencies
```bash
# Clone the repository
git clone https://github.com/THETECHYSASQUATCH/new-obd2-tool.git
cd new-obd2-tool

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .
```

#### Additional Dependencies (Optional)
```bash
# For Bluetooth support
pip install pybluez

# For Windows-specific features
pip install pywin32

# For development and testing
pip install pytest pytest-cov flake8
```

## Usage

### Running the Application
```bash
# From the project directory
python main.py

# Or using the module
python -m src.main

# With virtual environment activated
python main.py
```

### Basic Operations

#### 1. Connect to Vehicle
1. Launch the application
2. Click "Connect" or use File → Connect menu
3. Select connection type (USB/Serial, Bluetooth, Wi-Fi)
4. Choose your OBD-II adapter port
5. Click "Connect" to establish connection

#### 2. Read Diagnostic Trouble Codes
1. Ensure vehicle is connected
2. Go to "Diagnostics" tab
3. Click "Read Current DTCs" to read active codes
4. Use "Read Pending DTCs" for pending codes
5. View detailed information by double-clicking any DTC

#### 3. Monitor Live Data
1. Go to "Live Data" tab
2. Select parameters to monitor (RPM, Speed, Temperature, etc.)
3. Click "Start Monitor" to begin real-time monitoring
4. Data updates automatically in the table

#### 4. Programming Operations (Advanced)
⚠️ **Warning**: Programming operations can permanently modify vehicle software. Use with caution.

1. Go to "Programming" tab
2. Read ECU information first
3. Use feature management to enable/disable functions
4. Advanced users can access flash operations

### Configuration

The application creates a `config.ini` file with default settings:

```ini
[connection]
default_port = auto
default_baudrate = 38400
timeout = 5.0
adapter_type = ELM327

[gui]
window_width = 1024
window_height = 768
theme = default

[diagnostics]
auto_refresh_interval = 1000
max_dtc_history = 100
```

## Development

### Build from Source
```bash
# Run build script
python scripts/build.py --all

# Run tests only
python scripts/build.py --test

# Build executable
python scripts/build.py --build

# Set up development environment
python scripts/build.py --dev
```

### Running Tests
```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test modules
python -m pytest tests/test_core.py -v
python -m pytest tests/test_hardware.py -v
python -m pytest tests/test_gui.py -v

# With coverage report
python -m pytest tests/ --cov=src --cov-report=html
```

### Code Style
```bash
# Run linting
flake8 src/ --max-line-length=120

# Or use the build script
python scripts/build.py --lint
```

### Creating Plugins

Example plugin structure:
```python
from src.plugins.base_plugin import DiagnosticPlugin

class MyPlugin(DiagnosticPlugin):
    def __init__(self):
        super().__init__(
            name="My Custom Plugin",
            version="1.0.0",
            description="Custom diagnostic functionality"
        )
    
    def initialize(self, obd_manager, main_app, config):
        # Initialize plugin
        return True
    
    def get_supported_pids(self):
        # Return list of supported PIDs
        return [0xF0, 0xF1]
    
    # Implement other required methods...
```

## Hardware Compatibility

### Supported Adapters
- **ELM327-based adapters** (USB, Bluetooth, Wi-Fi)
- **Generic OBD-II adapters** with ELM327 command set
- **Professional scan tools** with OBD-II compatibility

### Tested Adapters
- BAFX Products 34t5 Bluetooth OBD2 Scanner
- OBDLink SX USB Interface
- Veepeak WiFi OBD2 Scanner
- Generic ELM327 USB adapters

### Connection Types
- **USB/Serial**: Direct USB connection via serial port
- **Bluetooth**: Wireless Bluetooth connection (requires pairing)
- **Wi-Fi**: TCP/IP connection over Wi-Fi network

## Troubleshooting

### Common Issues

#### Cannot Connect to Adapter
1. Check adapter is properly connected
2. Verify correct port/address in connection settings
3. Ensure adapter drivers are installed
4. Try different baud rates (38400, 115200, 9600)

#### No Response from Vehicle
1. Ensure vehicle is running or ignition is on
2. Check OBD-II connector is properly seated
3. Verify vehicle has OBD-II support (1996+ in US)
4. Try auto-detecting protocol

#### Permission Denied (Linux)
```bash
# Add user to dialout group
sudo usermod -a -G dialout $USER
# Log out and log back in

# Or run with sudo (not recommended)
sudo python main.py
```

#### Bluetooth Connection Issues
1. Ensure adapter is paired with computer
2. Check Bluetooth service is running
3. Verify correct MAC address
4. Install pybluez if not available

### Getting Help
- Check the [Issues](https://github.com/THETECHYSASQUATCH/new-obd2-tool/issues) page
- Review log files in `logs/` directory
- Enable debug logging in configuration
- Join the community discussions

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

### Reporting Issues
When reporting issues, please include:
- Operating system and version
- Python version
- Adapter type and model
- Vehicle make/model/year
- Complete error messages
- Steps to reproduce

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

⚠️ **Important Safety Notice**

This tool is designed for diagnostic and educational purposes. When using programming features:

- **Always backup** original ECU firmware before making changes
- **Test thoroughly** in safe environments
- **Understand the risks** of ECU modifications
- **Verify compatibility** with your specific vehicle
- **Use at your own risk** - modifications may void warranties

The authors are not responsible for any damage to vehicles, ECUs, or other systems resulting from the use of this software.

## Acknowledgments

- ELM Electronics for the ELM327 chipset and documentation
- The open-source automotive community
- Contributors and testers who helped improve the tool
- Various OBD-II specification documents and references

## Roadmap

### Planned Features
- [ ] Mobile app support (Android/iOS)
- [ ] Advanced data logging and analysis
- [ ] Cloud-based vehicle profiles
- [ ] Additional protocol support
- [ ] Enhanced plugin marketplace
- [ ] Web-based interface option
- [ ] Multi-language support
- [ ] Professional diagnostic features

### Version History
- **v0.1.0** - Initial release with core functionality
- **Future versions** - See [CHANGELOG.md](CHANGELOG.md) for details