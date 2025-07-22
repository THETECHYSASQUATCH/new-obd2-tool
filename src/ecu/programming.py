"""
ECU Programming Module
Handles ECU programming, flashing, and configuration
"""

import time
import logging
import hashlib
import struct
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass
from enum import Enum

class ECUProgrammingMode(Enum):
    """ECU Programming modes"""
    NORMAL = "normal"
    PROGRAMMING = "programming"
    DIAGNOSTIC = "diagnostic"
    BOOTLOADER = "bootloader"

@dataclass
class ECUInfo:
    """ECU Information"""
    ecu_id: str
    name: str
    part_number: str
    software_version: str
    hardware_version: str
    calibration_id: str
    supports_programming: bool
    memory_layout: Dict[str, Any]

@dataclass
class MemoryBlock:
    """Memory block definition"""
    start_address: int
    end_address: int
    size: int
    block_type: str  # "flash", "eeprom", "ram"
    read_only: bool
    description: str

class ECUProgrammer:
    """Main ECU programming interface"""
    
    def __init__(self, obd_interface, protocol_manager):
        """
        Initialize ECU programmer
        
        Args:
            obd_interface: OBDInterface instance
            protocol_manager: ProtocolManager instance
        """
        self.obd_interface = obd_interface
        self.protocol_manager = protocol_manager
        self.logger = logging.getLogger(__name__)
        self.current_mode = ECUProgrammingMode.NORMAL
        self.connected_ecus = {}
        self.programming_session_active = False
        
        # Standard diagnostic services (ISO 14229)
        self.diagnostic_services = {
            0x10: "Diagnostic Session Control",
            0x11: "ECU Reset",
            0x14: "Clear Diagnostic Information",
            0x19: "Read DTC Information",
            0x22: "Read Data By Identifier",
            0x23: "Read Memory By Address",
            0x27: "Security Access",
            0x2E: "Write Data By Identifier",
            0x31: "Routine Control",
            0x34: "Request Download",
            0x35: "Request Upload",
            0x36: "Transfer Data",
            0x37: "Request Transfer Exit",
            0x3D: "Write Memory By Address",
            0x85: "Control DTC Setting"
        }
    
    def scan_ecus(self) -> Dict[str, ECUInfo]:
        """
        Scan for available ECUs on the network
        
        Returns:
            dict: Dictionary of ECU ID -> ECUInfo
        """
        self.logger.info("Scanning for ECUs...")
        ecus = {}
        
        # Common ECU addresses for different protocols
        if self.protocol_manager.is_can_protocol():
            ecu_addresses = [
                "7E0",  # Engine ECU
                "7E1",  # Transmission ECU
                "7E2",  # ABS/ESP ECU
                "7E3",  # Airbag ECU
                "7E4",  # Climate Control
                "7E5",  # Body Control Module
                "7E8",  # Engine ECU (alternative)
                "7EA",  # Transmission ECU (alternative)
                "7EB",  # ABS ECU (alternative)
            ]
        else:
            # For non-CAN protocols, use standard addressing
            ecu_addresses = ["10", "11", "12", "13", "18", "28"]
        
        for address in ecu_addresses:
            ecu_info = self._probe_ecu(address)
            if ecu_info:
                ecus[address] = ecu_info
                self.connected_ecus[address] = ecu_info
        
        self.logger.info(f"Found {len(ecus)} ECUs")
        return ecus
    
    def _probe_ecu(self, address: str) -> Optional[ECUInfo]:
        """
        Probe a specific ECU address
        
        Args:
            address: ECU address to probe
            
        Returns:
            ECUInfo: ECU information if found
        """
        try:
            # Set target address
            if self.protocol_manager.is_can_protocol():
                self.obd_interface._send_command(f"ATSH{address}")
            
            # Try to read ECU identification
            ecu_info = self._read_ecu_identification(address)
            if ecu_info:
                return ecu_info
                
        except Exception as e:
            self.logger.debug(f"No ECU found at address {address}: {e}")
        
        return None
    
    def _read_ecu_identification(self, address: str) -> Optional[ECUInfo]:
        """
        Read ECU identification information
        
        Args:
            address: ECU address
            
        Returns:
            ECUInfo: ECU information
        """
        try:
            # Service 0x22 - Read Data By Identifier
            # Common Data Identifiers:
            # F186 - ECU Serial Number
            # F187 - ECU Part Number  
            # F188 - ECU Software Version
            # F189 - ECU Hardware Version
            # F18A - System Supplier ECU Name
            # F190 - Vehicle Identification Data
            
            part_number = self._read_data_identifier(address, "F187")
            software_version = self._read_data_identifier(address, "F188")
            hardware_version = self._read_data_identifier(address, "F189")
            ecu_name = self._read_data_identifier(address, "F18A")
            
            if part_number or software_version:
                return ECUInfo(
                    ecu_id=address,
                    name=ecu_name or f"ECU_{address}",
                    part_number=part_number or "Unknown",
                    software_version=software_version or "Unknown",
                    hardware_version=hardware_version or "Unknown",
                    calibration_id="Unknown",
                    supports_programming=True,  # Assume true for now
                    memory_layout={}
                )
        
        except Exception as e:
            self.logger.debug(f"Failed to read ECU identification: {e}")
        
        return None
    
    def _read_data_identifier(self, address: str, identifier: str) -> Optional[str]:
        """
        Read data by identifier from ECU
        
        Args:
            address: ECU address
            identifier: Data identifier (hex)
            
        Returns:
            str: Data value or None
        """
        try:
            # Send read data by identifier request
            command = f"22{identifier}"
            response = self.obd_interface._send_command(command)
            
            if response and "62" in response:  # Positive response
                # Parse response data
                hex_data = response.replace(" ", "")
                if len(hex_data) > 6:  # Skip service ID and identifier
                    data_hex = hex_data[6:]
                    # Convert hex to ASCII
                    try:
                        ascii_data = bytes.fromhex(data_hex).decode('ascii', errors='ignore')
                        return ascii_data.strip()
                    except:
                        return data_hex
        
        except Exception as e:
            self.logger.debug(f"Failed to read identifier {identifier}: {e}")
        
        return None
    
    def enter_programming_mode(self, ecu_address: str) -> bool:
        """
        Enter programming mode for specified ECU
        
        Args:
            ecu_address: ECU address to program
            
        Returns:
            bool: True if successful
        """
        try:
            self.logger.info(f"Entering programming mode for ECU {ecu_address}")
            
            # Set target ECU
            if self.protocol_manager.is_can_protocol():
                self.obd_interface._send_command(f"ATSH{ecu_address}")
            
            # Step 1: Enter programming session
            if not self._start_programming_session():
                return False
            
            # Step 2: Security access
            if not self._perform_security_access():
                return False
            
            # Step 3: Disable DTC setting
            if not self._disable_dtc_setting():
                return False
            
            self.current_mode = ECUProgrammingMode.PROGRAMMING
            self.programming_session_active = True
            self.logger.info("Successfully entered programming mode")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to enter programming mode: {e}")
            return False
    
    def _start_programming_session(self) -> bool:
        """Start programming diagnostic session"""
        # Service 0x10 - Diagnostic Session Control
        # 0x02 = Programming Session
        response = self.obd_interface._send_command("1002")
        return response and "5002" in response
    
    def _perform_security_access(self) -> bool:
        """Perform security access sequence"""
        try:
            # Service 0x27 - Security Access
            # 0x01 = Request Seed
            seed_response = self.obd_interface._send_command("2701")
            
            if not seed_response or "6701" not in seed_response:
                self.logger.warning("Failed to get security seed")
                return False
            
            # Extract seed from response
            hex_data = seed_response.replace(" ", "")
            if len(hex_data) >= 8:
                seed_hex = hex_data[6:]  # Skip service response
                seed = int(seed_hex, 16) if seed_hex else 0
                
                # Calculate key (simplified algorithm - real implementation varies)
                key = self._calculate_security_key(seed)
                
                # Send key
                key_hex = f"{key:04X}"
                key_response = self.obd_interface._send_command(f"2702{key_hex}")
                
                return key_response and "6702" in key_response
            
        except Exception as e:
            self.logger.error(f"Security access failed: {e}")
        
        return False
    
    def _calculate_security_key(self, seed: int) -> int:
        """
        Calculate security key from seed
        Note: This is a simplified example. Real implementations use
        manufacturer-specific algorithms.
        
        Args:
            seed: Security seed
            
        Returns:
            int: Calculated key
        """
        # Simplified key calculation (not for production use)
        # Real implementations require manufacturer-specific algorithms
        return (seed ^ 0x5555) + 0x1234
    
    def _disable_dtc_setting(self) -> bool:
        """Disable DTC setting during programming"""
        # Service 0x85 - Control DTC Setting
        # 0x02 = Off
        response = self.obd_interface._send_command("8502")
        return response and "C502" in response
    
    def exit_programming_mode(self) -> bool:
        """
        Exit programming mode and return to normal operation
        
        Returns:
            bool: True if successful
        """
        try:
            self.logger.info("Exiting programming mode")
            
            # Re-enable DTC setting
            self.obd_interface._send_command("8501")  # DTC setting on
            
            # Return to default session
            self.obd_interface._send_command("1001")  # Default session
            
            # Reset ECU
            self.obd_interface._send_command("1101")  # Hard reset
            
            self.current_mode = ECUProgrammingMode.NORMAL
            self.programming_session_active = False
            
            # Wait for ECU to restart
            time.sleep(3)
            
            self.logger.info("Exited programming mode")
            return True
            
        except Exception as e:
            self.logger.error(f"Error exiting programming mode: {e}")
            return False
    
    def read_memory(self, start_address: int, size: int) -> Optional[bytes]:
        """
        Read memory from ECU
        
        Args:
            start_address: Starting memory address
            size: Number of bytes to read
            
        Returns:
            bytes: Memory data or None if failed
        """
        if not self.programming_session_active:
            self.logger.error("Programming session not active")
            return None
        
        try:
            # Service 0x23 - Read Memory By Address
            address_hex = f"{start_address:08X}"
            size_hex = f"{size:04X}"
            
            command = f"23{address_hex}{size_hex}"
            response = self.obd_interface._send_command(command, timeout=10.0)
            
            if response and "63" in response:  # Positive response
                hex_data = response.replace(" ", "")
                data_hex = hex_data[2:]  # Skip service response
                return bytes.fromhex(data_hex)
            
        except Exception as e:
            self.logger.error(f"Memory read failed: {e}")
        
        return None
    
    def write_memory(self, start_address: int, data: bytes) -> bool:
        """
        Write memory to ECU
        
        Args:
            start_address: Starting memory address
            data: Data to write
            
        Returns:
            bool: True if successful
        """
        if not self.programming_session_active:
            self.logger.error("Programming session not active")
            return False
        
        try:
            # Service 0x3D - Write Memory By Address
            address_hex = f"{start_address:08X}"
            size_hex = f"{len(data):04X}"
            data_hex = data.hex().upper()
            
            command = f"3D{address_hex}{size_hex}{data_hex}"
            response = self.obd_interface._send_command(command, timeout=10.0)
            
            return response and "7D" in response  # Positive response
            
        except Exception as e:
            self.logger.error(f"Memory write failed: {e}")
            return False
    
    def flash_firmware(self, firmware_data: bytes, verify: bool = True) -> bool:
        """
        Flash firmware to ECU
        
        Args:
            firmware_data: Firmware binary data
            verify: Whether to verify after flashing
            
        Returns:
            bool: True if successful
        """
        if not self.programming_session_active:
            self.logger.error("Programming session not active")
            return False
        
        try:
            self.logger.info(f"Starting firmware flash ({len(firmware_data)} bytes)")
            
            # Step 1: Erase flash memory
            if not self._erase_flash_memory():
                return False
            
            # Step 2: Request download
            if not self._request_download(len(firmware_data)):
                return False
            
            # Step 3: Transfer data in blocks
            block_size = 256  # Typical block size
            total_blocks = (len(firmware_data) + block_size - 1) // block_size
            
            for block_num in range(total_blocks):
                start_idx = block_num * block_size
                end_idx = min(start_idx + block_size, len(firmware_data))
                block_data = firmware_data[start_idx:end_idx]
                
                if not self._transfer_data_block(block_num + 1, block_data):
                    self.logger.error(f"Failed to transfer block {block_num + 1}")
                    return False
                
                # Progress update
                progress = (block_num + 1) / total_blocks * 100
                self.logger.info(f"Flash progress: {progress:.1f}%")
            
            # Step 4: Request transfer exit
            if not self._request_transfer_exit():
                return False
            
            # Step 5: Verify if requested
            if verify:
                if not self._verify_firmware(firmware_data):
                    self.logger.error("Firmware verification failed")
                    return False
            
            self.logger.info("Firmware flash completed successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Firmware flash failed: {e}")
            return False
    
    def _erase_flash_memory(self) -> bool:
        """Erase flash memory"""
        # Service 0x31 - Routine Control
        # 0x01 = Start Routine
        # 0xFF00 = Erase Memory routine (example)
        response = self.obd_interface._send_command("310101FF00", timeout=30.0)
        return response and "7101" in response
    
    def _request_download(self, data_size: int) -> bool:
        """Request download session"""
        # Service 0x34 - Request Download
        # Format: 34 [dataFormatIdentifier] [addressAndLengthFormatIdentifier] [memoryAddress] [memorySize]
        address_hex = "00000000"  # Start at beginning of flash
        size_hex = f"{data_size:08X}"
        
        command = f"3400{address_hex}{size_hex}"
        response = self.obd_interface._send_command(command, timeout=5.0)
        return response and "74" in response
    
    def _transfer_data_block(self, block_number: int, data: bytes) -> bool:
        """Transfer a single data block"""
        # Service 0x36 - Transfer Data
        block_num_hex = f"{block_number:02X}"
        data_hex = data.hex().upper()
        
        command = f"36{block_num_hex}{data_hex}"
        response = self.obd_interface._send_command(command, timeout=5.0)
        return response and "76" in response
    
    def _request_transfer_exit(self) -> bool:
        """Request transfer exit"""
        # Service 0x37 - Request Transfer Exit
        response = self.obd_interface._send_command("37", timeout=5.0)
        return response and "77" in response
    
    def _verify_firmware(self, expected_data: bytes) -> bool:
        """Verify flashed firmware"""
        try:
            # Calculate checksum of expected data
            expected_checksum = hashlib.md5(expected_data).hexdigest()
            
            # Read back firmware and calculate checksum
            read_data = self.read_memory(0x00000000, len(expected_data))
            if not read_data:
                return False
            
            actual_checksum = hashlib.md5(read_data).hexdigest()
            
            if expected_checksum == actual_checksum:
                self.logger.info("Firmware verification successful")
                return True
            else:
                self.logger.error("Firmware verification failed - checksum mismatch")
                return False
                
        except Exception as e:
            self.logger.error(f"Firmware verification error: {e}")
            return False
    
    def backup_ecu_firmware(self, output_file: str) -> bool:
        """
        Backup ECU firmware to file
        
        Args:
            output_file: Output file path
            
        Returns:
            bool: True if successful
        """
        try:
            self.logger.info(f"Backing up ECU firmware to {output_file}")
            
            # Determine firmware size (typically need to read memory layout)
            # For this example, assume 1MB flash
            firmware_size = 1024 * 1024
            
            # Read firmware in chunks
            chunk_size = 1024
            firmware_data = b""
            
            for offset in range(0, firmware_size, chunk_size):
                chunk = self.read_memory(offset, min(chunk_size, firmware_size - offset))
                if not chunk:
                    self.logger.error(f"Failed to read firmware at offset {offset:08X}")
                    return False
                
                firmware_data += chunk
                
                progress = (offset + len(chunk)) / firmware_size * 100
                self.logger.info(f"Backup progress: {progress:.1f}%")
            
            # Write to file
            with open(output_file, 'wb') as f:
                f.write(firmware_data)
            
            self.logger.info(f"Firmware backup completed: {len(firmware_data)} bytes")
            return True
            
        except Exception as e:
            self.logger.error(f"Firmware backup failed: {e}")
            return False
    
    def load_firmware_file(self, firmware_file: str) -> Optional[bytes]:
        """
        Load firmware from file
        
        Args:
            firmware_file: Firmware file path
            
        Returns:
            bytes: Firmware data or None if failed
        """
        try:
            with open(firmware_file, 'rb') as f:
                firmware_data = f.read()
            
            self.logger.info(f"Loaded firmware file: {len(firmware_data)} bytes")
            return firmware_data
            
        except Exception as e:
            self.logger.error(f"Failed to load firmware file: {e}")
            return None
    
    def get_ecu_status(self, ecu_address: str) -> Dict[str, Any]:
        """
        Get current ECU status and information
        
        Args:
            ecu_address: ECU address
            
        Returns:
            dict: ECU status information
        """
        status = {
            "address": ecu_address,
            "connected": False,
            "mode": self.current_mode.value,
            "programming_session": self.programming_session_active,
            "error_count": 0,
            "last_error": None
        }
        
        try:
            # Set target ECU
            if self.protocol_manager.is_can_protocol():
                self.obd_interface._send_command(f"ATSH{ecu_address}")
            
            # Try to read a basic identifier
            response = self._read_data_identifier(ecu_address, "F186")
            if response:
                status["connected"] = True
            
            # Read DTC count
            dtc_response = self.obd_interface._send_command("1901")
            if dtc_response:
                # Parse DTC count from response
                hex_data = dtc_response.replace(" ", "")
                if len(hex_data) >= 8:
                    dtc_count_hex = hex_data[6:8]
                    status["error_count"] = int(dtc_count_hex, 16)
                    
        except Exception as e:
            status["last_error"] = str(e)
        
        return status