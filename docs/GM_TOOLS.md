# GM Vehicle Tools Documentation

## Overview

The GM Tools module provides comprehensive diagnostic and service capabilities for General Motors vehicles, including Chevrolet, Cadillac, GMC, and Buick brands. This module delivers brand-specific functionality while maintaining compatibility with the existing OBD-II framework.

## Supported Brands

- **Chevrolet**: Performance and truck-focused features
- **Cadillac**: Luxury and technology-focused features
- **GMC**: Professional-grade and off-road features
- **Buick**: Comfort and reliability-focused features

## Features

### GM Live Data

#### Common GM Features
- **AFM Cylinder Deactivation**: Active Fuel Management system status
- **Transmission Adaptive Pressure**: Real-time adaptive pressure values
- **DFM Dynamic Fuel Management**: Advanced cylinder deactivation technology
- **4WD Transfer Case Status**: Four-wheel drive system mode and operation

#### Brand-Specific Features

##### Chevrolet
- **Z51 Performance Package Data**: Track-focused performance metrics
- **Performance Traction Management**: PTM system status
- **Magnetic Ride Control**: Suspension damping control

##### Cadillac
- **Super Cruise Status**: Hands-free driving system status
- **Air Suspension Height**: Pneumatic suspension position
- **Supercharger Boost Pressure**: Performance engine boost monitoring
- **Launch Control Status**: Track mode launch system
- **Track Mode Data**: Comprehensive performance data

##### GMC
- **Carbon Fiber Bed Data**: Smart bed load monitoring
- **MultiPro Tailgate Status**: Advanced tailgate position and configuration
- **AT4 Off-Road Mode Data**: Off-road driving mode status

### GM Service Tools

#### Common Tools

##### ECM Health Check
- Engine Control Module diagnostics
- AFM lifter health monitoring
- System voltage and temperature
- Diagnostic trouble code analysis

##### Transmission Relearn
- Adaptive value reset and relearning
- Shift quality optimization
- Pressure adaptation calibration
- Learning progress monitoring

##### BCM Configuration
- Body Control Module settings
- Lighting and convenience features
- Remote start configuration
- Keyless entry settings

##### OnStar Activation
- Cellular connectivity verification
- Emergency services availability
- Signal strength monitoring
- Service activation status

##### Key Learning
- New key programming
- Security code management
- Remote function configuration
- Immobilizer setup

#### Brand-Specific Tools

##### Chevrolet Tools
- **AFM Disable**: Permanent Active Fuel Management deactivation
- **DFM Calibration**: Dynamic Fuel Management optimization
- **Performance Mode Setup**: Track and sport mode configuration
- **Towing Package Configuration**: Trailer towing optimization

##### Cadillac Tools
- **Super Cruise Update**: Map data and software updates
- **Magnetic Ride Calibration**: Suspension system optimization
- **CUE System Configuration**: Infotainment system setup
- **Night Vision Setup**: Enhanced vision system calibration

##### GMC Tools
- **MultiPro Tailgate Service**: Tailgate system calibration
- **AT4 Off-Road Calibration**: Off-road mode optimization
- **ProGrade Trailering Setup**: Advanced towing configuration
- **Terrain Mode Configuration**: Drive mode system setup

### GM Programming Tools

#### Security Access
- GM-specific seed/key algorithm
- Multi-level security implementation
- Module-specific access procedures
- Timeout and retry management

#### Flash Programming
- Multi-ECU support (ECM, TCM, BCM, SDM, EBCM, RCDLR)
- Comprehensive progress monitoring
- Automatic backup and recovery
- Safety validation procedures

#### VIN Writing
- Vehicle Identification Number programming
- Legal compliance verification
- Audit trail maintenance
- Security validation

#### Calibration Management
- Parameter optimization
- Performance tuning
- Emissions compliance
- Regional variations

## Technical Implementation

### Service Architecture
```dart
GMService
├── Brand Detection & Configuration
├── Live Data Collection (Brand-Specific)
├── Service Tool Operations
├── Programming Functions
└── Security Management
```

### Supported ECU Types
- **ECM** (Engine Control Module)
- **TCM** (Transmission Control Module)
- **BCM** (Body Control Module)
- **SDM** (Sensing and Diagnostic Module)
- **EBCM** (Electronic Brake Control Module)
- **RCDLR** (Remote Control Door Lock Receiver)

### GM-Specific PIDs

#### Common PIDs
| PID | Description | Unit | Brands |
|-----|-------------|------|--------|
| GM01 | AFM Cylinder Deactivation Status | Boolean | Chevrolet, GMC |
| GM02 | Transmission Adaptive Pressure | PSI | All |
| GM03 | DFM Dynamic Fuel Management | Complex | Chevrolet, GMC |
| GM06 | 4WD Transfer Case Status | Mode | Chevrolet, GMC |
| GM07 | Trailer Brake Controller | Complex | Chevrolet, GMC |

#### Cadillac-Specific PIDs
| PID | Description | Unit |
|-----|-------------|------|
| GM08 | Super Cruise Status | Complex |
| GM09 | Magnetic Ride Control | Complex |
| GM10 | Air Suspension Height | Inches |
| GM11 | Supercharger Boost Pressure | PSI |
| GM12 | Launch Control Status | Boolean |
| GM13 | Track Mode Data | Complex |

#### GMC-Specific PIDs
| PID | Description | Unit |
|-----|-------------|------|
| GM14 | Carbon Fiber Bed Data | Complex |
| GM15 | MultiPro Tailgate Status | Complex |
| GM16 | AT4 Off-Road Mode Data | Complex |

## Usage Examples

### Initialize GM Service
```dart
final gmService = GMService(obdService);
final vehicle = VehicleInfo(
  make: 'Chevrolet',
  model: 'Silverado 1500',
  year: 2023,
);
gmService.initialize(vehicle);
```

### Get Brand-Specific Live Data
```dart
final liveData = await gmService.getGMLiveData();
final afmStatus = liveData['AFM Cylinder Deactivation Status'];
final superCruiseData = liveData['Super Cruise Status'];
```

### Run Brand-Specific Service Tool
```dart
// Chevrolet AFM disable
final result = await gmService.runGMServiceTool(
  'afm_disable',
  {},
);

// Cadillac Super Cruise update
final updateResult = await gmService.runGMServiceTool(
  'super_cruise_update',
  {},
);
```

### Perform GM Programming
```dart
final success = await gmService.performGMProgramming(
  ecuType: 'ECM',
  operation: 'calibration',
  parameters: {
    'calibration_file': 'path/to/cal.hex',
    'vin_validation': true,
  },
);
```

## Brand-Specific Features

### Chevrolet Features
- **Active Fuel Management (AFM)**: Cylinder deactivation for fuel economy
- **Dynamic Fuel Management (DFM)**: Advanced variable cylinder operation
- **Performance Packages**: Z51, ZR1, and other performance configurations
- **Towing Packages**: Advanced trailer towing capabilities

### Cadillac Features
- **Super Cruise**: Hands-free highway driving technology
- **Magnetic Ride Control**: Real-time suspension adjustment
- **Night Vision**: Enhanced driver visibility system
- **CUE Infotainment**: Advanced multimedia and connectivity

### GMC Features
- **MultiPro Tailgate**: Six-function tailgate system
- **AT4 Off-Road**: Advanced off-road driving capabilities
- **ProGrade Trailering**: Professional-grade towing features
- **Carbon Fiber Bed**: Advanced load monitoring and protection

## Error Handling

### Brand-Specific Error Handling
- **AFM/DFM Errors**: Specialized handling for fuel management issues
- **Super Cruise Errors**: Map data and sensor validation
- **MultiPro Errors**: Mechanical and electrical system diagnostics
- **Security Errors**: Brand-specific security protocol handling

### Recovery Procedures
- **Automatic Rollback**: Failed programming operation recovery
- **Service Mode**: Safe mode operation during diagnostics
- **Backup Validation**: Integrity checking for backup files
- **Error Reporting**: Comprehensive error logging and reporting

## Best Practices

1. **Brand Recognition**: Ensure correct brand detection before service operations
2. **Feature Validation**: Verify vehicle-specific feature availability
3. **Security Compliance**: Follow GM security protocols strictly
4. **Data Backup**: Always backup before programming operations
5. **Progressive Enhancement**: Use fallback modes for unsupported features

## Integration

The GM Tools module integrates with:
- Main OBD-II communication framework
- Vehicle database with GM-specific configurations
- Brand-specific feature detection
- Cloud sync for brand-specific data
- User interface with brand-aware navigation

## Future Enhancements

- Additional GM brand support (Buick specific features)
- Enhanced hybrid and electric vehicle support
- Advanced OnStar integration
- OTA (Over-The-Air) update capabilities
- Mobile app connectivity features
- Advanced telemetry and remote diagnostics

## Troubleshooting

### Common Issues

1. **Brand Detection Failure**
   - Verify VIN or manual brand selection
   - Check vehicle database update

2. **AFM/DFM Communication Errors**
   - Ensure compatible ECM version
   - Verify security access completion

3. **Super Cruise Availability**
   - Check map data currency
   - Verify sensor calibration

4. **Programming Failures**
   - Ensure stable power supply
   - Verify compatible calibration files
   - Check security access status