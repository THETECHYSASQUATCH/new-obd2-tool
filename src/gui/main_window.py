"""
Main GUI window for the OBD-II Diagnostics and Programming Tool
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import logging
import threading
from typing import Dict, Any, Optional

from ..core.obd_manager import OBDManager
from ..hardware.adapter_manager import AdapterManager
from .connection_dialog import ConnectionDialog
from .diagnostics_panel import DiagnosticsPanel
from .programming_panel import ProgrammingPanel

logger = logging.getLogger(__name__)


class OBD2ToolGUI:
    """Main GUI application for the OBD-II Tool"""
    
    def __init__(self, config):
        """
        Initialize GUI application.
        
        Args:
            config: Configuration object
        """
        self.config = config
        self.root = None
        self.notebook = None
        self.status_var = None
        self.connection_status_var = None
        
        # Core components
        self.adapter_manager = None
        self.obd_manager = None
        
        # GUI panels
        self.connection_dialog = None
        self.diagnostics_panel = None
        self.programming_panel = None
        
        # Status tracking
        self.connected = False
        self.monitoring_active = False
        
        self._setup_gui()
        self._setup_logging_handler()
    
    def _setup_gui(self) -> None:
        """Setup the main GUI window and components."""
        # Create main window
        self.root = tk.Tk()
        self.root.title("OBD-II Diagnostics and Programming Tool")
        
        # Configure window
        gui_config = self.config.get_gui_config()
        self.root.geometry(f"{gui_config['window_width']}x{gui_config['window_height']}")
        self.root.minsize(800, 600)
        
        # Create menu bar
        self._create_menu_bar()
        
        # Create toolbar
        self._create_toolbar()
        
        # Create main notebook (tabbed interface)
        self._create_notebook()
        
        # Create status bar
        self._create_status_bar()
        
        # Initialize core components
        self._initialize_core_components()
        
        # Bind window close event
        self.root.protocol("WM_DELETE_WINDOW", self._on_closing)
    
    def _create_menu_bar(self) -> None:
        """Create the main menu bar."""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Connect...", command=self.show_connection_dialog)
        file_menu.add_command(label="Disconnect", command=self.disconnect)
        file_menu.add_separator()
        file_menu.add_command(label="Export DTCs...", command=self.export_dtcs)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self._on_closing)
        
        # Tools menu
        tools_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="Scan Ports", command=self.scan_ports)
        tools_menu.add_command(label="Test Connection", command=self.test_connection)
        tools_menu.add_separator()
        tools_menu.add_command(label="Settings...", command=self.show_settings)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About...", command=self.show_about)
        help_menu.add_command(label="User Guide", command=self.show_user_guide)
    
    def _create_toolbar(self) -> None:
        """Create the toolbar."""
        toolbar = ttk.Frame(self.root)
        toolbar.pack(side=tk.TOP, fill=tk.X, padx=5, pady=2)
        
        # Connection buttons
        ttk.Button(toolbar, text="Connect", command=self.show_connection_dialog).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Disconnect", command=self.disconnect).pack(side=tk.LEFT, padx=2)
        
        # Separator
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=5)
        
        # Diagnostic buttons
        ttk.Button(toolbar, text="Read DTCs", command=self.read_dtcs).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Clear DTCs", command=self.clear_dtcs).pack(side=tk.LEFT, padx=2)
        
        # Separator
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=5)
        
        # Monitoring buttons
        ttk.Button(toolbar, text="Start Monitor", command=self.start_monitoring).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Stop Monitor", command=self.stop_monitoring).pack(side=tk.LEFT, padx=2)
    
    def _create_notebook(self) -> None:
        """Create the main tabbed interface."""
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Live Data tab
        self._create_live_data_tab()
        
        # Diagnostics tab
        self._create_diagnostics_tab()
        
        # Programming tab (placeholder for now)
        self._create_programming_tab()
        
        # Vehicle Info tab
        self._create_vehicle_info_tab()
        
        # Log tab
        self._create_log_tab()
    
    def _create_live_data_tab(self) -> None:
        """Create the live data monitoring tab."""
        live_frame = ttk.Frame(self.notebook)
        self.notebook.add(live_frame, text="Live Data")
        
        # Parameter selection frame
        param_frame = ttk.LabelFrame(live_frame, text="Parameters to Monitor")
        param_frame.pack(fill=tk.X, padx=5, pady=5)
        
        # Create checkboxes for common parameters
        self.param_vars = {}
        common_params = [
            (0x0C, "Engine RPM"),
            (0x0D, "Vehicle Speed"),
            (0x05, "Coolant Temperature"),
            (0x04, "Engine Load"),
            (0x11, "Throttle Position"),
            (0x0B, "Intake Pressure"),
            (0x0F, "Intake Air Temperature"),
            (0x10, "MAF Rate"),
        ]
        
        for i, (pid, name) in enumerate(common_params):
            var = tk.BooleanVar()
            self.param_vars[pid] = var
            cb = ttk.Checkbutton(param_frame, text=name, variable=var)
            cb.grid(row=i//4, column=i%4, sticky=tk.W, padx=5, pady=2)
        
        # Data display frame
        data_frame = ttk.LabelFrame(live_frame, text="Live Data")
        data_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Create treeview for data display
        columns = ("Parameter", "Value", "Unit", "Last Update")
        self.data_tree = ttk.Treeview(data_frame, columns=columns, show="headings")
        
        for col in columns:
            self.data_tree.heading(col, text=col)
            self.data_tree.column(col, width=150)
        
        # Add scrollbar
        scrollbar = ttk.Scrollbar(data_frame, orient=tk.VERTICAL, command=self.data_tree.yview)
        self.data_tree.configure(yscrollcommand=scrollbar.set)
        
        self.data_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def _create_diagnostics_tab(self) -> None:
        """Create the diagnostics tab."""
        diag_frame = ttk.Frame(self.notebook)
        self.notebook.add(diag_frame, text="Diagnostics")
        
        # Create diagnostics panel
        self.diagnostics_panel = DiagnosticsPanel(diag_frame, self)
    
    def _create_programming_tab(self) -> None:
        """Create the programming tab."""
        prog_frame = ttk.Frame(self.notebook)
        self.notebook.add(prog_frame, text="Programming")
        
        # Create programming panel
        self.programming_panel = ProgrammingPanel(prog_frame, self)
    
    def _create_vehicle_info_tab(self) -> None:
        """Create the vehicle information tab."""
        info_frame = ttk.Frame(self.notebook)
        self.notebook.add(info_frame, text="Vehicle Info")
        
        # Vehicle info display
        info_text = scrolledtext.ScrolledText(info_frame, wrap=tk.WORD, height=20)
        info_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.vehicle_info_text = info_text
    
    def _create_log_tab(self) -> None:
        """Create the log display tab."""
        log_frame = ttk.Frame(self.notebook)
        self.notebook.add(log_frame, text="Log")
        
        # Log display
        log_text = scrolledtext.ScrolledText(log_frame, wrap=tk.WORD, height=20, state=tk.DISABLED)
        log_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.log_text = log_text
    
    def _create_status_bar(self) -> None:
        """Create the status bar."""
        status_frame = ttk.Frame(self.root)
        status_frame.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Status text
        self.status_var = tk.StringVar()
        self.status_var.set("Ready")
        ttk.Label(status_frame, textvariable=self.status_var).pack(side=tk.LEFT, padx=5)
        
        # Connection status
        self.connection_status_var = tk.StringVar()
        self.connection_status_var.set("Disconnected")
        ttk.Label(status_frame, textvariable=self.connection_status_var).pack(side=tk.RIGHT, padx=5)
    
    def _initialize_core_components(self) -> None:
        """Initialize core OBD components."""
        # Initialize adapter manager
        connection_config = self.config.get_connection_config()
        self.adapter_manager = AdapterManager(connection_config)
        
        # Initialize OBD manager
        self.obd_manager = OBDManager(self.adapter_manager)
    
    def _setup_logging_handler(self) -> None:
        """Setup logging handler to display logs in GUI."""
        class GUILogHandler(logging.Handler):
            def __init__(self, text_widget):
                super().__init__()
                self.text_widget = text_widget
            
            def emit(self, record):
                try:
                    msg = self.format(record)
                    self.text_widget.config(state=tk.NORMAL)
                    self.text_widget.insert(tk.END, msg + '\n')
                    self.text_widget.see(tk.END)
                    self.text_widget.config(state=tk.DISABLED)
                except Exception:
                    pass
        
        # Add GUI log handler
        gui_handler = GUILogHandler(self.log_text)
        gui_handler.setLevel(logging.INFO)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        gui_handler.setFormatter(formatter)
        logging.getLogger().addHandler(gui_handler)
    
    def run(self) -> None:
        """Run the GUI application."""
        try:
            self.root.mainloop()
        except Exception as e:
            logger.error(f"Error running GUI: {e}")
            messagebox.showerror("Error", f"Fatal error: {e}")
    
    def show_connection_dialog(self) -> None:
        """Show connection configuration dialog."""
        if not self.connection_dialog:
            self.connection_dialog = ConnectionDialog(self.root, self)
        
        self.connection_dialog.show()
    
    def connect(self, connection_params: Dict[str, Any]) -> bool:
        """
        Connect to OBD-II adapter.
        
        Args:
            connection_params: Connection parameters
            
        Returns:
            True if connection successful
        """
        try:
            self.status_var.set("Connecting...")
            self.root.update()
            
            # Connect adapter
            if not self.adapter_manager.connect(**connection_params):
                self.status_var.set("Connection failed")
                return False
            
            # Connect OBD manager
            if not self.obd_manager.connect():
                self.adapter_manager.disconnect()
                self.status_var.set("OBD connection failed")
                return False
            
            self.connected = True
            self.status_var.set("Connected")
            self.connection_status_var.set("Connected")
            
            # Update vehicle info
            self._update_vehicle_info()
            
            logger.info("Successfully connected to vehicle")
            return True
            
        except Exception as e:
            logger.error(f"Error connecting: {e}")
            self.status_var.set("Connection error")
            return False
    
    def disconnect(self) -> None:
        """Disconnect from OBD-II adapter."""
        try:
            self.stop_monitoring()
            
            if self.obd_manager:
                self.obd_manager.disconnect()
            
            if self.adapter_manager:
                self.adapter_manager.disconnect()
            
            self.connected = False
            self.status_var.set("Disconnected")
            self.connection_status_var.set("Disconnected")
            
            # Clear displays
            self._clear_displays()
            
            logger.info("Disconnected from vehicle")
            
        except Exception as e:
            logger.error(f"Error disconnecting: {e}")
    
    def read_dtcs(self) -> None:
        """Read diagnostic trouble codes."""
        if not self.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            self.status_var.set("Reading DTCs...")
            self.root.update()
            
            dtcs = self.obd_manager.get_dtc_manager().read_current_dtcs()
            
            if self.diagnostics_panel:
                self.diagnostics_panel.update_dtcs(dtcs)
            
            self.status_var.set(f"Read {len(dtcs)} DTCs")
            
        except Exception as e:
            logger.error(f"Error reading DTCs: {e}")
            messagebox.showerror("Error", f"Failed to read DTCs: {e}")
            self.status_var.set("Error reading DTCs")
    
    def clear_dtcs(self) -> None:
        """Clear diagnostic trouble codes."""
        if not self.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        result = messagebox.askyesno("Confirm", "Clear all diagnostic trouble codes?")
        if not result:
            return
        
        try:
            self.status_var.set("Clearing DTCs...")
            self.root.update()
            
            success = self.obd_manager.get_dtc_manager().clear_dtcs()
            
            if success:
                self.status_var.set("DTCs cleared")
                messagebox.showinfo("Success", "DTCs cleared successfully")
                
                # Refresh DTC display
                if self.diagnostics_panel:
                    self.diagnostics_panel.update_dtcs([])
            else:
                self.status_var.set("Failed to clear DTCs")
                messagebox.showerror("Error", "Failed to clear DTCs")
                
        except Exception as e:
            logger.error(f"Error clearing DTCs: {e}")
            messagebox.showerror("Error", f"Failed to clear DTCs: {e}")
            self.status_var.set("Error clearing DTCs")
    
    def start_monitoring(self) -> None:
        """Start live data monitoring."""
        if not self.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        if self.monitoring_active:
            return
        
        # Get selected parameters
        selected_pids = [pid for pid, var in self.param_vars.items() if var.get()]
        
        if not selected_pids:
            messagebox.showwarning("Warning", "No parameters selected for monitoring")
            return
        
        try:
            self.monitoring_active = True
            self.status_var.set("Monitoring started")
            
            # Start monitoring in separate thread
            def monitoring_callback(data):
                self.root.after(0, lambda: self._update_live_data(data))
            
            self.obd_manager.start_monitoring(selected_pids, monitoring_callback, interval=1.0)
            
        except Exception as e:
            logger.error(f"Error starting monitoring: {e}")
            messagebox.showerror("Error", f"Failed to start monitoring: {e}")
            self.monitoring_active = False
    
    def stop_monitoring(self) -> None:
        """Stop live data monitoring."""
        if not self.monitoring_active:
            return
        
        try:
            self.obd_manager.stop_monitoring()
            self.monitoring_active = False
            self.status_var.set("Monitoring stopped")
            
        except Exception as e:
            logger.error(f"Error stopping monitoring: {e}")
    
    def _update_live_data(self, data: Dict[int, Any]) -> None:
        """Update live data display."""
        from datetime import datetime
        
        for pid, value in data.items():
            if pid in self.obd_manager.STANDARD_PIDS:
                param = self.obd_manager.STANDARD_PIDS[pid]
                
                # Find existing item or create new one
                item_id = None
                for item in self.data_tree.get_children():
                    if self.data_tree.set(item, "Parameter") == param.name:
                        item_id = item
                        break
                
                if item_id:
                    # Update existing item
                    self.data_tree.set(item_id, "Value", f"{value:.2f}" if isinstance(value, float) else str(value))
                    self.data_tree.set(item_id, "Last Update", datetime.now().strftime("%H:%M:%S"))
                else:
                    # Create new item
                    self.data_tree.insert("", "end", values=(
                        param.name,
                        f"{value:.2f}" if isinstance(value, float) else str(value),
                        param.unit,
                        datetime.now().strftime("%H:%M:%S")
                    ))
    
    def _update_vehicle_info(self) -> None:
        """Update vehicle information display."""
        try:
            info = self.obd_manager.get_vehicle_info()
            adapter_info = self.adapter_manager.get_adapter_info()
            
            info_text = "Vehicle Information:\n"
            info_text += "=" * 50 + "\n\n"
            
            for key, value in info.items():
                info_text += f"{key.replace('_', ' ').title()}: {value}\n"
            
            info_text += "\nAdapter Information:\n"
            info_text += "=" * 50 + "\n\n"
            
            for key, value in adapter_info.items():
                if isinstance(value, dict):
                    info_text += f"{key.replace('_', ' ').title()}:\n"
                    for sub_key, sub_value in value.items():
                        info_text += f"  {sub_key.replace('_', ' ').title()}: {sub_value}\n"
                else:
                    info_text += f"{key.replace('_', ' ').title()}: {value}\n"
            
            self.vehicle_info_text.delete(1.0, tk.END)
            self.vehicle_info_text.insert(1.0, info_text)
            
        except Exception as e:
            logger.error(f"Error updating vehicle info: {e}")
    
    def _clear_displays(self) -> None:
        """Clear all data displays."""
        # Clear live data
        for item in self.data_tree.get_children():
            self.data_tree.delete(item)
        
        # Clear vehicle info
        self.vehicle_info_text.delete(1.0, tk.END)
        
        # Clear diagnostics panel
        if self.diagnostics_panel:
            self.diagnostics_panel.clear()
    
    def scan_ports(self) -> None:
        """Scan for available ports."""
        try:
            ports = self.adapter_manager.scan_ports()
            
            if ports:
                port_info = "Available Ports:\n"
                port_info += "=" * 30 + "\n\n"
                
                for port in ports:
                    port_info += f"Port: {port['device']}\n"
                    port_info += f"Description: {port['description']}\n"
                    port_info += f"Manufacturer: {port['manufacturer']}\n\n"
                
                messagebox.showinfo("Port Scan Results", port_info)
            else:
                messagebox.showinfo("Port Scan Results", "No serial ports found")
                
        except Exception as e:
            logger.error(f"Error scanning ports: {e}")
            messagebox.showerror("Error", f"Failed to scan ports: {e}")
    
    def test_connection(self) -> None:
        """Test connection to vehicle."""
        if not self.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            success = self.adapter_manager.test_communication()
            
            if success:
                messagebox.showinfo("Connection Test", "Communication test successful")
            else:
                messagebox.showwarning("Connection Test", "Communication test failed")
                
        except Exception as e:
            logger.error(f"Error testing connection: {e}")
            messagebox.showerror("Error", f"Connection test error: {e}")
    
    def export_dtcs(self) -> None:
        """Export DTCs to file."""
        if not self.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            from tkinter import filedialog
            
            filename = filedialog.asksaveasfilename(
                defaultextension=".json",
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
            )
            
            if filename:
                success = self.obd_manager.get_dtc_manager().export_dtcs(filename)
                
                if success:
                    messagebox.showinfo("Export", f"DTCs exported to {filename}")
                else:
                    messagebox.showerror("Export", "Failed to export DTCs")
                    
        except Exception as e:
            logger.error(f"Error exporting DTCs: {e}")
            messagebox.showerror("Error", f"Failed to export DTCs: {e}")
    
    def show_settings(self) -> None:
        """Show settings dialog."""
        messagebox.showinfo("Settings", "Settings dialog not implemented yet")
    
    def show_about(self) -> None:
        """Show about dialog."""
        about_text = """OBD-II Diagnostics and Programming Tool
Version 0.1.0

A comprehensive tool for OBD-II vehicle diagnostics 
and programming operations.

Copyright (c) 2025 THETECHYSASQUATCH
Licensed under MIT License"""
        
        messagebox.showinfo("About", about_text)
    
    def show_user_guide(self) -> None:
        """Show user guide."""
        messagebox.showinfo("User Guide", "User guide not implemented yet")
    
    def _on_closing(self) -> None:
        """Handle window closing event."""
        try:
            self.disconnect()
            self.root.destroy()
        except Exception as e:
            logger.error(f"Error during shutdown: {e}")
            self.root.destroy()