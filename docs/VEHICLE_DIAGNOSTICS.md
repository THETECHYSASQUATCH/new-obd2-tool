# Vehicle-Specific Diagnostics Guide

This document explains how the vehicle-specific diagnostic system works and how to extend it.

## Overview

The vehicle database provides manufacturer-specific information including:
- Supported OBD protocols
- Custom manufacturer PIDs
- ECU programming capabilities  
- Specific DTC code interpretations

## Vehicle Database Structure

The vehicle database is stored in `assets/data/vehicle_database.json` and contains:

### Vehicle Information
- Make, Model, Year, Trim
- Engine and Transmission details
- Supported OBD protocols
- Manufacturer-specific PIDs

### Manufacturer Configurations
- Preferred diagnostic protocols
- Custom PID definitions
- DTC lookup tables
- ECU programming support details

## Currently Supported Manufacturers

### Toyota Motor Corporation
- **Models**: Camry, Prius
- **Protocols**: CAN, ISO9141-2
- **Custom PIDs**: Hybrid system monitoring
- **ECU Programming**: Supported with security access

### Ford Motor Company  
- **Models**: F-150
- **Protocols**: CAN, KWP2000
- **Custom PIDs**: EcoBoost specific parameters
- **ECU Programming**: Supported for PCM, TCM, BCM

### Honda Motor Co., Ltd.
- **Models**: Civic
- **Protocols**: CAN, ISO9141-2
- **Custom PIDs**: VTEC and CVT specific
- **ECU Programming**: Supported with adaptation

### BMW (Bayerische Motoren Werke AG)
- **Models**: 3 Series
- **Protocols**: CAN, KWP2000
- **Custom PIDs**: Advanced suspension and iDrive
- **ECU Programming**: Full coding and adaptation support

### Mercedes-Benz Group AG
- **Models**: C-Class
- **Protocols**: CAN
- **Custom PIDs**: Air suspension and COMAND
- **ECU Programming**: SCN and adaptation support

## Adding New Vehicles

1. Edit `assets/data/vehicle_database.json`
2. Add vehicle entry under appropriate manufacturer
3. Include manufacturer configuration if new
4. Test with actual vehicle for validation

## Protocol Selection

The system automatically selects the optimal protocol based on:
1. Vehicle-specific preferred protocols
2. Manufacturer default protocols  
3. Generic OBD-II fallback protocols

## Custom PIDs

Manufacturer-specific PIDs provide access to:
- Proprietary sensor data
- Advanced system status
- Performance metrics
- Diagnostic capabilities not available through standard OBD-II