"""
ELM327 adapter implementation
"""

import logging
import time
from typing import Optional, Dict, Any, List

from .connection_types import BaseConnection

logger = logging.getLogger(__name__)


class ELM327Adapter:
    """ELM327 OBD-II adapter implementation"""
    
    # Common ELM327 commands
    COMMANDS = {
        'reset': 'ATZ',
        'version': 'ATI',
        'voltage': 'ATRV',
        'device_id': 'AT@1',
        'echo_off': 'ATE0',
        'echo_on': 'ATE1',
        'linefeed_off': 'ATL0',
        'linefeed_on': 'ATL1',
        'spaces_off': 'ATS0',
        'spaces_on': 'ATS1',
        'headers_off': 'ATH0',
        'headers_on': 'ATH1',
        'memory_off': 'ATM0',
        'memory_on': 'ATM1',
        'protocol_auto': 'ATSP0',
        'protocol_close': 'ATPC',
        'describe_protocol': 'ATDP',
        'describe_protocol_num': 'ATDPN',
    }
    
    def __init__(self, connection: BaseConnection):
        """
        Initialize ELM327 adapter.
        
        Args:
            connection: Connection object for communication
        """
        self.connection = connection
        self.adapter_info = {}
        self.initialized = False
        self.last_command_time = 0
        self.min_command_interval = 0.1  # Minimum time between commands
    
    def initialize(self) -> bool:
        """
        Initialize ELM327 adapter.
        
        Returns:
            True if initialization successful
        """
        try:
            if not self.connection.is_connected():
                logger.error("Connection not established")
                return False
            
            # Reset adapter
            if not self._reset():
                return False
            
            # Get adapter information
            if not self._get_adapter_info():
                return False
            
            # Configure basic settings
            if not self._configure_basic_settings():
                return False
            
            self.initialized = True
            logger.info("ELM327 adapter initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Error initializing ELM327 adapter: {e}")
            return False
    
    def send_command(self, command: str, timeout: float = 5.0) -> Optional[str]:
        """
        Send command to ELM327 adapter.
        
        Args:
            command: Command to send
            timeout: Command timeout in seconds
            
        Returns:
            Response string or None if failed
        """
        try:
            # Enforce minimum command interval
            current_time = time.time()
            time_since_last = current_time - self.last_command_time
            if time_since_last < self.min_command_interval:
                time.sleep(self.min_command_interval - time_since_last)
            
            # Send command
            if not self.connection.send(command):
                logger.error(f"Failed to send command: {command}")
                return None
            
            # Receive response
            response = self.connection.receive(timeout)
            self.last_command_time = time.time()
            
            if response:
                # Clean up response
                response = self._clean_response(response)
                logger.debug(f"Command: {command} -> Response: {response}")
                return response
            else:
                logger.warning(f"No response to command: {command}")
                return None
                
        except Exception as e:
            logger.error(f"Error sending command {command}: {e}")
            return None
    
    def _reset(self) -> bool:
        """Reset the ELM327 adapter."""
        try:
            response = self.send_command(self.COMMANDS['reset'], timeout=3.0)
            
            if response and ('ELM327' in response or 'ELM320' in response):
                logger.info("ELM327 reset successful")
                time.sleep(1)  # Give adapter time to stabilize
                return True
            else:
                logger.error(f"Unexpected reset response: {response}")
                return False
                
        except Exception as e:
            logger.error(f"Error resetting ELM327: {e}")
            return False
    
    def _get_adapter_info(self) -> bool:
        """Get adapter information."""
        try:
            # Get version info
            version_response = self.send_command(self.COMMANDS['version'])
            if version_response:
                self.adapter_info['version'] = version_response
            
            # Get voltage
            voltage_response = self.send_command(self.COMMANDS['voltage'])
            if voltage_response:
                self.adapter_info['voltage'] = voltage_response
            
            # Get device ID (if supported)
            device_id_response = self.send_command(self.COMMANDS['device_id'])
            if device_id_response and 'ERROR' not in device_id_response.upper():
                self.adapter_info['device_id'] = device_id_response
            
            logger.info(f"Adapter info: {self.adapter_info}")
            return True
            
        except Exception as e:
            logger.error(f"Error getting adapter info: {e}")
            return False
    
    def _configure_basic_settings(self) -> bool:
        """Configure basic ELM327 settings."""
        try:
            settings = [
                (self.COMMANDS['echo_off'], "Turn off echo"),
                (self.COMMANDS['linefeed_off'], "Turn off line feeds"),
                (self.COMMANDS['spaces_off'], "Turn off spaces"),
                (self.COMMANDS['memory_off'], "Turn off memory"),
            ]
            
            for command, description in settings:
                response = self.send_command(command)
                if not response or 'OK' not in response.upper():
                    logger.warning(f"Failed to {description}: {response}")
                    # Continue anyway, some settings might not be critical
            
            return True
            
        except Exception as e:
            logger.error(f"Error configuring basic settings: {e}")
            return False
    
    def _clean_response(self, response: str) -> str:
        """
        Clean adapter response.
        
        Args:
            response: Raw response from adapter
            
        Returns:
            Cleaned response
        """
        if not response:
            return ""
        
        # Remove common artifacts
        cleaned = response.strip()
        
        # Remove echo of the command (if echo is on)
        # and other common patterns
        lines = cleaned.split('\r')
        if lines:
            # Usually the last non-empty line is the actual response
            for line in reversed(lines):
                line = line.strip()
                if line and not line.startswith('AT'):
                    return line
        
        return cleaned
    
    def get_supported_protocols(self) -> List[str]:
        """
        Get list of supported protocols.
        
        Returns:
            List of protocol names
        """
        # ELM327 typically supports these protocols
        return [
            "SAE J1850 PWM (41.6 kbit/s)",
            "SAE J1850 VPW (10.4 kbit/s)", 
            "ISO 9141-2",
            "ISO 14230-4 (KWP2000) 5 baud init",
            "ISO 14230-4 (KWP2000) fast init",
            "ISO 15765-4 (CAN 11/500)",
            "ISO 15765-4 (CAN 29/500)",
            "ISO 15765-4 (CAN 11/250)",
            "ISO 15765-4 (CAN 29/250)",
        ]
    
    def set_protocol(self, protocol_num: int) -> bool:
        """
        Set communication protocol.
        
        Args:
            protocol_num: Protocol number (0=auto, 1-9=specific protocols)
            
        Returns:
            True if successful
        """
        try:
            command = f"ATSP{protocol_num}"
            response = self.send_command(command)
            
            if response and 'OK' in response.upper():
                logger.info(f"Protocol set to: {protocol_num}")
                return True
            else:
                logger.error(f"Failed to set protocol: {response}")
                return False
                
        except Exception as e:
            logger.error(f"Error setting protocol: {e}")
            return False
    
    def get_protocol_description(self) -> Optional[str]:
        """
        Get current protocol description.
        
        Returns:
            Protocol description string or None
        """
        try:
            response = self.send_command(self.COMMANDS['describe_protocol'])
            return response if response else None
            
        except Exception as e:
            logger.error(f"Error getting protocol description: {e}")
            return None
    
    def test_connection(self) -> bool:
        """
        Test connection to vehicle.
        
        Returns:
            True if vehicle responds
        """
        try:
            # Try a simple OBD command
            response = self.send_command("0100", timeout=10.0)
            
            if response and not self._is_error_response(response):
                logger.info("Vehicle connection test successful")
                return True
            else:
                logger.warning(f"Vehicle connection test failed: {response}")
                return False
                
        except Exception as e:
            logger.error(f"Error testing vehicle connection: {e}")
            return False
    
    def _is_error_response(self, response: str) -> bool:
        """Check if response indicates an error."""
        if not response:
            return True
        
        error_patterns = [
            'NO DATA',
            'ERROR',
            'STOPPED',
            'UNABLE TO CONNECT',
            'BUS INIT',
            'SEARCHING',
            '?'
        ]
        
        response_upper = response.upper()
        return any(pattern in response_upper for pattern in error_patterns)
    
    def get_adapter_info(self) -> Dict[str, Any]:
        """Get adapter information."""
        return {
            'type': 'ELM327',
            'initialized': self.initialized,
            'info': self.adapter_info.copy(),
            'connection': self.connection.get_info()
        }
    
    def close(self) -> None:
        """Close adapter connection."""
        try:
            if self.initialized:
                # Send close protocol command
                self.send_command(self.COMMANDS['protocol_close'])
            
            self.initialized = False
            
        except Exception as e:
            logger.error(f"Error closing ELM327 adapter: {e}")