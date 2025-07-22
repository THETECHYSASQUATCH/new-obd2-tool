"""
Protocol Handler for OBD-II communication protocols
"""

import logging
import time
from typing import Optional, Dict, Any
from enum import Enum

logger = logging.getLogger(__name__)


class OBDProtocol(Enum):
    """OBD-II communication protocols"""
    AUTO = "AUTO"
    ISO_9141_2 = "ISO 9141-2"
    KWP2000_SLOW = "KWP2000 (ISO 14230-4) 5 baud init"
    KWP2000_FAST = "KWP2000 (ISO 14230-4) fast init"
    CAN_11_500 = "ISO 15765-4 (CAN 11/500)"
    CAN_29_500 = "ISO 15765-4 (CAN 29/500)"
    CAN_11_250 = "ISO 15765-4 (CAN 11/250)"
    CAN_29_250 = "ISO 15765-4 (CAN 29/250)"
    J1850_PWM = "SAE J1850 PWM (41.6 kbit/s)"
    J1850_VPW = "SAE J1850 VPW (10.4 kbit/s)"


class ProtocolHandler:
    """Handles OBD-II protocol communication"""
    
    # ELM327 protocol numbers
    ELM327_PROTOCOLS = {
        OBDProtocol.AUTO: "0",
        OBDProtocol.J1850_PWM: "1",
        OBDProtocol.J1850_VPW: "2",
        OBDProtocol.ISO_9141_2: "3",
        OBDProtocol.KWP2000_SLOW: "4",
        OBDProtocol.KWP2000_FAST: "5",
        OBDProtocol.CAN_11_500: "6",
        OBDProtocol.CAN_29_500: "7",
        OBDProtocol.CAN_11_250: "8",
        OBDProtocol.CAN_29_250: "9",
    }
    
    def __init__(self, adapter_manager):
        """
        Initialize protocol handler.
        
        Args:
            adapter_manager: Hardware adapter manager instance
        """
        self.adapter_manager = adapter_manager
        self.current_protocol = None
        self.protocol_info = {}
        self.initialized = False
    
    def initialize(self) -> bool:
        """
        Initialize OBD-II protocol communication.
        
        Returns:
            True if initialization successful
        """
        try:
            if not self.adapter_manager.is_connected():
                logger.error("Adapter not connected")
                return False
            
            # Reset adapter
            if not self._reset_adapter():
                return False
            
            # Detect and set protocol
            if not self._detect_protocol():
                return False
            
            # Configure adapter settings
            if not self._configure_adapter():
                return False
            
            self.initialized = True
            logger.info(f"Protocol initialized: {self.current_protocol}")
            return True
            
        except Exception as e:
            logger.error(f"Error initializing protocol: {e}")
            self.initialized = False
            return False
    
    def send_command(self, command: str, timeout: float = 5.0) -> Optional[str]:
        """
        Send OBD-II command and get response.
        
        Args:
            command: OBD-II command to send
            timeout: Command timeout in seconds
            
        Returns:
            Response string or None if failed
        """
        if not self.initialized:
            logger.error("Protocol not initialized")
            return None
        
        try:
            # Send command through adapter
            response = self.adapter_manager.send_command(command, timeout)
            
            if not response:
                logger.warning(f"No response to command: {command}")
                return None
            
            # Validate response
            if self._is_error_response(response):
                logger.warning(f"Error response to command {command}: {response}")
                return None
            
            return response
            
        except Exception as e:
            logger.error(f"Error sending command {command}: {e}")
            return None
    
    def _reset_adapter(self) -> bool:
        """Reset the OBD adapter."""
        try:
            # Send reset command
            response = self.adapter_manager.send_command("ATZ", timeout=3.0)
            
            if response and "ELM327" in response:
                logger.info("Adapter reset successful")
                time.sleep(1)  # Give adapter time to stabilize
                return True
            else:
                logger.error("Adapter reset failed or unexpected response")
                return False
                
        except Exception as e:
            logger.error(f"Error resetting adapter: {e}")
            return False
    
    def _detect_protocol(self) -> bool:
        """Detect vehicle protocol."""
        try:
            # Set protocol to auto-detect
            response = self.adapter_manager.send_command("ATSP0", timeout=2.0)
            
            if not response or "OK" not in response:
                logger.error("Failed to set auto-detect protocol")
                return False
            
            # Try to connect to vehicle with a simple command
            response = self.adapter_manager.send_command("0100", timeout=10.0)
            
            if not response:
                logger.error("No response from vehicle during protocol detection")
                return False
            
            # Get protocol information
            protocol_response = self.adapter_manager.send_command("ATDP", timeout=2.0)
            
            if protocol_response:
                self._parse_protocol_info(protocol_response)
                logger.info(f"Detected protocol: {self.current_protocol}")
                return True
            else:
                logger.warning("Could not get protocol information")
                # Assume successful if we got a response to 0100
                self.current_protocol = OBDProtocol.AUTO
                return True
                
        except Exception as e:
            logger.error(f"Error detecting protocol: {e}")
            return False
    
    def _parse_protocol_info(self, response: str) -> None:
        """Parse protocol information from adapter response."""
        try:
            response = response.strip().upper()
            
            # Map common responses to protocols
            protocol_map = {
                "ISO 9141-2": OBDProtocol.ISO_9141_2,
                "KWP2000": OBDProtocol.KWP2000_FAST,
                "CAN 11/500": OBDProtocol.CAN_11_500,
                "CAN 29/500": OBDProtocol.CAN_29_500,
                "CAN 11/250": OBDProtocol.CAN_11_250,
                "CAN 29/250": OBDProtocol.CAN_29_250,
                "SAE J1850 PWM": OBDProtocol.J1850_PWM,
                "SAE J1850 VPW": OBDProtocol.J1850_VPW,
            }
            
            # Find matching protocol
            for key, protocol in protocol_map.items():
                if key.upper() in response:
                    self.current_protocol = protocol
                    self.protocol_info['detected'] = response
                    return
            
            # Default to auto if no match
            self.current_protocol = OBDProtocol.AUTO
            self.protocol_info['detected'] = response
            
        except Exception as e:
            logger.error(f"Error parsing protocol info: {e}")
            self.current_protocol = OBDProtocol.AUTO
    
    def _configure_adapter(self) -> bool:
        """Configure adapter settings for optimal performance."""
        try:
            commands = [
                ("ATE0", "Turn off echo"),
                ("ATL0", "Turn off line feeds"),
                ("ATS0", "Turn off spaces"),
                ("ATH1", "Turn on headers"),
                ("ATST96", "Set timeout to 150ms * 4 = 600ms"),
            ]
            
            for command, description in commands:
                response = self.adapter_manager.send_command(command, timeout=2.0)
                if not response or "OK" not in response:
                    logger.warning(f"Failed to {description}: {command}")
                    # Continue anyway, some settings might not be critical
            
            logger.info("Adapter configuration completed")
            return True
            
        except Exception as e:
            logger.error(f"Error configuring adapter: {e}")
            return False
    
    def _is_error_response(self, response: str) -> bool:
        """Check if response indicates an error."""
        if not response:
            return True
        
        error_indicators = [
            "NO DATA",
            "ERROR",
            "STOPPED",
            "UNABLE TO CONNECT",
            "BUS INIT",
            "BUS ERROR",
            "CAN ERROR",
            "FB ERROR",
            "DATA ERROR",
            "LV RESET",
            "?"
        ]
        
        response_upper = response.upper()
        return any(error in response_upper for error in error_indicators)
    
    def set_protocol(self, protocol: OBDProtocol) -> bool:
        """
        Manually set protocol.
        
        Args:
            protocol: Protocol to set
            
        Returns:
            True if successful
        """
        try:
            if protocol not in self.ELM327_PROTOCOLS:
                logger.error(f"Unsupported protocol: {protocol}")
                return False
            
            protocol_num = self.ELM327_PROTOCOLS[protocol]
            command = f"ATSP{protocol_num}"
            
            response = self.adapter_manager.send_command(command, timeout=5.0)
            
            if response and "OK" in response:
                self.current_protocol = protocol
                logger.info(f"Protocol set to: {protocol}")
                return True
            else:
                logger.error(f"Failed to set protocol: {response}")
                return False
                
        except Exception as e:
            logger.error(f"Error setting protocol: {e}")
            return False
    
    def get_current_protocol(self) -> Optional[OBDProtocol]:
        """Get current protocol."""
        return self.current_protocol
    
    def get_protocol_info(self) -> Dict[str, Any]:
        """Get protocol information."""
        return {
            'current_protocol': self.current_protocol.value if self.current_protocol else None,
            'detected_info': self.protocol_info.get('detected', 'Unknown'),
            'initialized': self.initialized
        }
    
    def close(self) -> None:
        """Close protocol handler."""
        try:
            if self.adapter_manager.is_connected():
                # Send close protocol command
                self.adapter_manager.send_command("ATPC", timeout=2.0)
            
            self.initialized = False
            self.current_protocol = None
            self.protocol_info.clear()
            
        except Exception as e:
            logger.error(f"Error closing protocol handler: {e}")