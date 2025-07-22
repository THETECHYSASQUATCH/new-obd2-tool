#!/usr/bin/env python3
"""
OBD-II Diagnostics and Programming Tool
Main entry point for the application.
"""

import sys
import logging
from pathlib import Path

# Add src directory to path
src_path = Path(__file__).parent / "src"
sys.path.insert(0, str(src_path))

from src.utils.logger import setup_logging
from src.utils.config import Config
from src.gui.main_window import OBD2ToolGUI


def main():
    """Main entry point for the OBD-II Tool."""
    # Setup logging
    setup_logging()
    logger = logging.getLogger(__name__)
    
    logger.info("Starting OBD-II Diagnostics and Programming Tool")
    
    try:
        # Load configuration
        config = Config()
        
        # Create and run the GUI application
        app = OBD2ToolGUI(config)
        app.run()
        
    except KeyboardInterrupt:
        logger.info("Application interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)
    
    logger.info("Application terminated normally")


if __name__ == "__main__":
    main()