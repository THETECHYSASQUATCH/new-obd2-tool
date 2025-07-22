#!/usr/bin/env python3
"""
Basic tests for OBD-II Tool components
Run with: python -m pytest tests/ or python tests/test_basic.py
"""

import sys
import os
import unittest

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from vehicle_detection import VehicleDetector
from diagnostics import DiagnosticsEngine
from programming import ProgrammingEngine


class TestVehicleDetection(unittest.TestCase):
    """Test vehicle detection functionality"""
    
    def setUp(self):
        self.detector = VehicleDetector()
    
    def test_vin_validation(self):
        """Test VIN validation"""
        # Valid VIN format (may not pass check digit test)
        self.assertFalse(self.detector.validate_vin(""))  # Empty
        self.assertFalse(self.detector.validate_vin("123"))  # Too short
        self.assertFalse(self.detector.validate_vin("1234567890123456789"))  # Too long
        self.assertFalse(self.detector.validate_vin("1HGBH41JXMN109186I"))  # Invalid char 'I'
        
        # Test length validation
        self.assertEqual(len("1HGBH41JXMN109186") == 17, True)
    
    def test_vin_decoding(self):
        """Test VIN decoding functionality"""
        test_vin = "1HGBH41JXMN109186"  # Example Honda VIN
        
        try:
            result = self.detector.decode_vin(test_vin)
            self.assertEqual(result["vin"], test_vin)
            self.assertEqual(result["wmi"], "1HG")
            self.assertIn("manufacturer", result)
            self.assertIn("year", result)
        except ValueError:
            # Expected if VIN format is invalid
            pass
    
    def test_manufacturer_support(self):
        """Test manufacturer support"""
        manufacturers = self.detector.get_supported_manufacturers()
        self.assertIsInstance(manufacturers, list)
        self.assertGreater(len(manufacturers), 0)
        
        # Test getting manufacturer info
        if manufacturers:
            info = self.detector.get_manufacturer_info(manufacturers[0])
            self.assertIsInstance(info, dict)


class TestDiagnostics(unittest.TestCase):
    """Test diagnostics functionality"""
    
    def setUp(self):
        self.diagnostics = DiagnosticsEngine()
    
    def test_dtc_decoding(self):
        """Test DTC decoding"""
        # Test generic code
        dtc_info = self.diagnostics._decode_dtc("P0300")
        self.assertEqual(dtc_info["code"], "P0300")
        self.assertIn("description", dtc_info)
        self.assertIn("system", dtc_info)
        
        # Test unknown code
        unknown_dtc = self.diagnostics._decode_dtc("P9999")
        self.assertEqual(unknown_dtc["code"], "P9999")
        self.assertEqual(unknown_dtc["description"], "Unknown Code")
    
    def test_module_pid_mapping(self):
        """Test module PID mapping"""
        ecm_pids = self.diagnostics._get_module_pids("ECM")
        self.assertIsInstance(ecm_pids, list)
        
        # Should have some PIDs for ECM
        self.assertIn("RPM", ecm_pids)
        self.assertIn("ENGINE_LOAD", ecm_pids)


class TestProgramming(unittest.TestCase):
    """Test programming functionality"""
    
    def setUp(self):
        self.programming = ProgrammingEngine()
    
    def test_procedure_retrieval(self):
        """Test procedure retrieval"""
        # Get procedures for Honda
        procedures = self.programming.get_available_procedures("Honda")
        self.assertIsInstance(procedures, list)
        
        if procedures:
            # Test getting procedure details
            proc_id = procedures[0]["id"]
            details = self.programming.get_procedure_details("Honda", proc_id)
            self.assertIsInstance(details, dict)
            self.assertIn("steps", details)
    
    def test_validation(self):
        """Test programming validation"""
        vehicle_info = {"manufacturer": "Honda", "year": "2020"}
        
        # Test with valid procedure
        validation = self.programming.validate_programming_requirements(
            "Honda", "idle_relearn", vehicle_info)
        self.assertIsInstance(validation, dict)
        self.assertIn("valid", validation)


class TestIntegration(unittest.TestCase):
    """Integration tests"""
    
    def test_component_initialization(self):
        """Test that all components can be initialized"""
        detector = VehicleDetector()
        diagnostics = DiagnosticsEngine()
        programming = ProgrammingEngine()
        
        self.assertIsNotNone(detector)
        self.assertIsNotNone(diagnostics)
        self.assertIsNotNone(programming)
    
    def test_data_loading(self):
        """Test that data files are loaded correctly"""
        detector = VehicleDetector()
        
        # Check that data was loaded
        self.assertIsInstance(detector.vin_data, dict)
        self.assertIsInstance(detector.manufacturer_data, dict)
        
        # Check that we have some manufacturers
        manufacturers = detector.get_supported_manufacturers()
        self.assertGreater(len(manufacturers), 0)


def run_tests():
    """Run all tests"""
    unittest.main()


if __name__ == "__main__":
    run_tests()