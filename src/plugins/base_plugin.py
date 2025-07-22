"""
Base plugin class for the OBD-II Tool plugin system
"""

import logging
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, List

logger = logging.getLogger(__name__)


class BasePlugin(ABC):
    """Base class for all OBD-II Tool plugins"""
    
    def __init__(self, name: str, version: str, description: str):
        """
        Initialize base plugin.
        
        Args:
            name: Plugin name
            version: Plugin version
            description: Plugin description
        """
        self.name = name
        self.version = version
        self.description = description
        self.enabled = False
        self.initialized = False
        self.config = {}
        self.obd_manager = None
        self.main_app = None
    
    @abstractmethod
    def initialize(self, obd_manager, main_app, config: Dict[str, Any]) -> bool:
        """
        Initialize the plugin.
        
        Args:
            obd_manager: OBD manager instance
            main_app: Main application instance
            config: Plugin configuration
            
        Returns:
            True if initialization successful
        """
        pass
    
    @abstractmethod
    def shutdown(self) -> None:
        """Shutdown the plugin and clean up resources."""
        pass
    
    @abstractmethod
    def get_menu_items(self) -> List[Dict[str, Any]]:
        """
        Get menu items to add to the main application.
        
        Returns:
            List of menu item dictionaries with keys:
            - 'label': Menu item label
            - 'command': Callback function
            - 'submenu': Optional submenu items
        """
        pass
    
    @abstractmethod
    def get_toolbar_items(self) -> List[Dict[str, Any]]:
        """
        Get toolbar items to add to the main application.
        
        Returns:
            List of toolbar item dictionaries with keys:
            - 'label': Button label
            - 'command': Callback function
            - 'icon': Optional icon path
            - 'tooltip': Optional tooltip text
        """
        pass
    
    def get_info(self) -> Dict[str, Any]:
        """
        Get plugin information.
        
        Returns:
            Plugin information dictionary
        """
        return {
            'name': self.name,
            'version': self.version,
            'description': self.description,
            'enabled': self.enabled,
            'initialized': self.initialized
        }
    
    def enable(self) -> bool:
        """
        Enable the plugin.
        
        Returns:
            True if enabled successfully
        """
        try:
            if not self.initialized:
                logger.error(f"Cannot enable uninitialized plugin: {self.name}")
                return False
            
            self.enabled = True
            logger.info(f"Plugin enabled: {self.name}")
            return True
            
        except Exception as e:
            logger.error(f"Error enabling plugin {self.name}: {e}")
            return False
    
    def disable(self) -> bool:
        """
        Disable the plugin.
        
        Returns:
            True if disabled successfully
        """
        try:
            self.enabled = False
            logger.info(f"Plugin disabled: {self.name}")
            return True
            
        except Exception as e:
            logger.error(f"Error disabling plugin {self.name}: {e}")
            return False
    
    def set_config(self, config: Dict[str, Any]) -> None:
        """
        Set plugin configuration.
        
        Args:
            config: Configuration dictionary
        """
        self.config = config.copy()
    
    def get_config(self) -> Dict[str, Any]:
        """
        Get plugin configuration.
        
        Returns:
            Configuration dictionary
        """
        return self.config.copy()
    
    def log_info(self, message: str) -> None:
        """Log info message with plugin name prefix."""
        logger.info(f"[{self.name}] {message}")
    
    def log_warning(self, message: str) -> None:
        """Log warning message with plugin name prefix."""
        logger.warning(f"[{self.name}] {message}")
    
    def log_error(self, message: str) -> None:
        """Log error message with plugin name prefix."""
        logger.error(f"[{self.name}] {message}")


class DiagnosticPlugin(BasePlugin):
    """Base class for diagnostic plugins"""
    
    @abstractmethod
    def get_supported_pids(self) -> List[int]:
        """
        Get list of supported PIDs.
        
        Returns:
            List of PID numbers
        """
        pass
    
    @abstractmethod
    def process_pid_data(self, pid: int, raw_data: bytes) -> Optional[Any]:
        """
        Process PID data.
        
        Args:
            pid: PID number
            raw_data: Raw data bytes
            
        Returns:
            Processed data or None
        """
        pass
    
    @abstractmethod
    def get_dtc_descriptions(self) -> Dict[str, str]:
        """
        Get DTC code descriptions.
        
        Returns:
            Dictionary mapping DTC codes to descriptions
        """
        pass


class ProgrammingPlugin(BasePlugin):
    """Base class for programming plugins"""
    
    @abstractmethod
    def get_supported_operations(self) -> List[str]:
        """
        Get list of supported programming operations.
        
        Returns:
            List of operation names
        """
        pass
    
    @abstractmethod
    def execute_operation(self, operation: str, parameters: Dict[str, Any]) -> bool:
        """
        Execute programming operation.
        
        Args:
            operation: Operation name
            parameters: Operation parameters
            
        Returns:
            True if successful
        """
        pass
    
    @abstractmethod
    def get_operation_parameters(self, operation: str) -> List[Dict[str, Any]]:
        """
        Get parameters required for an operation.
        
        Args:
            operation: Operation name
            
        Returns:
            List of parameter dictionaries with keys:
            - 'name': Parameter name
            - 'type': Parameter type (str, int, float, bool, file)
            - 'description': Parameter description
            - 'required': Whether parameter is required
            - 'default': Default value (optional)
        """
        pass


class ProtocolPlugin(BasePlugin):
    """Base class for protocol plugins"""
    
    @abstractmethod
    def get_supported_protocols(self) -> List[str]:
        """
        Get list of supported protocols.
        
        Returns:
            List of protocol names
        """
        pass
    
    @abstractmethod
    def send_command(self, command: str, protocol: str) -> Optional[str]:
        """
        Send command using specific protocol.
        
        Args:
            command: Command to send
            protocol: Protocol to use
            
        Returns:
            Response string or None
        """
        pass
    
    @abstractmethod
    def initialize_protocol(self, protocol: str, parameters: Dict[str, Any]) -> bool:
        """
        Initialize specific protocol.
        
        Args:
            protocol: Protocol name
            parameters: Protocol parameters
            
        Returns:
            True if successful
        """
        pass


class UIPlugin(BasePlugin):
    """Base class for UI enhancement plugins"""
    
    @abstractmethod
    def create_panel(self, parent_widget) -> Optional[Any]:
        """
        Create custom UI panel.
        
        Args:
            parent_widget: Parent widget for the panel
            
        Returns:
            Panel widget or None
        """
        pass
    
    @abstractmethod
    def get_panel_title(self) -> str:
        """
        Get panel title for notebook tab.
        
        Returns:
            Panel title string
        """
        pass
    
    def update_panel(self, data: Dict[str, Any]) -> None:
        """
        Update panel with new data.
        
        Args:
            data: Data to update panel with
        """
        pass