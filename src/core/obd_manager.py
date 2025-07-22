"""
OBD-II Manager - Main interface for OBD-II operations
"""

import logging
import time
from typing import Dict, List, Optional, Any, Callable
from enum import Enum

from ..hardware.adapter_manager import AdapterManager
from .protocol_handler import ProtocolHandler
from .dtc_manager import DTCManager
from .data_parser import DataParser

logger = logging.getLogger(__name__)


class OBDMode(Enum):
    """OBD-II service modes"""
    CURRENT_DATA = 0x01
    FREEZE_FRAME = 0x02
    DTC_CODES = 0x03
    CLEAR_DTC = 0x04
    O2_SENSOR_TEST = 0x05
    ON_BOARD_MONITORING = 0x06
    PENDING_DTC = 0x07
    CONTROL_OPERATION = 0x08
    VEHICLE_INFO = 0x09
    PERMANENT_DTC = 0x0A


class OBDParameter:
    """Represents an OBD-II parameter"""
    
    def __init__(self, pid: int, name: str, description: str, unit: str, 
                 formula: Optional[Callable] = None):
        self.pid = pid
        self.name = name
        self.description = description
        self.unit = unit
        self.formula = formula or (lambda x: x)
        self.last_value = None
        self.last_update = None


class OBDManager:
    """Main OBD-II management class"""
    
    # Common OBD-II PIDs for Mode 01 (Current Data)
    STANDARD_PIDS = {
        0x00: OBDParameter(0x00, "Supported PIDs", "PIDs supported (01-20)", "bitmap"),
        0x01: OBDParameter(0x01, "Monitor Status", "Monitor status since DTCs cleared", "bitmap"),
        0x04: OBDParameter(0x04, "Engine Load", "Calculated engine load", "%", lambda x: x[0] * 100 / 255),
        0x05: OBDParameter(0x05, "Coolant Temp", "Engine coolant temperature", "°C", lambda x: x[0] - 40),
        0x06: OBDParameter(0x06, "Short Fuel Trim 1", "Short term fuel trim—Bank 1", "%", lambda x: (x[0] - 128) * 100 / 128),
        0x07: OBDParameter(0x07, "Long Fuel Trim 1", "Long term fuel trim—Bank 1", "%", lambda x: (x[0] - 128) * 100 / 128),
        0x0A: OBDParameter(0x0A, "Fuel Pressure", "Fuel pressure", "kPa", lambda x: x[0] * 3),
        0x0B: OBDParameter(0x0B, "Intake Pressure", "Intake manifold absolute pressure", "kPa", lambda x: x[0]),
        0x0C: OBDParameter(0x0C, "Engine RPM", "Engine RPM", "rpm", lambda x: ((x[0] * 256) + x[1]) / 4),
        0x0D: OBDParameter(0x0D, "Vehicle Speed", "Vehicle speed", "km/h", lambda x: x[0]),
        0x0F: OBDParameter(0x0F, "Intake Air Temp", "Intake air temperature", "°C", lambda x: x[0] - 40),
        0x10: OBDParameter(0x10, "MAF Rate", "Mass air flow sensor air flow rate", "g/s", lambda x: ((x[0] * 256) + x[1]) / 100),
        0x11: OBDParameter(0x11, "Throttle Position", "Throttle position", "%", lambda x: x[0] * 100 / 255),
        0x1F: OBDParameter(0x1F, "Runtime", "Run time since engine start", "s", lambda x: (x[0] * 256) + x[1]),
        0x21: OBDParameter(0x21, "Distance with MIL", "Distance traveled with malfunction indicator lamp (MIL) on", "km", lambda x: (x[0] * 256) + x[1]),
        0x2F: OBDParameter(0x2F, "Fuel Level", "Fuel tank level input", "%", lambda x: x[0] * 100 / 255),
        0x33: OBDParameter(0x33, "Barometric Pressure", "Absolute barometric pressure", "kPa", lambda x: x[0]),
        0x42: OBDParameter(0x42, "Control Module Voltage", "Control module power supply", "V", lambda x: ((x[0] * 256) + x[1]) / 1000),
        0x51: OBDParameter(0x51, "Fuel Type", "Fuel Type", "enum", lambda x: x[0]),
    }
    
    def __init__(self, adapter_manager: AdapterManager):
        """
        Initialize OBD Manager.
        
        Args:
            adapter_manager: Hardware adapter manager instance
        """
        self.adapter_manager = adapter_manager
        self.protocol_handler = ProtocolHandler(adapter_manager)
        self.dtc_manager = DTCManager(self)
        self.data_parser = DataParser()
        
        self.connected = False
        self.vehicle_info = {}
        self.supported_pids = set()
        self.monitoring_active = False
        self._monitoring_callback = None
        
    def connect(self) -> bool:
        """
        Connect to vehicle via OBD-II adapter.
        
        Returns:
            True if connection successful, False otherwise
        """
        try:
            if not self.adapter_manager.connect():
                return False
            
            # Initialize protocol
            if not self.protocol_handler.initialize():
                self.adapter_manager.disconnect()
                return False
            
            # Query vehicle information
            self._query_vehicle_info()
            
            # Query supported PIDs
            self._query_supported_pids()
            
            self.connected = True
            logger.info("Successfully connected to vehicle")
            return True
            
        except Exception as e:
            logger.error(f"Error connecting to vehicle: {e}")
            self.connected = False
            return False
    
    def disconnect(self) -> None:
        """Disconnect from vehicle."""
        try:
            self.stop_monitoring()
            self.adapter_manager.disconnect()
            self.connected = False
            logger.info("Disconnected from vehicle")
        except Exception as e:
            logger.error(f"Error disconnecting: {e}")
    
    def is_connected(self) -> bool:
        """Check if connected to vehicle."""
        return self.connected and self.adapter_manager.is_connected()
    
    def query_parameter(self, pid: int) -> Optional[Any]:
        """
        Query a specific OBD-II parameter.
        
        Args:
            pid: Parameter ID to query
            
        Returns:
            Parameter value or None if failed
        """
        if not self.is_connected():
            logger.error("Not connected to vehicle")
            return None
        
        try:
            # Send OBD-II request
            command = f"01{pid:02X}"
            response = self.protocol_handler.send_command(command)
            
            if not response:
                return None
            
            # Parse response
            parsed_data = self.data_parser.parse_response(command, response)
            
            # Apply formula if parameter is known
            if pid in self.STANDARD_PIDS:
                param = self.STANDARD_PIDS[pid]
                if parsed_data:
                    value = param.formula(parsed_data)
                    param.last_value = value
                    param.last_update = time.time()
                    return value
            
            return parsed_data
            
        except Exception as e:
            logger.error(f"Error querying parameter {pid:02X}: {e}")
            return None
    
    def query_multiple_parameters(self, pids: List[int]) -> Dict[int, Any]:
        """
        Query multiple parameters efficiently.
        
        Args:
            pids: List of parameter IDs to query
            
        Returns:
            Dictionary mapping PID to value
        """
        results = {}
        for pid in pids:
            if pid in self.supported_pids:
                value = self.query_parameter(pid)
                if value is not None:
                    results[pid] = value
        return results
    
    def start_monitoring(self, pids: List[int], callback: Callable, interval: float = 1.0) -> None:
        """
        Start continuous monitoring of parameters.
        
        Args:
            pids: List of parameter IDs to monitor
            callback: Callback function called with results
            interval: Update interval in seconds
        """
        if self.monitoring_active:
            self.stop_monitoring()
        
        self.monitoring_active = True
        self._monitoring_callback = callback
        
        def monitor_loop():
            while self.monitoring_active and self.is_connected():
                try:
                    results = self.query_multiple_parameters(pids)
                    if callback and results:
                        callback(results)
                    time.sleep(interval)
                except Exception as e:
                    logger.error(f"Error in monitoring loop: {e}")
                    break
        
        import threading
        self.monitoring_thread = threading.Thread(target=monitor_loop, daemon=True)
        self.monitoring_thread.start()
        logger.info(f"Started monitoring {len(pids)} parameters")
    
    def stop_monitoring(self) -> None:
        """Stop parameter monitoring."""
        self.monitoring_active = False
        self._monitoring_callback = None
        logger.info("Stopped parameter monitoring")
    
    def get_vehicle_info(self) -> Dict[str, Any]:
        """Get vehicle information."""
        return self.vehicle_info.copy()
    
    def get_supported_parameters(self) -> List[OBDParameter]:
        """Get list of supported parameters."""
        return [param for pid, param in self.STANDARD_PIDS.items() 
                if pid in self.supported_pids]
    
    def _query_vehicle_info(self) -> None:
        """Query basic vehicle information."""
        try:
            # VIN (Vehicle Identification Number)
            vin_response = self.protocol_handler.send_command("0902")
            if vin_response:
                self.vehicle_info['vin'] = self.data_parser.parse_vin(vin_response)
            
            # Calibration ID
            cal_id_response = self.protocol_handler.send_command("0904")
            if cal_id_response:
                self.vehicle_info['calibration_id'] = self.data_parser.parse_ascii(cal_id_response)
                
        except Exception as e:
            logger.error(f"Error querying vehicle info: {e}")
    
    def _query_supported_pids(self) -> None:
        """Query supported PIDs from vehicle."""
        try:
            # Query PIDs 01-20
            response = self.protocol_handler.send_command("0100")
            if response:
                supported = self.data_parser.parse_supported_pids(response, 0x01)
                self.supported_pids.update(supported)
            
            # Query PIDs 21-40 if PID 20 is supported
            if 0x20 in self.supported_pids:
                response = self.protocol_handler.send_command("0120")
                if response:
                    supported = self.data_parser.parse_supported_pids(response, 0x21)
                    self.supported_pids.update(supported)
            
            logger.info(f"Vehicle supports {len(self.supported_pids)} PIDs")
            
        except Exception as e:
            logger.error(f"Error querying supported PIDs: {e}")
    
    def get_dtc_manager(self) -> DTCManager:
        """Get DTC manager instance."""
        return self.dtc_manager