"""
Diagnostics Module for OBD-II Tool
Handles diagnostic functions for all vehicle modules
"""

import json
import os
from typing import Dict, List, Optional, Tuple

# Try to import OBD library, handle gracefully if not available
try:
    import obd
    OBD_AVAILABLE = True
except ImportError:
    OBD_AVAILABLE = False
    # Create mock obd module for testing
    class MockCommands:
        GET_DTC = "mock_get_dtc"
        CLEAR_DTC = "mock_clear_dtc"
        RPM = "mock_rpm"
        SPEED = "mock_speed"
        THROTTLE_POS = "mock_throttle"
        ENGINE_LOAD = "mock_load"
        COOLANT_TEMP = "mock_temp"
        FUEL_LEVEL = "mock_fuel"
        INTAKE_TEMP = "mock_intake"
        MAF = "mock_maf"
        FUEL_PRESSURE = "mock_pressure"
        TIMING_ADVANCE = "mock_timing"
        FREEZE_DTC = "mock_freeze"
        STATUS = "mock_status"
    
    obd = type('MockOBD', (), {
        'commands': MockCommands()
    })()


class DiagnosticsEngine:
    """Handles diagnostic operations for vehicle modules"""
    
    def __init__(self):
        self.dtc_data = self._load_dtc_data()
        self.manufacturer_data = self._load_manufacturer_data()
        
    def _load_dtc_data(self) -> Dict:
        """Load DTC code data from JSON file"""
        data_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'dtc_codes.json')
        try:
            with open(data_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"generic_codes": {}, "manufacturer_specific": {}}
    
    def _load_manufacturer_data(self) -> Dict:
        """Load manufacturer-specific data from JSON file"""
        data_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'manufacturers.json')
        try:
            with open(data_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"manufacturers": {}}
    
    def read_diagnostic_codes(self, connection, manufacturer: str = None) -> List[Dict]:
        """
        Read diagnostic trouble codes from vehicle
        
        Args:
            connection: OBD connection object
            manufacturer: Vehicle manufacturer for specific decoding
            
        Returns:
            List of dictionaries containing DTC information
        """
        dtc_list = []
        
        try:
            if not connection or not connection.is_connected():
                return []
            
            # Read DTCs using OBD command
            response = connection.query(obd.commands.GET_DTC)
            
            if response.is_null():
                return []
            
            for dtc_tuple in response.value:
                dtc_code = dtc_tuple[0]
                dtc_info = self._decode_dtc(dtc_code, manufacturer)
                dtc_info["status"] = dtc_tuple[1] if len(dtc_tuple) > 1 else "Active"
                dtc_list.append(dtc_info)
            
            return dtc_list
            
        except Exception as e:
            print(f"Error reading DTCs: {e}")
            return []
    
    def _decode_dtc(self, dtc_code: str, manufacturer: str = None) -> Dict:
        """
        Decode DTC code to get description and system information
        
        Args:
            dtc_code: Diagnostic Trouble Code
            manufacturer: Vehicle manufacturer for specific decoding
            
        Returns:
            Dictionary with DTC information
        """
        dtc_info = {
            "code": dtc_code,
            "description": "Unknown Code",
            "system": "Unknown",
            "manufacturer_specific": False
        }
        
        # Check generic codes first
        generic_codes = self.dtc_data.get("generic_codes", {})
        if dtc_code in generic_codes:
            code_data = generic_codes[dtc_code]
            dtc_info["description"] = code_data.get("description", "Unknown Code")
            dtc_info["system"] = code_data.get("system", "Unknown")
            return dtc_info
        
        # Check manufacturer-specific codes
        if manufacturer:
            mfg_codes = self.dtc_data.get("manufacturer_specific", {}).get(manufacturer, {})
            if dtc_code in mfg_codes:
                code_data = mfg_codes[dtc_code]
                dtc_info["description"] = code_data.get("description", "Unknown Code")
                dtc_info["system"] = code_data.get("system", "Unknown")
                dtc_info["manufacturer_specific"] = True
        
        return dtc_info
    
    def clear_diagnostic_codes(self, connection) -> bool:
        """
        Clear diagnostic trouble codes from vehicle
        
        Args:
            connection: OBD connection object
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if not connection or not connection.is_connected():
                return False
            
            response = connection.query(obd.commands.CLEAR_DTC)
            return not response.is_null()
            
        except Exception as e:
            print(f"Error clearing DTCs: {e}")
            return False
    
    def read_live_data(self, connection, pids: List[str] = None) -> Dict:
        """
        Read live data from vehicle
        
        Args:
            connection: OBD connection object
            pids: List of PIDs to read (if None, read common ones)
            
        Returns:
            Dictionary with live data values
        """
        live_data = {}
        
        if not connection or not connection.is_connected():
            return live_data
        
        # Default PIDs if none specified
        if pids is None:
            common_pids = [
                "RPM", "SPEED", "THROTTLE_POS", "ENGINE_LOAD",
                "COOLANT_TEMP", "FUEL_LEVEL", "INTAKE_TEMP",
                "MAF", "FUEL_PRESSURE", "TIMING_ADVANCE"
            ]
        else:
            common_pids = pids
        
        for pid in common_pids:
            try:
                if hasattr(obd.commands, pid):
                    cmd = getattr(obd.commands, pid)
                    response = connection.query(cmd)
                    if not response.is_null():
                        live_data[pid] = {
                            "value": response.value,
                            "unit": str(response.unit) if response.unit else "",
                            "time": response.time
                        }
            except Exception as e:
                print(f"Error reading PID {pid}: {e}")
        
        return live_data
    
    def read_freeze_frame_data(self, connection) -> Dict:
        """
        Read freeze frame data from vehicle
        
        Args:
            connection: OBD connection object
            
        Returns:
            Dictionary with freeze frame data
        """
        freeze_data = {}
        
        try:
            if not connection or not connection.is_connected():
                return freeze_data
            
            response = connection.query(obd.commands.FREEZE_DTC)
            if not response.is_null():
                freeze_data["freeze_frame"] = response.value
            
            return freeze_data
            
        except Exception as e:
            print(f"Error reading freeze frame data: {e}")
            return freeze_data
    
    def get_readiness_tests(self, connection) -> Dict:
        """
        Get readiness test status
        
        Args:
            connection: OBD connection object
            
        Returns:
            Dictionary with readiness test results
        """
        readiness = {}
        
        try:
            if not connection or not connection.is_connected():
                return readiness
            
            response = connection.query(obd.commands.STATUS)
            if not response.is_null():
                status = response.value
                readiness["mil_on"] = status.MIL
                readiness["dtc_count"] = status.DTC_count
                
                # Individual test results
                tests = [
                    "MISFIRE_MONITORING", "FUEL_SYSTEM_MONITORING",
                    "COMPONENT_MONITORING", "CATALYST_MONITORING",
                    "HEATED_CATALYST_MONITORING", "EVAPORATIVE_SYSTEM_MONITORING",
                    "SECONDARY_AIR_SYSTEM_MONITORING", "OXYGEN_SENSOR_MONITORING",
                    "OXYGEN_SENSOR_HEATER_MONITORING", "EGR_SYSTEM_MONITORING"
                ]
                
                for test in tests:
                    if hasattr(status, test):
                        readiness[test] = getattr(status, test)
            
            return readiness
            
        except Exception as e:
            print(f"Error reading readiness tests: {e}")
            return readiness
    
    def perform_module_diagnosis(self, connection, module: str, manufacturer: str = None) -> Dict:
        """
        Perform diagnosis on specific vehicle module
        
        Args:
            connection: OBD connection object
            module: Module name (ECM, TCM, ABS, etc.)
            manufacturer: Vehicle manufacturer
            
        Returns:
            Dictionary with module diagnosis results
        """
        results = {
            "module": module,
            "status": "Unknown",
            "dtcs": [],
            "live_data": {},
            "manufacturer_specific": {}
        }
        
        try:
            # Get manufacturer-specific module information
            if manufacturer:
                mfg_data = self.manufacturer_data.get("manufacturers", {}).get(manufacturer, {})
                supported_modules = mfg_data.get("modules", [])
                
                if module not in supported_modules:
                    results["status"] = "Not Supported"
                    return results
                
                # Add manufacturer-specific commands if available
                specific_commands = mfg_data.get("specific_commands", {})
                results["manufacturer_specific"] = specific_commands
            
            # Read DTCs for this module (simplified - in reality would use module-specific commands)
            dtcs = self.read_diagnostic_codes(connection, manufacturer)
            results["dtcs"] = [dtc for dtc in dtcs if self._is_module_related(dtc, module)]
            
            # Read relevant live data
            module_pids = self._get_module_pids(module)
            results["live_data"] = self.read_live_data(connection, module_pids)
            
            results["status"] = "Diagnosed"
            
        except Exception as e:
            print(f"Error diagnosing module {module}: {e}")
            results["status"] = "Error"
        
        return results
    
    def _is_module_related(self, dtc: Dict, module: str) -> bool:
        """Check if DTC is related to specific module"""
        # Simplified mapping - in reality would be more sophisticated
        module_mappings = {
            "ECM": ["Engine", "Powertrain"],
            "TCM": ["Transmission"],
            "ABS": ["Brake", "Chassis"],
            "SRS": ["Airbag", "Safety"],
            "BCM": ["Body", "Electrical"]
        }
        
        related_systems = module_mappings.get(module, [])
        dtc_system = dtc.get("system", "")
        
        return any(system.lower() in dtc_system.lower() for system in related_systems)
    
    def _get_module_pids(self, module: str) -> List[str]:
        """Get relevant PIDs for specific module"""
        module_pids = {
            "ECM": ["RPM", "ENGINE_LOAD", "COOLANT_TEMP", "THROTTLE_POS", "MAF"],
            "TCM": ["SPEED", "THROTTLE_POS", "ENGINE_LOAD"],
            "ABS": ["SPEED"],
            "SRS": [],  # Usually no live PIDs for SRS
            "BCM": ["FUEL_LEVEL"]
        }
        
        return module_pids.get(module, [])