"""
Tests for GUI functionality
"""

import unittest
import sys
import tkinter as tk
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

# Add src directory to path
src_path = Path(__file__).parent.parent / "src"
sys.path.insert(0, str(src_path))

from src.utils.config import Config
from src.gui.connection_dialog import ConnectionDialog
from src.hardware.connection_types import ConnectionType
from src.hardware.adapter_manager import AdapterType


class TestGUIComponents(unittest.TestCase):
    """Test cases for GUI components"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test class."""
        # Create root window for GUI tests
        cls.root = tk.Tk()
        cls.root.withdraw()  # Hide the window during tests
    
    @classmethod
    def tearDownClass(cls):
        """Clean up test class."""
        cls.root.destroy()
    
    def setUp(self):
        """Set up test fixtures."""
        # Mock main application
        self.mock_main_app = Mock()
        self.mock_main_app.root = self.root
        self.mock_main_app.connected = False
        
        # Mock config
        self.mock_config = Mock()
        self.mock_config.get_connection_config.return_value = {
            'port': 'auto',
            'baudrate': 38400,
            'timeout': 5.0,
            'adapter_type': 'ELM327'
        }
        self.mock_main_app.config = self.mock_config
        
        # Mock adapter manager
        self.mock_adapter_manager = Mock()
        self.mock_adapter_manager.scan_ports.return_value = [
            {
                'device': '/dev/ttyUSB0',
                'description': 'USB Serial Device',
                'manufacturer': 'FTDI',
                'product': 'FT232R USB UART',
                'vid': 0x0403,
                'pid': 0x6001
            }
        ]
        self.mock_main_app.adapter_manager = self.mock_adapter_manager
    
    def test_connection_dialog_creation(self):
        """Test connection dialog creation."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        self.assertEqual(dialog.parent, self.root)
        self.assertEqual(dialog.main_app, self.mock_main_app)
        self.assertIsNone(dialog.dialog)
        self.assertIsNone(dialog.result)
    
    def test_connection_dialog_default_values(self):
        """Test connection dialog default values."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        self.assertEqual(dialog.connection_type_var.get(), "USB/Serial")
        self.assertEqual(dialog.adapter_type_var.get(), "ELM327")
        self.assertEqual(dialog.port_var.get(), "auto")
        self.assertEqual(dialog.baudrate_var.get(), "38400")
        self.assertEqual(dialog.timeout_var.get(), "5.0")
        self.assertEqual(dialog.port_num_var.get(), "35000")
    
    def test_connection_type_mapping(self):
        """Test connection type mapping."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        # Test USB/Serial mapping
        dialog.connection_type_var.set("USB/Serial")
        conn_type = dialog._get_connection_type()
        self.assertEqual(conn_type, ConnectionType.USB_SERIAL)
        
        # Test Bluetooth mapping
        dialog.connection_type_var.set("Bluetooth")
        conn_type = dialog._get_connection_type()
        self.assertEqual(conn_type, ConnectionType.BLUETOOTH)
        
        # Test Wi-Fi mapping
        dialog.connection_type_var.set("Wi-Fi")
        conn_type = dialog._get_connection_type()
        self.assertEqual(conn_type, ConnectionType.WIFI)
    
    def test_adapter_type_mapping(self):
        """Test adapter type mapping."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        # Test ELM327 mapping
        dialog.adapter_type_var.set("ELM327")
        adapter_type = dialog._get_adapter_type()
        self.assertEqual(adapter_type, AdapterType.ELM327)
        
        # Test Generic mapping
        dialog.adapter_type_var.set("Generic")
        adapter_type = dialog._get_adapter_type()
        self.assertEqual(adapter_type, AdapterType.GENERIC)
    
    def test_serial_connection_params(self):
        """Test serial connection parameters."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        dialog.connection_type_var.set("USB/Serial")
        dialog.port_var.set("/dev/ttyUSB0")
        dialog.baudrate_var.set("38400")
        dialog.timeout_var.set("5.0")
        
        params = dialog._get_connection_params()
        
        self.assertEqual(params['port'], "/dev/ttyUSB0")
        self.assertEqual(params['baudrate'], 38400)
        self.assertEqual(params['timeout'], 5.0)
    
    def test_bluetooth_connection_params(self):
        """Test Bluetooth connection parameters."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        dialog.connection_type_var.set("Bluetooth")
        dialog.address_var.set("00:11:22:33:44:55")
        dialog.port_num_var.set("1")
        dialog.timeout_var.set("5.0")
        
        params = dialog._get_connection_params()
        
        self.assertEqual(params['address'], "00:11:22:33:44:55")
        self.assertEqual(params['port'], 1)
        self.assertEqual(params['timeout'], 5.0)
    
    def test_wifi_connection_params(self):
        """Test Wi-Fi connection parameters."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        dialog.connection_type_var.set("Wi-Fi")
        dialog.host_var.set("192.168.1.100")
        dialog.port_num_var.set("35000")
        dialog.timeout_var.set("5.0")
        
        params = dialog._get_connection_params()
        
        self.assertEqual(params['host'], "192.168.1.100")
        self.assertEqual(params['port'], 35000)
        self.assertEqual(params['timeout'], 5.0)
    
    def test_parameter_validation_serial(self):
        """Test parameter validation for serial connection."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        dialog.connection_type_var.set("USB/Serial")
        
        # Valid parameters
        params = {
            'port': '/dev/ttyUSB0',
            'baudrate': 38400,
            'timeout': 5.0
        }
        self.assertTrue(dialog._validate_params(params))
        
        # Missing port
        params = {
            'baudrate': 38400,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))
        
        # Invalid baudrate
        params = {
            'port': '/dev/ttyUSB0',
            'baudrate': -1,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))
        
        # Invalid timeout
        params = {
            'port': '/dev/ttyUSB0',
            'baudrate': 38400,
            'timeout': 0
        }
        self.assertFalse(dialog._validate_params(params))
    
    def test_parameter_validation_bluetooth(self):
        """Test parameter validation for Bluetooth connection."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        dialog.connection_type_var.set("Bluetooth")
        
        # Valid parameters
        params = {
            'address': '00:11:22:33:44:55',
            'port': 1,
            'timeout': 5.0
        }
        self.assertTrue(dialog._validate_params(params))
        
        # Missing address
        params = {
            'port': 1,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))
        
        # Invalid port
        params = {
            'address': '00:11:22:33:44:55',
            'port': 0,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))
        
        # Port out of range
        params = {
            'address': '00:11:22:33:44:55',
            'port': 70000,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))
    
    def test_parameter_validation_wifi(self):
        """Test parameter validation for Wi-Fi connection."""
        dialog = ConnectionDialog(self.root, self.mock_main_app)
        
        dialog.connection_type_var.set("Wi-Fi")
        
        # Valid parameters
        params = {
            'host': '192.168.1.100',
            'port': 35000,
            'timeout': 5.0
        }
        self.assertTrue(dialog._validate_params(params))
        
        # Missing host
        params = {
            'port': 35000,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))
        
        # Invalid port
        params = {
            'host': '192.168.1.100',
            'port': -1,
            'timeout': 5.0
        }
        self.assertFalse(dialog._validate_params(params))


class TestDiagnosticsPanel(unittest.TestCase):
    """Test cases for diagnostics panel"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test class."""
        cls.root = tk.Tk()
        cls.root.withdraw()
    
    @classmethod
    def tearDownClass(cls):
        """Clean up test class."""
        cls.root.destroy()
    
    def setUp(self):
        """Set up test fixtures."""
        # Create a frame for the panel
        self.parent_frame = tk.Frame(self.root)
        
        # Mock main application
        self.mock_main_app = Mock()
        self.mock_main_app.connected = False
        
        # Mock OBD manager with DTC manager
        self.mock_dtc_manager = Mock()
        self.mock_obd_manager = Mock()
        self.mock_obd_manager.get_dtc_manager.return_value = self.mock_dtc_manager
        self.mock_main_app.obd_manager = self.mock_obd_manager
    
    def test_diagnostics_panel_creation(self):
        """Test diagnostics panel creation."""
        from src.gui.diagnostics_panel import DiagnosticsPanel
        
        panel = DiagnosticsPanel(self.parent_frame, self.mock_main_app)
        
        self.assertEqual(panel.parent, self.parent_frame)
        self.assertEqual(panel.main_app, self.mock_main_app)
        self.assertEqual(len(panel.current_dtcs), 0)
        self.assertEqual(len(panel.pending_dtcs), 0)
        self.assertEqual(len(panel.permanent_dtcs), 0)
    
    def test_dtc_tree_population(self):
        """Test DTC tree population."""
        from src.gui.diagnostics_panel import DiagnosticsPanel
        from src.core.dtc_manager import DTC
        from datetime import datetime
        
        panel = DiagnosticsPanel(self.parent_frame, self.mock_main_app)
        
        # Create mock DTCs
        dtcs = [
            DTC(
                code="P0300",
                description="Random/Multiple Cylinder Misfire Detected",
                status="Current",
                detected_time=datetime.now()
            ),
            DTC(
                code="P0420",
                description="Catalyst System Efficiency Below Threshold",
                status="Current",
                detected_time=datetime.now()
            )
        ]
        
        # Populate tree
        panel._populate_dtc_tree(panel.current_tree, dtcs)
        
        # Check tree has correct number of items
        children = panel.current_tree.get_children()
        self.assertEqual(len(children), 2)
        
        # Check first item values
        first_item = panel.current_tree.item(children[0])
        values = first_item['values']
        self.assertEqual(values[0], "P0300")
        self.assertEqual(values[1], "Random/Multiple Cylinder Misfire Detected")
        self.assertEqual(values[2], "Current")


class TestProgrammingPanel(unittest.TestCase):
    """Test cases for programming panel"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test class."""
        cls.root = tk.Tk()
        cls.root.withdraw()
    
    @classmethod
    def tearDownClass(cls):
        """Clean up test class."""
        cls.root.destroy()
    
    def setUp(self):
        """Set up test fixtures."""
        # Create a frame for the panel
        self.parent_frame = tk.Frame(self.root)
        
        # Mock main application
        self.mock_main_app = Mock()
        self.mock_main_app.connected = False
    
    def test_programming_panel_creation(self):
        """Test programming panel creation."""
        from src.gui.programming_panel import ProgrammingPanel
        
        panel = ProgrammingPanel(self.parent_frame, self.mock_main_app)
        
        self.assertEqual(panel.parent, self.parent_frame)
        self.assertEqual(panel.main_app, self.mock_main_app)
    
    def test_connection_check(self):
        """Test connection checking."""
        from src.gui.programming_panel import ProgrammingPanel
        
        panel = ProgrammingPanel(self.parent_frame, self.mock_main_app)
        
        # Test when not connected
        self.mock_main_app.connected = False
        result = panel._check_connection()
        self.assertFalse(result)
        
        # Test when connected
        self.mock_main_app.connected = True
        result = panel._check_connection()
        self.assertTrue(result)
    
    def test_programming_log(self):
        """Test programming log functionality."""
        from src.gui.programming_panel import ProgrammingPanel
        
        panel = ProgrammingPanel(self.parent_frame, self.mock_main_app)
        
        # Test logging message
        test_message = "Test programming operation"
        panel._log_programming_message(test_message)
        
        # Check log content (simplified test)
        log_content = panel.prog_log.get("1.0", tk.END)
        self.assertIn(test_message, log_content)


if __name__ == '__main__':
    # Run tests
    unittest.main()