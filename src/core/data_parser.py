"""
Data Parser for OBD-II responses
"""

import logging
from typing import List, Optional, Dict, Any, Union

logger = logging.getLogger(__name__)


class DataParser:
    """Parses OBD-II response data"""
    
    def __init__(self):
        """Initialize data parser."""
        pass
    
    def parse_response(self, command: str, response: str) -> Optional[List[int]]:
        """
        Parse OBD-II response data.
        
        Args:
            command: Original command sent
            response: Raw response from adapter
            
        Returns:
            Parsed data as list of bytes or None if parsing failed
        """
        try:
            # Clean response
            cleaned = self._clean_response(response)
            
            if not cleaned:
                return None
            
            # Verify response matches command
            if not self._verify_response(command, cleaned):
                logger.warning(f"Response doesn't match command: {command} -> {cleaned}")
                return None
            
            # Extract data bytes
            return self._extract_data_bytes(command, cleaned)
            
        except Exception as e:
            logger.error(f"Error parsing response: {e}")
            return None
    
    def _clean_response(self, response: str) -> str:
        """
        Clean raw response from adapter.
        
        Args:
            response: Raw response string
            
        Returns:
            Cleaned response string
        """
        if not response:
            return ""
        
        # Remove common prefixes/suffixes
        cleaned = response.strip()
        
        # Remove line endings and extra whitespace
        cleaned = ' '.join(cleaned.split())
        
        # Remove spaces between hex digits
        cleaned = cleaned.replace(' ', '')
        
        # Convert to uppercase
        cleaned = cleaned.upper()
        
        # Remove common error responses
        error_responses = ['NO DATA', 'ERROR', 'STOPPED', 'UNABLE TO CONNECT', '?']
        if any(err in cleaned for err in error_responses):
            return ""
        
        return cleaned
    
    def _verify_response(self, command: str, response: str) -> bool:
        """
        Verify response matches command.
        
        Args:
            command: Original command
            response: Cleaned response
            
        Returns:
            True if response is valid for command
        """
        if not command or not response:
            return False
        
        # For OBD-II commands, response should start with (command_byte + 0x40)
        try:
            if len(command) >= 2:
                command_byte = int(command[:2], 16)
                expected_response = f"{command_byte + 0x40:02X}"
                
                if response.startswith(expected_response):
                    return True
            
            return False
            
        except ValueError:
            return False
    
    def _extract_data_bytes(self, command: str, response: str) -> List[int]:
        """
        Extract data bytes from response.
        
        Args:
            command: Original command
            response: Cleaned response
            
        Returns:
            List of data bytes
        """
        try:
            # Skip response header (mode + PID)
            if len(response) >= 4:
                data_part = response[4:]  # Skip first 2 bytes (response header)
                
                # Convert hex string to bytes
                data_bytes = []
                for i in range(0, len(data_part), 2):
                    if i + 1 < len(data_part):
                        byte_str = data_part[i:i+2]
                        data_bytes.append(int(byte_str, 16))
                
                return data_bytes
            
            return []
            
        except ValueError as e:
            logger.error(f"Error extracting data bytes: {e}")
            return []
    
    def parse_supported_pids(self, response: str, base_pid: int) -> List[int]:
        """
        Parse supported PIDs response.
        
        Args:
            response: Response to PID support query
            base_pid: Base PID number (e.g., 0x01 for PIDs 1-32)
            
        Returns:
            List of supported PID numbers
        """
        try:
            data_bytes = self.parse_response(f"01{base_pid:02X}", response)
            
            if not data_bytes or len(data_bytes) < 4:
                return []
            
            supported_pids = []
            
            # Check each bit in the 4-byte response
            for byte_idx, byte_val in enumerate(data_bytes):
                for bit_idx in range(8):
                    if byte_val & (0x80 >> bit_idx):
                        pid_num = base_pid + (byte_idx * 8) + bit_idx
                        supported_pids.append(pid_num)
            
            return supported_pids
            
        except Exception as e:
            logger.error(f"Error parsing supported PIDs: {e}")
            return []
    
    def parse_vin(self, response: str) -> Optional[str]:
        """
        Parse VIN from Mode 09, PID 02 response.
        
        Args:
            response: VIN response data
            
        Returns:
            VIN string or None
        """
        try:
            # VIN response format varies by vehicle
            # This is a simplified implementation
            data_bytes = self.parse_response("0902", response)
            
            if not data_bytes:
                return None
            
            # Convert bytes to ASCII characters
            vin_chars = []
            for byte_val in data_bytes:
                if 32 <= byte_val <= 126:  # Printable ASCII
                    vin_chars.append(chr(byte_val))
            
            vin = ''.join(vin_chars).strip()
            
            # VIN should be 17 characters
            if len(vin) == 17:
                return vin
            
            return None
            
        except Exception as e:
            logger.error(f"Error parsing VIN: {e}")
            return None
    
    def parse_ascii(self, response: str) -> Optional[str]:
        """
        Parse ASCII data from response.
        
        Args:
            response: Response containing ASCII data
            
        Returns:
            ASCII string or None
        """
        try:
            # Extract data part (skip mode and PID)
            cleaned = self._clean_response(response)
            if len(cleaned) >= 4:
                data_part = cleaned[4:]
                
                # Convert hex to ASCII
                ascii_chars = []
                for i in range(0, len(data_part), 2):
                    if i + 1 < len(data_part):
                        byte_str = data_part[i:i+2]
                        byte_val = int(byte_str, 16)
                        if 32 <= byte_val <= 126:  # Printable ASCII
                            ascii_chars.append(chr(byte_val))
                
                return ''.join(ascii_chars).strip()
            
            return None
            
        except Exception as e:
            logger.error(f"Error parsing ASCII: {e}")
            return None
    
    def calculate_checksum(self, data: str) -> int:
        """
        Calculate checksum for data.
        
        Args:
            data: Hex data string
            
        Returns:
            Checksum value
        """
        try:
            checksum = 0
            for i in range(0, len(data), 2):
                if i + 1 < len(data):
                    byte_val = int(data[i:i+2], 16)
                    checksum += byte_val
            
            return checksum & 0xFF
            
        except Exception as e:
            logger.error(f"Error calculating checksum: {e}")
            return 0
    
    def format_hex_data(self, data: Union[str, List[int]], separator: str = " ") -> str:
        """
        Format hex data for display.
        
        Args:
            data: Data to format (hex string or byte list)
            separator: Separator between bytes
            
        Returns:
            Formatted hex string
        """
        try:
            if isinstance(data, str):
                # Add separators to hex string
                formatted = separator.join(data[i:i+2] for i in range(0, len(data), 2))
                return formatted.upper()
            elif isinstance(data, list):
                # Convert byte list to hex string
                hex_bytes = [f"{byte:02X}" for byte in data]
                return separator.join(hex_bytes)
            else:
                return str(data)
                
        except Exception as e:
            logger.error(f"Error formatting hex data: {e}")
            return str(data)
    
    def validate_response_format(self, response: str) -> bool:
        """
        Validate response format.
        
        Args:
            response: Response to validate
            
        Returns:
            True if format is valid
        """
        try:
            cleaned = self._clean_response(response)
            
            # Check if it's valid hex
            if not cleaned:
                return False
            
            # Must be even length (complete bytes)
            if len(cleaned) % 2 != 0:
                return False
            
            # Try to parse as hex
            for i in range(0, len(cleaned), 2):
                int(cleaned[i:i+2], 16)
            
            return True
            
        except ValueError:
            return False
        except Exception as e:
            logger.error(f"Error validating response format: {e}")
            return False