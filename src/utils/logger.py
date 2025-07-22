"""
Logging Utilities Module
"""

import logging
import logging.handlers
import os
from typing import Optional

def setup_logging(
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    max_size: int = 10485760,  # 10MB
    backup_count: int = 5
) -> None:
    """
    Setup application logging
    
    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Log file path (optional)
        max_size: Maximum log file size in bytes
        backup_count: Number of backup log files to keep
    """
    # Convert string level to logging level
    numeric_level = getattr(logging, log_level.upper(), logging.INFO)
    
    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(numeric_level)
    
    # Clear existing handlers
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(numeric_level)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)
    
    # File handler (if specified)
    if log_file:
        try:
            # Create log directory if it doesn't exist
            log_dir = os.path.dirname(log_file)
            if log_dir and not os.path.exists(log_dir):
                os.makedirs(log_dir)
            
            # Rotating file handler
            file_handler = logging.handlers.RotatingFileHandler(
                log_file,
                maxBytes=max_size,
                backupCount=backup_count
            )
            file_handler.setLevel(numeric_level)
            file_handler.setFormatter(formatter)
            root_logger.addHandler(file_handler)
            
        except Exception as e:
            logging.warning(f"Failed to setup file logging: {e}")

class OBDLogger:
    """Specialized logger for OBD operations"""
    
    def __init__(self, name: str):
        """Initialize OBD logger"""
        self.logger = logging.getLogger(name)
    
    def log_command(self, command: str, response: Optional[str] = None, success: bool = True):
        """
        Log OBD command and response
        
        Args:
            command: OBD command sent
            response: Response received
            success: Whether command was successful
        """
        if success:
            self.logger.debug(f"CMD: {command} -> RSP: {response}")
        else:
            self.logger.warning(f"CMD: {command} -> FAILED: {response}")
    
    def log_connection(self, port: str, baudrate: int, success: bool = True):
        """
        Log connection attempt
        
        Args:
            port: Serial port
            baudrate: Baudrate
            success: Whether connection was successful
        """
        if success:
            self.logger.info(f"Connected to {port} at {baudrate} baud")
        else:
            self.logger.error(f"Failed to connect to {port} at {baudrate} baud")
    
    def log_dtc(self, dtc_code: str, description: str = ""):
        """
        Log DTC code
        
        Args:
            dtc_code: DTC code
            description: DTC description
        """
        self.logger.info(f"DTC: {dtc_code} - {description}")
    
    def log_programming_operation(self, operation: str, ecu_address: str, success: bool = True):
        """
        Log programming operation
        
        Args:
            operation: Operation type
            ecu_address: ECU address
            success: Whether operation was successful
        """
        status = "SUCCESS" if success else "FAILED"
        self.logger.info(f"PROGRAMMING [{ecu_address}]: {operation} - {status}")
    
    def log_procedure_step(self, procedure: str, step: int, description: str, success: bool = True):
        """
        Log relearn procedure step
        
        Args:
            procedure: Procedure name
            step: Step number
            description: Step description
            success: Whether step was successful
        """
        status = "OK" if success else "FAILED"
        self.logger.info(f"PROCEDURE [{procedure}] Step {step}: {description} - {status}")