"""
Configuration management for the OBD-II Tool
"""

import json
import configparser
from pathlib import Path
from typing import Any, Dict, Optional
import logging

logger = logging.getLogger(__name__)


class Config:
    """Configuration manager for the OBD-II Tool."""
    
    DEFAULT_CONFIG = {
        "connection": {
            "default_port": "auto",
            "default_baudrate": 38400,
            "timeout": 5.0,
            "adapter_type": "ELM327"
        },
        "gui": {
            "window_width": 1024,
            "window_height": 768,
            "theme": "default"
        },
        "diagnostics": {
            "auto_refresh_interval": 1000,  # milliseconds
            "max_dtc_history": 100
        },
        "logging": {
            "level": "INFO",
            "file_enabled": True,
            "console_enabled": True
        },
        "plugins": {
            "enabled": True,
            "auto_load": True,
            "plugin_directories": ["plugins/"]
        }
    }
    
    def __init__(self, config_file: Optional[str] = None):
        """
        Initialize configuration manager.
        
        Args:
            config_file: Path to configuration file
        """
        self.config_file = Path(config_file or "config.ini")
        self.config = configparser.ConfigParser()
        self._load_config()
    
    def _load_config(self) -> None:
        """Load configuration from file or create default."""
        try:
            if self.config_file.exists():
                self.config.read(self.config_file)
                logger.info(f"Loaded configuration from {self.config_file}")
            else:
                self._create_default_config()
                logger.info("Created default configuration")
        except Exception as e:
            logger.error(f"Error loading configuration: {e}")
            self._create_default_config()
    
    def _create_default_config(self) -> None:
        """Create default configuration file."""
        try:
            for section, settings in self.DEFAULT_CONFIG.items():
                self.config.add_section(section)
                for key, value in settings.items():
                    if isinstance(value, list):
                        self.config.set(section, key, json.dumps(value))
                    else:
                        self.config.set(section, key, str(value))
            
            self.save()
        except Exception as e:
            logger.error(f"Error creating default configuration: {e}")
    
    def get(self, section: str, key: str, fallback: Any = None) -> Any:
        """
        Get configuration value.
        
        Args:
            section: Configuration section
            key: Configuration key
            fallback: Fallback value if key not found
            
        Returns:
            Configuration value
        """
        try:
            value = self.config.get(section, key, fallback=str(fallback) if fallback else None)
            
            # Try to parse as JSON for complex types
            if value and value.startswith(('[', '{')):
                try:
                    return json.loads(value)
                except json.JSONDecodeError:
                    pass
            
            # Convert basic types
            if value:
                if value.lower() in ('true', 'false'):
                    return value.lower() == 'true'
                try:
                    # Try int first
                    if '.' not in value:
                        return int(value)
                    # Then float
                    return float(value)
                except ValueError:
                    pass
            
            return value or fallback
        except Exception as e:
            logger.error(f"Error getting config value {section}.{key}: {e}")
            return fallback
    
    def set(self, section: str, key: str, value: Any) -> None:
        """
        Set configuration value.
        
        Args:
            section: Configuration section
            key: Configuration key
            value: Value to set
        """
        try:
            if not self.config.has_section(section):
                self.config.add_section(section)
            
            if isinstance(value, (list, dict)):
                self.config.set(section, key, json.dumps(value))
            else:
                self.config.set(section, key, str(value))
        except Exception as e:
            logger.error(f"Error setting config value {section}.{key}: {e}")
    
    def save(self) -> None:
        """Save configuration to file."""
        try:
            with open(self.config_file, 'w') as f:
                self.config.write(f)
            logger.debug(f"Configuration saved to {self.config_file}")
        except Exception as e:
            logger.error(f"Error saving configuration: {e}")
    
    def get_connection_config(self) -> Dict[str, Any]:
        """Get connection configuration."""
        return {
            'port': self.get('connection', 'default_port', 'auto'),
            'baudrate': self.get('connection', 'default_baudrate', 38400),
            'timeout': self.get('connection', 'timeout', 5.0),
            'adapter_type': self.get('connection', 'adapter_type', 'ELM327')
        }
    
    def get_gui_config(self) -> Dict[str, Any]:
        """Get GUI configuration."""
        return {
            'window_width': self.get('gui', 'window_width', 1024),
            'window_height': self.get('gui', 'window_height', 768),
            'theme': self.get('gui', 'theme', 'default')
        }