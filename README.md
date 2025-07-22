# OBD-II Diagnostics and Programming Tool

A comprehensive OBD-II diagnostics and programming tool that provides advanced vehicle diagnostic capabilities, ECU programming, live data monitoring, and relearn procedures.

## Features

### 🚗 Core Diagnostics
- **Diagnostic Trouble Codes (DTCs)**: Read, analyze, and clear DTCs with detailed descriptions and solutions
- **Live Data Monitoring**: Real-time monitoring of vehicle sensors and parameters
- **Protocol Support**: Compatible with multiple OBD protocols (SAE J1850, ISO 9141-2, ISO 14230-4, ISO 15765-4 CAN, SAE J1939)
- **Hardware Compatibility**: Works with popular OBD-II adapters including ELM327

### 🔧 ECU Programming
- **ECU Communication**: Connect and communicate with multiple ECUs on the vehicle network
- **Firmware Management**: Backup and flash ECU firmware
- **Memory Operations**: Read and write ECU memory addresses
- **Security Access**: Proper security handling for programming operations

### 📊 Live Data Features
- **Real-time Monitoring**: Monitor engine RPM, speed, temperature, and other parameters
- **Custom PIDs**: Add custom Parameter IDs for monitoring
- **Data Export**: Export monitoring data to CSV files
- **Configurable Refresh Rate**: Adjust monitoring frequency

### 🔄 Relearn Procedures
- **Throttle Body Relearn**: Reset and relearn throttle position
- **Transmission Adaptive Learning**: Reset transmission shift patterns
- **TPMS Sensor Relearn**: Relearn tire pressure sensor positions
- **Fuel Trim Reset**: Reset and relearn fuel delivery parameters
- **Steering Angle Calibration**: Calibrate steering angle sensor

### 🖥️ User Interface
- **Intuitive GUI**: Easy-to-use graphical interface with tabbed layout
- **Connection Management**: Simple connection setup and monitoring
- **Real-time Status**: Live connection and operation status updates
- **Comprehensive Help**: Built-in help and documentation

## Installation

### Prerequisites
- Python 3.7 or higher
- Serial port access (varies by operating system)

### Install Dependencies
```bash
pip install -r requirements.txt
```

### Install Package
```bash
pip install -e .
```

## Usage

### GUI Mode (Recommended)
```bash
python main.py
```

### Command Line Options
```bash
# Specify port and baudrate
python main.py --port COM3 --baudrate 38400

# Enable debug logging
python main.py --log-level DEBUG

# Use custom configuration file
python main.py --config my_config.json

# Save logs to file
python main.py --log-file obd_tool.log
```

### Quick Start Guide

1. **Connect Hardware**
   - Connect your OBD-II adapter to the vehicle's diagnostic port
   - Connect adapter to computer via USB/Bluetooth

2. **Launch Application**
   ```bash
   python main.py
   ```

3. **Establish Connection**
   - Select the correct COM port from the dropdown
   - Click "Connect" to establish communication
   - Tool will auto-detect the vehicle protocol

4. **Basic Diagnostics**
   - Go to "Diagnostics" tab
   - Click "Read DTCs" to scan for error codes
   - Double-click any DTC for detailed information

5. **Live Data Monitoring**
   - Go to "Live Data" tab
   - Click "Start Monitoring" to begin real-time data collection
   - Add custom PIDs using "Add PID" button

## Hardware Compatibility

### Supported Adapters
- **ELM327**: USB, Bluetooth, and WiFi variants
- **OBDLink**: Professional OBD adapters
- **Generic**: Most standard OBD-II adapters

### Supported Protocols
- SAE J1850 PWM (41.6 kbaud)
- SAE J1850 VPW (10.4 kbaud)
- ISO 9141-2 (5 baud init)
- ISO 14230-4 (KWP2000)
- ISO 15765-4 CAN (11-bit and 29-bit ID)
- SAE J1939 CAN (Heavy duty vehicles)

## Advanced Features

### ECU Programming
⚠️ **Warning**: ECU programming can permanently damage your vehicle if done incorrectly. Only perform these operations if you fully understand the risks.

1. **Scan for ECUs**
   - Use "ECU Programming" tab
   - Click "Scan ECUs" to find available modules

2. **Enter Programming Mode**
   - Select target ECU
   - Click "Enter Programming Mode"
   - Follow security access procedures

3. **Backup Firmware**
   - Always backup before making changes
   - Click "Backup Firmware" and save to file

4. **Flash Firmware**
   - Load firmware file
   - Click "Flash Firmware"
   - Verify operation completes successfully

### Relearn Procedures

1. **Select Procedure**
   - Go to "Relearn Procedures" tab
   - Choose procedure from dropdown

2. **Check Preconditions**
   - Click "Check Preconditions"
   - Ensure all requirements are met

3. **Execute Procedure**
   - Click "Start Procedure"
   - Follow step-by-step instructions
   - Complete manual steps as prompted

## Configuration

The tool uses a JSON configuration file (`config.json`) for settings:

```json
{
  "connection": {
    "default_port": "",
    "default_baudrate": 38400,
    "timeout": 3.0,
    "auto_connect": false
  },
  "monitoring": {
    "default_refresh_rate": 1.0,
    "default_pids": ["0C", "0D", "05", "11"],
    "max_data_points": 1000
  },
  "programming": {
    "backup_directory": "./backups",
    "verify_after_flash": true,
    "security_warnings": true
  },
  "interface": {
    "window_geometry": "1200x800",
    "theme": "default",
    "font_size": 10
  },
  "logging": {
    "level": "INFO",
    "log_file": "obd_tool.log",
    "max_log_size": 10485760,
    "backup_count": 5
  }
}
```

## Troubleshooting

### Connection Issues
- **No response from adapter**: Check port selection and cable connections
- **Permission denied**: Run as administrator (Windows) or add user to dialout group (Linux)
- **Protocol detection fails**: Try manual protocol selection
- **Timeout errors**: Increase timeout in configuration

### Programming Issues
- **Security access failed**: Ensure correct key calculation algorithm
- **Flash verification failed**: Check firmware file integrity
- **Communication lost**: Verify stable connection and power

### Common Error Codes
- **P0XXX**: Powertrain codes (engine, transmission)
- **B0XXX**: Body codes (airbags, lighting, etc.)
- **C0XXX**: Chassis codes (ABS, steering, suspension)
- **U0XXX**: Network codes (communication errors)

## Development

### Project Structure
```
src/
├── core/           # Core OBD communication
├── diagnostics/    # DTC and live data management
├── ecu/           # ECU programming functionality
├── procedures/    # Relearn procedures
├── gui/           # User interface
└── utils/         # Utilities and configuration
```

### Adding New Features
1. Follow existing module structure
2. Add appropriate error handling
3. Include logging for debugging
4. Update GUI if needed
5. Test thoroughly with real hardware

### Contributing
1. Fork the repository
2. Create feature branch
3. Make changes with proper testing
4. Submit pull request

## Safety and Legal Notices

⚠️ **Important Safety Information**:
- This tool can modify vehicle systems
- Improper use may cause vehicle damage or safety issues
- Always backup ECU data before programming
- Use only on vehicles you own or have permission to modify
- Comply with local laws and regulations

### Disclaimer
This software is provided "as is" without warranty of any kind. The authors are not responsible for any damage to vehicles or other property resulting from the use of this software.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

- **Issues**: Report bugs and request features on GitHub
- **Documentation**: Check wiki for detailed guides
- **Community**: Join discussions in the project forum

## Version History

### v1.0.0
- Initial release
- Complete OBD-II diagnostic functionality
- ECU programming capabilities
- Live data monitoring
- Relearn procedures
- GUI interface
- Hardware compatibility with ELM327

---

**Made with ❤️ for the automotive community**