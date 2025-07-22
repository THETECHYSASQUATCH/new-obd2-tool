#!/usr/bin/env python3
"""
OBD-II Diagnostics and Programming Tool
Main entry point for the application
"""

import sys
import os
import tkinter as tk
from tkinter import messagebox

# Add src directory to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
src_dir = os.path.join(current_dir, 'src')
sys.path.insert(0, src_dir)

def check_dependencies():
    """Check if required dependencies are installed"""
    missing_deps = []
    
    try:
        import tkinter
    except ImportError:
        missing_deps.append("tkinter")
    
    try:
        import json
    except ImportError:
        missing_deps.append("json")
    
    # Optional dependencies
    optional_missing = []
    try:
        import obd
    except ImportError:
        optional_missing.append("python-obd")
    
    if missing_deps:
        print(f"Error: Missing required dependencies: {', '.join(missing_deps)}")
        print("Please install the missing dependencies and try again.")
        return False
    
    if optional_missing:
        print(f"Warning: Optional dependencies not installed: {', '.join(optional_missing)}")
        print("Some features may not work without these dependencies.")
        print("To install: pip install -r requirements.txt")
    
    return True

def main():
    """Main application entry point"""
    print("OBD-II Diagnostics and Programming Tool")
    print("======================================")
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    try:
        # Import GUI after dependency check
        from gui.main_gui import OBD2ToolGUI
        
        # Create and run the application
        root = tk.Tk()
        app = OBD2ToolGUI(root)
        
        print("Starting GUI application...")
        root.mainloop()
        
    except ImportError as e:
        print(f"Error importing GUI components: {e}")
        print("Please make sure all files are in the correct location.")
        sys.exit(1)
    except Exception as e:
        print(f"Error starting application: {e}")
        messagebox.showerror("Application Error", f"Failed to start application: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()