#!/usr/bin/env python3
"""
OBD-II Diagnostics and Programming Tool
Main entry point for the application
"""

import sys
import os
import argparse
import logging

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from src.utils.config import ConfigManager
from src.utils.logger import setup_logging

# Import GUI module only when needed
MainWindow = None

def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="OBD-II Diagnostics and Programming Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                          # Launch GUI
  %(prog)s --port COM3              # Launch GUI with specific port
  %(prog)s --config custom.json     # Use custom config file
  %(prog)s --log-level DEBUG        # Enable debug logging
        """
    )
    
    parser.add_argument(
        '--port', '-p',
        help='Serial port for OBD adapter (e.g., COM3, /dev/ttyUSB0)'
    )
    
    parser.add_argument(
        '--baudrate', '-b',
        type=int,
        default=38400,
        help='Baudrate for serial communication (default: 38400)'
    )
    
    parser.add_argument(
        '--config', '-c',
        default='config.json',
        help='Configuration file path (default: config.json)'
    )
    
    parser.add_argument(
        '--log-level', '-l',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
        default='INFO',
        help='Logging level (default: INFO)'
    )
    
    parser.add_argument(
        '--log-file',
        help='Log file path (default: no file logging)'
    )
    
    parser.add_argument(
        '--no-gui',
        action='store_true',
        help='Run in command-line mode (not implemented yet)'
    )
    
    parser.add_argument(
        '--version', '-v',
        action='version',
        version='OBD-II Tool v1.0.0'
    )
    
    return parser.parse_args()

def main():
    """Main entry point"""
    # Parse arguments
    args = parse_arguments()
    
    # Load configuration
    config_manager = ConfigManager(args.config)
    
    # Setup logging
    log_config = config_manager.get_logging_config()
    log_level = args.log_level or log_config.get('level', 'INFO')
    log_file = args.log_file or log_config.get('log_file')
    
    setup_logging(
        log_level=log_level,
        log_file=log_file,
        max_size=log_config.get('max_log_size', 10485760),
        backup_count=log_config.get('backup_count', 5)
    )
    
    logger = logging.getLogger(__name__)
    logger.info("Starting OBD-II Diagnostics and Programming Tool")
    
    # Update configuration with command line arguments
    if args.port:
        config_manager.set('connection.default_port', args.port)
    if args.baudrate != 38400:
        config_manager.set('connection.default_baudrate', args.baudrate)
    
    try:
        if args.no_gui:
            # Command-line mode (not implemented yet)
            logger.error("Command-line mode not implemented yet")
            print("Command-line mode is not implemented yet.")
            print("Please run without --no-gui to use the graphical interface.")
            sys.exit(1)
        else:
            # GUI mode
            try:
                # Import GUI module
                from src.gui.main_window import MainWindow
                
                logger.info("Launching GUI application")
                app = MainWindow()
                
                # Pre-configure connection if specified
                if args.port:
                    app.port_var.set(args.port)
                if args.baudrate != 38400:
                    app.baudrate_var.set(str(args.baudrate))
                
                # Run application
                app.run()
                
            except ImportError as e:
                logger.error(f"GUI not available: {e}")
                print("Error: GUI interface not available.")
                print("This may be due to missing tkinter or other GUI dependencies.")
                print("Please install tkinter or run with --no-gui option.")
                sys.exit(1)
            
    except KeyboardInterrupt:
        logger.info("Application interrupted by user")
    except Exception as e:
        logger.exception("Unexpected error occurred")
        print(f"Error: {e}")
        sys.exit(1)
    
    logger.info("Application shutdown complete")

if __name__ == "__main__":
    main()