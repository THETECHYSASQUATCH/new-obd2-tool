"""
Core OBD-II Interface Module
Handles communication with OBD-II adapters and vehicles
"""

import serial
import time
import logging
from typing import Optional, Dict, List, Tuple

class OBDInterface:
    """Main interface for OBD-II communication"""
    
    def __init__(self, port: str = None, baudrate: int = 38400, timeout: float = 3.0):
        """
        Initialize OBD-II interface
        
        Args:
            port: Serial port for OBD adapter (e.g., '/dev/ttyUSB0', 'COM3')
            baudrate: Communication baudrate
            timeout: Communication timeout in seconds
        """
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.connection = None
        self.is_connected = False
        self.protocols = []
        self.current_protocol = None
        
        # Initialize logging
        self.logger = logging.getLogger(__name__)
        
    def connect(self, port: str = None) -> bool:
        """
        Connect to OBD-II adapter
        
        Args:
            port: Serial port to connect to
            
        Returns:
            bool: True if connection successful
        """
        if port:
            self.port = port
            
        if not self.port:
            self.logger.error("No port specified for connection")
            return False
            
        try:
            self.connection = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                bytesize=serial.EIGHTBITS
            )
            
            # Initialize ELM327 adapter
            if self._initialize_elm327():
                self.is_connected = True
                self.logger.info(f"Connected to OBD-II adapter on {self.port}")
                return True
            else:
                self.disconnect()
                return False
                
        except serial.SerialException as e:
            self.logger.error(f"Failed to connect to {self.port}: {e}")
            return False
    
    def disconnect(self) -> None:
        """Disconnect from OBD-II adapter"""
        if self.connection and self.connection.is_open:
            self.connection.close()
        self.is_connected = False
        self.logger.info("Disconnected from OBD-II adapter")
    
    def _initialize_elm327(self) -> bool:
        """
        Initialize ELM327 adapter with standard commands
        
        Returns:
            bool: True if initialization successful
        """
        init_commands = [
            ("ATZ", "ELM327"),      # Reset
            ("ATE0", "OK"),         # Echo off
            ("ATL0", "OK"),         # Linefeeds off
            ("ATS0", "OK"),         # Spaces off
            ("ATH1", "OK"),         # Headers on
            ("ATSP0", "OK"),        # Auto protocol
        ]
        
        for cmd, expected in init_commands:
            response = self._send_command(cmd, 2.0)
            if not response or expected not in response:
                self.logger.error(f"ELM327 initialization failed at: {cmd}")
                return False
            time.sleep(0.1)
        
        # Get supported protocols
        self._get_supported_protocols()
        return True
    
    def _send_command(self, command: str, timeout: float = None) -> Optional[str]:
        """
        Send command to OBD adapter and receive response
        
        Args:
            command: Command to send
            timeout: Optional timeout override
            
        Returns:
            str: Response from adapter, None if failed
        """
        if not self.is_connected or not self.connection:
            return None
            
        try:
            # Clear input buffer
            self.connection.reset_input_buffer()
            
            # Send command
            cmd = f"{command}\r"
            self.connection.write(cmd.encode('ascii'))
            
            # Read response
            response = ""
            start_time = time.time()
            current_timeout = timeout or self.timeout
            
            while time.time() - start_time < current_timeout:
                if self.connection.in_waiting > 0:
                    char = self.connection.read(1).decode('ascii', errors='ignore')
                    if char == '>':  # ELM327 prompt
                        break
                    response += char
                time.sleep(0.01)
            
            # Clean up response
            response = response.strip().replace('\r', '').replace('\n', ' ')
            self.logger.debug(f"Command: {command} -> Response: {response}")
            return response
            
        except Exception as e:
            self.logger.error(f"Command failed: {command} - {e}")
            return None
    
    def _get_supported_protocols(self) -> None:
        """Get list of supported OBD protocols"""
        protocol_response = self._send_command("ATDP")
        if protocol_response:
            self.current_protocol = protocol_response
            
        # Try to get protocol list
        proto_list = self._send_command("ATDPN")
        if proto_list:
            self.protocols = proto_list.split()
    
    def read_pid(self, mode: str, pid: str) -> Optional[str]:
        """
        Read Parameter ID (PID) from vehicle
        
        Args:
            mode: OBD mode (e.g., '01' for current data)
            pid: Parameter ID to read
            
        Returns:
            str: Raw response data or None if failed
        """
        command = f"{mode}{pid}"
        response = self._send_command(command)
        
        if response and "NO DATA" not in response and "?" not in response:
            return response
        return None
    
    def read_dtc(self) -> List[str]:
        """
        Read Diagnostic Trouble Codes
        
        Returns:
            list: List of DTC codes
        """
        dtc_codes = []
        
        # Read stored DTCs (mode 03)
        response = self._send_command("03")
        if response and response != "NO DATA":
            # Parse DTC codes from response
            dtc_codes.extend(self._parse_dtc_response(response))
        
        return dtc_codes
    
    def clear_dtc(self) -> bool:
        """
        Clear Diagnostic Trouble Codes
        
        Returns:
            bool: True if successful
        """
        response = self._send_command("04")
        return response is not None and "OK" in response
    
    def _parse_dtc_response(self, response: str) -> List[str]:
        """
        Parse DTC codes from raw response
        
        Args:
            response: Raw response from adapter
            
        Returns:
            list: Parsed DTC codes
        """
        dtc_codes = []
        # Remove spaces and split into hex pairs
        hex_data = response.replace(" ", "")
        
        # Skip first 4 characters (response header)
        if len(hex_data) > 4:
            hex_data = hex_data[4:]
        
        # Process pairs of hex bytes
        for i in range(0, len(hex_data), 4):
            if i + 3 < len(hex_data):
                dtc_hex = hex_data[i:i+4]
                dtc_code = self._hex_to_dtc(dtc_hex)
                if dtc_code:
                    dtc_codes.append(dtc_code)
        
        return dtc_codes
    
    def _hex_to_dtc(self, hex_code: str) -> Optional[str]:
        """
        Convert hex code to DTC format
        
        Args:
            hex_code: 4-character hex code
            
        Returns:
            str: DTC code in standard format (e.g., P0301)
        """
        if len(hex_code) != 4:
            return None
            
        try:
            first_byte = int(hex_code[:2], 16)
            second_byte = int(hex_code[2:], 16)
            
            # Determine prefix based on first two bits
            prefix_map = {0: 'P', 1: 'P', 2: 'B', 3: 'C'}
            prefix = prefix_map.get((first_byte >> 6) & 0x03, 'P')
            
            # Calculate numeric part
            numeric = ((first_byte & 0x3F) << 8) + second_byte
            
            if numeric == 0:
                return None
                
            return f"{prefix}{numeric:04d}"
            
        except ValueError:
            return None
    
    def get_vehicle_info(self) -> Dict[str, str]:
        """
        Get basic vehicle information
        
        Returns:
            dict: Vehicle information
        """
        info = {}
        
        # VIN (Vehicle Identification Number)
        vin_response = self._send_command("0902")
        if vin_response:
            info['VIN'] = self._parse_vin(vin_response)
        
        # ECU Name
        ecu_response = self._send_command("090A")
        if ecu_response:
            info['ECU_NAME'] = ecu_response
        
        # Supported PIDs
        pids_response = self._send_command("0100")
        if pids_response:
            info['SUPPORTED_PIDS'] = pids_response
        
        return info
    
    def _parse_vin(self, response: str) -> str:
        """Parse VIN from raw response"""
        # This is a simplified VIN parser
        # Real implementation would need proper VIN parsing
        hex_data = response.replace(" ", "")
        if len(hex_data) > 8:  # Skip header
            hex_data = hex_data[8:]
        
        try:
            # Convert hex to ASCII
            vin = ""
            for i in range(0, len(hex_data), 2):
                if i + 1 < len(hex_data):
                    hex_byte = hex_data[i:i+2]
                    char_code = int(hex_byte, 16)
                    if 32 <= char_code <= 126:  # Printable ASCII
                        vin += chr(char_code)
            return vin.strip()
        except ValueError:
            return "Unknown"

    def is_vehicle_connected(self) -> bool:
        """
        Check if vehicle is connected and responding
        
        Returns:
            bool: True if vehicle is responding
        """
        if not self.is_connected:
            return False
            
        # Try to read a basic PID
        response = self.read_pid("01", "00")  # Supported PIDs
        return response is not None