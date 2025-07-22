"""
Programming panel for ECU programming and feature management
"""

import tkinter as tk
from tkinter import ttk, messagebox
import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)


class ProgrammingPanel:
    """Panel for ECU programming and feature management operations"""
    
    def __init__(self, parent, main_app):
        """
        Initialize programming panel.
        
        Args:
            parent: Parent widget
            main_app: Reference to main application
        """
        self.parent = parent
        self.main_app = main_app
        
        self._create_widgets()
    
    def _create_widgets(self) -> None:
        """Create panel widgets."""
        # Warning frame
        warning_frame = ttk.LabelFrame(self.parent, text="⚠️  WARNING", padding="10")
        warning_frame.pack(fill=tk.X, padx=5, pady=5)
        
        warning_text = """ECU programming operations can permanently modify your vehicle's software.
Incorrect programming can result in:
• Vehicle malfunction or damage
• Loss of warranty
• Expensive repairs
• Safety hazards

Only proceed if you are experienced with ECU programming and have proper backup files."""
        
        ttk.Label(warning_frame, text=warning_text, foreground="red", font=("TkDefaultFont", 9)).pack()
        
        # Create notebook for programming functions
        self.prog_notebook = ttk.Notebook(self.parent)
        self.prog_notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # ECU Information tab
        self._create_ecu_info_tab()
        
        # Feature Management tab
        self._create_feature_management_tab()
        
        # Programming Operations tab
        self._create_programming_operations_tab()
        
        # Advanced Functions tab
        self._create_advanced_functions_tab()
    
    def _create_ecu_info_tab(self) -> None:
        """Create ECU information tab."""
        ecu_frame = ttk.Frame(self.prog_notebook)
        self.prog_notebook.add(ecu_frame, text="ECU Information")
        
        # Control frame
        control_frame = ttk.Frame(ecu_frame)
        control_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Button(control_frame, text="Read ECU Information", command=self._read_ecu_info).pack(side=tk.LEFT, padx=2)
        ttk.Button(control_frame, text="Read Calibration ID", command=self._read_calibration_id).pack(side=tk.LEFT, padx=2)
        ttk.Button(control_frame, text="Read Software Version", command=self._read_software_version).pack(side=tk.LEFT, padx=2)
        
        # ECU info display
        info_frame = ttk.LabelFrame(ecu_frame, text="ECU Information", padding="5")
        info_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Create treeview for ECU info
        columns = ("Parameter", "Value", "Description")
        self.ecu_info_tree = ttk.Treeview(info_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.ecu_info_tree.heading(col, text=col)
            if col == "Parameter":
                self.ecu_info_tree.column(col, width=150)
            elif col == "Value":
                self.ecu_info_tree.column(col, width=200)
            else:
                self.ecu_info_tree.column(col, width=300)
        
        # Add scrollbars
        ecu_scrollbar_v = ttk.Scrollbar(info_frame, orient=tk.VERTICAL, command=self.ecu_info_tree.yview)
        ecu_scrollbar_h = ttk.Scrollbar(info_frame, orient=tk.HORIZONTAL, command=self.ecu_info_tree.xview)
        self.ecu_info_tree.configure(yscrollcommand=ecu_scrollbar_v.set, xscrollcommand=ecu_scrollbar_h.set)
        
        self.ecu_info_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        ecu_scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        ecu_scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)
    
    def _create_feature_management_tab(self) -> None:
        """Create feature management tab."""
        feature_frame = ttk.Frame(self.prog_notebook)
        self.prog_notebook.add(feature_frame, text="Feature Management")
        
        # Info label
        info_label = ttk.Label(feature_frame, text="Manage vehicle features and configurations (implementation varies by vehicle)")
        info_label.pack(anchor=tk.W, padx=5, pady=5)
        
        # Feature categories frame
        categories_frame = ttk.LabelFrame(feature_frame, text="Feature Categories", padding="5")
        categories_frame.pack(fill=tk.X, padx=5, pady=5)
        
        # Create buttons for different feature categories
        button_frame = ttk.Frame(categories_frame)
        button_frame.pack(fill=tk.X)
        
        ttk.Button(button_frame, text="Comfort Features", command=lambda: self._show_features("comfort")).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Safety Features", command=lambda: self._show_features("safety")).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Engine Features", command=lambda: self._show_features("engine")).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Lighting Features", command=lambda: self._show_features("lighting")).pack(side=tk.LEFT, padx=2)
        
        # Features display frame
        features_display_frame = ttk.LabelFrame(feature_frame, text="Available Features", padding="5")
        features_display_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Create treeview for features
        columns = ("Feature", "Status", "Description", "Action")
        self.features_tree = ttk.Treeview(features_display_frame, columns=columns, show="headings", height=12)
        
        for col in columns:
            self.features_tree.heading(col, text=col)
            if col == "Feature":
                self.features_tree.column(col, width=200)
            elif col == "Status":
                self.features_tree.column(col, width=80)
            elif col == "Action":
                self.features_tree.column(col, width=100)
            else:
                self.features_tree.column(col, width=300)
        
        # Add scrollbars
        features_scrollbar_v = ttk.Scrollbar(features_display_frame, orient=tk.VERTICAL, command=self.features_tree.yview)
        features_scrollbar_h = ttk.Scrollbar(features_display_frame, orient=tk.HORIZONTAL, command=self.features_tree.xview)
        self.features_tree.configure(yscrollcommand=features_scrollbar_v.set, xscrollcommand=features_scrollbar_h.set)
        
        self.features_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        features_scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        features_scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Control buttons
        feature_control_frame = ttk.Frame(feature_frame)
        feature_control_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Button(feature_control_frame, text="Enable Selected", command=self._enable_feature).pack(side=tk.LEFT, padx=2)
        ttk.Button(feature_control_frame, text="Disable Selected", command=self._disable_feature).pack(side=tk.LEFT, padx=2)
        ttk.Button(feature_control_frame, text="Read Current Status", command=self._read_feature_status).pack(side=tk.LEFT, padx=10)
        
        # Bind double-click event
        self.features_tree.bind("<Double-1>", self._on_feature_double_click)
    
    def _create_programming_operations_tab(self) -> None:
        """Create programming operations tab."""
        prog_ops_frame = ttk.Frame(self.prog_notebook)
        self.prog_notebook.add(prog_ops_frame, text="Programming Operations")
        
        # Warning
        warning_label = ttk.Label(prog_ops_frame, text="⚠️  These operations can permanently modify ECU firmware", foreground="red")
        warning_label.pack(anchor=tk.W, padx=5, pady=5)
        
        # Flash operations frame
        flash_frame = ttk.LabelFrame(prog_ops_frame, text="Flash Operations", padding="5")
        flash_frame.pack(fill=tk.X, padx=5, pady=5)
        
        flash_button_frame = ttk.Frame(flash_frame)
        flash_button_frame.pack(fill=tk.X)
        
        ttk.Button(flash_button_frame, text="Read Flash", command=self._read_flash).pack(side=tk.LEFT, padx=2)
        ttk.Button(flash_button_frame, text="Write Flash", command=self._write_flash).pack(side=tk.LEFT, padx=2)
        ttk.Button(flash_button_frame, text="Verify Flash", command=self._verify_flash).pack(side=tk.LEFT, padx=2)
        ttk.Button(flash_button_frame, text="Erase Flash", command=self._erase_flash).pack(side=tk.LEFT, padx=2)
        
        # Calibration operations frame
        cal_frame = ttk.LabelFrame(prog_ops_frame, text="Calibration Operations", padding="5")
        cal_frame.pack(fill=tk.X, padx=5, pady=5)
        
        cal_button_frame = ttk.Frame(cal_frame)
        cal_button_frame.pack(fill=tk.X)
        
        ttk.Button(cal_button_frame, text="Read Calibration", command=self._read_calibration).pack(side=tk.LEFT, padx=2)
        ttk.Button(cal_button_frame, text="Write Calibration", command=self._write_calibration).pack(side=tk.LEFT, padx=2)
        ttk.Button(cal_button_frame, text="Backup Calibration", command=self._backup_calibration).pack(side=tk.LEFT, padx=2)
        ttk.Button(cal_button_frame, text="Restore Calibration", command=self._restore_calibration).pack(side=tk.LEFT, padx=2)
        
        # Progress frame
        progress_frame = ttk.LabelFrame(prog_ops_frame, text="Operation Progress", padding="5")
        progress_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.progress_var = tk.StringVar()
        self.progress_var.set("Ready")
        ttk.Label(progress_frame, textvariable=self.progress_var).pack(anchor=tk.W)
        
        self.progress_bar = ttk.Progressbar(progress_frame, mode='determinate', length=400)
        self.progress_bar.pack(fill=tk.X, pady=5)
        
        # Log frame
        log_frame = ttk.LabelFrame(prog_ops_frame, text="Operation Log", padding="5")
        log_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.prog_log = tk.Text(log_frame, height=8, state=tk.DISABLED)
        prog_log_scrollbar = ttk.Scrollbar(log_frame, orient=tk.VERTICAL, command=self.prog_log.yview)
        self.prog_log.configure(yscrollcommand=prog_log_scrollbar.set)
        
        self.prog_log.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        prog_log_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def _create_advanced_functions_tab(self) -> None:
        """Create advanced functions tab."""
        advanced_frame = ttk.Frame(self.prog_notebook)
        self.prog_notebook.add(advanced_frame, text="Advanced Functions")
        
        # Security access frame
        security_frame = ttk.LabelFrame(advanced_frame, text="Security Access", padding="5")
        security_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Label(security_frame, text="Security Level:").pack(side=tk.LEFT)
        self.security_level_var = tk.StringVar(value="1")
        security_combo = ttk.Combobox(security_frame, textvariable=self.security_level_var, 
                                    values=["1", "2", "3", "4", "5"], width=5)
        security_combo.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(security_frame, text="Request Seed", command=self._request_seed).pack(side=tk.LEFT, padx=5)
        ttk.Button(security_frame, text="Send Key", command=self._send_key).pack(side=tk.LEFT, padx=2)
        
        # Communication control frame
        comm_frame = ttk.LabelFrame(advanced_frame, text="Communication Control", padding="5")
        comm_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Button(comm_frame, text="Enable Communications", command=self._enable_communications).pack(side=tk.LEFT, padx=2)
        ttk.Button(comm_frame, text="Disable Communications", command=self._disable_communications).pack(side=tk.LEFT, padx=2)
        ttk.Button(comm_frame, text="Reset ECU", command=self._reset_ecu).pack(side=tk.LEFT, padx=10)
        
        # Memory access frame
        memory_frame = ttk.LabelFrame(advanced_frame, text="Memory Access", padding="5")
        memory_frame.pack(fill=tk.X, padx=5, pady=5)
        
        # Address input
        addr_frame = ttk.Frame(memory_frame)
        addr_frame.pack(fill=tk.X, pady=2)
        
        ttk.Label(addr_frame, text="Address:").pack(side=tk.LEFT)
        self.address_var = tk.StringVar()
        ttk.Entry(addr_frame, textvariable=self.address_var, width=10).pack(side=tk.LEFT, padx=5)
        
        ttk.Label(addr_frame, text="Length:").pack(side=tk.LEFT, padx=(10, 0))
        self.length_var = tk.StringVar()
        ttk.Entry(addr_frame, textvariable=self.length_var, width=10).pack(side=tk.LEFT, padx=5)
        
        # Memory operation buttons
        mem_button_frame = ttk.Frame(memory_frame)
        mem_button_frame.pack(fill=tk.X, pady=5)
        
        ttk.Button(mem_button_frame, text="Read Memory", command=self._read_memory).pack(side=tk.LEFT, padx=2)
        ttk.Button(mem_button_frame, text="Write Memory", command=self._write_memory).pack(side=tk.LEFT, padx=2)
        
        # Memory display
        mem_display_frame = ttk.LabelFrame(advanced_frame, text="Memory Data", padding="5")
        mem_display_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.memory_text = tk.Text(mem_display_frame, height=10, font=("Courier", 9))
        mem_scrollbar = ttk.Scrollbar(mem_display_frame, orient=tk.VERTICAL, command=self.memory_text.yview)
        self.memory_text.configure(yscrollcommand=mem_scrollbar.set)
        
        self.memory_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        mem_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def _log_programming_message(self, message: str) -> None:
        """Log message to programming log."""
        self.prog_log.config(state=tk.NORMAL)
        self.prog_log.insert(tk.END, f"{message}\n")
        self.prog_log.see(tk.END)
        self.prog_log.config(state=tk.DISABLED)
    
    def _check_connection(self) -> bool:
        """Check if connected to vehicle."""
        if not self.main_app.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return False
        return True
    
    # ECU Information Methods
    def _read_ecu_info(self) -> None:
        """Read ECU information."""
        if not self._check_connection():
            return
        
        try:
            # Clear existing info
            for item in self.ecu_info_tree.get_children():
                self.ecu_info_tree.delete(item)
            
            # This is a placeholder implementation
            # Real implementation would depend on vehicle-specific protocols
            ecu_info = [
                ("ECU Type", "Engine Control Module", "Primary engine management ECU"),
                ("Part Number", "12345-ABC-67890", "Manufacturer part number"),
                ("Hardware Version", "1.2.3", "ECU hardware revision"),
                ("Software Version", "4.5.6", "ECU software version"),
                ("Calibration ID", "CAL123456", "Calibration identification"),
                ("Serial Number", "SN789012345", "ECU serial number"),
                ("Boot Software", "BOOT1.0", "Boot loader version"),
                ("Application Software", "APP2.1", "Application software version"),
            ]
            
            for param, value, description in ecu_info:
                self.ecu_info_tree.insert("", "end", values=(param, value, description))
            
            messagebox.showinfo("ECU Information", "ECU information read successfully\n(Note: This is simulated data)")
            
        except Exception as e:
            logger.error(f"Error reading ECU information: {e}")
            messagebox.showerror("Error", f"Failed to read ECU information: {e}")
    
    def _read_calibration_id(self) -> None:
        """Read calibration ID."""
        if not self._check_connection():
            return
        
        try:
            # This would use Mode 09, PID 04 for calibration ID
            response = self.main_app.obd_manager.protocol_handler.send_command("0904")
            
            if response:
                cal_id = self.main_app.obd_manager.data_parser.parse_ascii(response)
                if cal_id:
                    messagebox.showinfo("Calibration ID", f"Calibration ID: {cal_id}")
                else:
                    messagebox.showwarning("Calibration ID", "No calibration ID data received")
            else:
                messagebox.showerror("Error", "Failed to read calibration ID")
                
        except Exception as e:
            logger.error(f"Error reading calibration ID: {e}")
            messagebox.showerror("Error", f"Failed to read calibration ID: {e}")
    
    def _read_software_version(self) -> None:
        """Read software version."""
        if not self._check_connection():
            return
        
        messagebox.showinfo("Software Version", "Software version reading not implemented yet\n(Requires vehicle-specific protocols)")
    
    # Feature Management Methods
    def _show_features(self, category: str) -> None:
        """Show features for a specific category."""
        # Clear existing features
        for item in self.features_tree.get_children():
            self.features_tree.delete(item)
        
        # Sample features (real implementation would read from vehicle)
        sample_features = {
            "comfort": [
                ("Auto Door Lock", "Enabled", "Automatically lock doors when driving", "Toggle"),
                ("Welcome Lights", "Disabled", "Turn on lights when approaching vehicle", "Toggle"),
                ("Seat Memory", "Enabled", "Remember seat positions", "Configure"),
                ("Climate Control", "Auto", "Automatic climate control", "Configure"),
            ],
            "safety": [
                ("Lane Departure Warning", "Enabled", "Warn when departing lane", "Toggle"),
                ("Collision Warning", "Enabled", "Forward collision warning", "Toggle"),
                ("Blind Spot Monitor", "Disabled", "Monitor blind spots", "Toggle"),
                ("Auto Emergency Braking", "Enabled", "Automatic emergency braking", "Configure"),
            ],
            "engine": [
                ("Start/Stop System", "Enabled", "Engine start/stop system", "Toggle"),
                ("Sport Mode", "Available", "Sport driving mode", "Toggle"),
                ("Eco Mode", "Enabled", "Economy driving mode", "Toggle"),
                ("Launch Control", "Disabled", "Launch control system", "Configure"),
            ],
            "lighting": [
                ("Daytime Running Lights", "Enabled", "DRL operation", "Toggle"),
                ("Auto Headlights", "Enabled", "Automatic headlight control", "Toggle"),
                ("Welcome Animation", "Disabled", "LED welcome animation", "Toggle"),
                ("Cornering Lights", "Enabled", "Additional cornering illumination", "Toggle"),
            ]
        }
        
        features = sample_features.get(category, [])
        
        for feature, status, description, action in features:
            self.features_tree.insert("", "end", values=(feature, status, description, action))
        
        messagebox.showinfo("Features", f"Showing {category} features\n(Note: This is simulated data)")
    
    def _enable_feature(self) -> None:
        """Enable selected feature."""
        selection = self.features_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "No feature selected")
            return
        
        feature_name = self.features_tree.item(selection[0], "values")[0]
        result = messagebox.askyesno("Confirm", f"Enable feature: {feature_name}?")
        
        if result:
            messagebox.showinfo("Feature Enable", f"Feature '{feature_name}' would be enabled\n(Not implemented)")
    
    def _disable_feature(self) -> None:
        """Disable selected feature."""
        selection = self.features_tree.selection()
        if not selection:
            messagebox.showwarning("Warning", "No feature selected")
            return
        
        feature_name = self.features_tree.item(selection[0], "values")[0]
        result = messagebox.askyesno("Confirm", f"Disable feature: {feature_name}?")
        
        if result:
            messagebox.showinfo("Feature Disable", f"Feature '{feature_name}' would be disabled\n(Not implemented)")
    
    def _read_feature_status(self) -> None:
        """Read current feature status."""
        if not self._check_connection():
            return
        
        messagebox.showinfo("Feature Status", "Feature status reading not implemented yet\n(Requires vehicle-specific protocols)")
    
    def _on_feature_double_click(self, event) -> None:
        """Handle double-click on feature."""
        selection = self.features_tree.selection()
        if selection:
            feature_name = self.features_tree.item(selection[0], "values")[0]
            messagebox.showinfo("Feature Details", f"Feature: {feature_name}\n\nDouble-click functionality not implemented yet")
    
    # Programming Operations Methods (Placeholders)
    def _read_flash(self) -> None:
        """Read flash memory."""
        if not self._check_connection():
            return
        
        result = messagebox.askyesno("Confirm", "Read flash memory?\nThis operation may take several minutes.")
        if result:
            self._log_programming_message("Flash read operation not implemented")
            messagebox.showinfo("Flash Read", "Flash read operation not implemented yet")
    
    def _write_flash(self) -> None:
        """Write flash memory."""
        if not self._check_connection():
            return
        
        result = messagebox.askyesno("Confirm", "⚠️  Write flash memory?\nThis can permanently modify ECU firmware!")
        if result:
            self._log_programming_message("Flash write operation not implemented")
            messagebox.showinfo("Flash Write", "Flash write operation not implemented yet")
    
    def _verify_flash(self) -> None:
        """Verify flash memory."""
        if not self._check_connection():
            return
        
        self._log_programming_message("Flash verify operation not implemented")
        messagebox.showinfo("Flash Verify", "Flash verify operation not implemented yet")
    
    def _erase_flash(self) -> None:
        """Erase flash memory."""
        if not self._check_connection():
            return
        
        result = messagebox.askyesno("Confirm", "⚠️  Erase flash memory?\nThis will permanently delete ECU firmware!")
        if result:
            self._log_programming_message("Flash erase operation not implemented")
            messagebox.showinfo("Flash Erase", "Flash erase operation not implemented yet")
    
    def _read_calibration(self) -> None:
        """Read calibration data."""
        if not self._check_connection():
            return
        
        self._log_programming_message("Calibration read operation not implemented")
        messagebox.showinfo("Calibration Read", "Calibration read operation not implemented yet")
    
    def _write_calibration(self) -> None:
        """Write calibration data."""
        if not self._check_connection():
            return
        
        result = messagebox.askyesno("Confirm", "⚠️  Write calibration data?\nThis can modify engine parameters!")
        if result:
            self._log_programming_message("Calibration write operation not implemented")
            messagebox.showinfo("Calibration Write", "Calibration write operation not implemented yet")
    
    def _backup_calibration(self) -> None:
        """Backup calibration data."""
        if not self._check_connection():
            return
        
        self._log_programming_message("Calibration backup operation not implemented")
        messagebox.showinfo("Calibration Backup", "Calibration backup operation not implemented yet")
    
    def _restore_calibration(self) -> None:
        """Restore calibration data."""
        if not self._check_connection():
            return
        
        result = messagebox.askyesno("Confirm", "Restore calibration data from backup?")
        if result:
            self._log_programming_message("Calibration restore operation not implemented")
            messagebox.showinfo("Calibration Restore", "Calibration restore operation not implemented yet")
    
    # Advanced Functions Methods (Placeholders)
    def _request_seed(self) -> None:
        """Request security seed."""
        if not self._check_connection():
            return
        
        level = self.security_level_var.get()
        self._log_programming_message(f"Security seed request for level {level} not implemented")
        messagebox.showinfo("Security Access", f"Security seed request for level {level} not implemented yet")
    
    def _send_key(self) -> None:
        """Send security key."""
        if not self._check_connection():
            return
        
        self._log_programming_message("Security key send not implemented")
        messagebox.showinfo("Security Access", "Security key send not implemented yet")
    
    def _enable_communications(self) -> None:
        """Enable communications."""
        if not self._check_connection():
            return
        
        self._log_programming_message("Enable communications not implemented")
        messagebox.showinfo("Communication Control", "Enable communications not implemented yet")
    
    def _disable_communications(self) -> None:
        """Disable communications."""
        if not self._check_connection():
            return
        
        self._log_programming_message("Disable communications not implemented")
        messagebox.showinfo("Communication Control", "Disable communications not implemented yet")
    
    def _reset_ecu(self) -> None:
        """Reset ECU."""
        if not self._check_connection():
            return
        
        result = messagebox.askyesno("Confirm", "Reset ECU?\nThis will restart the ECU.")
        if result:
            self._log_programming_message("ECU reset not implemented")
            messagebox.showinfo("ECU Reset", "ECU reset not implemented yet")
    
    def _read_memory(self) -> None:
        """Read memory."""
        if not self._check_connection():
            return
        
        address = self.address_var.get()
        length = self.length_var.get()
        
        if not address or not length:
            messagebox.showwarning("Warning", "Please specify address and length")
            return
        
        self._log_programming_message(f"Memory read from {address}, length {length} not implemented")
        messagebox.showinfo("Memory Access", "Memory read not implemented yet")
    
    def _write_memory(self) -> None:
        """Write memory."""
        if not self._check_connection():
            return
        
        address = self.address_var.get()
        
        if not address:
            messagebox.showwarning("Warning", "Please specify address")
            return
        
        result = messagebox.askyesno("Confirm", f"⚠️  Write to memory address {address}?\nThis can modify ECU operation!")
        if result:
            self._log_programming_message(f"Memory write to {address} not implemented")
            messagebox.showinfo("Memory Access", "Memory write not implemented yet")