"""
Example plugin demonstrating the plugin system
"""

import tkinter as tk
from tkinter import ttk, messagebox
from typing import Dict, Any, List, Optional
import time

from .base_plugin import DiagnosticPlugin


class ExampleDiagnosticPlugin(DiagnosticPlugin):
    """Example diagnostic plugin for demonstration purposes"""
    
    def __init__(self):
        """Initialize example plugin."""
        super().__init__(
            name="Example Diagnostic Plugin",
            version="1.0.0",
            description="Example plugin demonstrating diagnostic capabilities"
        )
        
        # Custom PIDs supported by this plugin
        self.custom_pids = {
            0xF0: {
                'name': 'Custom Parameter 1',
                'unit': 'units',
                'formula': lambda x: x[0] * 0.5,
                'description': 'Example custom parameter'
            },
            0xF1: {
                'name': 'Custom Parameter 2', 
                'unit': '%',
                'formula': lambda x: x[0] * 100 / 255,
                'description': 'Example percentage parameter'
            }
        }
        
        # Custom DTC descriptions
        self.custom_dtcs = {
            'P1234': 'Example Custom DTC - Test Code',
            'P1235': 'Example Custom DTC - Demo Fault',
            'B1236': 'Example Body DTC - Demo Issue'
        }
        
        self.panel_widget = None
    
    def initialize(self, obd_manager, main_app, config: Dict[str, Any]) -> bool:
        """Initialize the plugin."""
        try:
            self.obd_manager = obd_manager
            self.main_app = main_app
            self.config = config
            
            self.log_info("Initializing example diagnostic plugin")
            
            # Add custom PIDs to OBD manager if available
            if hasattr(self.obd_manager, 'STANDARD_PIDS'):
                for pid, info in self.custom_pids.items():
                    from ..core.obd_manager import OBDParameter
                    param = OBDParameter(
                        pid=pid,
                        name=info['name'],
                        description=info['description'],
                        unit=info['unit'],
                        formula=info['formula']
                    )
                    self.obd_manager.STANDARD_PIDS[pid] = param
            
            self.initialized = True
            self.log_info("Plugin initialized successfully")
            return True
            
        except Exception as e:
            self.log_error(f"Error initializing plugin: {e}")
            return False
    
    def shutdown(self) -> None:
        """Shutdown the plugin."""
        try:
            self.log_info("Shutting down plugin")
            
            # Remove custom PIDs from OBD manager
            if self.obd_manager and hasattr(self.obd_manager, 'STANDARD_PIDS'):
                for pid in self.custom_pids.keys():
                    self.obd_manager.STANDARD_PIDS.pop(pid, None)
            
            self.initialized = False
            self.enabled = False
            
        except Exception as e:
            self.log_error(f"Error shutting down plugin: {e}")
    
    def get_menu_items(self) -> List[Dict[str, Any]]:
        """Get menu items for the plugin."""
        return [
            {
                'label': 'Example Plugin',
                'submenu': [
                    {
                        'label': 'Show Custom Panel',
                        'command': self._show_custom_panel
                    },
                    {
                        'label': 'Test Custom PIDs',
                        'command': self._test_custom_pids
                    },
                    {
                        'label': 'Plugin Info',
                        'command': self._show_plugin_info
                    }
                ]
            }
        ]
    
    def get_toolbar_items(self) -> List[Dict[str, Any]]:
        """Get toolbar items for the plugin."""
        return [
            {
                'label': 'Example',
                'command': self._show_custom_panel,
                'tooltip': 'Show example plugin panel'
            }
        ]
    
    def get_supported_pids(self) -> List[int]:
        """Get list of supported PIDs."""
        return list(self.custom_pids.keys())
    
    def process_pid_data(self, pid: int, raw_data: bytes) -> Optional[Any]:
        """Process PID data."""
        if pid in self.custom_pids:
            try:
                # Convert bytes to list for formula
                data_list = list(raw_data)
                formula = self.custom_pids[pid]['formula']
                return formula(data_list)
            except Exception as e:
                self.log_error(f"Error processing PID {pid:02X}: {e}")
                return None
        
        return None
    
    def get_dtc_descriptions(self) -> Dict[str, str]:
        """Get DTC code descriptions."""
        return self.custom_dtcs.copy()
    
    def _show_custom_panel(self) -> None:
        """Show custom plugin panel."""
        try:
            # Create a new window for the plugin panel
            panel_window = tk.Toplevel(self.main_app.root)
            panel_window.title(f"{self.name} - Custom Panel")
            panel_window.geometry("600x400")
            panel_window.transient(self.main_app.root)
            
            # Create panel content
            self._create_panel_content(panel_window)
            
        except Exception as e:
            self.log_error(f"Error showing custom panel: {e}")
            messagebox.showerror("Error", f"Failed to show custom panel: {e}")
    
    def _create_panel_content(self, parent) -> None:
        """Create content for the custom panel."""
        main_frame = ttk.Frame(parent, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Plugin info section
        info_frame = ttk.LabelFrame(main_frame, text="Plugin Information", padding="5")
        info_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(info_frame, text=f"Name: {self.name}").pack(anchor=tk.W)
        ttk.Label(info_frame, text=f"Version: {self.version}").pack(anchor=tk.W)
        ttk.Label(info_frame, text=f"Description: {self.description}").pack(anchor=tk.W)
        ttk.Label(info_frame, text=f"Status: {'Enabled' if self.enabled else 'Disabled'}").pack(anchor=tk.W)
        
        # Custom PIDs section
        pids_frame = ttk.LabelFrame(main_frame, text="Custom PIDs", padding="5")
        pids_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Create treeview for PIDs
        columns = ("PID", "Name", "Unit", "Description")
        pid_tree = ttk.Treeview(pids_frame, columns=columns, show="headings", height=6)
        
        for col in columns:
            pid_tree.heading(col, text=col)
            if col == "PID":
                pid_tree.column(col, width=60)
            elif col == "Unit":
                pid_tree.column(col, width=80)
            else:
                pid_tree.column(col, width=150)
        
        # Populate PID tree
        for pid, info in self.custom_pids.items():
            pid_tree.insert("", "end", values=(
                f"0x{pid:02X}",
                info['name'],
                info['unit'],
                info['description']
            ))
        
        pid_tree.pack(fill=tk.X)
        
        # Custom DTCs section
        dtcs_frame = ttk.LabelFrame(main_frame, text="Custom DTCs", padding="5")
        dtcs_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Create treeview for DTCs
        dtc_columns = ("Code", "Description")
        dtc_tree = ttk.Treeview(dtcs_frame, columns=dtc_columns, show="headings", height=6)
        
        for col in dtc_columns:
            dtc_tree.heading(col, text=col)
            if col == "Code":
                dtc_tree.column(col, width=100)
            else:
                dtc_tree.column(col, width=400)
        
        # Populate DTC tree
        for code, description in self.custom_dtcs.items():
            dtc_tree.insert("", "end", values=(code, description))
        
        dtc_tree.pack(fill=tk.X)
        
        # Action buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Button(button_frame, text="Test PIDs", command=self._test_custom_pids).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Simulate DTC", command=self._simulate_dtc).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Close", command=parent.destroy).pack(side=tk.RIGHT, padx=2)
    
    def _test_custom_pids(self) -> None:
        """Test custom PIDs."""
        try:
            if not self.main_app.connected:
                messagebox.showwarning("Warning", "Not connected to vehicle")
                return
            
            self.log_info("Testing custom PIDs")
            
            results = []
            for pid in self.custom_pids.keys():
                # Simulate reading the PID (real implementation would query vehicle)
                import random
                simulated_data = bytes([random.randint(0, 255) for _ in range(4)])
                value = self.process_pid_data(pid, simulated_data)
                
                if value is not None:
                    results.append(f"PID 0x{pid:02X}: {value:.2f} {self.custom_pids[pid]['unit']}")
                else:
                    results.append(f"PID 0x{pid:02X}: No data")
            
            result_text = "Custom PID Test Results:\n\n" + "\n".join(results)
            result_text += "\n\nNote: These are simulated values for demonstration"
            
            messagebox.showinfo("PID Test Results", result_text)
            
        except Exception as e:
            self.log_error(f"Error testing custom PIDs: {e}")
            messagebox.showerror("Error", f"Failed to test PIDs: {e}")
    
    def _simulate_dtc(self) -> None:
        """Simulate a custom DTC."""
        try:
            import random
            
            # Pick a random custom DTC
            dtc_code = random.choice(list(self.custom_dtcs.keys()))
            description = self.custom_dtcs[dtc_code]
            
            messagebox.showinfo("Simulated DTC", 
                              f"Simulated DTC Detection:\n\n"
                              f"Code: {dtc_code}\n"
                              f"Description: {description}\n\n"
                              f"This is a demonstration of custom DTC handling.")
            
            self.log_info(f"Simulated DTC: {dtc_code} - {description}")
            
        except Exception as e:
            self.log_error(f"Error simulating DTC: {e}")
            messagebox.showerror("Error", f"Failed to simulate DTC: {e}")
    
    def _show_plugin_info(self) -> None:
        """Show plugin information dialog."""
        info_text = f"""Plugin Information:

Name: {self.name}
Version: {self.version}
Description: {self.description}

Status:
- Initialized: {self.initialized}
- Enabled: {self.enabled}

Capabilities:
- Custom PIDs: {len(self.custom_pids)}
- Custom DTCs: {len(self.custom_dtcs)}

This is an example plugin that demonstrates:
- Adding custom PID definitions
- Providing custom DTC descriptions
- Creating custom UI panels
- Integrating with the main application"""
        
        messagebox.showinfo("Plugin Information", info_text)