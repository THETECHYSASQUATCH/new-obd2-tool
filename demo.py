#!/usr/bin/env python3
"""
Example usage of the OBD-II Tool API
Demonstrates basic usage without GUI
"""

import sys
import os
import time

# Add project root to path
project_root = os.path.dirname(__file__)
sys.path.insert(0, project_root)

from src.core.obd_interface import OBDInterface
from src.core.protocols import ProtocolManager
from src.diagnostics.error_codes import DTCManager, ErrorCodeDatabase
from src.diagnostics.live_data import LiveDataMonitor
from src.procedures.relearn import RelearnManager

def demonstrate_dtc_database():
    """Demonstrate DTC database functionality"""
    print("=== DTC Database Demo ===")
    
    # Create error database
    error_db = ErrorCodeDatabase()
    
    # Look up some common codes
    test_codes = ["P0301", "P0171", "P0420", "B0001"]
    
    for code in test_codes:
        dtc_info = error_db.get_dtc_info(code)
        if dtc_info:
            print(f"\nCode: {dtc_info.code}")
            print(f"Description: {dtc_info.description}")
            print(f"System: {dtc_info.system}")
            print(f"Severity: {dtc_info.severity}")
            print("Possible Causes:")
            for cause in dtc_info.possible_causes[:2]:  # Show first 2
                print(f"  • {cause}")
            print("Suggested Solutions:")
            for solution in dtc_info.suggested_solutions[:2]:  # Show first 2
                print(f"  • {solution}")
    
    # Search functionality
    print(f"\n--- Search Results for 'misfire' ---")
    search_results = error_db.search_dtc_by_description("misfire")
    for result in search_results[:3]:  # Show first 3
        print(f"  {result.code}: {result.description}")

def demonstrate_relearn_procedures():
    """Demonstrate relearn procedures"""
    print("\n=== Relearn Procedures Demo ===")
    
    # Create mock OBD interface for demo
    obd_interface = OBDInterface()
    relearn_mgr = RelearnManager(obd_interface)
    
    # List available procedures
    procedures = relearn_mgr.get_available_procedures()
    print(f"Available Procedures ({len(procedures)}):")
    for proc in procedures:
        print(f"  • {proc}")
    
    # Get details for throttle body relearn
    if "throttle_body_relearn" in procedures:
        proc_info = relearn_mgr.get_procedure_info("throttle_body_relearn")
        print(f"\n--- {proc_info.name} ---")
        print(f"Description: {proc_info.description}")
        print(f"Estimated Time: {proc_info.estimated_time} minutes")
        print(f"Difficulty: {proc_info.difficulty}")
        print(f"Steps: {len(proc_info.steps)}")
        
        print("\nVehicle Requirements:")
        for req in proc_info.vehicle_requirements:
            print(f"  • {req}")
        
        print("\nPreconditions:")
        for precond in proc_info.preconditions:
            print(f"  • {precond}")

def demonstrate_live_data_monitoring():
    """Demonstrate live data monitoring setup"""
    print("\n=== Live Data Monitoring Demo ===")
    
    # Create mock OBD interface
    obd_interface = OBDInterface()
    live_monitor = LiveDataMonitor(obd_interface)
    
    # Show PID definitions
    common_pids = ["0C", "0D", "05", "11", "0F", "10"]
    print("Common PID Definitions:")
    
    for pid in common_pids:
        pid_info = live_monitor.get_pid_info(pid)
        if pid_info:
            print(f"  {pid}: {pid_info.name} ({pid_info.unit})")
            print(f"      {pid_info.description}")

def demonstrate_ecu_programming():
    """Demonstrate ECU programming concepts"""
    print("\n=== ECU Programming Demo ===")
    
    from src.ecu.programming import ECUProgrammer
    
    # Create mock interfaces
    obd_interface = OBDInterface()
    protocol_mgr = ProtocolManager(obd_interface)
    ecu_programmer = ECUProgrammer(obd_interface, protocol_mgr)
    
    print("ECU Programming Capabilities:")
    print("  • ECU Scanning and Identification")
    print("  • Security Access Management")
    print("  • Memory Read/Write Operations")
    print("  • Firmware Backup and Flashing")
    print("  • Multiple ECU Support")
    
    print("\nDiagnostic Services Supported:")
    for service_id, description in list(ecu_programmer.diagnostic_services.items())[:5]:
        print(f"  0x{service_id:02X}: {description}")

def main():
    """Main demonstration function"""
    print("OBD-II Diagnostics and Programming Tool")
    print("=" * 50)
    print("This demonstration shows the capabilities of the tool")
    print("without requiring actual OBD hardware.\n")
    
    try:
        demonstrate_dtc_database()
        demonstrate_relearn_procedures()
        demonstrate_live_data_monitoring()
        demonstrate_ecu_programming()
        
        print("\n" + "=" * 50)
        print("Demo completed successfully!")
        print("\nTo use with real hardware:")
        print("1. Connect OBD-II adapter to vehicle")
        print("2. Run: python main.py")
        print("3. Select COM port and connect")
        print("4. Use the GUI to perform diagnostics")
        
    except Exception as e:
        print(f"Demo error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())