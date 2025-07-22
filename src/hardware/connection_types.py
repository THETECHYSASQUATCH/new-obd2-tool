"""
Connection types for OBD-II adapters
"""

import logging
from abc import ABC, abstractmethod
from typing import Optional, Dict, Any
from enum import Enum

logger = logging.getLogger(__name__)


class ConnectionType(Enum):
    """Types of connections supported"""
    USB_SERIAL = "USB/Serial"
    BLUETOOTH = "Bluetooth" 
    WIFI = "Wi-Fi"
    ETHERNET = "Ethernet"


class BaseConnection(ABC):
    """Base class for all connection types"""
    
    def __init__(self, connection_params: Dict[str, Any]):
        """
        Initialize connection.
        
        Args:
            connection_params: Connection parameters
        """
        self.connection_params = connection_params
        self.is_open = False
        self.timeout = connection_params.get('timeout', 5.0)
    
    @abstractmethod
    def open(self) -> bool:
        """
        Open connection.
        
        Returns:
            True if successful
        """
        pass
    
    @abstractmethod
    def close(self) -> None:
        """Close connection."""
        pass
    
    @abstractmethod
    def send(self, data: str) -> bool:
        """
        Send data.
        
        Args:
            data: Data to send
            
        Returns:
            True if successful
        """
        pass
    
    @abstractmethod
    def receive(self, timeout: Optional[float] = None) -> Optional[str]:
        """
        Receive data.
        
        Args:
            timeout: Receive timeout
            
        Returns:
            Received data or None
        """
        pass
    
    @abstractmethod
    def is_connected(self) -> bool:
        """
        Check if connection is active.
        
        Returns:
            True if connected
        """
        pass
    
    def get_info(self) -> Dict[str, Any]:
        """Get connection information."""
        return {
            'type': self.__class__.__name__,
            'params': self.connection_params.copy(),
            'connected': self.is_connected()
        }


class SerialConnection(BaseConnection):
    """Serial/USB connection implementation"""
    
    def __init__(self, connection_params: Dict[str, Any]):
        """
        Initialize serial connection.
        
        Args:
            connection_params: Must include 'port' and optionally 'baudrate'
        """
        super().__init__(connection_params)
        self.serial_port = None
        self.port = connection_params.get('port')
        self.baudrate = connection_params.get('baudrate', 38400)
        
        if not self.port:
            raise ValueError("Serial port must be specified")
    
    def open(self) -> bool:
        """Open serial connection."""
        try:
            import serial
            
            self.serial_port = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                bytesize=serial.EIGHTBITS
            )
            
            if self.serial_port.is_open:
                self.is_open = True
                logger.info(f"Serial connection opened: {self.port}@{self.baudrate}")
                return True
            else:
                logger.error("Failed to open serial port")
                return False
                
        except Exception as e:
            logger.error(f"Error opening serial connection: {e}")
            return False
    
    def close(self) -> None:
        """Close serial connection."""
        try:
            if self.serial_port and self.serial_port.is_open:
                self.serial_port.close()
                logger.info("Serial connection closed")
            self.is_open = False
        except Exception as e:
            logger.error(f"Error closing serial connection: {e}")
    
    def send(self, data: str) -> bool:
        """Send data over serial connection."""
        try:
            if not self.is_connected():
                return False
            
            # Add carriage return if not present
            if not data.endswith('\r'):
                data += '\r'
            
            self.serial_port.write(data.encode('ascii'))
            self.serial_port.flush()
            return True
            
        except Exception as e:
            logger.error(f"Error sending data: {e}")
            return False
    
    def receive(self, timeout: Optional[float] = None) -> Optional[str]:
        """Receive data from serial connection."""
        try:
            if not self.is_connected():
                return None
            
            if timeout is not None:
                original_timeout = self.serial_port.timeout
                self.serial_port.timeout = timeout
            
            # Read until carriage return or timeout
            response = self.serial_port.read_until(b'\r').decode('ascii', errors='ignore')
            
            if timeout is not None:
                self.serial_port.timeout = original_timeout
            
            return response.strip() if response else None
            
        except Exception as e:
            logger.error(f"Error receiving data: {e}")
            return None
    
    def is_connected(self) -> bool:
        """Check if serial connection is active."""
        return self.is_open and self.serial_port and self.serial_port.is_open


class BluetoothConnection(BaseConnection):
    """Bluetooth connection implementation"""
    
    def __init__(self, connection_params: Dict[str, Any]):
        """
        Initialize Bluetooth connection.
        
        Args:
            connection_params: Must include 'address' and optionally 'port'
        """
        super().__init__(connection_params)
        self.socket = None
        self.address = connection_params.get('address')
        self.port = connection_params.get('port', 1)  # Default RFCOMM port
        
        if not self.address:
            raise ValueError("Bluetooth address must be specified")
    
    def open(self) -> bool:
        """Open Bluetooth connection."""
        try:
            import bluetooth
            
            self.socket = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
            self.socket.settimeout(self.timeout)
            self.socket.connect((self.address, self.port))
            
            self.is_open = True
            logger.info(f"Bluetooth connection opened: {self.address}:{self.port}")
            return True
            
        except ImportError:
            logger.error("Bluetooth support not available (pybluez not installed)")
            return False
        except Exception as e:
            logger.error(f"Error opening Bluetooth connection: {e}")
            return False
    
    def close(self) -> None:
        """Close Bluetooth connection."""
        try:
            if self.socket:
                self.socket.close()
                logger.info("Bluetooth connection closed")
            self.is_open = False
        except Exception as e:
            logger.error(f"Error closing Bluetooth connection: {e}")
    
    def send(self, data: str) -> bool:
        """Send data over Bluetooth connection."""
        try:
            if not self.is_connected():
                return False
            
            # Add carriage return if not present
            if not data.endswith('\r'):
                data += '\r'
            
            self.socket.send(data.encode('ascii'))
            return True
            
        except Exception as e:
            logger.error(f"Error sending data: {e}")
            return False
    
    def receive(self, timeout: Optional[float] = None) -> Optional[str]:
        """Receive data from Bluetooth connection."""
        try:
            if not self.is_connected():
                return None
            
            if timeout is not None:
                self.socket.settimeout(timeout)
            
            # Read data until carriage return
            response = ""
            while True:
                chunk = self.socket.recv(1).decode('ascii', errors='ignore')
                if not chunk or chunk == '\r':
                    break
                response += chunk
            
            return response.strip() if response else None
            
        except Exception as e:
            logger.error(f"Error receiving data: {e}")
            return None
    
    def is_connected(self) -> bool:
        """Check if Bluetooth connection is active."""
        return self.is_open and self.socket


class WiFiConnection(BaseConnection):
    """Wi-Fi/Network connection implementation"""
    
    def __init__(self, connection_params: Dict[str, Any]):
        """
        Initialize Wi-Fi connection.
        
        Args:
            connection_params: Must include 'host' and 'port'
        """
        super().__init__(connection_params)
        self.socket = None
        self.host = connection_params.get('host')
        self.port = connection_params.get('port', 35000)  # Common OBD-II Wi-Fi port
        
        if not self.host:
            raise ValueError("Host address must be specified")
    
    def open(self) -> bool:
        """Open Wi-Fi connection."""
        try:
            import socket
            
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.settimeout(self.timeout)
            self.socket.connect((self.host, self.port))
            
            self.is_open = True
            logger.info(f"Wi-Fi connection opened: {self.host}:{self.port}")
            return True
            
        except Exception as e:
            logger.error(f"Error opening Wi-Fi connection: {e}")
            return False
    
    def close(self) -> None:
        """Close Wi-Fi connection."""
        try:
            if self.socket:
                self.socket.close()
                logger.info("Wi-Fi connection closed")
            self.is_open = False
        except Exception as e:
            logger.error(f"Error closing Wi-Fi connection: {e}")
    
    def send(self, data: str) -> bool:
        """Send data over Wi-Fi connection."""
        try:
            if not self.is_connected():
                return False
            
            # Add carriage return if not present
            if not data.endswith('\r'):
                data += '\r'
            
            self.socket.send(data.encode('ascii'))
            return True
            
        except Exception as e:
            logger.error(f"Error sending data: {e}")
            return False
    
    def receive(self, timeout: Optional[float] = None) -> Optional[str]:
        """Receive data from Wi-Fi connection."""
        try:
            if not self.is_connected():
                return None
            
            if timeout is not None:
                self.socket.settimeout(timeout)
            
            # Read data until carriage return
            response = ""
            while True:
                chunk = self.socket.recv(1).decode('ascii', errors='ignore')
                if not chunk or chunk == '\r':
                    break
                response += chunk
            
            return response.strip() if response else None
            
        except Exception as e:
            logger.error(f"Error receiving data: {e}")
            return None
    
    def is_connected(self) -> bool:
        """Check if Wi-Fi connection is active."""
        return self.is_open and self.socket


def create_connection(connection_type: ConnectionType, params: Dict[str, Any]) -> BaseConnection:
    """
    Factory function to create connection objects.
    
    Args:
        connection_type: Type of connection to create
        params: Connection parameters
        
    Returns:
        Connection object
        
    Raises:
        ValueError: If connection type is not supported
    """
    if connection_type == ConnectionType.USB_SERIAL:
        return SerialConnection(params)
    elif connection_type == ConnectionType.BLUETOOTH:
        return BluetoothConnection(params)
    elif connection_type == ConnectionType.WIFI:
        return WiFiConnection(params)
    else:
        raise ValueError(f"Unsupported connection type: {connection_type}")