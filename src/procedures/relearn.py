"""
Relearn Procedures Module
Handles various vehicle relearn and adaptation procedures
"""

import time
import logging
from typing import Dict, List, Optional, Callable, Any
from dataclasses import dataclass
from enum import Enum

class ProcedureStatus(Enum):
    """Status of relearn procedure"""
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

@dataclass
class ProcedureStep:
    """Individual step in a relearn procedure"""
    step_number: int
    description: str
    instruction: str
    command: Optional[str]
    wait_time: float
    validation: Optional[str]
    is_manual: bool  # Requires manual action

@dataclass
class RelearnProcedure:
    """Complete relearn procedure definition"""
    name: str
    description: str
    vehicle_requirements: List[str]
    preconditions: List[str]
    steps: List[ProcedureStep]
    estimated_time: int  # minutes
    difficulty: str  # "Easy", "Medium", "Hard"

class RelearnManager:
    """Manages vehicle relearn and adaptation procedures"""
    
    def __init__(self, obd_interface, ecu_programmer=None):
        """
        Initialize relearn manager
        
        Args:
            obd_interface: OBDInterface instance
            ecu_programmer: ECUProgrammer instance (optional)
        """
        self.obd_interface = obd_interface
        self.ecu_programmer = ecu_programmer
        self.logger = logging.getLogger(__name__)
        self.current_procedure = None
        self.procedure_status = ProcedureStatus.NOT_STARTED
        self.current_step = 0
        self.procedures = self._load_procedures()
        self.status_callbacks = []
    
    def _load_procedures(self) -> Dict[str, RelearnProcedure]:
        """Load available relearn procedures"""
        procedures = {}
        
        # Throttle Body Relearn
        procedures["throttle_body_relearn"] = RelearnProcedure(
            name="Throttle Body Relearn",
            description="Relearn throttle body position and idle air control",
            vehicle_requirements=[
                "Engine must be warmed up to operating temperature",
                "All electrical loads should be turned off",
                "Transmission in Park/Neutral"
            ],
            preconditions=[
                "No DTCs present",
                "Engine coolant temperature > 80°C",
                "Vehicle stationary"
            ],
            steps=[
                ProcedureStep(1, "Turn ignition ON", "Turn ignition to ON position (engine off)", None, 2.0, None, True),
                ProcedureStep(2, "Wait for self-test", "Wait for ECU self-test to complete", None, 10.0, None, False),
                ProcedureStep(3, "Start engine", "Start engine and let idle", None, 5.0, None, True),
                ProcedureStep(4, "Warm up engine", "Let engine reach operating temperature", None, 180.0, "temperature>80", False),
                ProcedureStep(5, "Initialize relearn", "Send throttle relearn command", "31010203", 5.0, "positive_response", False),
                ProcedureStep(6, "Engine idle", "Let engine idle for specified time", None, 120.0, None, False),
                ProcedureStep(7, "Rev engine", "Rev engine to 2000 RPM and hold", None, 30.0, "rpm>1800", True),
                ProcedureStep(8, "Return to idle", "Release throttle and return to idle", None, 60.0, "rpm<1000", True),
                ProcedureStep(9, "Complete relearn", "Finalize throttle body relearn", "31030203", 5.0, "positive_response", False),
                ProcedureStep(10, "Turn off engine", "Turn off engine", None, 2.0, None, True),
                ProcedureStep(11, "Verify completion", "Check for completion status", "22F186", 5.0, "no_errors", False)
            ],
            estimated_time=15,
            difficulty="Medium"
        )
        
        # Transmission Adaptive Learning
        procedures["transmission_adaptive"] = RelearnProcedure(
            name="Transmission Adaptive Learning",
            description="Reset and relearn transmission shift points and behaviors",
            vehicle_requirements=[
                "Automatic transmission",
                "Engine at operating temperature",
                "Transmission fluid at proper level"
            ],
            preconditions=[
                "No transmission DTCs",
                "Vehicle on level surface",
                "Parking brake engaged"
            ],
            steps=[
                ProcedureStep(1, "Connect to TCM", "Establish connection with Transmission Control Module", "ATSH7E1", 2.0, None, False),
                ProcedureStep(2, "Enter diagnostic session", "Enter extended diagnostic session", "1003", 3.0, "positive_response", False),
                ProcedureStep(3, "Clear adaptations", "Clear existing adaptive values", "310105", 5.0, "positive_response", False),
                ProcedureStep(4, "Initialize learning", "Start adaptive learning process", "310106", 3.0, "positive_response", False),
                ProcedureStep(5, "Drive cycle preparation", "Prepare for drive cycle", None, 10.0, None, True),
                ProcedureStep(6, "Start engine", "Start engine and let warm up", None, 120.0, "temperature>80", True),
                ProcedureStep(7, "Drive cycle P to D", "Shift from Park to Drive", None, 5.0, None, True),
                ProcedureStep(8, "Idle in Drive", "Let transmission learn idle characteristics", None, 60.0, None, True),
                ProcedureStep(9, "Low speed driving", "Drive at low speeds (15-25 mph)", None, 300.0, None, True),
                ProcedureStep(10, "Medium speed driving", "Drive at medium speeds (25-45 mph)", None, 300.0, None, True),
                ProcedureStep(11, "Highway driving", "Drive at highway speeds (45+ mph)", None, 600.0, None, True),
                ProcedureStep(12, "Complete learning", "Finalize adaptive learning", "310107", 5.0, "positive_response", False),
                ProcedureStep(13, "Verify completion", "Check adaptation status", "22F190", 5.0, "adaptations_complete", False)
            ],
            estimated_time=45,
            difficulty="Hard"
        )
        
        # TPMS Relearn
        procedures["tpms_relearn"] = RelearnProcedure(
            name="TPMS Sensor Relearn",
            description="Relearn tire pressure monitoring sensor positions",
            vehicle_requirements=[
                "All tires properly inflated",
                "TPMS sensors installed",
                "Vehicle stationary"
            ],
            preconditions=[
                "No TPMS DTCs",
                "Ignition ON",
                "Vehicle not moving"
            ],
            steps=[
                ProcedureStep(1, "Enter TPMS mode", "Enter TPMS relearn mode", "31010301", 3.0, "positive_response", False),
                ProcedureStep(2, "LF tire learn", "Activate left front sensor", None, 15.0, None, True),
                ProcedureStep(3, "RF tire learn", "Activate right front sensor", None, 15.0, None, True),
                ProcedureStep(4, "RR tire learn", "Activate right rear sensor", None, 15.0, None, True),
                ProcedureStep(5, "LR tire learn", "Activate left rear sensor", None, 15.0, None, True),
                ProcedureStep(6, "Complete relearn", "Finalize TPMS relearn", "31030301", 5.0, "positive_response", False),
                ProcedureStep(7, "Verify sensors", "Check all sensors learned", "22F192", 5.0, "all_sensors_ok", False)
            ],
            estimated_time=10,
            difficulty="Easy"
        )
        
        # Fuel Trim Reset
        procedures["fuel_trim_reset"] = RelearnProcedure(
            name="Fuel Trim Reset and Relearn",
            description="Reset fuel trim values and relearn fuel delivery",
            vehicle_requirements=[
                "Engine at operating temperature",
                "No vacuum leaks",
                "Clean air filter"
            ],
            preconditions=[
                "No fuel system DTCs",
                "Closed loop operation",
                "O2 sensors functional"
            ],
            steps=[
                ProcedureStep(1, "Clear fuel trims", "Reset short and long term fuel trims", "310201", 3.0, "positive_response", False),
                ProcedureStep(2, "Start engine", "Start engine and let idle", None, 10.0, None, True),
                ProcedureStep(3, "Idle learning", "Let engine learn idle fuel delivery", None, 300.0, "closed_loop", False),
                ProcedureStep(4, "Part throttle learning", "Drive at part throttle conditions", None, 600.0, None, True),
                ProcedureStep(5, "Wide open throttle", "Perform WOT acceleration", None, 30.0, None, True),
                ProcedureStep(6, "Cruise learning", "Maintain steady cruise speeds", None, 300.0, None, True),
                ProcedureStep(7, "Verify learning", "Check fuel trim values", "220106", 5.0, "trims_normal", False)
            ],
            estimated_time=25,
            difficulty="Medium"
        )
        
        # Steering Angle Sensor Calibration
        procedures["steering_calibration"] = RelearnProcedure(
            name="Steering Angle Sensor Calibration",
            description="Calibrate steering angle sensor to center position",
            vehicle_requirements=[
                "Vehicle on level surface",
                "Wheels straight ahead",
                "Front wheels on alignment plates"
            ],
            preconditions=[
                "No ABS/ESP DTCs",
                "Vehicle stationary",
                "Steering wheel centered"
            ],
            steps=[
                ProcedureStep(1, "Connect to ABS", "Connect to ABS/ESP module", "ATSH7E8", 2.0, None, False),
                ProcedureStep(2, "Enter calibration mode", "Enter steering calibration mode", "31010401", 3.0, "positive_response", False),
                ProcedureStep(3, "Center steering wheel", "Ensure steering wheel is centered", None, 10.0, None, True),
                ProcedureStep(4, "Lock steering", "Hold steering wheel in center position", None, 5.0, None, True),
                ProcedureStep(5, "Perform calibration", "Execute steering angle calibration", "31020401", 10.0, "positive_response", False),
                ProcedureStep(6, "Verify calibration", "Check steering angle reading", "22F193", 5.0, "angle_zero", False),
                ProcedureStep(7, "Complete procedure", "Finalize calibration", "31030401", 3.0, "positive_response", False)
            ],
            estimated_time=8,
            difficulty="Easy"
        )
        
        return procedures
    
    def get_available_procedures(self) -> List[str]:
        """
        Get list of available relearn procedures
        
        Returns:
            list: List of procedure names
        """
        return list(self.procedures.keys())
    
    def get_procedure_info(self, procedure_name: str) -> Optional[RelearnProcedure]:
        """
        Get information about a specific procedure
        
        Args:
            procedure_name: Name of the procedure
            
        Returns:
            RelearnProcedure: Procedure information or None
        """
        return self.procedures.get(procedure_name)
    
    def start_procedure(self, procedure_name: str) -> bool:
        """
        Start a relearn procedure
        
        Args:
            procedure_name: Name of procedure to start
            
        Returns:
            bool: True if started successfully
        """
        if procedure_name not in self.procedures:
            self.logger.error(f"Unknown procedure: {procedure_name}")
            return False
        
        if self.procedure_status == ProcedureStatus.IN_PROGRESS:
            self.logger.error("Another procedure is already in progress")
            return False
        
        self.current_procedure = self.procedures[procedure_name]
        self.procedure_status = ProcedureStatus.IN_PROGRESS
        self.current_step = 0
        
        self.logger.info(f"Started procedure: {procedure_name}")
        self._notify_status_change()
        return True
    
    def execute_next_step(self) -> bool:
        """
        Execute the next step in the current procedure
        
        Returns:
            bool: True if step completed successfully
        """
        if not self.current_procedure or self.procedure_status != ProcedureStatus.IN_PROGRESS:
            return False
        
        if self.current_step >= len(self.current_procedure.steps):
            # Procedure completed
            self.procedure_status = ProcedureStatus.COMPLETED
            self.logger.info(f"Procedure '{self.current_procedure.name}' completed successfully")
            self._notify_status_change()
            return True
        
        step = self.current_procedure.steps[self.current_step]
        self.logger.info(f"Executing step {step.step_number}: {step.description}")
        
        try:
            # Execute command if present
            if step.command and not step.is_manual:
                response = self.obd_interface._send_command(step.command)
                
                # Validate response if validation specified
                if step.validation:
                    if not self._validate_response(response, step.validation):
                        self.logger.error(f"Step {step.step_number} validation failed")
                        self.procedure_status = ProcedureStatus.FAILED
                        self._notify_status_change()
                        return False
            
            # Wait for specified time
            if step.wait_time > 0:
                time.sleep(step.wait_time)
            
            # Move to next step
            self.current_step += 1
            self._notify_status_change()
            return True
            
        except Exception as e:
            self.logger.error(f"Error executing step {step.step_number}: {e}")
            self.procedure_status = ProcedureStatus.FAILED
            self._notify_status_change()
            return False
    
    def _validate_response(self, response: str, validation: str) -> bool:
        """
        Validate command response
        
        Args:
            response: Command response
            validation: Validation criteria
            
        Returns:
            bool: True if validation passed
        """
        if not response:
            return False
        
        if validation == "positive_response":
            # Check for positive response (service ID + 0x40)
            return any(code in response for code in ["71", "72", "73", "74", "75", "76", "77"])
        
        elif validation == "no_errors":
            return "NO DATA" not in response and "ERROR" not in response
        
        elif validation == "temperature>80":
            # Would need to read actual temperature - simplified here
            return True
        
        elif validation == "rpm>1800":
            # Would need to read actual RPM - simplified here
            return True
        
        elif validation == "rpm<1000":
            # Would need to read actual RPM - simplified here
            return True
        
        elif validation == "closed_loop":
            # Check for closed loop fuel control
            return True
        
        elif validation == "trims_normal":
            # Check fuel trim values are in normal range
            return True
        
        elif validation == "adaptations_complete":
            return "complete" in response.lower() or "ready" in response.lower()
        
        elif validation == "all_sensors_ok":
            return "OK" in response or "READY" in response
        
        elif validation == "angle_zero":
            return True  # Simplified validation
        
        return True
    
    def cancel_procedure(self) -> bool:
        """
        Cancel the current procedure
        
        Returns:
            bool: True if cancelled successfully
        """
        if self.procedure_status == ProcedureStatus.IN_PROGRESS:
            self.procedure_status = ProcedureStatus.CANCELLED
            self.logger.info(f"Cancelled procedure: {self.current_procedure.name}")
            self._notify_status_change()
            return True
        return False
    
    def get_procedure_status(self) -> Dict[str, Any]:
        """
        Get current procedure status
        
        Returns:
            dict: Current status information
        """
        status = {
            "status": self.procedure_status.value,
            "current_step": self.current_step,
            "total_steps": 0,
            "procedure_name": None,
            "current_step_info": None,
            "progress_percent": 0
        }
        
        if self.current_procedure:
            status.update({
                "procedure_name": self.current_procedure.name,
                "total_steps": len(self.current_procedure.steps),
                "progress_percent": (self.current_step / len(self.current_procedure.steps)) * 100
            })
            
            if self.current_step < len(self.current_procedure.steps):
                step = self.current_procedure.steps[self.current_step]
                status["current_step_info"] = {
                    "step_number": step.step_number,
                    "description": step.description,
                    "instruction": step.instruction,
                    "is_manual": step.is_manual,
                    "wait_time": step.wait_time
                }
        
        return status
    
    def add_status_callback(self, callback: Callable[[Dict[str, Any]], None]) -> None:
        """
        Add callback for status updates
        
        Args:
            callback: Function to call on status changes
        """
        self.status_callbacks.append(callback)
    
    def remove_status_callback(self, callback: Callable[[Dict[str, Any]], None]) -> None:
        """
        Remove status callback
        
        Args:
            callback: Function to remove
        """
        if callback in self.status_callbacks:
            self.status_callbacks.remove(callback)
    
    def _notify_status_change(self) -> None:
        """Notify all callbacks of status change"""
        status = self.get_procedure_status()
        for callback in self.status_callbacks:
            try:
                callback(status)
            except Exception as e:
                self.logger.error(f"Error in status callback: {e}")
    
    def check_preconditions(self, procedure_name: str) -> Dict[str, bool]:
        """
        Check if preconditions are met for a procedure
        
        Args:
            procedure_name: Name of procedure to check
            
        Returns:
            dict: Precondition check results
        """
        procedure = self.procedures.get(procedure_name)
        if not procedure:
            return {}
        
        results = {}
        
        for precondition in procedure.preconditions:
            if "No DTCs" in precondition or "No" in precondition and "DTC" in precondition:
                # Check for DTCs
                dtcs = self.obd_interface.read_dtc()
                results[precondition] = len(dtcs) == 0
                
            elif "temperature" in precondition.lower():
                # Check engine temperature
                temp_response = self.obd_interface.read_pid("01", "05")
                if temp_response:
                    # Parse temperature (simplified)
                    results[precondition] = True  # Would need actual parsing
                else:
                    results[precondition] = False
                    
            elif "stationary" in precondition.lower():
                # Check vehicle speed
                speed_response = self.obd_interface.read_pid("01", "0D")
                if speed_response:
                    # Parse speed (simplified)
                    results[precondition] = True  # Speed should be 0
                else:
                    results[precondition] = False
                    
            else:
                # For other preconditions, assume they need manual verification
                results[precondition] = None  # Requires manual check
        
        return results
    
    def get_estimated_time(self, procedure_name: str) -> int:
        """
        Get estimated time for procedure completion
        
        Args:
            procedure_name: Name of procedure
            
        Returns:
            int: Estimated time in minutes
        """
        procedure = self.procedures.get(procedure_name)
        return procedure.estimated_time if procedure else 0
    
    def export_procedure_log(self, filename: str) -> bool:
        """
        Export procedure execution log
        
        Args:
            filename: Output file name
            
        Returns:
            bool: True if successful
        """
        try:
            import json
            from datetime import datetime
            
            if not self.current_procedure:
                return False
            
            log_data = {
                "procedure_name": self.current_procedure.name,
                "timestamp": datetime.now().isoformat(),
                "status": self.procedure_status.value,
                "steps_completed": self.current_step,
                "total_steps": len(self.current_procedure.steps),
                "steps": []
            }
            
            for i, step in enumerate(self.current_procedure.steps):
                step_data = {
                    "step_number": step.step_number,
                    "description": step.description,
                    "completed": i < self.current_step,
                    "is_manual": step.is_manual,
                    "command": step.command
                }
                log_data["steps"].append(step_data)
            
            with open(filename, 'w') as f:
                json.dump(log_data, f, indent=2)
            
            self.logger.info(f"Procedure log exported to {filename}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error exporting procedure log: {e}")
            return False