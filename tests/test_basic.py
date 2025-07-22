#!/usr/bin/env python3
"""
Basic functionality test for OBD-II tool
"""

import sys
import os

# Add project root to path
project_root = os.path.dirname(os.path.dirname(__file__))
sys.path.insert(0, project_root)

def test_imports():
    """Test that all modules can be imported"""
    print("Testing module imports...")
    
    try:
        from src.core.obd_interface import OBDInterface
        print("✓ OBDInterface imported successfully")
        
        from src.core.protocols import ProtocolManager
        print("✓ ProtocolManager imported successfully")
        
        from src.diagnostics.error_codes import DTCManager, ErrorCodeDatabase
        print("✓ DTCManager and ErrorCodeDatabase imported successfully")
        
        from src.diagnostics.live_data import LiveDataMonitor
        print("✓ LiveDataMonitor imported successfully")
        
        from src.ecu.programming import ECUProgrammer
        print("✓ ECUProgrammer imported successfully")
        
        from src.procedures.relearn import RelearnManager
        print("✓ RelearnManager imported successfully")
        
        from src.utils.config import ConfigManager
        print("✓ ConfigManager imported successfully")
        
        from src.utils.logger import setup_logging
        print("✓ Logger utilities imported successfully")
        
        return True
        
    except ImportError as e:
        print(f"✗ Import failed: {e}")
        return False

def test_core_functionality():
    """Test core functionality without hardware"""
    print("\nTesting core functionality...")
    
    try:
        # Test OBD Interface initialization
        from src.core.obd_interface import OBDInterface
        obd = OBDInterface()
        print("✓ OBDInterface initialization successful")
        
        # Test Protocol Manager
        from src.core.protocols import ProtocolManager
        protocol_mgr = ProtocolManager(obd)
        print("✓ ProtocolManager initialization successful")
        
        # Test DTC Manager
        from src.diagnostics.error_codes import DTCManager
        dtc_mgr = DTCManager(obd)
        print("✓ DTCManager initialization successful")
        
        # Test Error Database
        from src.diagnostics.error_codes import ErrorCodeDatabase
        error_db = ErrorCodeDatabase()
        
        # Test getting DTC info
        dtc_info = error_db.get_dtc_info("P0301")
        if dtc_info and dtc_info.code == "P0301":
            print("✓ Error database lookup successful")
        else:
            print("✗ Error database lookup failed")
            return False
        
        # Test Live Data Monitor
        from src.diagnostics.live_data import LiveDataMonitor
        live_monitor = LiveDataMonitor(obd)
        print("✓ LiveDataMonitor initialization successful")
        
        # Test ECU Programmer
        from src.ecu.programming import ECUProgrammer
        ecu_prog = ECUProgrammer(obd, protocol_mgr)
        print("✓ ECUProgrammer initialization successful")
        
        # Test Relearn Manager
        from src.procedures.relearn import RelearnManager
        relearn_mgr = RelearnManager(obd, ecu_prog)
        
        # Test procedure list
        procedures = relearn_mgr.get_available_procedures()
        if len(procedures) > 0:
            print(f"✓ RelearnManager loaded {len(procedures)} procedures")
        else:
            print("✗ RelearnManager failed to load procedures")
            return False
        
        # Test Configuration
        from src.utils.config import ConfigManager
        config = ConfigManager("test_config.json")
        
        # Test config operations
        config.set("test.value", "test123")
        if config.get("test.value") == "test123":
            print("✓ Configuration management successful")
        else:
            print("✗ Configuration management failed")
            return False
        
        return True
        
    except Exception as e:
        print(f"✗ Core functionality test failed: {e}")
        return False

def test_dtc_database():
    """Test DTC database functionality"""
    print("\nTesting DTC database...")
    
    try:
        from src.diagnostics.error_codes import ErrorCodeDatabase
        error_db = ErrorCodeDatabase()
        
        # Test known DTC codes
        test_codes = ["P0301", "P0171", "P0420", "B0001", "C0121", "U0100"]
        
        for code in test_codes:
            dtc_info = error_db.get_dtc_info(code)
            if dtc_info:
                print(f"✓ {code}: {dtc_info.description}")
            else:
                print(f"✗ {code}: Not found in database")
        
        # Test search functionality
        search_results = error_db.search_dtc_by_description("misfire")
        if len(search_results) > 0:
            print(f"✓ Search found {len(search_results)} misfire-related codes")
        else:
            print("✗ Search functionality failed")
            return False
        
        return True
        
    except Exception as e:
        print(f"✗ DTC database test failed: {e}")
        return False

def test_relearn_procedures():
    """Test relearn procedures"""
    print("\nTesting relearn procedures...")
    
    try:
        from src.procedures.relearn import RelearnManager
        from src.core.obd_interface import OBDInterface
        
        obd = OBDInterface()
        relearn_mgr = RelearnManager(obd)
        
        # Test procedure listing
        procedures = relearn_mgr.get_available_procedures()
        print(f"✓ Found {len(procedures)} available procedures:")
        for proc in procedures:
            print(f"  - {proc}")
        
        # Test procedure info
        if "throttle_body_relearn" in procedures:
            proc_info = relearn_mgr.get_procedure_info("throttle_body_relearn")
            if proc_info:
                print(f"✓ Throttle body relearn: {proc_info.estimated_time} minutes, {len(proc_info.steps)} steps")
            else:
                print("✗ Failed to get procedure info")
                return False
        
        return True
        
    except Exception as e:
        print(f"✗ Relearn procedures test failed: {e}")
        return False

def test_gui_imports():
    """Test GUI imports (without creating windows)"""
    print("\nTesting GUI imports...")
    
    try:
        import tkinter as tk
        print("✓ tkinter available")
        
        # Test our GUI module imports
        from src.gui.main_window import MainWindow
        print("✓ MainWindow class imported successfully")
        
        return True
        
    except ImportError as e:
        print(f"✗ GUI import failed: {e}")
        print("  Note: GUI functionality requires tkinter")
        return False

def main():
    """Run all tests"""
    print("OBD-II Tool Functionality Tests")
    print("=" * 40)
    
    tests = [
        ("Module Imports", test_imports),
        ("Core Functionality", test_core_functionality),
        ("DTC Database", test_dtc_database),
        ("Relearn Procedures", test_relearn_procedures),
        ("GUI Imports", test_gui_imports),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{test_name}:")
        print("-" * len(test_name))
        if test_func():
            passed += 1
            print(f"✓ {test_name} PASSED")
        else:
            print(f"✗ {test_name} FAILED")
    
    print("\n" + "=" * 40)
    print(f"Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("✓ All tests passed!")
        return 0
    else:
        print("✗ Some tests failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())