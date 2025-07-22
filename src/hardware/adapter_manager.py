"""
Adapter Manager - Manages different types of OBD-II adapters
"""

import logging
from typing import Optional, Dict, Any, List
from enum import Enum

from .connection_types import ConnectionType, create_connection
from .elm327 import ELM327Adapter

logger = logging.getLogger(__name__)


class AdapterType(Enum):
    """Types of OBD-II adapters supported"""
    ELM327 = "ELM327"
    GENERIC = "Generic"


class AdapterManager:
    """Manages OBD-II adapter connections and communication"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize adapter manager.
        
        Args:
            config: Configuration dictionary
        """
        self.config = config
        self.connection = None
        self.adapter = None
        self.adapter_type = None
        self.connected = False
    
    def scan_ports(self) -> List[Dict[str, str]]:
        """
        Scan for available serial ports.
        
        Returns:
            List of port information dictionaries
        """
        ports = []
        
        try:
            import serial.tools.list_ports
            
            for port in serial.tools.list_ports.comports():
                port_info = {
                    'device': port.device,
                    'description': port.description,
                    'manufacturer': getattr(port, 'manufacturer', 'Unknown'),
                    'product': getattr(port, 'product', 'Unknown'),
                    'vid': getattr(port, 'vid', None),
                    'pid': getattr(port, 'pid', None),
                }
                ports.append(port_info)
                
        except ImportError:
            logger.error("pyserial not available for port scanning")
        except Exception as e:
            logger.error(f"Error scanning ports: {e}")
        
        return ports
    
    def auto_detect_adapter(self) -> Optional[str]:
        """
        Auto-detect OBD-II adapter.
        
        Returns:
            Port name if adapter found, None otherwise
        """
        logger.info("Starting auto-detection of OBD-II adapter")
        
        # Scan available ports
        ports = self.scan_ports()
        
        for port_info in ports:
            port = port_info['device']
            logger.info(f"Testing port: {port}")
            
            try:
                # Test connection with this port
                test_config = {
                    'port': port,
                    'baudrate': self.config.get('baudrate', 38400),
                    'timeout': 3.0
                }
                
                if self._test_port(test_config):
                    logger.info(f"OBD-II adapter found on port: {port}")
                    return port
                    
            except Exception as e:
                logger.debug(f"Port {port} test failed: {e}")
                continue
        
        logger.warning("No OBD-II adapter found during auto-detection")
        return None
    
    def _test_port(self, connection_params: Dict[str, Any]) -> bool:
        """
        Test if a port has an OBD-II adapter.
        
        Args:
            connection_params: Connection parameters to test
            
        Returns:
            True if adapter found
        """
        try:
            # Create test connection
            test_connection = create_connection(ConnectionType.USB_SERIAL, connection_params)
            
            if not test_connection.open():
                return False
            
            # Create test adapter
            test_adapter = ELM327Adapter(test_connection)
            
            # Try to initialize
            success = test_adapter.initialize()
            
            # Clean up
            test_adapter.close()
            test_connection.close()
            
            return success
            
        except Exception as e:
            logger.debug(f"Port test error: {e}")
            return False
    
    def connect(self, connection_type: Optional[ConnectionType] = None, 
                connection_params: Optional[Dict[str, Any]] = None,
                adapter_type: Optional[AdapterType] = None) -> bool:
        """
        Connect to OBD-II adapter.
        
        Args:
            connection_type: Type of connection (defaults to USB_SERIAL)
            connection_params: Connection parameters (uses config if None)
            adapter_type: Type of adapter (defaults to ELM327)
            
        Returns:
            True if connection successful
        """
        try:
            # Use defaults if not specified
            if connection_type is None:
                connection_type = ConnectionType.USB_SERIAL
            
            if adapter_type is None:
                adapter_type = AdapterType.ELM327
            
            if connection_params is None:
                connection_params = self._get_default_connection_params()
            
            # Auto-detect port if needed
            if connection_params.get('port') == 'auto':
                detected_port = self.auto_detect_adapter()
                if detected_port:
                    connection_params['port'] = detected_port
                else:
                    logger.error("Auto-detection failed and no manual port specified")
                    return False
            
            # Create connection
            self.connection = create_connection(connection_type, connection_params)
            
            if not self.connection.open():
                logger.error("Failed to open connection")
                return False
            
            # Create adapter
            if adapter_type == AdapterType.ELM327:
                self.adapter = ELM327Adapter(self.connection)
            else:
                logger.error(f"Unsupported adapter type: {adapter_type}")
                self.connection.close()
                return False
            
            # Initialize adapter
            if not self.adapter.initialize():
                logger.error("Failed to initialize adapter")
                self.connection.close()
                return False
            
            self.adapter_type = adapter_type
            self.connected = True
            
            logger.info(f"Successfully connected to {adapter_type.value} adapter")
            return True
            
        except Exception as e:
            logger.error(f"Error connecting to adapter: {e}")
            self.disconnect()
            return False
    
    def disconnect(self) -> None:
        """Disconnect from adapter."""
        try:
            if self.adapter:
                self.adapter.close()
                self.adapter = None
            
            if self.connection:
                self.connection.close()
                self.connection = None
            
            self.connected = False
            self.adapter_type = None
            
            logger.info("Disconnected from adapter")
            
        except Exception as e:
            logger.error(f"Error disconnecting from adapter: {e}")
    
    def is_connected(self) -> bool:
        """
        Check if adapter is connected.
        
        Returns:
            True if connected
        """
        return (self.connected and 
                self.connection and self.connection.is_connected() and
                self.adapter and self.adapter.initialized)
    
    def send_command(self, command: str, timeout: float = 5.0) -> Optional[str]:
        """
        Send command to adapter.
        
        Args:
            command: Command to send
            timeout: Command timeout
            
        Returns:
            Response string or None
        """
        if not self.is_connected():
            logger.error("Adapter not connected")
            return None
        
        try:
            return self.adapter.send_command(command, timeout)
        except Exception as e:
            logger.error(f"Error sending command: {e}")
            return None
    
    def get_adapter_info(self) -> Dict[str, Any]:
        """
        Get adapter information.
        
        Returns:
            Adapter information dictionary
        """
        if not self.adapter:
            return {'connected': False}
        
        return self.adapter.get_adapter_info()
    
    def get_connection_info(self) -> Dict[str, Any]:
        """
        Get connection information.
        
        Returns:
            Connection information dictionary
        """
        if not self.connection:
            return {'connected': False}
        
        return self.connection.get_info()
    
    def _get_default_connection_params(self) -> Dict[str, Any]:
        """Get default connection parameters from config."""
        return {
            'port': self.config.get('port', 'auto'),
            'baudrate': self.config.get('baudrate', 38400),
            'timeout': self.config.get('timeout', 5.0)
        }
    
    def test_communication(self) -> bool:
        """
        Test communication with vehicle.
        
        Returns:
            True if communication successful
        """
        if not self.is_connected():
            return False
        
        try:
            return self.adapter.test_connection()
        except Exception as e:
            logger.error(f"Error testing communication: {e}")
            return False
    
    def get_supported_features(self) -> List[str]:
        """
        Get list of supported features.
        
        Returns:
            List of feature names
        """
        features = ['Basic OBD-II Communication']
        
        if self.adapter_type == AdapterType.ELM327:
            features.extend([
                'Multiple Protocol Support',
                'Diagnostic Trouble Codes',
                'Live Data Monitoring',
                'Freeze Frame Data',
                'Vehicle Information'
            ])
        
        return features