"""
Live Data Monitoring Module
Provides real-time monitoring of vehicle sensors and parameters
"""

import time
import threading
import logging
from typing import Dict, List, Optional, Callable, Any
from dataclasses import dataclass
from datetime import datetime
import queue

@dataclass
class SensorData:
    """Data class for sensor readings"""
    name: str
    value: Any
    unit: str
    timestamp: datetime
    pid: str
    raw_value: str

@dataclass
class PIDDefinition:
    """Definition of an OBD PID"""
    pid: str
    name: str
    description: str
    unit: str
    formula: str
    min_value: float
    max_value: float
    data_bytes: int

class LiveDataMonitor:
    """Monitors live vehicle data in real-time"""
    
    def __init__(self, obd_interface):
        """
        Initialize live data monitor
        
        Args:
            obd_interface: OBDInterface instance
        """
        self.obd_interface = obd_interface
        self.logger = logging.getLogger(__name__)
        self.is_monitoring = False
        self.monitoring_thread = None
        self.data_queue = queue.Queue()
        self.callbacks = []
        self.monitored_pids = []
        self.refresh_rate = 1.0  # seconds
        self.pid_definitions = self._load_pid_definitions()
        
    def _load_pid_definitions(self) -> Dict[str, PIDDefinition]:
        """Load standard OBD PID definitions"""
        pids = {
            "00": PIDDefinition("00", "Supported PIDs", "PIDs supported [01-20]", "bitmap", "A*256+B*128+C*64+D*32", 0, 0xFFFFFFFF, 4),
            "01": PIDDefinition("01", "Monitor Status", "Monitor status since DTCs cleared", "bitmap", "A*16777216+B*65536+C*256+D", 0, 0xFFFFFFFF, 4),
            "02": PIDDefinition("02", "Freeze Frame DTC", "DTC that caused freeze frame", "string", "A*256+B", 0, 0xFFFF, 2),
            "03": PIDDefinition("03", "Fuel System Status", "Fuel system status", "bitmap", "A*256+B", 0, 0xFFFF, 2),
            "04": PIDDefinition("04", "Engine Load", "Calculated engine load", "%", "A*100/255", 0, 100, 1),
            "05": PIDDefinition("05", "Engine Coolant Temp", "Engine coolant temperature", "°C", "A-40", -40, 215, 1),
            "06": PIDDefinition("06", "Short Fuel Trim Bank 1", "Short term fuel trim - Bank 1", "%", "(A-128)*100/128", -100, 99.22, 1),
            "07": PIDDefinition("07", "Long Fuel Trim Bank 1", "Long term fuel trim - Bank 1", "%", "(A-128)*100/128", -100, 99.22, 1),
            "08": PIDDefinition("08", "Short Fuel Trim Bank 2", "Short term fuel trim - Bank 2", "%", "(A-128)*100/128", -100, 99.22, 1),
            "09": PIDDefinition("09", "Long Fuel Trim Bank 2", "Long term fuel trim - Bank 2", "%", "(A-128)*100/128", -100, 99.22, 1),
            "0A": PIDDefinition("0A", "Fuel Pressure", "Fuel pressure", "kPa", "A*3", 0, 765, 1),
            "0B": PIDDefinition("0B", "Intake MAP", "Intake manifold absolute pressure", "kPa", "A", 0, 255, 1),
            "0C": PIDDefinition("0C", "Engine RPM", "Engine RPM", "rpm", "(A*256+B)/4", 0, 16383.75, 2),
            "0D": PIDDefinition("0D", "Vehicle Speed", "Vehicle speed", "km/h", "A", 0, 255, 1),
            "0E": PIDDefinition("0E", "Timing Advance", "Timing advance", "°", "(A-128)/2", -64, 63.5, 1),
            "0F": PIDDefinition("0F", "Intake Air Temp", "Intake air temperature", "°C", "A-40", -40, 215, 1),
            "10": PIDDefinition("10", "MAF Rate", "MAF air flow rate", "g/s", "(A*256+B)/100", 0, 655.35, 2),
            "11": PIDDefinition("11", "Throttle Position", "Throttle position", "%", "A*100/255", 0, 100, 1),
            "12": PIDDefinition("12", "Secondary Air Status", "Commanded secondary air status", "bitmap", "A", 0, 255, 1),
            "13": PIDDefinition("13", "O2 Sensors Present", "Oxygen sensors present", "bitmap", "A", 0, 255, 1),
            "14": PIDDefinition("14", "O2 Sensor 1 Voltage", "O2 Sensor 1 voltage", "V", "A/200", 0, 1.275, 1),
            "15": PIDDefinition("15", "O2 Sensor 2 Voltage", "O2 Sensor 2 voltage", "V", "A/200", 0, 1.275, 1),
            "16": PIDDefinition("16", "O2 Sensor 3 Voltage", "O2 Sensor 3 voltage", "V", "A/200", 0, 1.275, 1),
            "17": PIDDefinition("17", "O2 Sensor 4 Voltage", "O2 Sensor 4 voltage", "V", "A/200", 0, 1.275, 1),
            "18": PIDDefinition("18", "O2 Sensor 5 Voltage", "O2 Sensor 5 voltage", "V", "A/200", 0, 1.275, 1),
            "19": PIDDefinition("19", "O2 Sensor 6 Voltage", "O2 Sensor 6 voltage", "V", "A/200", 0, 1.275, 1),
            "1A": PIDDefinition("1A", "O2 Sensor 7 Voltage", "O2 Sensor 7 voltage", "V", "A/200", 0, 1.275, 1),
            "1B": PIDDefinition("1B", "O2 Sensor 8 Voltage", "O2 Sensor 8 voltage", "V", "A/200", 0, 1.275, 1),
            "1C": PIDDefinition("1C", "OBD Standards", "OBD standards this vehicle conforms to", "bitmap", "A", 0, 255, 1),
            "1D": PIDDefinition("1D", "O2 Sensors Present 2", "Oxygen sensors present (bank 3-4)", "bitmap", "A", 0, 255, 1),
            "1E": PIDDefinition("1E", "Auxiliary Input", "Auxiliary input status", "bitmap", "A", 0, 255, 1),
            "1F": PIDDefinition("1F", "Runtime Since Start", "Runtime since engine start", "seconds", "A*256+B", 0, 65535, 2),
            "21": PIDDefinition("21", "Distance with MIL", "Distance traveled with MIL on", "km", "A*256+B", 0, 65535, 2),
            "22": PIDDefinition("22", "Fuel Rail Pressure", "Fuel rail pressure", "kPa", "(A*256+B)*0.079", 0, 5177.265, 2),
            "23": PIDDefinition("23", "Fuel Rail Gauge Pressure", "Fuel rail gauge pressure", "kPa", "(A*256+B)*10", 0, 655350, 2),
            "24": PIDDefinition("24", "O2 Sensor 1 F-A Ratio", "O2 Sensor 1 fuel-air equivalence ratio", "ratio", "(A*256+B)*2/65536", 0, 2, 2),
            "2C": PIDDefinition("2C", "Commanded EGR", "Commanded EGR", "%", "A*100/255", 0, 100, 1),
            "2D": PIDDefinition("2D", "EGR Error", "EGR error", "%", "(A-128)*100/128", -100, 99.22, 1),
            "2E": PIDDefinition("2E", "Commanded Evap Purge", "Commanded evaporative purge", "%", "A*100/255", 0, 100, 1),
            "2F": PIDDefinition("2F", "Fuel Tank Level", "Fuel tank level input", "%", "A*100/255", 0, 100, 1),
            "30": PIDDefinition("30", "Warmups Since Clear", "Warm-ups since codes cleared", "count", "A", 0, 255, 1),
            "31": PIDDefinition("31", "Distance Since Clear", "Distance traveled since codes cleared", "km", "A*256+B", 0, 65535, 2),
            "32": PIDDefinition("32", "Evap Vapor Pressure", "Evap system vapor pressure", "Pa", "((A*256+B)-32768)/4", -8192, 8191.75, 2),
            "33": PIDDefinition("33", "Absolute Barometric", "Absolute barometric pressure", "kPa", "A", 0, 255, 1),
            "42": PIDDefinition("42", "Control Module Voltage", "Control module power supply voltage", "V", "(A*256+B)/1000", 0, 65.535, 2),
            "43": PIDDefinition("43", "Absolute Load Value", "Absolute load value", "%", "(A*256+B)*100/255", 0, 25700, 2),
            "44": PIDDefinition("44", "Command Equivalence Ratio", "Commanded air-fuel equivalence ratio", "ratio", "(A*256+B)/32768", 0, 2, 2),
            "45": PIDDefinition("45", "Relative Throttle Position", "Relative throttle position", "%", "A*100/255", 0, 100, 1),
            "46": PIDDefinition("46", "Ambient Air Temp", "Ambient air temperature", "°C", "A-40", -40, 215, 1),
            "47": PIDDefinition("47", "Absolute Throttle Position B", "Absolute throttle position B", "%", "A*100/255", 0, 100, 1),
            "48": PIDDefinition("48", "Absolute Throttle Position C", "Absolute throttle position C", "%", "A*100/255", 0, 100, 1),
            "49": PIDDefinition("49", "Accelerator Pedal Position D", "Accelerator pedal position D", "%", "A*100/255", 0, 100, 1),
            "4A": PIDDefinition("4A", "Accelerator Pedal Position E", "Accelerator pedal position E", "%", "A*100/255", 0, 100, 1),
            "4B": PIDDefinition("4B", "Accelerator Pedal Position F", "Accelerator pedal position F", "%", "A*100/255", 0, 100, 1),
            "4C": PIDDefinition("4C", "Commanded Throttle Actuator", "Commanded throttle actuator", "%", "A*100/255", 0, 100, 1),
            "4D": PIDDefinition("4D", "Time Run with MIL", "Time run with MIL on", "minutes", "A*256+B", 0, 65535, 2),
            "4E": PIDDefinition("4E", "Time Since Codes Cleared", "Time since trouble codes cleared", "minutes", "A*256+B", 0, 65535, 2),
        }
        return pids
    
    def get_supported_pids(self) -> List[str]:
        """
        Get list of PIDs supported by the vehicle
        
        Returns:
            list: List of supported PID codes
        """
        supported = []
        
        # Check PIDs 01-20
        response = self.obd_interface.read_pid("01", "00")
        if response:
            supported.extend(self._parse_supported_pids(response, 1))
        
        # Check PIDs 21-40
        response = self.obd_interface.read_pid("01", "20")
        if response:
            supported.extend(self._parse_supported_pids(response, 21))
        
        # Check PIDs 41-60
        response = self.obd_interface.read_pid("01", "40")
        if response:
            supported.extend(self._parse_supported_pids(response, 41))
        
        return supported
    
    def _parse_supported_pids(self, response: str, start_pid: int) -> List[str]:
        """Parse supported PIDs from bitmap response"""
        supported = []
        
        try:
            # Remove spaces and get hex data
            hex_data = response.replace(" ", "")
            if len(hex_data) >= 8:  # Need at least 4 bytes
                # Skip response header and get data
                data_start = 6 if len(hex_data) > 8 else 0
                bitmap_hex = hex_data[data_start:data_start+8]
                
                # Convert to binary
                bitmap = int(bitmap_hex, 16)
                
                # Check each bit
                for i in range(32):
                    if bitmap & (1 << (31 - i)):
                        pid_num = start_pid + i
                        pid_hex = f"{pid_num:02X}"
                        supported.append(pid_hex)
        
        except ValueError as e:
            self.logger.error(f"Error parsing supported PIDs: {e}")
        
        return supported
    
    def add_pid_to_monitor(self, pid: str) -> bool:
        """
        Add a PID to the monitoring list
        
        Args:
            pid: PID code to monitor
            
        Returns:
            bool: True if successfully added
        """
        if pid not in self.monitored_pids:
            # Test if PID is readable
            test_response = self.obd_interface.read_pid("01", pid)
            if test_response:
                self.monitored_pids.append(pid)
                self.logger.info(f"Added PID {pid} to monitoring list")
                return True
            else:
                self.logger.warning(f"PID {pid} not supported or readable")
                return False
        return True
    
    def remove_pid_from_monitor(self, pid: str) -> bool:
        """
        Remove a PID from the monitoring list
        
        Args:
            pid: PID code to remove
            
        Returns:
            bool: True if successfully removed
        """
        if pid in self.monitored_pids:
            self.monitored_pids.remove(pid)
            self.logger.info(f"Removed PID {pid} from monitoring list")
            return True
        return False
    
    def start_monitoring(self, refresh_rate: float = 1.0) -> bool:
        """
        Start live data monitoring
        
        Args:
            refresh_rate: Refresh rate in seconds
            
        Returns:
            bool: True if monitoring started successfully
        """
        if self.is_monitoring:
            self.logger.warning("Monitoring already active")
            return False
        
        if not self.monitored_pids:
            self.logger.error("No PIDs configured for monitoring")
            return False
        
        self.refresh_rate = refresh_rate
        self.is_monitoring = True
        
        # Start monitoring thread
        self.monitoring_thread = threading.Thread(target=self._monitoring_loop, daemon=True)
        self.monitoring_thread.start()
        
        self.logger.info(f"Started monitoring {len(self.monitored_pids)} PIDs at {refresh_rate}s intervals")
        return True
    
    def stop_monitoring(self) -> None:
        """Stop live data monitoring"""
        self.is_monitoring = False
        if self.monitoring_thread:
            self.monitoring_thread.join(timeout=2.0)
        self.logger.info("Stopped live data monitoring")
    
    def _monitoring_loop(self) -> None:
        """Main monitoring loop running in separate thread"""
        while self.is_monitoring:
            start_time = time.time()
            
            for pid in self.monitored_pids:
                if not self.is_monitoring:
                    break
                
                try:
                    # Read PID data
                    raw_response = self.obd_interface.read_pid("01", pid)
                    if raw_response:
                        # Parse and convert data
                        sensor_data = self._parse_pid_data(pid, raw_response)
                        if sensor_data:
                            # Add to queue
                            self.data_queue.put(sensor_data)
                            
                            # Notify callbacks
                            for callback in self.callbacks:
                                try:
                                    callback(sensor_data)
                                except Exception as e:
                                    self.logger.error(f"Error in callback: {e}")
                
                except Exception as e:
                    self.logger.error(f"Error reading PID {pid}: {e}")
            
            # Sleep for remaining time to maintain refresh rate
            elapsed = time.time() - start_time
            sleep_time = max(0, self.refresh_rate - elapsed)
            if sleep_time > 0:
                time.sleep(sleep_time)
    
    def _parse_pid_data(self, pid: str, raw_response: str) -> Optional[SensorData]:
        """
        Parse raw PID response into sensor data
        
        Args:
            pid: PID code
            raw_response: Raw response from OBD interface
            
        Returns:
            SensorData: Parsed sensor data or None if failed
        """
        pid_def = self.pid_definitions.get(pid)
        if not pid_def:
            return None
        
        try:
            # Clean response and extract data bytes
            hex_data = raw_response.replace(" ", "")
            # Skip response header (typically first 4-6 characters)
            data_start = 6 if len(hex_data) > 8 else 4
            data_hex = hex_data[data_start:]
            
            # Convert hex bytes to integers
            data_bytes = []
            for i in range(0, len(data_hex), 2):
                if i + 1 < len(data_hex):
                    byte_val = int(data_hex[i:i+2], 16)
                    data_bytes.append(byte_val)
            
            if len(data_bytes) < pid_def.data_bytes:
                return None
            
            # Calculate value using formula
            value = self._calculate_pid_value(pid_def.formula, data_bytes)
            
            return SensorData(
                name=pid_def.name,
                value=value,
                unit=pid_def.unit,
                timestamp=datetime.now(),
                pid=pid,
                raw_value=raw_response
            )
        
        except Exception as e:
            self.logger.error(f"Error parsing PID {pid} data: {e}")
            return None
    
    def _calculate_pid_value(self, formula: str, data_bytes: List[int]) -> float:
        """
        Calculate PID value using formula
        
        Args:
            formula: Formula string
            data_bytes: List of data bytes
            
        Returns:
            float: Calculated value
        """
        # Map byte values to variables
        variables = {}
        for i, byte_val in enumerate(data_bytes[:8]):  # Support up to 8 bytes
            variables[chr(ord('A') + i)] = byte_val
        
        # Replace variables in formula
        eval_formula = formula
        for var, val in variables.items():
            eval_formula = eval_formula.replace(var, str(val))
        
        try:
            # Safely evaluate mathematical expression
            # Note: In production, use a safer expression evaluator
            result = eval(eval_formula)
            return float(result)
        except Exception:
            return 0.0
    
    def get_latest_data(self) -> List[SensorData]:
        """
        Get all data from queue
        
        Returns:
            list: List of latest sensor data
        """
        data = []
        while not self.data_queue.empty():
            try:
                data.append(self.data_queue.get_nowait())
            except queue.Empty:
                break
        return data
    
    def add_callback(self, callback: Callable[[SensorData], None]) -> None:
        """
        Add callback function for real-time data
        
        Args:
            callback: Function to call with new sensor data
        """
        self.callbacks.append(callback)
    
    def remove_callback(self, callback: Callable[[SensorData], None]) -> None:
        """
        Remove callback function
        
        Args:
            callback: Function to remove
        """
        if callback in self.callbacks:
            self.callbacks.remove(callback)
    
    def get_current_values(self) -> Dict[str, SensorData]:
        """
        Get current values for all monitored PIDs
        
        Returns:
            dict: Dictionary of PID -> SensorData
        """
        current_values = {}
        
        for pid in self.monitored_pids:
            raw_response = self.obd_interface.read_pid("01", pid)
            if raw_response:
                sensor_data = self._parse_pid_data(pid, raw_response)
                if sensor_data:
                    current_values[pid] = sensor_data
        
        return current_values
    
    def get_pid_info(self, pid: str) -> Optional[PIDDefinition]:
        """
        Get information about a specific PID
        
        Args:
            pid: PID code
            
        Returns:
            PIDDefinition: PID definition or None if not found
        """
        return self.pid_definitions.get(pid)
    
    def export_data_log(self, filename: str, duration: int = 60) -> bool:
        """
        Export monitoring data to file
        
        Args:
            filename: Output filename
            duration: Duration to log in seconds
            
        Returns:
            bool: True if successful
        """
        try:
            import csv
            
            with open(filename, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                
                # Write header
                header = ['Timestamp']
                for pid in self.monitored_pids:
                    pid_def = self.pid_definitions.get(pid)
                    if pid_def:
                        header.append(f"{pid_def.name} ({pid_def.unit})")
                writer.writerow(header)
                
                # Monitor and log data
                start_time = time.time()
                while time.time() - start_time < duration:
                    current_data = self.get_current_values()
                    
                    row = [datetime.now().isoformat()]
                    for pid in self.monitored_pids:
                        if pid in current_data:
                            row.append(current_data[pid].value)
                        else:
                            row.append('')
                    
                    writer.writerow(row)
                    time.sleep(self.refresh_rate)
                
            self.logger.info(f"Data logged to {filename}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error exporting data: {e}")
            return False