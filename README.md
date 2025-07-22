# OBD-II Diagnostics and Programming Tool

A comprehensive OBD-II diagnostics and programming tool that supports all major car manufacturers and their proprietary systems. This tool provides automatic vehicle detection, advanced diagnostics, programming capabilities, and an intuitive graphical user interface.

## Features

### 🚗 Automatic Vehicle Detection
- **VIN Decoding**: Automatically decode Vehicle Identification Numbers to extract vehicle information
- **OBD Communication**: Connect to vehicles via OBD-II interface for automatic detection
- **Manufacturer Identification**: Identify vehicle make, model, year, and region

### 🔧 Comprehensive Manufacturer Support
- **Universal Compatibility**: Support for all major car manufacturers including:
  - Honda, Toyota, Ford, General Motors
  - BMW, Mercedes-Benz, Audi, Volkswagen
  - Hyundai, Kia, Mazda, and more
- **Proprietary Systems**: Access manufacturer-specific diagnostic protocols and commands
- **Module Support**: Diagnostics for all vehicle modules (ECM, TCM, ABS, SRS, BCM, etc.)

### 🔍 Advanced Diagnostics
- **Diagnostic Trouble Codes (DTCs)**: Read, decode, and clear both generic and manufacturer-specific codes
- **Live Data Monitoring**: Real-time monitoring of vehicle parameters
- **Freeze Frame Data**: Access freeze frame data for diagnostic analysis
- **Readiness Tests**: Check emission system readiness status
- **Module-Specific Diagnosis**: Targeted diagnosis for individual vehicle modules

### 💻 Programming and Relearn Procedures
- **ECU Programming**: Perform manufacturer-specific programming operations
- **Relearn Procedures**: Execute relearn procedures for various components:
  - Idle air control relearn
  - TPMS sensor relearn
  - Throttle body adaptation
  - Brake bleeding procedures
  - Service interval resets
- **Backup and Restore**: Backup ECU data before programming operations

### 🔄 Extensible Architecture
- **Modular Design**: Easy to add new manufacturers and protocols
- **JSON Configuration**: Manufacturer data stored in easily editable JSON files
- **Plugin Architecture**: Extensible system for future enhancements

### 🖥️ User Interface
- **Intuitive GUI**: Easy-to-use graphical interface built with tkinter
- **Tabbed Layout**: Organized interface with separate tabs for different functions
- **Real-time Status**: Live connection status and operation progress
- **Detailed Results**: Comprehensive display of diagnostic and programming results

## Installation

### Prerequisites
- Python 3.7 or higher
- OBD-II adapter (ELM327 compatible recommended)

### Install Dependencies
```bash
pip install -r requirements.txt
```

### Required Dependencies
- `python-obd>=0.7.1` - OBD-II communication library
- `tkinter` - GUI framework (usually included with Python)

### Optional Dependencies
- `python-can>=4.0.0` - For advanced CAN bus communication
- `requests>=2.25.1` - For future online features

## Usage

### Starting the Application
```bash
python main.py
```

### Basic Workflow

1. **Connect to Vehicle**
   - Connect OBD-II adapter to vehicle diagnostic port
   - Launch the application
   - Click "Connect OBD" to establish connection

2. **Vehicle Detection**
   - Use "Auto-Detect Vehicle" for automatic identification
   - Or manually select manufacturer and enter VIN for manual identification

3. **Diagnostics**
   - Navigate to "Diagnostics" tab
   - Read DTCs, perform readiness tests, or diagnose specific modules
   - View live data in the "Live Data" tab

4. **Programming**
   - Go to "Programming" tab
   - Select from available manufacturer-specific procedures
   - Follow step-by-step instructions for relearn procedures

## Supported Manufacturers

### Currently Supported
- **Honda/Acura**: Full diagnostic and programming support
- **Toyota/Lexus**: Complete integration with Toyota-specific protocols
- **Ford/Lincoln**: Support for Ford's proprietary systems
- **General Motors**: Chevrolet, GMC, Cadillac, Buick support
- **BMW**: Full integration with BMW diagnostic protocols
- **Mercedes-Benz**: Support for Mercedes-specific systems
- **Audi**: VW Group diagnostic protocol support
- **Volkswagen**: Complete VW-specific functionality

### Adding New Manufacturers
The tool is designed for easy expansion. To add a new manufacturer:

1. Update `data/manufacturers.json` with manufacturer-specific information
2. Add DTC codes to `data/dtc_codes.json`
3. Create programming procedures in the programming engine
4. Update VIN decoder data if needed

## File Structure

```
new-obd2-tool/
├── main.py                     # Main application entry point
├── requirements.txt            # Python dependencies
├── README.md                   # This file
├── LICENSE                     # MIT License
├── src/                        # Source code
│   ├── vehicle_detection.py    # Vehicle detection and VIN decoding
│   ├── diagnostics.py          # Diagnostic functions
│   ├── programming.py          # Programming and relearn procedures
│   └── gui/                    # GUI components
│       └── main_gui.py         # Main GUI application
├── data/                       # Configuration and data files
│   ├── vin_decoder.json        # VIN decoding data
│   ├── manufacturers.json      # Manufacturer-specific information
│   ├── dtc_codes.json          # Diagnostic trouble codes
│   └── programming_procedures.json # Programming procedures
├── docs/                       # Documentation
└── tests/                      # Test files
```

## Configuration

### Manufacturer Data
Edit `data/manufacturers.json` to modify manufacturer-specific settings:
- Supported protocols
- Available modules
- Specific commands

### DTC Codes
Update `data/dtc_codes.json` to add new diagnostic trouble codes:
- Generic OBD-II codes
- Manufacturer-specific codes

### VIN Decoder
Modify `data/vin_decoder.json` to update VIN decoding information:
- World Manufacturer Identifier (WMI) codes
- Year codes

## Hardware Compatibility

### Recommended OBD-II Adapters
- **ELM327-based adapters**: Most common and widely supported
- **J2534 PassThru devices**: For advanced programming operations
- **Manufacturer-specific interfaces**: For maximum compatibility

### Supported Protocols
- ISO9141-2
- ISO14230 (KWP2000)
- SAE J1850 PWM
- SAE J1850 VPW
- CAN (ISO15765)
- CAN (SAE J1939)

## Troubleshooting

### Common Issues

1. **Connection Problems**
   - Verify OBD-II adapter is properly connected
   - Check vehicle ignition is ON
   - Ensure correct COM port is selected

2. **Vehicle Not Detected**
   - Try manual VIN entry
   - Check if vehicle supports OBD-II (1996+ for US vehicles)
   - Verify adapter compatibility

3. **Programming Failures**
   - Ensure all prerequisites are met
   - Maintain stable connection during programming
   - Check battery voltage is adequate

### Error Messages
- "No OBD connection": Check adapter connection and vehicle power
- "VIN decode error": Verify VIN is correct and complete
- "Procedure not supported": Check if manufacturer supports the specific procedure

## Contributing

Contributions are welcome! Areas where contributions are especially needed:

1. **New Manufacturer Support**: Adding support for additional manufacturers
2. **Programming Procedures**: Adding more relearn and programming procedures
3. **DTC Database**: Expanding the diagnostic trouble code database
4. **Protocol Support**: Adding support for additional communication protocols
5. **Testing**: Testing with different vehicles and adapters

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your specific vehicle/adapter combination
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This tool is for educational and diagnostic purposes. Always follow proper safety procedures when working with vehicles. The authors are not responsible for any damage that may occur from using this software. Always backup ECU data before performing programming operations.

## Support

For support, questions, or feature requests:
- Create an issue on the GitHub repository
- Check the troubleshooting section above
- Consult your vehicle's service manual for specific procedures

## Acknowledgments

- python-obd library for OBD-II communication
- ELM327 community for protocol documentation
- Automotive diagnostic community for sharing knowledge