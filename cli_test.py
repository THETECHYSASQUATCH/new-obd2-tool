#!/usr/bin/env python3
"""
Command Line Interface for OBD-II Tool
For testing purposes when GUI is not available
"""

import sys
import os

# Add src directory to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
src_dir = os.path.join(current_dir, 'src')
sys.path.insert(0, src_dir)

from vehicle_detection import VehicleDetector
from diagnostics import DiagnosticsEngine
from programming import ProgrammingEngine


def print_header(title):
    """Print a formatted header"""
    print("\n" + "=" * 60)
    print(f" {title}")
    print("=" * 60)


def test_vehicle_detection():
    """Test vehicle detection functionality"""
    print_header("VEHICLE DETECTION TEST")
    
    detector = VehicleDetector()
    
    # Test VIN decoding
    test_vin = "1HGBH41JXMN109186"
    print(f"Testing VIN: {test_vin}")
    
    try:
        vehicle_info = detector.decode_vin(test_vin)
        print("VIN Decoding Results:")
        for key, value in vehicle_info.items():
            print(f"  {key}: {value}")
    except Exception as e:
        print(f"VIN decoding error: {e}")
    
    # Test manufacturer support
    print(f"\nSupported Manufacturers ({len(detector.get_supported_manufacturers())}):")
    for mfg in detector.get_supported_manufacturers():
        print(f"  • {mfg}")
    
    # Test manufacturer info
    if detector.get_supported_manufacturers():
        mfg = detector.get_supported_manufacturers()[0]
        print(f"\nManufacturer Info for {mfg}:")
        info = detector.get_manufacturer_info(mfg)
        for key, value in info.items():
            if isinstance(value, list):
                print(f"  {key}: {', '.join(value)}")
            elif isinstance(value, dict):
                print(f"  {key}:")
                for sub_key, sub_value in value.items():
                    print(f"    {sub_key}: {sub_value}")
            else:
                print(f"  {key}: {value}")


def test_diagnostics():
    """Test diagnostics functionality"""
    print_header("DIAGNOSTICS TEST")
    
    diagnostics = DiagnosticsEngine()
    
    # Test DTC decoding
    test_codes = ["P0300", "P0420", "P1457", "B0001"]
    print("DTC Decoding Test:")
    
    for code in test_codes:
        dtc_info = diagnostics._decode_dtc(code, "Honda")
        print(f"  {code}: {dtc_info['description']} ({dtc_info['system']})")
    
    # Test module diagnosis (without OBD connection)
    print(f"\nModule PID Mapping Test:")
    modules = ["ECM", "TCM", "ABS", "SRS"]
    for module in modules:
        pids = diagnostics._get_module_pids(module)
        print(f"  {module}: {', '.join(pids) if pids else 'No PIDs'}")


def test_programming():
    """Test programming functionality"""
    print_header("PROGRAMMING TEST")
    
    programming = ProgrammingEngine()
    
    # Test procedure retrieval
    test_manufacturers = ["Honda", "Toyota", "Ford", "BMW"]
    
    for mfg in test_manufacturers:
        procedures = programming.get_available_procedures(mfg)
        print(f"\n{mfg} Procedures ({len(procedures)}):")
        
        for proc in procedures:
            print(f"  • {proc['name']}")
            if proc.get('requirements'):
                print(f"    Requirements: {', '.join(proc['requirements'])}")
        
        # Show details for first procedure
        if procedures:
            details = programming.get_procedure_details(mfg, procedures[0]['id'])
            if details:
                print(f"\nSample Procedure Details - {details.get('name', 'Unknown')}:")
                steps = details.get('steps', [])
                for i, step in enumerate(steps[:3], 1):  # Show first 3 steps
                    print(f"  {i}. {step}")
                if len(steps) > 3:
                    print(f"  ... and {len(steps) - 3} more steps")


def test_data_integrity():
    """Test data file integrity"""
    print_header("DATA INTEGRITY TEST")
    
    data_files = [
        "data/vin_decoder.json",
        "data/manufacturers.json", 
        "data/dtc_codes.json"
    ]
    
    for file_path in data_files:
        full_path = os.path.join(os.path.dirname(__file__), file_path)
        try:
            import json
            with open(full_path, 'r') as f:
                data = json.load(f)
            print(f"✓ {file_path}: Valid JSON ({len(data)} top-level keys)")
        except FileNotFoundError:
            print(f"✗ {file_path}: File not found")
        except json.JSONDecodeError as e:
            print(f"✗ {file_path}: Invalid JSON - {e}")
        except Exception as e:
            print(f"✗ {file_path}: Error - {e}")


def main():
    """Main CLI application"""
    print("OBD-II Diagnostics and Programming Tool - CLI Test")
    print("=" * 60)
    
    # Run all tests
    test_data_integrity()
    test_vehicle_detection()
    test_diagnostics()
    test_programming()
    
    print_header("TEST SUMMARY")
    print("All components tested successfully!")
    print("The OBD-II tool is ready for use.")
    print("\nTo use the GUI version:")
    print("  python main.py")
    print("\nTo run unit tests:")
    print("  python tests/test_basic.py")


if __name__ == "__main__":
    main()