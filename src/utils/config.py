"""
Configuration Management Module
"""

import os
import json
import logging
from typing import Dict, Any, Optional

class ConfigManager:
    """Manages application configuration"""
    
    def __init__(self, config_file: str = "config.json"):
        """
        Initialize configuration manager
        
        Args:
            config_file: Path to configuration file
        """
        self.config_file = config_file
        self.logger = logging.getLogger(__name__)
        self.config = self._load_default_config()
        self.load_config()
    
    def _load_default_config(self) -> Dict[str, Any]:
        """Load default configuration"""
        return {
            "connection": {
                "default_port": "",
                "default_baudrate": 38400,
                "timeout": 3.0,
                "auto_connect": False
            },
            "monitoring": {
                "default_refresh_rate": 1.0,
                "default_pids": ["0C", "0D", "05", "11"],
                "max_data_points": 1000
            },
            "programming": {
                "backup_directory": "./backups",
                "verify_after_flash": True,
                "security_warnings": True
            },
            "interface": {
                "window_geometry": "1200x800",
                "theme": "default",
                "font_size": 10,
                "auto_save_reports": True
            },
            "logging": {
                "level": "INFO",
                "log_file": "obd_tool.log",
                "max_log_size": 10485760,  # 10MB
                "backup_count": 5
            }
        }
    
    def load_config(self) -> None:
        """Load configuration from file"""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, 'r') as f:
                    file_config = json.load(f)
                    self._merge_config(self.config, file_config)
                self.logger.info(f"Configuration loaded from {self.config_file}")
            else:
                self.logger.info("Configuration file not found, using defaults")
                self.save_config()  # Create default config file
        except Exception as e:
            self.logger.error(f"Error loading configuration: {e}")
    
    def save_config(self) -> None:
        """Save configuration to file"""
        try:
            with open(self.config_file, 'w') as f:
                json.dump(self.config, f, indent=2)
            self.logger.info(f"Configuration saved to {self.config_file}")
        except Exception as e:
            self.logger.error(f"Error saving configuration: {e}")
    
    def _merge_config(self, default: Dict[str, Any], file_config: Dict[str, Any]) -> None:
        """Recursively merge configuration dictionaries"""
        for key, value in file_config.items():
            if key in default and isinstance(default[key], dict) and isinstance(value, dict):
                self._merge_config(default[key], value)
            else:
                default[key] = value
    
    def get(self, key_path: str, default: Any = None) -> Any:
        """
        Get configuration value using dot notation
        
        Args:
            key_path: Configuration key path (e.g., 'connection.default_port')
            default: Default value if key not found
            
        Returns:
            Configuration value
        """
        keys = key_path.split('.')
        value = self.config
        
        try:
            for key in keys:
                value = value[key]
            return value
        except (KeyError, TypeError):
            return default
    
    def set(self, key_path: str, value: Any) -> None:
        """
        Set configuration value using dot notation
        
        Args:
            key_path: Configuration key path
            value: Value to set
        """
        keys = key_path.split('.')
        config = self.config
        
        # Navigate to parent dictionary
        for key in keys[:-1]:
            if key not in config:
                config[key] = {}
            config = config[key]
        
        # Set value
        config[keys[-1]] = value
    
    def get_connection_config(self) -> Dict[str, Any]:
        """Get connection configuration"""
        return self.config.get("connection", {})
    
    def get_monitoring_config(self) -> Dict[str, Any]:
        """Get monitoring configuration"""
        return self.config.get("monitoring", {})
    
    def get_programming_config(self) -> Dict[str, Any]:
        """Get programming configuration"""
        return self.config.get("programming", {})
    
    def get_interface_config(self) -> Dict[str, Any]:
        """Get interface configuration"""
        return self.config.get("interface", {})
    
    def get_logging_config(self) -> Dict[str, Any]:
        """Get logging configuration"""
        return self.config.get("logging", {})