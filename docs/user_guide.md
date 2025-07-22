# OBD-II Tool User Guide

## Getting Started

### System Requirements
- Python 3.7 or higher
- OBD-II adapter (ELM327 compatible recommended)
- Vehicle with OBD-II port (1996+ for US vehicles)

### Installation
1. Clone or download the repository
2. Install dependencies: `pip install -r requirements.txt`
3. Run the application: `python main.py`

## Using the Application

### 1. Vehicle Detection Tab

#### Automatic Detection
1. Connect your OBD-II adapter to the vehicle's diagnostic port
2. Turn on vehicle ignition (engine can be off)
3. Click "Connect OBD" to establish connection
4. Click "Auto-Detect Vehicle" to automatically identify your vehicle

#### Manual Selection
1. Select manufacturer from dropdown menu
2. Enter VIN manually if auto-detection fails
3. Click "Decode VIN" to extract vehicle information

### 2. Diagnostics Tab

#### Reading Trouble Codes
1. Ensure OBD connection is established
2. Click "Read DTCs" to retrieve diagnostic trouble codes
3. View detailed descriptions and affected systems

#### Module Diagnosis
1. Select specific module (ECM, TCM, ABS, etc.)
2. Click "Diagnose Module" for targeted diagnosis
3. Review module-specific DTCs and live data

#### Clearing Codes
1. Click "Clear DTCs" to erase stored trouble codes
2. Confirm the action when prompted
3. Note: Only clear codes after repairs are completed

### 3. Programming Tab

#### Available Procedures
1. Procedures are automatically loaded based on detected vehicle
2. Select procedure from the list to view details
3. Review requirements and steps before proceeding

#### Executing Procedures
1. Ensure all prerequisites are met
2. Click "Execute Procedure" to start
3. Follow on-screen instructions carefully
4. Do not disconnect during programming

### 4. Live Data Tab

#### Monitoring Parameters
1. Click "Start Monitoring" for continuous data updates
2. View real-time engine parameters
3. Click "Stop Monitoring" to pause updates

#### Single Read
1. Click "Read Once" for snapshot of current values
2. Useful for checking specific parameters

## Supported Procedures by Manufacturer

### Honda/Acura
- Idle Air Control Relearn
- TPMS Sensor Relearn
- A/T Learning Procedure
- Steering Angle Sensor Reset

### Toyota/Lexus  
- Electronic Throttle Body Relearn
- Hybrid Battery System Reset
- ABS Brake System Bleeding
- Oil Life Reset

### Ford/Lincoln
- PCM Keep Alive Memory Reset
- Transponder Key Programming
- Transmission Relearn
- TPMS Reset

### BMW
- ECU Adaptations Reset
- Service Interval Reset
- Steering Angle Sensor Calibration
- DPF Regeneration

### Mercedes-Benz
- Engine Adaptation Reset
- Transmission Adaptation
- ESP Calibration
- Service Reset

## Troubleshooting

### Connection Issues
**Problem**: Cannot connect to vehicle
**Solutions**:
- Verify OBD adapter is properly connected
- Check vehicle ignition is ON
- Try different USB port or adapter
- Ensure vehicle supports OBD-II

### Detection Failures
**Problem**: Vehicle not detected automatically
**Solutions**:
- Try manual VIN entry
- Check VIN format (17 characters)
- Verify adapter compatibility with vehicle
- Some older vehicles may not support VIN reading

### Programming Errors
**Problem**: Procedure fails to complete
**Solutions**:
- Ensure battery voltage is adequate (>12V)
- Maintain stable connection throughout procedure
- Check all prerequisites are met
- Retry procedure if safe to do so

### No Live Data
**Problem**: Live data shows no values
**Solutions**:
- Verify engine is running for engine parameters
- Check OBD connection stability
- Some parameters only available under specific conditions
- Try different PIDs or parameters

## Safety Warnings

⚠️ **Important Safety Information**

### Before Programming
- Always backup ECU data before programming
- Ensure battery is fully charged
- Do not disconnect during programming operations
- Have vehicle service manual available

### General Precautions
- Only perform procedures you understand
- Follow manufacturer service procedures
- Some procedures require engine running - ensure proper ventilation
- Disconnect OBD adapter when not in use

### Legal Disclaimers
- This tool is for diagnostic and educational purposes
- Always follow local emissions and safety regulations
- Improper use may void vehicle warranty
- User assumes all responsibility for modifications

## Advanced Features

### Adding New Manufacturers
1. Edit `data/manufacturers.json` to add manufacturer data
2. Add DTC codes to `data/dtc_codes.json`
3. Create manufacturer-specific module in `src/manufacturers/`
4. Update VIN decoder if needed

### Custom Procedures
1. Add procedures to manufacturer data
2. Define steps and requirements
3. Test thoroughly before use
4. Document any special requirements

### Protocol Support
- ISO9141-2 (older vehicles)
- ISO14230 (KWP2000)
- SAE J1850 (Ford, GM)
- CAN Bus (ISO15765)
- Custom manufacturer protocols

## Command Line Interface

For systems without GUI support:
```bash
python cli_test.py
```

This provides basic testing and verification of all components.

## Support and Updates

### Getting Help
- Check this documentation first
- Review troubleshooting section
- Check GitHub issues for known problems
- Create new issue for bugs or feature requests

### Contributing
- Fork the repository
- Add support for new manufacturers
- Submit pull requests with improvements
- Help with testing on different vehicles

### Updates
- Check for updates regularly
- New manufacturers and procedures added frequently
- Update DTC database as new codes discovered
- Protocol support expanded over time