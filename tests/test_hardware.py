"""
Tests for hardware communication functionality
"""

import unittest
import sys
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

# Add src directory to path
src_path = Path(__file__).parent.parent / "src"
sys.path.insert(0, str(src_path))

from src.hardware.connection_types import (
    SerialConnection, BluetoothConnection, WiFiConnection,
    ConnectionType, create_connection
)
from src.hardware.elm327 import ELM327Adapter
from src.hardware.adapter_manager import AdapterManager


class TestConnectionTypes(unittest.TestCase):
    """Test cases for connection types"""
    
    def test_create_connection_factory(self):
        """Test connection factory function."""
        # Test USB/Serial connection creation
        params = {'port': '/dev/ttyUSB0', 'baudrate': 38400}
        conn = create_connection(ConnectionType.USB_SERIAL, params)
        self.assertIsInstance(conn, SerialConnection)
        
        # Test Bluetooth connection creation
        params = {'address': '00:11:22:33:44:55', 'port': 1}
        conn = create_connection(ConnectionType.BLUETOOTH, params)
        self.assertIsInstance(conn, BluetoothConnection)
        
        # Test Wi-Fi connection creation
        params = {'host': '192.168.1.100', 'port': 35000}
        conn = create_connection(ConnectionType.WIFI, params)
        self.assertIsInstance(conn, WiFiConnection)
        
        # Test unsupported connection type
        with self.assertRaises(ValueError):
            create_connection(ConnectionType.ETHERNET, {})
    
    def test_serial_connection_params(self):
        """Test serial connection parameter validation."""
        # Valid parameters
        params = {'port': '/dev/ttyUSB0', 'baudrate': 38400}
        conn = SerialConnection(params)
        self.assertEqual(conn.port, '/dev/ttyUSB0')
        self.assertEqual(conn.baudrate, 38400)
        
        # Missing port parameter
        with self.assertRaises(ValueError):
            SerialConnection({})
        
        # Default baudrate
        params = {'port': '/dev/ttyUSB0'}
        conn = SerialConnection(params)
        self.assertEqual(conn.baudrate, 38400)
    
    def test_bluetooth_connection_params(self):
        """Test Bluetooth connection parameter validation."""
        # Valid parameters
        params = {'address': '00:11:22:33:44:55', 'port': 1}
        conn = BluetoothConnection(params)
        self.assertEqual(conn.address, '00:11:22:33:44:55')
        self.assertEqual(conn.port, 1)
        
        # Missing address parameter
        with self.assertRaises(ValueError):
            BluetoothConnection({})
        
        # Default port
        params = {'address': '00:11:22:33:44:55'}
        conn = BluetoothConnection(params)
        self.assertEqual(conn.port, 1)
    
    def test_wifi_connection_params(self):
        """Test Wi-Fi connection parameter validation."""
        # Valid parameters
        params = {'host': '192.168.1.100', 'port': 35000}
        conn = WiFiConnection(params)
        self.assertEqual(conn.host, '192.168.1.100')
        self.assertEqual(conn.port, 35000)
        
        # Missing host parameter
        with self.assertRaises(ValueError):
            WiFiConnection({})
        
        # Default port
        params = {'host': '192.168.1.100'}
        conn = WiFiConnection(params)
        self.assertEqual(conn.port, 35000)
    
    @patch('serial.Serial')
    def test_serial_connection_open_close(self, mock_serial):
        """Test serial connection open/close operations."""
        # Mock serial port
        mock_port = Mock()
        mock_port.is_open = True
        mock_serial.return_value = mock_port
        
        params = {'port': '/dev/ttyUSB0', 'baudrate': 38400}
        conn = SerialConnection(params)
        
        # Test open
        result = conn.open()
        self.assertTrue(result)
        self.assertTrue(conn.is_connected())
        
        # Test close
        conn.close()
        self.assertFalse(conn.is_open)
        mock_port.close.assert_called_once()
    
    @patch('serial.Serial')
    def test_serial_send_receive(self, mock_serial):
        """Test serial send/receive operations."""
        # Mock serial port
        mock_port = Mock()
        mock_port.is_open = True
        mock_port.read_until.return_value = b'response\r'
        mock_serial.return_value = mock_port
        
        params = {'port': '/dev/ttyUSB0', 'baudrate': 38400}
        conn = SerialConnection(params)
        conn.open()
        
        # Test send
        result = conn.send("ATZ")
        self.assertTrue(result)
        mock_port.write.assert_called_with(b"ATZ\r")
        
        # Test receive
        response = conn.receive()
        self.assertEqual(response, "response")
        mock_port.read_until.assert_called_with(b'\r')


class TestELM327Adapter(unittest.TestCase):
    """Test cases for ELM327 adapter"""
    
    def setUp(self):
        """Set up test fixtures."""
        self.mock_connection = Mock()
        self.mock_connection.is_connected.return_value = True
        self.adapter = ELM327Adapter(self.mock_connection)
    
    def test_adapter_initialization(self):
        """Test adapter initialization."""
        self.assertFalse(self.adapter.initialized)
        self.assertEqual(self.adapter.connection, self.mock_connection)
    
    def test_send_command(self):
        """Test command sending."""
        # Mock successful response
        self.mock_connection.send.return_value = True
        self.mock_connection.receive.return_value = "ELM327 v1.5"
        
        response = self.adapter.send_command("ATI")
        self.assertEqual(response, "ELM327 v1.5")
        self.mock_connection.send.assert_called_with("ATI")
    
    def test_send_command_no_response(self):
        """Test command sending with no response."""
        self.mock_connection.send.return_value = True
        self.mock_connection.receive.return_value = None
        
        response = self.adapter.send_command("ATI")
        self.assertIsNone(response)
    
    def test_send_command_send_failure(self):
        """Test command sending with send failure."""
        self.mock_connection.send.return_value = False
        
        response = self.adapter.send_command("ATI")
        self.assertIsNone(response)
    
    def test_reset_adapter(self):
        """Test adapter reset."""
        # Mock successful reset
        self.mock_connection.send.return_value = True
        self.mock_connection.receive.return_value = "ELM327 v1.5"
        
        result = self.adapter._reset()
        self.assertTrue(result)
    
    def test_reset_adapter_failure(self):
        """Test adapter reset failure."""
        # Mock failed reset
        self.mock_connection.send.return_value = True
        self.mock_connection.receive.return_value = "ERROR"
        
        result = self.adapter._reset()
        self.assertFalse(result)
    
    def test_clean_response(self):
        """Test response cleaning."""
        # Test normal response
        cleaned = self.adapter._clean_response("ATZ\r\rELM327 v1.5\r>")
        self.assertEqual(cleaned, "ELM327 v1.5")
        
        # Test response with command echo
        cleaned = self.adapter._clean_response("ATI\rELM327 v1.5\r>")
        self.assertEqual(cleaned, "ELM327 v1.5")
    
    def test_error_response_detection(self):
        """Test error response detection."""
        # Error responses
        self.assertTrue(self.adapter._is_error_response("NO DATA"))
        self.assertTrue(self.adapter._is_error_response("ERROR"))
        self.assertTrue(self.adapter._is_error_response("STOPPED"))
        self.assertTrue(self.adapter._is_error_response("?"))
        
        # Valid responses
        self.assertFalse(self.adapter._is_error_response("ELM327 v1.5"))
        self.assertFalse(self.adapter._is_error_response("OK"))
        self.assertFalse(self.adapter._is_error_response("41 0C 1A F8"))
    
    def test_supported_protocols(self):
        """Test supported protocols list."""
        protocols = self.adapter.get_supported_protocols()
        self.assertIn("ISO 15765-4 (CAN 11/500)", protocols)
        self.assertIn("SAE J1850 PWM (41.6 kbit/s)", protocols)
        self.assertIn("ISO 9141-2", protocols)
    
    def test_set_protocol(self):
        """Test protocol setting."""
        # Mock successful protocol set
        self.mock_connection.send.return_value = True
        self.mock_connection.receive.return_value = "OK"
        
        result = self.adapter.set_protocol(6)  # CAN 11/500
        self.assertTrue(result)
        
        # Mock failed protocol set
        self.mock_connection.receive.return_value = "ERROR"
        result = self.adapter.set_protocol(6)
        self.assertFalse(result)


class TestAdapterManager(unittest.TestCase):
    """Test cases for adapter manager"""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = {
            'port': 'auto',
            'baudrate': 38400,
            'timeout': 5.0
        }
        self.manager = AdapterManager(self.config)
    
    @patch('serial.tools.list_ports.comports')
    def test_scan_ports(self, mock_comports):
        """Test port scanning."""
        # Mock available ports
        mock_port = Mock()
        mock_port.device = '/dev/ttyUSB0'
        mock_port.description = 'USB Serial Device'
        mock_port.manufacturer = 'FTDI'
        mock_port.product = 'FT232R USB UART'
        mock_port.vid = 0x0403
        mock_port.pid = 0x6001
        
        mock_comports.return_value = [mock_port]
        
        ports = self.manager.scan_ports()
        self.assertEqual(len(ports), 1)
        self.assertEqual(ports[0]['device'], '/dev/ttyUSB0')
        self.assertEqual(ports[0]['description'], 'USB Serial Device')
        self.assertEqual(ports[0]['manufacturer'], 'FTDI')
    
    def test_default_connection_params(self):
        """Test default connection parameters."""
        params = self.manager._get_default_connection_params()
        
        self.assertEqual(params['port'], 'auto')
        self.assertEqual(params['baudrate'], 38400)
        self.assertEqual(params['timeout'], 5.0)
    
    @patch.object(AdapterManager, '_test_port')
    @patch.object(AdapterManager, 'scan_ports')
    def test_auto_detect_adapter(self, mock_scan_ports, mock_test_port):
        """Test adapter auto-detection."""
        # Mock available ports
        mock_scan_ports.return_value = [
            {'device': '/dev/ttyUSB0', 'description': 'USB Serial'},
            {'device': '/dev/ttyUSB1', 'description': 'Another Device'}
        ]
        
        # Mock test results (first port fails, second succeeds)
        mock_test_port.side_effect = [False, True]
        
        detected_port = self.manager.auto_detect_adapter()
        self.assertEqual(detected_port, '/dev/ttyUSB1')
        
        # Test no adapter found
        mock_test_port.side_effect = [False, False]
        detected_port = self.manager.auto_detect_adapter()
        self.assertIsNone(detected_port)
    
    def test_connection_info(self):
        """Test connection information retrieval."""
        # Test when not connected
        info = self.manager.get_connection_info()
        self.assertEqual(info['connected'], False)
        
        # Test adapter info when no adapter
        info = self.manager.get_adapter_info()
        self.assertEqual(info['connected'], False)
    
    def test_supported_features(self):
        """Test supported features list."""
        features = self.manager.get_supported_features()
        self.assertIn('Basic OBD-II Communication', features)
        
        # When ELM327 adapter is set
        from src.hardware.adapter_manager import AdapterType
        self.manager.adapter_type = AdapterType.ELM327
        features = self.manager.get_supported_features()
        self.assertIn('Multiple Protocol Support', features)
        self.assertIn('Diagnostic Trouble Codes', features)


if __name__ == '__main__':
    # Run tests
    unittest.main()