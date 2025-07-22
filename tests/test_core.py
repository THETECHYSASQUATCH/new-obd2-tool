"""
Tests for core OBD-II functionality
"""

import unittest
import sys
from pathlib import Path

# Add src directory to path
src_path = Path(__file__).parent.parent / "src"
sys.path.insert(0, str(src_path))

from src.core.data_parser import DataParser
from src.core.dtc_manager import DTCManager, DTC
from src.utils.config import Config


class TestDataParser(unittest.TestCase):
    """Test cases for DataParser class"""
    
    def setUp(self):
        """Set up test fixtures."""
        self.parser = DataParser()
    
    def test_clean_response(self):
        """Test response cleaning."""
        # Test normal response
        response = "41 0C 1A F8"
        cleaned = self.parser._clean_response(response)
        self.assertEqual(cleaned, "410C1AF8")
        
        # Test response with extra whitespace
        response = "  41 0C 1A F8  \r\n"
        cleaned = self.parser._clean_response(response)
        self.assertEqual(cleaned, "410C1AF8")
        
        # Test empty response
        response = ""
        cleaned = self.parser._clean_response(response)
        self.assertEqual(cleaned, "")
    
    def test_verify_response(self):
        """Test response verification."""
        # Valid response for command 010C
        command = "010C"
        response = "410C1AF8"
        self.assertTrue(self.parser._verify_response(command, response))
        
        # Invalid response
        command = "010C"
        response = "420C1AF8"
        self.assertFalse(self.parser._verify_response(command, response))
        
        # Empty response
        command = "010C"
        response = ""
        self.assertFalse(self.parser._verify_response(command, response))
    
    def test_extract_data_bytes(self):
        """Test data byte extraction."""
        command = "010C"
        response = "410C1AF8"
        data_bytes = self.parser._extract_data_bytes(command, response)
        self.assertEqual(data_bytes, [0x1A, 0xF8])
        
        # Test with empty data
        response = "410C"
        data_bytes = self.parser._extract_data_bytes(command, response)
        self.assertEqual(data_bytes, [])
    
    def test_parse_supported_pids(self):
        """Test PID support parsing."""
        # Mock response for PIDs 01-20 support
        response = "4100BE1FA813"
        supported_pids = self.parser.parse_supported_pids(response, 0x01)
        
        # Should include some common PIDs
        self.assertIn(0x01, supported_pids)  # Monitor status
        self.assertIn(0x04, supported_pids)  # Engine load
        self.assertIn(0x05, supported_pids)  # Coolant temp
        self.assertIn(0x0C, supported_pids)  # Engine RPM
        self.assertIn(0x0D, supported_pids)  # Vehicle speed
    
    def test_format_hex_data(self):
        """Test hex data formatting."""
        # Test string input
        data = "410C1AF8"
        formatted = self.parser.format_hex_data(data)
        self.assertEqual(formatted, "41 0C 1A F8")
        
        # Test byte list input
        data = [0x41, 0x0C, 0x1A, 0xF8]
        formatted = self.parser.format_hex_data(data)
        self.assertEqual(formatted, "41 0C 1A F8")
        
        # Test with custom separator
        data = "410C1AF8"
        formatted = self.parser.format_hex_data(data, separator="-")
        self.assertEqual(formatted, "41-0C-1A-F8")
    
    def test_validate_response_format(self):
        """Test response format validation."""
        # Valid hex string
        self.assertTrue(self.parser.validate_response_format("410C1AF8"))
        
        # Invalid hex characters
        self.assertFalse(self.parser.validate_response_format("410G1AF8"))
        
        # Odd length (incomplete bytes)
        self.assertFalse(self.parser.validate_response_format("410C1AF"))
        
        # Empty string
        self.assertFalse(self.parser.validate_response_format(""))


class TestDTCDecoding(unittest.TestCase):
    """Test cases for DTC decoding"""
    
    def setUp(self):
        """Set up test fixtures."""
        self.dtc_manager = DTCManager(None)
    
    def test_decode_dtc_powertrain(self):
        """Test powertrain DTC decoding."""
        # P0300 - Random/Multiple Cylinder Misfire Detected
        dtc_code = self.dtc_manager._decode_dtc("0300")
        self.assertEqual(dtc_code, "P0300")
        
        # P0420 - Catalyst System Efficiency Below Threshold
        dtc_code = self.dtc_manager._decode_dtc("0420")
        self.assertEqual(dtc_code, "P0420")
    
    def test_decode_dtc_body(self):
        """Test body DTC decoding."""
        # B1000 (hypothetical body code)
        dtc_code = self.dtc_manager._decode_dtc("9000")  # 0x9000 = body code
        self.assertEqual(dtc_code, "B1000")
    
    def test_decode_dtc_chassis(self):
        """Test chassis DTC decoding."""
        # C1000 (hypothetical chassis code)
        dtc_code = self.dtc_manager._decode_dtc("D000")  # 0xD000 = chassis code
        self.assertEqual(dtc_code, "C1000")
    
    def test_decode_dtc_network(self):
        """Test network DTC decoding."""
        # U1000 (hypothetical network code)
        dtc_code = self.dtc_manager._decode_dtc("F000")  # 0xF000 = network code
        self.assertEqual(dtc_code, "U1000")
    
    def test_decode_invalid_dtc(self):
        """Test invalid DTC handling."""
        # Invalid length
        dtc_code = self.dtc_manager._decode_dtc("030")
        self.assertIsNone(dtc_code)
        
        # Zero value
        dtc_code = self.dtc_manager._decode_dtc("0000")
        self.assertIsNone(dtc_code)
        
        # Invalid hex
        dtc_code = self.dtc_manager._decode_dtc("G300")
        self.assertIsNone(dtc_code)
    
    def test_get_dtc_description(self):
        """Test DTC description retrieval."""
        # Known DTC
        description = self.dtc_manager.get_dtc_description("P0300")
        self.assertEqual(description, "Random/Multiple Cylinder Misfire Detected")
        
        # Unknown DTC
        description = self.dtc_manager.get_dtc_description("P9999")
        self.assertEqual(description, "Unknown DTC: P9999")


class TestConfig(unittest.TestCase):
    """Test cases for configuration management"""
    
    def setUp(self):
        """Set up test fixtures."""
        import tempfile
        import os
        
        # Create temporary config file
        self.temp_dir = tempfile.mkdtemp()
        self.config_file = os.path.join(self.temp_dir, "test_config.ini")
        self.config = Config(self.config_file)
    
    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_default_config_creation(self):
        """Test default configuration creation."""
        # Check that default values are set
        port = self.config.get('connection', 'default_port')
        self.assertEqual(port, 'auto')
        
        baudrate = self.config.get('connection', 'default_baudrate')
        self.assertEqual(baudrate, 38400)
        
        window_width = self.config.get('gui', 'window_width')
        self.assertEqual(window_width, 1024)
    
    def test_config_set_get(self):
        """Test setting and getting configuration values."""
        # Set a value
        self.config.set('test_section', 'test_key', 'test_value')
        
        # Get the value
        value = self.config.get('test_section', 'test_key')
        self.assertEqual(value, 'test_value')
        
        # Test with fallback
        value = self.config.get('test_section', 'nonexistent_key', 'fallback')
        self.assertEqual(value, 'fallback')
    
    def test_config_type_conversion(self):
        """Test automatic type conversion."""
        # Boolean values
        self.config.set('test_section', 'bool_true', True)
        self.config.set('test_section', 'bool_false', False)
        
        self.assertTrue(self.config.get('test_section', 'bool_true'))
        self.assertFalse(self.config.get('test_section', 'bool_false'))
        
        # Numeric values
        self.config.set('test_section', 'int_value', 42)
        self.config.set('test_section', 'float_value', 3.14)
        
        self.assertEqual(self.config.get('test_section', 'int_value'), 42)
        self.assertEqual(self.config.get('test_section', 'float_value'), 3.14)
        
        # List values
        self.config.set('test_section', 'list_value', ['item1', 'item2'])
        
        value = self.config.get('test_section', 'list_value')
        self.assertEqual(value, ['item1', 'item2'])
    
    def test_connection_config(self):
        """Test connection configuration retrieval."""
        conn_config = self.config.get_connection_config()
        
        self.assertIn('port', conn_config)
        self.assertIn('baudrate', conn_config)
        self.assertIn('timeout', conn_config)
        self.assertIn('adapter_type', conn_config)
        
        # Check default values
        self.assertEqual(conn_config['port'], 'auto')
        self.assertEqual(conn_config['baudrate'], 38400)
        self.assertEqual(conn_config['timeout'], 5.0)
        self.assertEqual(conn_config['adapter_type'], 'ELM327')
    
    def test_gui_config(self):
        """Test GUI configuration retrieval."""
        gui_config = self.config.get_gui_config()
        
        self.assertIn('window_width', gui_config)
        self.assertIn('window_height', gui_config)
        self.assertIn('theme', gui_config)
        
        # Check default values
        self.assertEqual(gui_config['window_width'], 1024)
        self.assertEqual(gui_config['window_height'], 768)
        self.assertEqual(gui_config['theme'], 'default')


if __name__ == '__main__':
    # Run tests
    unittest.main()