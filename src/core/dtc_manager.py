"""
DTC (Diagnostic Trouble Code) Manager
"""

import logging
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime

logger = logging.getLogger(__name__)


@dataclass
class DTC:
    """Represents a Diagnostic Trouble Code"""
    code: str
    description: str
    status: str
    detected_time: Optional[datetime] = None
    freeze_frame_data: Optional[Dict] = None


class DTCManager:
    """Manages Diagnostic Trouble Codes"""
    
    # DTC prefixes based on first character
    DTC_PREFIXES = {
        'P': 'Powertrain',
        'B': 'Body',
        'C': 'Chassis', 
        'U': 'Network'
    }
    
    # Common DTC codes and descriptions
    COMMON_DTCS = {
        'P0000': 'No DTCs detected',
        'P0100': 'Mass or Volume Air Flow Circuit Malfunction',
        'P0101': 'Mass or Volume Air Flow Circuit Range/Performance Problem',
        'P0102': 'Mass or Volume Air Flow Circuit Low Input',
        'P0103': 'Mass or Volume Air Flow Circuit High Input',
        'P0104': 'Mass or Volume Air Flow Circuit Intermittent',
        'P0105': 'Manifold Absolute Pressure/Barometric Pressure Circuit Malfunction',
        'P0106': 'Manifold Absolute Pressure/Barometric Pressure Circuit Range/Performance Problem',
        'P0107': 'Manifold Absolute Pressure/Barometric Pressure Circuit Low Input',
        'P0108': 'Manifold Absolute Pressure/Barometric Pressure Circuit High Input',
        'P0109': 'Manifold Absolute Pressure/Barometric Pressure Circuit Intermittent',
        'P0110': 'Intake Air Temperature Circuit Malfunction',
        'P0111': 'Intake Air Temperature Circuit Range/Performance Problem',
        'P0112': 'Intake Air Temperature Circuit Low Input',
        'P0113': 'Intake Air Temperature Circuit High Input',
        'P0114': 'Intake Air Temperature Circuit Intermittent',
        'P0115': 'Engine Coolant Temperature Circuit Malfunction',
        'P0116': 'Engine Coolant Temperature Circuit Range/Performance Problem',
        'P0117': 'Engine Coolant Temperature Circuit Low Input',
        'P0118': 'Engine Coolant Temperature Circuit High Input',
        'P0119': 'Engine Coolant Temperature Circuit Intermittent',
        'P0120': 'Throttle/Pedal Position Sensor/Switch A Circuit Malfunction',
        'P0130': 'O2 Sensor Circuit Malfunction (Bank 1, Sensor 1)',
        'P0131': 'O2 Sensor Circuit Low Voltage (Bank 1, Sensor 1)',
        'P0132': 'O2 Sensor Circuit High Voltage (Bank 1, Sensor 1)',
        'P0133': 'O2 Sensor Circuit Slow Response (Bank 1, Sensor 1)',
        'P0134': 'O2 Sensor Circuit No Activity Detected (Bank 1, Sensor 1)',
        'P0135': 'O2 Sensor Heater Circuit Malfunction (Bank 1, Sensor 1)',
        'P0300': 'Random/Multiple Cylinder Misfire Detected',
        'P0301': 'Cylinder 1 Misfire Detected',
        'P0302': 'Cylinder 2 Misfire Detected',
        'P0303': 'Cylinder 3 Misfire Detected',
        'P0304': 'Cylinder 4 Misfire Detected',
        'P0305': 'Cylinder 5 Misfire Detected',
        'P0306': 'Cylinder 6 Misfire Detected',
        'P0307': 'Cylinder 7 Misfire Detected',
        'P0308': 'Cylinder 8 Misfire Detected',
        'P0420': 'Catalyst System Efficiency Below Threshold (Bank 1)',
        'P0430': 'Catalyst System Efficiency Below Threshold (Bank 2)',
        'P0440': 'Evaporative Emission Control System Malfunction',
        'P0441': 'Evaporative Emission Control System Incorrect Purge Flow',
        'P0442': 'Evaporative Emission Control System Leak Detected (Small Leak)',
        'P0443': 'Evaporative Emission Control System Purge Control Valve Circuit Malfunction',
        'P0446': 'Evaporative Emission Control System Vent Control Circuit Malfunction',
        'P0500': 'Vehicle Speed Sensor Malfunction',
        'P0505': 'Idle Control System Malfunction',
        'P0506': 'Idle Control System RPM Lower Than Expected',
        'P0507': 'Idle Control System RPM Higher Than Expected',
        'P0510': 'Closed Throttle Position Switch Malfunction',
        'P0520': 'Engine Oil Pressure Sensor/Switch Circuit Malfunction',
        'P0600': 'Serial Communication Link Malfunction',
        'P0601': 'Internal Control Module Memory Checksum Error',
        'P0602': 'Control Module Programming Error',
        'P0603': 'Internal Control Module Keep Alive Memory (KAM) Error',
        'P0604': 'Internal Control Module Random Access Memory (RAM) Error',
        'P0605': 'Internal Control Module Read Only Memory (ROM) Error',
    }
    
    def __init__(self, obd_manager):
        """
        Initialize DTC Manager.
        
        Args:
            obd_manager: Reference to main OBD manager
        """
        self.obd_manager = obd_manager
        self.current_dtcs = []
        self.pending_dtcs = []
        self.permanent_dtcs = []
        self.dtc_history = []
    
    def read_current_dtcs(self) -> List[DTC]:
        """
        Read current DTCs from vehicle.
        
        Returns:
            List of current DTCs
        """
        if not self.obd_manager.is_connected():
            logger.error("Not connected to vehicle")
            return []
        
        try:
            # Send Mode 03 command to read DTCs
            response = self.obd_manager.protocol_handler.send_command("03")
            
            if not response:
                logger.warning("No response to DTC read command")
                return []
            
            # Parse DTC response
            dtcs = self._parse_dtc_response(response)
            self.current_dtcs = dtcs
            
            # Add to history
            for dtc in dtcs:
                dtc.detected_time = datetime.now()
                self.dtc_history.append(dtc)
            
            logger.info(f"Read {len(dtcs)} current DTCs")
            return dtcs
            
        except Exception as e:
            logger.error(f"Error reading current DTCs: {e}")
            return []
    
    def read_pending_dtcs(self) -> List[DTC]:
        """
        Read pending DTCs from vehicle.
        
        Returns:
            List of pending DTCs
        """
        if not self.obd_manager.is_connected():
            logger.error("Not connected to vehicle")
            return []
        
        try:
            # Send Mode 07 command to read pending DTCs
            response = self.obd_manager.protocol_handler.send_command("07")
            
            if not response:
                return []
            
            dtcs = self._parse_dtc_response(response)
            self.pending_dtcs = dtcs
            
            logger.info(f"Read {len(dtcs)} pending DTCs")
            return dtcs
            
        except Exception as e:
            logger.error(f"Error reading pending DTCs: {e}")
            return []
    
    def read_permanent_dtcs(self) -> List[DTC]:
        """
        Read permanent DTCs from vehicle.
        
        Returns:
            List of permanent DTCs
        """
        if not self.obd_manager.is_connected():
            logger.error("Not connected to vehicle")
            return []
        
        try:
            # Send Mode 0A command to read permanent DTCs
            response = self.obd_manager.protocol_handler.send_command("0A")
            
            if not response:
                return []
            
            dtcs = self._parse_dtc_response(response)
            self.permanent_dtcs = dtcs
            
            logger.info(f"Read {len(dtcs)} permanent DTCs")
            return dtcs
            
        except Exception as e:
            logger.error(f"Error reading permanent DTCs: {e}")
            return []
    
    def clear_dtcs(self) -> bool:
        """
        Clear DTCs from vehicle.
        
        Returns:
            True if successful, False otherwise
        """
        if not self.obd_manager.is_connected():
            logger.error("Not connected to vehicle")
            return False
        
        try:
            # Send Mode 04 command to clear DTCs
            response = self.obd_manager.protocol_handler.send_command("04")
            
            if response:
                # Clear local DTC lists
                self.current_dtcs.clear()
                self.pending_dtcs.clear()
                # Note: permanent DTCs cannot be cleared this way
                
                logger.info("DTCs cleared successfully")
                return True
            else:
                logger.error("Failed to clear DTCs")
                return False
                
        except Exception as e:
            logger.error(f"Error clearing DTCs: {e}")
            return False
    
    def get_freeze_frame_data(self, dtc_code: str) -> Optional[Dict]:
        """
        Get freeze frame data for a specific DTC.
        
        Args:
            dtc_code: DTC code to get freeze frame data for
            
        Returns:
            Freeze frame data dictionary or None
        """
        if not self.obd_manager.is_connected():
            return None
        
        try:
            # Send Mode 02 command for freeze frame data
            # This is a simplified implementation
            response = self.obd_manager.protocol_handler.send_command("0200")
            
            if response:
                # Parse freeze frame data (implementation depends on vehicle)
                return self._parse_freeze_frame_data(response)
            
        except Exception as e:
            logger.error(f"Error getting freeze frame data: {e}")
        
        return None
    
    def _parse_dtc_response(self, response: str) -> List[DTC]:
        """
        Parse DTC response data.
        
        Args:
            response: Raw response from vehicle
            
        Returns:
            List of DTC objects
        """
        dtcs = []
        
        try:
            # Remove spaces and convert to uppercase
            data = response.replace(' ', '').upper()
            
            # Skip response header (first 2-4 characters depending on protocol)
            if data.startswith('43'):  # Mode 03 response
                data = data[2:]
            elif data.startswith('47'):  # Mode 07 response
                data = data[2:]
            elif data.startswith('4A'):  # Mode 0A response
                data = data[2:]
            
            # Get number of DTCs (first byte)
            if len(data) >= 2:
                num_dtcs = int(data[:2], 16)
                data = data[2:]
                
                # Parse each DTC (2 bytes each)
                for i in range(num_dtcs):
                    if len(data) >= 4:
                        dtc_bytes = data[i*4:(i+1)*4]
                        dtc_code = self._decode_dtc(dtc_bytes)
                        
                        if dtc_code and dtc_code != 'P0000':
                            description = self.COMMON_DTCS.get(dtc_code, 'Unknown DTC')
                            dtcs.append(DTC(
                                code=dtc_code,
                                description=description,
                                status='Current'
                            ))
            
        except Exception as e:
            logger.error(f"Error parsing DTC response: {e}")
        
        return dtcs
    
    def _decode_dtc(self, dtc_bytes: str) -> Optional[str]:
        """
        Decode DTC from hex bytes.
        
        Args:
            dtc_bytes: 4-character hex string
            
        Returns:
            DTC code string or None
        """
        try:
            if len(dtc_bytes) != 4:
                return None
            
            # Convert to integer
            dtc_int = int(dtc_bytes, 16)
            
            if dtc_int == 0:
                return None
            
            # Extract components
            first_digit = (dtc_int >> 14) & 0x03
            second_digit = (dtc_int >> 12) & 0x03
            third_digit = (dtc_int >> 8) & 0x0F
            fourth_digit = (dtc_int >> 4) & 0x0F
            fifth_digit = dtc_int & 0x0F
            
            # Determine prefix
            if first_digit == 0:
                prefix = 'P'
            elif first_digit == 1:
                prefix = 'P'
            elif first_digit == 2:
                prefix = 'B'
            elif first_digit == 3:
                prefix = 'C'
            else:
                prefix = 'U'
            
            # Build DTC code
            dtc_code = f"{prefix}{second_digit}{third_digit:X}{fourth_digit:X}{fifth_digit:X}"
            
            return dtc_code
            
        except Exception as e:
            logger.error(f"Error decoding DTC: {e}")
            return None
    
    def _parse_freeze_frame_data(self, response: str) -> Dict:
        """
        Parse freeze frame data response.
        
        Args:
            response: Raw response from vehicle
            
        Returns:
            Dictionary of freeze frame data
        """
        # This is a simplified implementation
        # Real freeze frame parsing would be more complex
        return {
            'raw_data': response,
            'timestamp': datetime.now()
        }
    
    def get_dtc_description(self, dtc_code: str) -> str:
        """
        Get description for a DTC code.
        
        Args:
            dtc_code: DTC code
            
        Returns:
            Description string
        """
        return self.COMMON_DTCS.get(dtc_code, f"Unknown DTC: {dtc_code}")
    
    def get_dtc_history(self) -> List[DTC]:
        """Get DTC history."""
        return self.dtc_history.copy()
    
    def export_dtcs(self, filename: str) -> bool:
        """
        Export DTCs to file.
        
        Args:
            filename: Output filename
            
        Returns:
            True if successful
        """
        try:
            import json
            
            export_data = {
                'timestamp': datetime.now().isoformat(),
                'current_dtcs': [
                    {
                        'code': dtc.code,
                        'description': dtc.description,
                        'status': dtc.status
                    } for dtc in self.current_dtcs
                ],
                'pending_dtcs': [
                    {
                        'code': dtc.code,
                        'description': dtc.description,
                        'status': dtc.status
                    } for dtc in self.pending_dtcs
                ],
                'permanent_dtcs': [
                    {
                        'code': dtc.code,
                        'description': dtc.description,
                        'status': dtc.status
                    } for dtc in self.permanent_dtcs
                ]
            }
            
            with open(filename, 'w') as f:
                json.dump(export_data, f, indent=2)
            
            logger.info(f"DTCs exported to {filename}")
            return True
            
        except Exception as e:
            logger.error(f"Error exporting DTCs: {e}")
            return False