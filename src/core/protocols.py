"""
OBD-II Protocols Module
Supports multiple vehicle communication protocols
"""

from enum import Enum
from typing import Dict, List, Optional
import logging

class OBDProtocol(Enum):
    """Supported OBD protocols"""
    SAE_J1850_PWM = "1"         # 41.6 kbaud
    SAE_J1850_VPW = "2"         # 10.4 kbaud
    ISO_9141_2 = "3"            # 5 baud init
    ISO_14230_4_KWP = "4"       # 5 baud init
    ISO_14230_4_KWP_FAST = "5"  # Fast init
    ISO_15765_4_CAN_11 = "6"    # 11 bit ID, 500 kbaud
    ISO_15765_4_CAN_29 = "7"    # 29 bit ID, 500 kbaud
    ISO_15765_4_CAN_11_250 = "8"  # 11 bit ID, 250 kbaud
    ISO_15765_4_CAN_29_250 = "9"  # 29 bit ID, 250 kbaud
    SAE_J1939_CAN = "A"         # 29 bit ID, 250 kbaud
    USER1_CAN = "B"             # User definable
    USER2_CAN = "C"             # User definable

class ProtocolManager:
    """Manages OBD protocol detection and configuration"""
    
    def __init__(self, obd_interface):
        """
        Initialize protocol manager
        
        Args:
            obd_interface: OBDInterface instance
        """
        self.obd_interface = obd_interface
        self.logger = logging.getLogger(__name__)
        self.current_protocol = None
        self.supported_protocols = []
        
        # Protocol characteristics
        self.protocol_info = {
            OBDProtocol.SAE_J1850_PWM: {
                "name": "SAE J1850 PWM",
                "speed": "41.6 kbaud",
                "description": "Ford and other manufacturers",
                "header_length": 3,
                "supports_can": False
            },
            OBDProtocol.SAE_J1850_VPW: {
                "name": "SAE J1850 VPW", 
                "speed": "10.4 kbaud",
                "description": "GM and other manufacturers",
                "header_length": 3,
                "supports_can": False
            },
            OBDProtocol.ISO_9141_2: {
                "name": "ISO 9141-2",
                "speed": "10.4 kbaud",
                "description": "European and Asian vehicles",
                "header_length": 4,
                "supports_can": False
            },
            OBDProtocol.ISO_14230_4_KWP: {
                "name": "ISO 14230-4 (KWP2000)",
                "speed": "10.4 kbaud",
                "description": "Keyword Protocol 2000",
                "header_length": 4,
                "supports_can": False
            },
            OBDProtocol.ISO_14230_4_KWP_FAST: {
                "name": "ISO 14230-4 (KWP2000 Fast)",
                "speed": "10.4 kbaud",
                "description": "Fast init KWP2000",
                "header_length": 4,
                "supports_can": False
            },
            OBDProtocol.ISO_15765_4_CAN_11: {
                "name": "ISO 15765-4 (CAN)",
                "speed": "500 kbaud",
                "description": "11-bit CAN ID",
                "header_length": 8,
                "supports_can": True
            },
            OBDProtocol.ISO_15765_4_CAN_29: {
                "name": "ISO 15765-4 (CAN)",
                "speed": "500 kbaud", 
                "description": "29-bit CAN ID",
                "header_length": 8,
                "supports_can": True
            },
            OBDProtocol.ISO_15765_4_CAN_11_250: {
                "name": "ISO 15765-4 (CAN)",
                "speed": "250 kbaud",
                "description": "11-bit CAN ID, 250k",
                "header_length": 8,
                "supports_can": True
            },
            OBDProtocol.ISO_15765_4_CAN_29_250: {
                "name": "ISO 15765-4 (CAN)",
                "speed": "250 kbaud",
                "description": "29-bit CAN ID, 250k", 
                "header_length": 8,
                "supports_can": True
            },
            OBDProtocol.SAE_J1939_CAN: {
                "name": "SAE J1939 (CAN)",
                "speed": "250 kbaud",
                "description": "Heavy duty vehicles",
                "header_length": 8,
                "supports_can": True
            }
        }
    
    def detect_protocol(self) -> Optional[OBDProtocol]:
        """
        Auto-detect the vehicle's protocol
        
        Returns:
            OBDProtocol: Detected protocol or None
        """
        self.logger.info("Starting protocol detection...")
        
        # Set to auto protocol detection
        response = self.obd_interface._send_command("ATSP0")
        if not response or "OK" not in response:
            self.logger.error("Failed to set auto protocol mode")
            return None
        
        # Try to communicate with vehicle
        test_response = self.obd_interface.read_pid("01", "00")
        if not test_response:
            self.logger.error("No response from vehicle during protocol detection")
            return None
        
        # Get current protocol
        protocol_response = self.obd_interface._send_command("ATDP")
        if protocol_response:
            detected = self._parse_protocol_response(protocol_response)
            if detected:
                self.current_protocol = detected
                self.logger.info(f"Detected protocol: {self.get_protocol_info(detected)['name']}")
                return detected
        
        return None
    
    def set_protocol(self, protocol: OBDProtocol) -> bool:
        """
        Manually set the communication protocol
        
        Args:
            protocol: Protocol to set
            
        Returns:
            bool: True if successful
        """
        command = f"ATSP{protocol.value}"
        response = self.obd_interface._send_command(command)
        
        if response and "OK" in response:
            self.current_protocol = protocol
            self.logger.info(f"Set protocol to: {self.get_protocol_info(protocol)['name']}")
            return True
        else:
            self.logger.error(f"Failed to set protocol: {protocol.value}")
            return False
    
    def _parse_protocol_response(self, response: str) -> Optional[OBDProtocol]:
        """
        Parse protocol from adapter response
        
        Args:
            response: Raw response from adapter
            
        Returns:
            OBDProtocol: Parsed protocol or None
        """
        # Look for protocol indicators in response
        protocol_mappings = {
            "SAE J1850 PWM": OBDProtocol.SAE_J1850_PWM,
            "SAE J1850 VPW": OBDProtocol.SAE_J1850_VPW,
            "ISO 9141-2": OBDProtocol.ISO_9141_2,
            "ISO 14230-4": OBDProtocol.ISO_14230_4_KWP,
            "ISO 15765-4": OBDProtocol.ISO_15765_4_CAN_11,
            "SAE J1939": OBDProtocol.SAE_J1939_CAN,
        }
        
        response_upper = response.upper()
        for name, protocol in protocol_mappings.items():
            if name.upper() in response_upper:
                return protocol
        
        # Try to match by protocol number
        for protocol in OBDProtocol:
            if protocol.value in response:
                return protocol
        
        return None
    
    def get_protocol_info(self, protocol: OBDProtocol) -> Dict[str, str]:
        """
        Get information about a protocol
        
        Args:
            protocol: Protocol to get info for
            
        Returns:
            dict: Protocol information
        """
        return self.protocol_info.get(protocol, {})
    
    def get_supported_protocols(self) -> List[OBDProtocol]:
        """
        Get list of supported protocols
        
        Returns:
            list: List of supported protocols
        """
        if not self.supported_protocols:
            # Try each protocol to see which are supported
            for protocol in OBDProtocol:
                if self._test_protocol(protocol):
                    self.supported_protocols.append(protocol)
        
        return self.supported_protocols
    
    def _test_protocol(self, protocol: OBDProtocol) -> bool:
        """
        Test if a protocol is supported
        
        Args:
            protocol: Protocol to test
            
        Returns:
            bool: True if supported
        """
        # Save current protocol
        original = self.current_protocol
        
        try:
            # Try to set the protocol
            if self.set_protocol(protocol):
                # Try a simple command
                response = self.obd_interface.read_pid("01", "00")
                success = response is not None
                
                # Restore original protocol
                if original:
                    self.set_protocol(original)
                
                return success
            return False
            
        except Exception as e:
            self.logger.error(f"Error testing protocol {protocol.value}: {e}")
            # Restore original protocol
            if original:
                self.set_protocol(original)
            return False
    
    def is_can_protocol(self, protocol: OBDProtocol = None) -> bool:
        """
        Check if protocol supports CAN
        
        Args:
            protocol: Protocol to check (current if None)
            
        Returns:
            bool: True if CAN protocol
        """
        check_protocol = protocol or self.current_protocol
        if check_protocol:
            return self.protocol_info.get(check_protocol, {}).get("supports_can", False)
        return False
    
    def get_current_protocol_name(self) -> str:
        """
        Get current protocol name
        
        Returns:
            str: Protocol name
        """
        if self.current_protocol:
            return self.get_protocol_info(self.current_protocol).get("name", "Unknown")
        return "None"
    
    def configure_can_filtering(self, can_id: str = None, mask: str = None) -> bool:
        """
        Configure CAN message filtering for advanced diagnostics
        
        Args:
            can_id: CAN ID to filter for
            mask: CAN mask for filtering
            
        Returns:
            bool: True if successful
        """
        if not self.is_can_protocol():
            self.logger.warning("CAN filtering only available for CAN protocols")
            return False
        
        commands = []
        if can_id:
            commands.append(f"ATCF{can_id}")
        if mask:
            commands.append(f"ATCM{mask}")
        
        for cmd in commands:
            response = self.obd_interface._send_command(cmd)
            if not response or "OK" not in response:
                self.logger.error(f"Failed to set CAN filter: {cmd}")
                return False
        
        return True
    
    def send_raw_can_message(self, can_id: str, data: str) -> Optional[str]:
        """
        Send raw CAN message (for advanced programming)
        
        Args:
            can_id: CAN identifier
            data: Data payload in hex
            
        Returns:
            str: Response or None if failed
        """
        if not self.is_can_protocol():
            self.logger.warning("Raw CAN messages only available for CAN protocols")
            return None
        
        # Set CAN ID
        header_cmd = f"ATSH{can_id}"
        response = self.obd_interface._send_command(header_cmd)
        if not response or "OK" not in response:
            return None
        
        # Send data
        return self.obd_interface._send_command(data)