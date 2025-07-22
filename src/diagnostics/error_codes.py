"""
Error Code Management Module
Provides detailed descriptions and solutions for diagnostic trouble codes
"""

import json
import logging
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass

@dataclass
class DTCInfo:
    """Data class for Diagnostic Trouble Code information"""
    code: str
    description: str
    category: str
    severity: str
    system: str
    possible_causes: List[str]
    suggested_solutions: List[str]
    related_codes: List[str]

class ErrorCodeDatabase:
    """Database of error codes with descriptions and solutions"""
    
    def __init__(self):
        """Initialize error code database"""
        self.logger = logging.getLogger(__name__)
        self.dtc_database = self._load_dtc_database()
        
    def _load_dtc_database(self) -> Dict[str, DTCInfo]:
        """
        Load DTC database with comprehensive error codes
        
        Returns:
            dict: Database of DTC information
        """
        # Comprehensive DTC database
        dtc_data = {
            # P0xxx - Powertrain codes
            "P0100": DTCInfo(
                code="P0100",
                description="Mass or Volume Air Flow Circuit Malfunction",
                category="Powertrain",
                severity="Medium",
                system="Fuel and Air Metering",
                possible_causes=[
                    "Faulty Mass Air Flow (MAF) sensor",
                    "Dirty or contaminated MAF sensor",
                    "Vacuum leak in intake system",
                    "Wiring issues in MAF circuit",
                    "Faulty Engine Control Module (ECM)"
                ],
                suggested_solutions=[
                    "Clean MAF sensor with appropriate cleaner",
                    "Inspect and repair vacuum leaks",
                    "Check MAF sensor wiring and connections",
                    "Replace MAF sensor if cleaning doesn't help",
                    "Verify ECM functionality"
                ],
                related_codes=["P0101", "P0102", "P0103", "P0104"]
            ),
            "P0101": DTCInfo(
                code="P0101",
                description="Mass or Volume Air Flow Circuit Range/Performance Problem",
                category="Powertrain",
                severity="Medium",
                system="Fuel and Air Metering",
                possible_causes=[
                    "Dirty MAF sensor",
                    "Air filter restriction",
                    "Vacuum leak",
                    "MAF sensor out of calibration"
                ],
                suggested_solutions=[
                    "Replace air filter",
                    "Clean MAF sensor",
                    "Check for vacuum leaks",
                    "Calibrate or replace MAF sensor"
                ],
                related_codes=["P0100", "P0102", "P0103"]
            ),
            "P0171": DTCInfo(
                code="P0171",
                description="System Too Lean (Bank 1)",
                category="Powertrain",
                severity="Medium",
                system="Fuel and Air Metering",
                possible_causes=[
                    "Vacuum leak in intake manifold",
                    "Faulty fuel injectors",
                    "Weak fuel pump",
                    "Dirty MAF sensor",
                    "Faulty oxygen sensor"
                ],
                suggested_solutions=[
                    "Check for vacuum leaks using smoke test",
                    "Clean fuel injectors",
                    "Test fuel pump pressure",
                    "Clean MAF sensor",
                    "Replace oxygen sensor if needed"
                ],
                related_codes=["P0174", "P0172", "P0175"]
            ),
            "P0301": DTCInfo(
                code="P0301",
                description="Cylinder 1 Misfire Detected",
                category="Powertrain",
                severity="High",
                system="Ignition System",
                possible_causes=[
                    "Faulty spark plug",
                    "Faulty ignition coil",
                    "Fuel injector problems",
                    "Low compression",
                    "Vacuum leak"
                ],
                suggested_solutions=[
                    "Replace spark plug for cylinder 1",
                    "Test and replace ignition coil if needed",
                    "Clean or replace fuel injector",
                    "Perform compression test",
                    "Check for vacuum leaks"
                ],
                related_codes=["P0302", "P0303", "P0304", "P0305", "P0306", "P0307", "P0308"]
            ),
            "P0420": DTCInfo(
                code="P0420",
                description="Catalyst System Efficiency Below Threshold (Bank 1)",
                category="Powertrain",
                severity="Medium",
                system="Emission Control",
                possible_causes=[
                    "Faulty catalytic converter",
                    "Faulty oxygen sensors",
                    "Engine running rich or lean",
                    "Internal engine problems",
                    "Exhaust leak"
                ],
                suggested_solutions=[
                    "Test oxygen sensor functionality",
                    "Check for exhaust leaks",
                    "Verify engine running conditions",
                    "Replace catalytic converter if confirmed faulty",
                    "Address any engine performance issues"
                ],
                related_codes=["P0430", "P0421", "P0431"]
            ),
            # B0xxx - Body codes
            "B0001": DTCInfo(
                code="B0001",
                description="Driver Airbag Circuit Short to Ground",
                category="Body",
                severity="High",
                system="Airbag System",
                possible_causes=[
                    "Damaged airbag wiring",
                    "Faulty airbag module",
                    "Short circuit in harness",
                    "Damaged clock spring"
                ],
                suggested_solutions=[
                    "Inspect airbag wiring for damage",
                    "Test airbag module resistance",
                    "Check clock spring continuity",
                    "Replace damaged components",
                    "Clear codes and retest"
                ],
                related_codes=["B0002", "B0003", "B0004"]
            ),
            # C0xxx - Chassis codes
            "C0121": DTCInfo(
                code="C0121",
                description="ABS Wheel Speed Sensor Front Left Circuit",
                category="Chassis",
                severity="Medium",
                system="Anti-lock Brake System",
                possible_causes=[
                    "Faulty wheel speed sensor",
                    "Damaged sensor wiring",
                    "Dirty or damaged tone ring",
                    "Poor sensor mounting"
                ],
                suggested_solutions=[
                    "Inspect wheel speed sensor",
                    "Check sensor wiring and connections",
                    "Clean tone ring",
                    "Replace sensor if faulty",
                    "Verify proper sensor gap"
                ],
                related_codes=["C0122", "C0123", "C0124"]
            ),
            # U0xxx - Network codes
            "U0100": DTCInfo(
                code="U0100",
                description="Lost Communication with ECM/PCM",
                category="Network",
                severity="High",
                system="Communication",
                possible_causes=[
                    "Faulty ECM/PCM",
                    "CAN bus wiring issues",
                    "Poor connections",
                    "Bus termination problems"
                ],
                suggested_solutions=[
                    "Check CAN bus wiring",
                    "Verify bus termination resistors",
                    "Test ECM/PCM power and ground",
                    "Replace ECM/PCM if confirmed faulty",
                    "Check for other network codes"
                ],
                related_codes=["U0101", "U0102", "U0103"]
            )
        }
        
        # Add more generic patterns for common codes
        self._add_generic_patterns(dtc_data)
        
        return dtc_data
    
    def _add_generic_patterns(self, dtc_data: Dict[str, DTCInfo]) -> None:
        """Add generic patterns for common DTC codes"""
        
        # P030x misfire codes (cylinders 2-8)
        for cyl in range(2, 9):
            code = f"P030{cyl}"
            dtc_data[code] = DTCInfo(
                code=code,
                description=f"Cylinder {cyl} Misfire Detected",
                category="Powertrain",
                severity="High",
                system="Ignition System",
                possible_causes=[
                    f"Faulty spark plug cylinder {cyl}",
                    f"Faulty ignition coil cylinder {cyl}",
                    f"Fuel injector problems cylinder {cyl}",
                    f"Low compression cylinder {cyl}",
                    "Vacuum leak"
                ],
                suggested_solutions=[
                    f"Replace spark plug for cylinder {cyl}",
                    f"Test and replace ignition coil if needed",
                    f"Clean or replace fuel injector",
                    "Perform compression test",
                    "Check for vacuum leaks"
                ],
                related_codes=[f"P030{i}" for i in range(1, 9) if i != cyl]
            )
    
    def get_dtc_info(self, code: str) -> Optional[DTCInfo]:
        """
        Get detailed information for a DTC code
        
        Args:
            code: DTC code (e.g., 'P0301')
            
        Returns:
            DTCInfo: Detailed DTC information or None if not found
        """
        code = code.upper().strip()
        return self.dtc_database.get(code)
    
    def search_dtc_by_description(self, search_term: str) -> List[DTCInfo]:
        """
        Search DTC codes by description
        
        Args:
            search_term: Term to search for
            
        Returns:
            list: List of matching DTCInfo objects
        """
        search_term = search_term.lower()
        results = []
        
        for dtc_info in self.dtc_database.values():
            if (search_term in dtc_info.description.lower() or
                search_term in dtc_info.system.lower() or
                any(search_term in cause.lower() for cause in dtc_info.possible_causes)):
                results.append(dtc_info)
        
        return results
    
    def get_dtcs_by_system(self, system: str) -> List[DTCInfo]:
        """
        Get all DTCs for a specific system
        
        Args:
            system: System name to filter by
            
        Returns:
            list: List of DTCInfo objects for the system
        """
        system = system.lower()
        results = []
        
        for dtc_info in self.dtc_database.values():
            if system in dtc_info.system.lower():
                results.append(dtc_info)
        
        return results
    
    def get_dtcs_by_severity(self, severity: str) -> List[DTCInfo]:
        """
        Get all DTCs by severity level
        
        Args:
            severity: Severity level (Low, Medium, High)
            
        Returns:
            list: List of DTCInfo objects with specified severity
        """
        severity = severity.lower()
        results = []
        
        for dtc_info in self.dtc_database.values():
            if dtc_info.severity.lower() == severity:
                results.append(dtc_info)
        
        return results

class DTCManager:
    """Manages DTC reading, analysis, and reporting"""
    
    def __init__(self, obd_interface):
        """
        Initialize DTC manager
        
        Args:
            obd_interface: OBDInterface instance
        """
        self.obd_interface = obd_interface
        self.error_db = ErrorCodeDatabase()
        self.logger = logging.getLogger(__name__)
        self.current_dtcs = []
        self.pending_dtcs = []
        self.permanent_dtcs = []
    
    def read_all_dtcs(self) -> Dict[str, List[str]]:
        """
        Read all types of DTCs from vehicle
        
        Returns:
            dict: Dictionary with DTC types and codes
        """
        dtc_results = {
            "stored": [],
            "pending": [],
            "permanent": []
        }
        
        # Read stored DTCs (mode 03)
        stored = self._read_stored_dtcs()
        if stored:
            dtc_results["stored"] = stored
            self.current_dtcs = stored
        
        # Read pending DTCs (mode 07)
        pending = self._read_pending_dtcs()
        if pending:
            dtc_results["pending"] = pending
            self.pending_dtcs = pending
        
        # Read permanent DTCs (mode 0A)
        permanent = self._read_permanent_dtcs()
        if permanent:
            dtc_results["permanent"] = permanent
            self.permanent_dtcs = permanent
        
        return dtc_results
    
    def _read_stored_dtcs(self) -> List[str]:
        """Read stored DTCs using mode 03"""
        return self.obd_interface.read_dtc()
    
    def _read_pending_dtcs(self) -> List[str]:
        """Read pending DTCs using mode 07"""
        response = self.obd_interface._send_command("07")
        if response and response != "NO DATA":
            return self.obd_interface._parse_dtc_response(response)
        return []
    
    def _read_permanent_dtcs(self) -> List[str]:
        """Read permanent DTCs using mode 0A"""
        response = self.obd_interface._send_command("0A")
        if response and response != "NO DATA":
            return self.obd_interface._parse_dtc_response(response)
        return []
    
    def clear_dtcs(self, dtc_type: str = "stored") -> bool:
        """
        Clear DTCs of specified type
        
        Args:
            dtc_type: Type of DTCs to clear ("stored", "pending", "all")
            
        Returns:
            bool: True if successful
        """
        success = False
        
        if dtc_type in ["stored", "all"]:
            # Clear stored DTCs (mode 04)
            success = self.obd_interface.clear_dtc()
        
        if dtc_type == "all":
            # Additional clearing commands for some vehicles
            self.obd_interface._send_command("04")  # Standard clear
            
        if success:
            self.logger.info(f"Cleared {dtc_type} DTCs")
            if dtc_type in ["stored", "all"]:
                self.current_dtcs = []
            if dtc_type == "all":
                self.pending_dtcs = []
        
        return success
    
    def analyze_dtcs(self, dtc_codes: List[str]) -> List[Dict]:
        """
        Analyze DTC codes and provide detailed information
        
        Args:
            dtc_codes: List of DTC codes to analyze
            
        Returns:
            list: List of dictionaries with DTC analysis
        """
        analysis = []
        
        for code in dtc_codes:
            dtc_info = self.error_db.get_dtc_info(code)
            
            if dtc_info:
                analysis.append({
                    "code": code,
                    "description": dtc_info.description,
                    "severity": dtc_info.severity,
                    "system": dtc_info.system,
                    "category": dtc_info.category,
                    "possible_causes": dtc_info.possible_causes,
                    "suggested_solutions": dtc_info.suggested_solutions,
                    "related_codes": dtc_info.related_codes
                })
            else:
                # Generic analysis for unknown codes
                analysis.append({
                    "code": code,
                    "description": self._generate_generic_description(code),
                    "severity": "Unknown",
                    "system": self._determine_system_from_code(code),
                    "category": self._determine_category_from_code(code),
                    "possible_causes": ["Code not in database", "Consult service manual"],
                    "suggested_solutions": ["Research specific code", "Consult professional"],
                    "related_codes": []
                })
        
        return analysis
    
    def _generate_generic_description(self, code: str) -> str:
        """Generate generic description for unknown codes"""
        if code.startswith('P'):
            return f"Powertrain diagnostic trouble code {code}"
        elif code.startswith('B'):
            return f"Body diagnostic trouble code {code}"
        elif code.startswith('C'):
            return f"Chassis diagnostic trouble code {code}"
        elif code.startswith('U'):
            return f"Network diagnostic trouble code {code}"
        else:
            return f"Diagnostic trouble code {code}"
    
    def _determine_system_from_code(self, code: str) -> str:
        """Determine system from DTC code pattern"""
        if code.startswith('P0'):
            if code.startswith('P01'):
                return "Fuel and Air Metering"
            elif code.startswith('P02'):
                return "Fuel and Air Metering"
            elif code.startswith('P03'):
                return "Ignition System"
            elif code.startswith('P04'):
                return "Emission Control"
            elif code.startswith('P05'):
                return "Idle Speed Control"
            elif code.startswith('P06'):
                return "ECM/PCM"
            elif code.startswith('P07'):
                return "Transmission"
            else:
                return "Powertrain"
        elif code.startswith('B'):
            return "Body Control"
        elif code.startswith('C'):
            return "Chassis Control"
        elif code.startswith('U'):
            return "Network Communication"
        else:
            return "Unknown"
    
    def _determine_category_from_code(self, code: str) -> str:
        """Determine category from DTC code"""
        if code.startswith('P'):
            return "Powertrain"
        elif code.startswith('B'):
            return "Body"
        elif code.startswith('C'):
            return "Chassis"
        elif code.startswith('U'):
            return "Network"
        else:
            return "Unknown"
    
    def get_dtc_priority(self, dtc_codes: List[str]) -> List[Tuple[str, int]]:
        """
        Prioritize DTCs by severity and system impact
        
        Args:
            dtc_codes: List of DTC codes
            
        Returns:
            list: List of tuples (code, priority) sorted by priority
        """
        priorities = []
        
        for code in dtc_codes:
            dtc_info = self.error_db.get_dtc_info(code)
            priority = 3  # Default medium priority
            
            if dtc_info:
                if dtc_info.severity == "High":
                    priority = 1
                elif dtc_info.severity == "Medium":
                    priority = 2
                elif dtc_info.severity == "Low":
                    priority = 3
                
                # Adjust priority based on system
                if "engine" in dtc_info.system.lower() or "ignition" in dtc_info.system.lower():
                    priority = min(priority, 1)  # Engine issues are high priority
                elif "emission" in dtc_info.system.lower():
                    priority = min(priority, 2)  # Emission issues are medium-high priority
            
            priorities.append((code, priority))
        
        # Sort by priority (1 = highest priority)
        priorities.sort(key=lambda x: x[1])
        return priorities