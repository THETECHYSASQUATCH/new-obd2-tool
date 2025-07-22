"""
Vehicle Detection Module for OBD-II Tool
Handles automatic vehicle detection using VIN decoding and OBD communication
"""

import json
import os
from typing import Dict, Optional, Tuple

# Try to import OBD library, handle gracefully if not available
try:
    import obd
    OBD_AVAILABLE = True
except ImportError:
    OBD_AVAILABLE = False
    # Create mock obd module for testing
    class MockOBD:
        def __init__(self):
            self.connected = False
        def is_connected(self):
            return self.connected
        def protocol_name(self):
            return "Mock Protocol"
        def query(self, cmd):
            class MockResponse:
                def __init__(self):
                    self.value = "Mock VIN"
                def is_null(self):
                    return False
            return MockResponse()
    
    class MockCommands:
        VIN = "mock_vin_command"
    
    obd = type('MockOBD', (), {
        'OBD': MockOBD,
        'commands': MockCommands()
    })()


class VehicleDetector:
    """Handles automatic vehicle detection and VIN decoding"""
    
    def __init__(self):
        self.vin_data = self._load_vin_data()
        self.manufacturer_data = self._load_manufacturer_data()
        
    def _load_vin_data(self) -> Dict:
        """Load VIN decoding data from JSON file"""
        data_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'vin_decoder.json')
        try:
            with open(data_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"wmi_codes": {}, "year_codes": {}}
    
    def _load_manufacturer_data(self) -> Dict:
        """Load manufacturer-specific data from JSON file"""
        data_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'manufacturers.json')
        try:
            with open(data_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"manufacturers": {}}
    
    def decode_vin(self, vin: str) -> Dict[str, str]:
        """
        Decode VIN to extract vehicle information
        
        Args:
            vin: 17-character Vehicle Identification Number
            
        Returns:
            Dictionary containing decoded vehicle information
        """
        if len(vin) != 17:
            raise ValueError("VIN must be exactly 17 characters")
        
        result = {
            "vin": vin,
            "wmi": vin[:3],  # World Manufacturer Identifier
            "vds": vin[3:9],  # Vehicle Descriptor Section
            "vis": vin[9:],   # Vehicle Identifier Section
            "manufacturer": "Unknown",
            "region": "Unknown",
            "year": "Unknown"
        }
        
        # Decode manufacturer from WMI
        wmi = vin[:3]
        if wmi in self.vin_data.get("wmi_codes", {}):
            wmi_info = self.vin_data["wmi_codes"][wmi]
            result["manufacturer"] = wmi_info.get("manufacturer", "Unknown")
            result["region"] = wmi_info.get("region", "Unknown")
        
        # Decode year from 10th character
        year_char = vin[9]
        if year_char in self.vin_data.get("year_codes", {}):
            result["year"] = str(self.vin_data["year_codes"][year_char])
        
        return result
    
    def auto_detect_vehicle(self, connection=None) -> Optional[Dict]:
        """
        Automatically detect vehicle using OBD connection
        
        Args:
            connection: OBD connection object (optional)
            
        Returns:
            Dictionary with vehicle information if successful, None otherwise
        """
        try:
            # If no connection provided, try to establish one
            if connection is None:
                connection = obd.OBD()
            
            if not connection.is_connected():
                return None
            
            # Try to get VIN from OBD
            vin_cmd = obd.commands.VIN
            response = connection.query(vin_cmd)
            
            if response.is_null():
                return None
            
            vin = str(response.value)
            vehicle_info = self.decode_vin(vin)
            
            # Add OBD protocol information
            vehicle_info["obd_protocol"] = str(connection.protocol_name())
            vehicle_info["connection_status"] = "Connected"
            
            # Get supported protocols for this manufacturer
            manufacturer = vehicle_info["manufacturer"]
            if manufacturer in self.manufacturer_data.get("manufacturers", {}):
                mfg_data = self.manufacturer_data["manufacturers"][manufacturer]
                vehicle_info["supported_protocols"] = mfg_data.get("supported_protocols", [])
                vehicle_info["supported_modules"] = mfg_data.get("modules", [])
            
            return vehicle_info
            
        except Exception as e:
            print(f"Error during auto-detection: {e}")
            return None
    
    def get_manufacturer_info(self, manufacturer: str) -> Dict:
        """
        Get manufacturer-specific information
        
        Args:
            manufacturer: Manufacturer name
            
        Returns:
            Dictionary with manufacturer information
        """
        manufacturers = self.manufacturer_data.get("manufacturers", {})
        return manufacturers.get(manufacturer, {})
    
    def get_supported_manufacturers(self) -> list:
        """Get list of all supported manufacturers"""
        return list(self.manufacturer_data.get("manufacturers", {}).keys())
    
    def validate_vin(self, vin: str) -> bool:
        """
        Validate VIN format and check digit
        
        Args:
            vin: Vehicle Identification Number
            
        Returns:
            True if VIN is valid, False otherwise
        """
        if len(vin) != 17:
            return False
        
        # Check for invalid characters
        invalid_chars = ['I', 'O', 'Q']
        if any(char in vin.upper() for char in invalid_chars):
            return False
        
        # VIN check digit validation (simplified)
        weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
        values = {
            'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
            'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9, 'S': 2,
            'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9
        }
        
        try:
            total = 0
            for i, char in enumerate(vin.upper()):
                if char.isdigit():
                    total += int(char) * weights[i]
                elif char in values:
                    total += values[char] * weights[i]
            
            check_digit = total % 11
            if check_digit == 10:
                check_digit = 'X'
            else:
                check_digit = str(check_digit)
            
            return vin[8] == check_digit
        except:
            return False