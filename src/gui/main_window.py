"""
Main GUI Window for OBD-II Diagnostics Tool
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import threading
import logging
from typing import Optional, Dict, Any

from ..core.obd_interface import OBDInterface
from ..core.protocols import ProtocolManager
from ..diagnostics.error_codes import DTCManager
from ..diagnostics.live_data import LiveDataMonitor
from ..ecu.programming import ECUProgrammer
from ..procedures.relearn import RelearnManager

class MainWindow:
    """Main application window"""
    
    def __init__(self):
        """Initialize main window"""
        self.root = tk.Tk()
        self.root.title("OBD-II Diagnostics and Programming Tool")
        self.root.geometry("1200x800")
        
        # Initialize logging
        self.setup_logging()
        self.logger = logging.getLogger(__name__)
        
        # Initialize core components
        self.obd_interface = OBDInterface()
        self.protocol_manager = ProtocolManager(self.obd_interface)
        self.dtc_manager = DTCManager(self.obd_interface)
        self.live_data_monitor = LiveDataMonitor(self.obd_interface)
        self.ecu_programmer = ECUProgrammer(self.obd_interface, self.protocol_manager)
        self.relearn_manager = RelearnManager(self.obd_interface, self.ecu_programmer)
        
        # Connection status
        self.is_connected = False
        self.connection_thread = None
        
        # Create GUI
        self.create_menu()
        self.create_main_interface()
        self.create_status_bar()
        
        # Setup update timer
        self.root.after(1000, self.update_status)
    
    def setup_logging(self):
        """Setup logging configuration"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
    
    def create_menu(self):
        """Create application menu"""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Connect", command=self.connect_dialog)
        file_menu.add_command(label="Disconnect", command=self.disconnect)
        file_menu.add_separator()
        file_menu.add_command(label="Export Report", command=self.export_report)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # Tools menu
        tools_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="Scan for ECUs", command=self.scan_ecus)
        tools_menu.add_command(label="Protocol Detection", command=self.detect_protocol)
        tools_menu.add_command(label="Clear All DTCs", command=self.clear_all_dtcs)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)
        help_menu.add_command(label="Help", command=self.show_help)
    
    def create_main_interface(self):
        """Create main interface with tabs"""
        # Create notebook for tabs
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Connection tab
        self.create_connection_tab()
        
        # Diagnostics tab
        self.create_diagnostics_tab()
        
        # Live Data tab
        self.create_live_data_tab()
        
        # ECU Programming tab
        self.create_programming_tab()
        
        # Relearn Procedures tab
        self.create_relearn_tab()
    
    def create_connection_tab(self):
        """Create connection and vehicle info tab"""
        conn_frame = ttk.Frame(self.notebook)
        self.notebook.add(conn_frame, text="Connection")
        
        # Connection section
        conn_section = ttk.LabelFrame(conn_frame, text="Connection Settings")
        conn_section.pack(fill=tk.X, padx=5, pady=5)
        
        # Port selection
        tk.Label(conn_section, text="Port:").grid(row=0, column=0, sticky=tk.W, padx=5, pady=5)
        self.port_var = tk.StringVar()
        self.port_combo = ttk.Combobox(conn_section, textvariable=self.port_var, width=20)
        self.port_combo.grid(row=0, column=1, padx=5, pady=5)
        self.refresh_ports()
        
        # Baudrate selection
        tk.Label(conn_section, text="Baudrate:").grid(row=0, column=2, sticky=tk.W, padx=5, pady=5)
        self.baudrate_var = tk.StringVar(value="38400")
        baudrate_combo = ttk.Combobox(conn_section, textvariable=self.baudrate_var, width=10)
        baudrate_combo['values'] = ("9600", "38400", "115200")
        baudrate_combo.grid(row=0, column=3, padx=5, pady=5)
        
        # Buttons
        button_frame = tk.Frame(conn_section)
        button_frame.grid(row=1, column=0, columnspan=4, pady=10)
        
        self.connect_btn = tk.Button(button_frame, text="Connect", command=self.connect)
        self.connect_btn.pack(side=tk.LEFT, padx=5)
        
        self.disconnect_btn = tk.Button(button_frame, text="Disconnect", command=self.disconnect, state=tk.DISABLED)
        self.disconnect_btn.pack(side=tk.LEFT, padx=5)
        
        tk.Button(button_frame, text="Refresh Ports", command=self.refresh_ports).pack(side=tk.LEFT, padx=5)
        
        # Vehicle info section
        info_section = ttk.LabelFrame(conn_frame, text="Vehicle Information")
        info_section.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Create text widget for vehicle info
        self.vehicle_info_text = tk.Text(info_section, height=15, width=60)
        info_scrollbar = tk.Scrollbar(info_section, orient=tk.VERTICAL, command=self.vehicle_info_text.yview)
        self.vehicle_info_text.configure(yscrollcommand=info_scrollbar.set)
        
        self.vehicle_info_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        info_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_diagnostics_tab(self):
        """Create diagnostics tab"""
        diag_frame = ttk.Frame(self.notebook)
        self.notebook.add(diag_frame, text="Diagnostics")
        
        # DTC section
        dtc_section = ttk.LabelFrame(diag_frame, text="Diagnostic Trouble Codes")
        dtc_section.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # DTC buttons
        dtc_button_frame = tk.Frame(dtc_section)
        dtc_button_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Button(dtc_button_frame, text="Read DTCs", command=self.read_dtcs).pack(side=tk.LEFT, padx=5)
        tk.Button(dtc_button_frame, text="Clear DTCs", command=self.clear_dtcs).pack(side=tk.LEFT, padx=5)
        tk.Button(dtc_button_frame, text="Read Pending", command=self.read_pending_dtcs).pack(side=tk.LEFT, padx=5)
        
        # DTC tree view
        self.dtc_tree = ttk.Treeview(dtc_section, columns=("Code", "Description", "Severity", "System"), show="headings")
        self.dtc_tree.heading("Code", text="Code")
        self.dtc_tree.heading("Description", text="Description")
        self.dtc_tree.heading("Severity", text="Severity")
        self.dtc_tree.heading("System", text="System")
        
        dtc_scrollbar = tk.Scrollbar(dtc_section, orient=tk.VERTICAL, command=self.dtc_tree.yview)
        self.dtc_tree.configure(yscrollcommand=dtc_scrollbar.set)
        
        self.dtc_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        dtc_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Bind double-click event
        self.dtc_tree.bind("<Double-1>", self.show_dtc_details)
    
    def create_live_data_tab(self):
        """Create live data monitoring tab"""
        live_frame = ttk.Frame(self.notebook)
        self.notebook.add(live_frame, text="Live Data")
        
        # Control section
        control_section = ttk.LabelFrame(live_frame, text="Monitoring Controls")
        control_section.pack(fill=tk.X, padx=5, pady=5)
        
        # Control buttons
        control_button_frame = tk.Frame(control_section)
        control_button_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.start_monitor_btn = tk.Button(control_button_frame, text="Start Monitoring", command=self.start_monitoring)
        self.start_monitor_btn.pack(side=tk.LEFT, padx=5)
        
        self.stop_monitor_btn = tk.Button(control_button_frame, text="Stop Monitoring", command=self.stop_monitoring, state=tk.DISABLED)
        self.stop_monitor_btn.pack(side=tk.LEFT, padx=5)
        
        tk.Button(control_button_frame, text="Add PID", command=self.add_pid_dialog).pack(side=tk.LEFT, padx=5)
        tk.Button(control_button_frame, text="Export Data", command=self.export_live_data).pack(side=tk.LEFT, padx=5)
        
        # Refresh rate
        tk.Label(control_button_frame, text="Refresh Rate (s):").pack(side=tk.LEFT, padx=(20, 5))
        self.refresh_rate_var = tk.StringVar(value="1.0")
        refresh_entry = tk.Entry(control_button_frame, textvariable=self.refresh_rate_var, width=5)
        refresh_entry.pack(side=tk.LEFT, padx=5)
        
        # Live data display
        data_section = ttk.LabelFrame(live_frame, text="Live Data")
        data_section.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Data tree view
        self.live_data_tree = ttk.Treeview(data_section, columns=("PID", "Name", "Value", "Unit", "Timestamp"), show="headings")
        self.live_data_tree.heading("PID", text="PID")
        self.live_data_tree.heading("Name", text="Parameter")
        self.live_data_tree.heading("Value", text="Value")
        self.live_data_tree.heading("Unit", text="Unit")
        self.live_data_tree.heading("Timestamp", text="Timestamp")
        
        live_data_scrollbar = tk.Scrollbar(data_section, orient=tk.VERTICAL, command=self.live_data_tree.yview)
        self.live_data_tree.configure(yscrollcommand=live_data_scrollbar.set)
        
        self.live_data_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        live_data_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_programming_tab(self):
        """Create ECU programming tab"""
        prog_frame = ttk.Frame(self.notebook)
        self.notebook.add(prog_frame, text="ECU Programming")
        
        # ECU selection section
        ecu_section = ttk.LabelFrame(prog_frame, text="ECU Selection")
        ecu_section.pack(fill=tk.X, padx=5, pady=5)
        
        # ECU controls
        ecu_control_frame = tk.Frame(ecu_section)
        ecu_control_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Button(ecu_control_frame, text="Scan ECUs", command=self.scan_ecus).pack(side=tk.LEFT, padx=5)
        
        tk.Label(ecu_control_frame, text="Select ECU:").pack(side=tk.LEFT, padx=(20, 5))
        self.ecu_var = tk.StringVar()
        self.ecu_combo = ttk.Combobox(ecu_control_frame, textvariable=self.ecu_var, width=20)
        self.ecu_combo.pack(side=tk.LEFT, padx=5)
        
        # Programming operations
        ops_section = ttk.LabelFrame(prog_frame, text="Programming Operations")
        ops_section.pack(fill=tk.X, padx=5, pady=5)
        
        ops_frame = tk.Frame(ops_section)
        ops_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Button(ops_frame, text="Enter Programming Mode", command=self.enter_programming_mode).pack(side=tk.LEFT, padx=5)
        tk.Button(ops_frame, text="Exit Programming Mode", command=self.exit_programming_mode).pack(side=tk.LEFT, padx=5)
        tk.Button(ops_frame, text="Backup Firmware", command=self.backup_firmware).pack(side=tk.LEFT, padx=5)
        tk.Button(ops_frame, text="Flash Firmware", command=self.flash_firmware).pack(side=tk.LEFT, padx=5)
        
        # Programming status
        status_section = ttk.LabelFrame(prog_frame, text="Programming Status")
        status_section.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.programming_status_text = tk.Text(status_section, height=15)
        prog_scrollbar = tk.Scrollbar(status_section, orient=tk.VERTICAL, command=self.programming_status_text.yview)
        self.programming_status_text.configure(yscrollcommand=prog_scrollbar.set)
        
        self.programming_status_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        prog_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_relearn_tab(self):
        """Create relearn procedures tab"""
        relearn_frame = ttk.Frame(self.notebook)
        self.notebook.add(relearn_frame, text="Relearn Procedures")
        
        # Procedure selection
        selection_section = ttk.LabelFrame(relearn_frame, text="Select Procedure")
        selection_section.pack(fill=tk.X, padx=5, pady=5)
        
        selection_frame = tk.Frame(selection_section)
        selection_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Label(selection_frame, text="Procedure:").pack(side=tk.LEFT, padx=5)
        self.procedure_var = tk.StringVar()
        self.procedure_combo = ttk.Combobox(selection_frame, textvariable=self.procedure_var, width=30)
        self.procedure_combo['values'] = self.relearn_manager.get_available_procedures()
        self.procedure_combo.pack(side=tk.LEFT, padx=5)
        self.procedure_combo.bind("<<ComboboxSelected>>", self.on_procedure_selected)
        
        tk.Button(selection_frame, text="Check Preconditions", command=self.check_preconditions).pack(side=tk.LEFT, padx=5)
        
        # Procedure controls
        control_section = ttk.LabelFrame(relearn_frame, text="Procedure Control")
        control_section.pack(fill=tk.X, padx=5, pady=5)
        
        control_frame = tk.Frame(control_section)
        control_frame.pack(fill=tk.X, padx=5, pady=5)
        
        self.start_procedure_btn = tk.Button(control_frame, text="Start Procedure", command=self.start_procedure)
        self.start_procedure_btn.pack(side=tk.LEFT, padx=5)
        
        self.next_step_btn = tk.Button(control_frame, text="Next Step", command=self.next_step, state=tk.DISABLED)
        self.next_step_btn.pack(side=tk.LEFT, padx=5)
        
        self.cancel_procedure_btn = tk.Button(control_frame, text="Cancel", command=self.cancel_procedure, state=tk.DISABLED)
        self.cancel_procedure_btn.pack(side=tk.LEFT, padx=5)
        
        # Progress bar
        self.procedure_progress = ttk.Progressbar(control_section, mode='determinate')
        self.procedure_progress.pack(fill=tk.X, padx=5, pady=5)
        
        # Procedure status
        status_section = ttk.LabelFrame(relearn_frame, text="Procedure Status")
        status_section.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.procedure_status_text = tk.Text(status_section, height=10)
        proc_scrollbar = tk.Scrollbar(status_section, orient=tk.VERTICAL, command=self.procedure_status_text.yview)
        self.procedure_status_text.configure(yscrollcommand=proc_scrollbar.set)
        
        self.procedure_status_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        proc_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_status_bar(self):
        """Create status bar"""
        self.status_frame = tk.Frame(self.root, relief=tk.SUNKEN, bd=1)
        self.status_frame.pack(side=tk.BOTTOM, fill=tk.X)
        
        self.status_label = tk.Label(self.status_frame, text="Ready", anchor=tk.W)
        self.status_label.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        self.connection_label = tk.Label(self.status_frame, text="Disconnected", anchor=tk.E)
        self.connection_label.pack(side=tk.RIGHT)
    
    def refresh_ports(self):
        """Refresh available serial ports"""
        try:
            import serial.tools.list_ports
            ports = [port.device for port in serial.tools.list_ports.comports()]
            self.port_combo['values'] = ports
            if ports:
                self.port_combo.set(ports[0])
        except ImportError:
            # Fallback for common port names
            common_ports = ["/dev/ttyUSB0", "/dev/ttyUSB1", "COM1", "COM2", "COM3", "COM4"]
            self.port_combo['values'] = common_ports
    
    def connect_dialog(self):
        """Show connection dialog"""
        if not self.port_var.get():
            messagebox.showerror("Error", "Please select a port first")
            return
        self.connect()
    
    def connect(self):
        """Connect to OBD adapter"""
        if self.is_connected:
            return
        
        port = self.port_var.get()
        baudrate = int(self.baudrate_var.get())
        
        if not port:
            messagebox.showerror("Error", "Please select a port")
            return
        
        self.status_label.config(text="Connecting...")
        self.connect_btn.config(state=tk.DISABLED)
        
        # Connect in separate thread
        self.connection_thread = threading.Thread(target=self._connect_worker, args=(port, baudrate))
        self.connection_thread.start()
    
    def _connect_worker(self, port: str, baudrate: int):
        """Worker function for connection"""
        try:
            if self.obd_interface.connect(port):
                self.is_connected = True
                self.root.after(0, self._connection_success)
            else:
                self.root.after(0, self._connection_failed)
        except Exception as e:
            self.logger.error(f"Connection error: {e}")
            self.root.after(0, self._connection_failed)
    
    def _connection_success(self):
        """Handle successful connection"""
        self.status_label.config(text="Connected successfully")
        self.connection_label.config(text="Connected")
        self.connect_btn.config(state=tk.DISABLED)
        self.disconnect_btn.config(state=tk.NORMAL)
        
        # Get vehicle information
        self.get_vehicle_info()
        
        # Detect protocol
        protocol = self.protocol_manager.detect_protocol()
        if protocol:
            self.status_label.config(text=f"Connected - Protocol: {self.protocol_manager.get_current_protocol_name()}")
    
    def _connection_failed(self):
        """Handle failed connection"""
        self.status_label.config(text="Connection failed")
        self.connection_label.config(text="Disconnected")
        self.connect_btn.config(state=tk.NORMAL)
        messagebox.showerror("Connection Error", "Failed to connect to OBD adapter")
    
    def disconnect(self):
        """Disconnect from OBD adapter"""
        if self.live_data_monitor.is_monitoring:
            self.stop_monitoring()
        
        if self.ecu_programmer.programming_session_active:
            self.exit_programming_mode()
        
        self.obd_interface.disconnect()
        self.is_connected = False
        
        self.status_label.config(text="Disconnected")
        self.connection_label.config(text="Disconnected")
        self.connect_btn.config(state=tk.NORMAL)
        self.disconnect_btn.config(state=tk.DISABLED)
        
        # Clear vehicle info
        self.vehicle_info_text.delete(1.0, tk.END)
    
    def get_vehicle_info(self):
        """Get and display vehicle information"""
        if not self.is_connected:
            return
        
        try:
            info = self.obd_interface.get_vehicle_info()
            
            self.vehicle_info_text.delete(1.0, tk.END)
            self.vehicle_info_text.insert(tk.END, "Vehicle Information:\n")
            self.vehicle_info_text.insert(tk.END, "=" * 50 + "\n\n")
            
            for key, value in info.items():
                self.vehicle_info_text.insert(tk.END, f"{key}: {value}\n")
            
            # Get supported PIDs
            if hasattr(self, 'live_data_monitor'):
                supported_pids = self.live_data_monitor.get_supported_pids()
                self.vehicle_info_text.insert(tk.END, f"\nSupported PIDs: {', '.join(supported_pids[:10])}...\n")
                self.vehicle_info_text.insert(tk.END, f"Total PIDs supported: {len(supported_pids)}\n")
            
        except Exception as e:
            self.logger.error(f"Error getting vehicle info: {e}")
    
    def read_dtcs(self):
        """Read diagnostic trouble codes"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        try:
            # Clear existing DTCs from tree
            for item in self.dtc_tree.get_children():
                self.dtc_tree.delete(item)
            
            # Read all types of DTCs
            dtc_results = self.dtc_manager.read_all_dtcs()
            all_dtcs = dtc_results["stored"] + dtc_results["pending"] + dtc_results["permanent"]
            
            if not all_dtcs:
                messagebox.showinfo("DTCs", "No diagnostic trouble codes found")
                return
            
            # Analyze DTCs
            analysis = self.dtc_manager.analyze_dtcs(all_dtcs)
            
            # Add to tree view
            for dtc_info in analysis:
                self.dtc_tree.insert("", tk.END, values=(
                    dtc_info["code"],
                    dtc_info["description"][:50] + "..." if len(dtc_info["description"]) > 50 else dtc_info["description"],
                    dtc_info["severity"],
                    dtc_info["system"]
                ))
            
            self.status_label.config(text=f"Found {len(all_dtcs)} DTCs")
            
        except Exception as e:
            self.logger.error(f"Error reading DTCs: {e}")
            messagebox.showerror("Error", f"Failed to read DTCs: {str(e)}")
    
    def clear_dtcs(self):
        """Clear diagnostic trouble codes"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        result = messagebox.askyesno("Clear DTCs", "Are you sure you want to clear all DTCs?")
        if result:
            try:
                if self.dtc_manager.clear_dtcs():
                    messagebox.showinfo("Success", "DTCs cleared successfully")
                    # Refresh DTC display
                    self.read_dtcs()
                else:
                    messagebox.showerror("Error", "Failed to clear DTCs")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to clear DTCs: {str(e)}")
    
    def read_pending_dtcs(self):
        """Read pending DTCs"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        try:
            pending_dtcs = self.dtc_manager._read_pending_dtcs()
            if pending_dtcs:
                messagebox.showinfo("Pending DTCs", f"Found {len(pending_dtcs)} pending DTCs:\n" + "\n".join(pending_dtcs))
            else:
                messagebox.showinfo("Pending DTCs", "No pending DTCs found")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to read pending DTCs: {str(e)}")
    
    def show_dtc_details(self, event):
        """Show detailed DTC information"""
        selection = self.dtc_tree.selection()
        if not selection:
            return
        
        item = self.dtc_tree.item(selection[0])
        dtc_code = item['values'][0]
        
        # Get detailed info
        dtc_info = self.dtc_manager.error_db.get_dtc_info(dtc_code)
        if not dtc_info:
            return
        
        # Create detail window
        detail_window = tk.Toplevel(self.root)
        detail_window.title(f"DTC Details - {dtc_code}")
        detail_window.geometry("600x500")
        
        # Create scrolled text
        detail_text = tk.Text(detail_window, wrap=tk.WORD)
        scrollbar = tk.Scrollbar(detail_window, orient=tk.VERTICAL, command=detail_text.yview)
        detail_text.configure(yscrollcommand=scrollbar.set)
        
        # Add content
        detail_text.insert(tk.END, f"Code: {dtc_info.code}\n")
        detail_text.insert(tk.END, f"Description: {dtc_info.description}\n\n")
        detail_text.insert(tk.END, f"System: {dtc_info.system}\n")
        detail_text.insert(tk.END, f"Severity: {dtc_info.severity}\n")
        detail_text.insert(tk.END, f"Category: {dtc_info.category}\n\n")
        
        detail_text.insert(tk.END, "Possible Causes:\n")
        for cause in dtc_info.possible_causes:
            detail_text.insert(tk.END, f"• {cause}\n")
        
        detail_text.insert(tk.END, "\nSuggested Solutions:\n")
        for solution in dtc_info.suggested_solutions:
            detail_text.insert(tk.END, f"• {solution}\n")
        
        if dtc_info.related_codes:
            detail_text.insert(tk.END, f"\nRelated Codes: {', '.join(dtc_info.related_codes)}\n")
        
        detail_text.config(state=tk.DISABLED)
        
        detail_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def start_monitoring(self):
        """Start live data monitoring"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        try:
            refresh_rate = float(self.refresh_rate_var.get())
            
            # Add some default PIDs if none are added
            if not self.live_data_monitor.monitored_pids:
                default_pids = ["0C", "0D", "05", "11"]  # RPM, Speed, Coolant Temp, Throttle Position
                for pid in default_pids:
                    self.live_data_monitor.add_pid_to_monitor(pid)
            
            # Add callback for data updates
            self.live_data_monitor.add_callback(self._update_live_data)
            
            if self.live_data_monitor.start_monitoring(refresh_rate):
                self.start_monitor_btn.config(state=tk.DISABLED)
                self.stop_monitor_btn.config(state=tk.NORMAL)
                self.status_label.config(text="Live data monitoring started")
            else:
                messagebox.showerror("Error", "Failed to start monitoring")
                
        except ValueError:
            messagebox.showerror("Error", "Invalid refresh rate")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start monitoring: {str(e)}")
    
    def stop_monitoring(self):
        """Stop live data monitoring"""
        self.live_data_monitor.stop_monitoring()
        self.start_monitor_btn.config(state=tk.NORMAL)
        self.stop_monitor_btn.config(state=tk.DISABLED)
        self.status_label.config(text="Live data monitoring stopped")
    
    def _update_live_data(self, sensor_data):
        """Update live data display"""
        def update_gui():
            # Find existing item or create new one
            for item in self.live_data_tree.get_children():
                if self.live_data_tree.item(item)['values'][0] == sensor_data.pid:
                    # Update existing item
                    self.live_data_tree.item(item, values=(
                        sensor_data.pid,
                        sensor_data.name,
                        f"{sensor_data.value:.2f}" if isinstance(sensor_data.value, float) else str(sensor_data.value),
                        sensor_data.unit,
                        sensor_data.timestamp.strftime("%H:%M:%S")
                    ))
                    return
            
            # Add new item
            self.live_data_tree.insert("", tk.END, values=(
                sensor_data.pid,
                sensor_data.name,
                f"{sensor_data.value:.2f}" if isinstance(sensor_data.value, float) else str(sensor_data.value),
                sensor_data.unit,
                sensor_data.timestamp.strftime("%H:%M:%S")
            ))
        
        self.root.after(0, update_gui)
    
    def add_pid_dialog(self):
        """Show dialog to add PID for monitoring"""
        dialog = tk.Toplevel(self.root)
        dialog.title("Add PID")
        dialog.geometry("300x150")
        dialog.transient(self.root)
        dialog.grab_set()
        
        tk.Label(dialog, text="Enter PID (hex):").pack(pady=10)
        
        pid_var = tk.StringVar()
        pid_entry = tk.Entry(dialog, textvariable=pid_var)
        pid_entry.pack(pady=5)
        pid_entry.focus()
        
        def add_pid():
            pid = pid_var.get().upper().strip()
            if not pid:
                return
            
            if self.live_data_monitor.add_pid_to_monitor(pid):
                dialog.destroy()
                self.status_label.config(text=f"Added PID {pid} to monitoring")
            else:
                messagebox.showerror("Error", f"Failed to add PID {pid}")
        
        button_frame = tk.Frame(dialog)
        button_frame.pack(pady=10)
        
        tk.Button(button_frame, text="Add", command=add_pid).pack(side=tk.LEFT, padx=5)
        tk.Button(button_frame, text="Cancel", command=dialog.destroy).pack(side=tk.LEFT, padx=5)
        
        pid_entry.bind("<Return>", lambda e: add_pid())
    
    def export_live_data(self):
        """Export live data to file"""
        if not self.live_data_monitor.is_monitoring:
            messagebox.showerror("Error", "Monitoring is not active")
            return
        
        filename = filedialog.asksaveasfilename(
            defaultextension=".csv",
            filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                duration = 60  # 1 minute default
                result = messagebox.askyesno("Export", f"Export data for {duration} seconds?")
                if result:
                    if self.live_data_monitor.export_data_log(filename, duration):
                        messagebox.showinfo("Success", f"Data exported to {filename}")
                    else:
                        messagebox.showerror("Error", "Failed to export data")
            except Exception as e:
                messagebox.showerror("Error", f"Export failed: {str(e)}")
    
    def scan_ecus(self):
        """Scan for available ECUs"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        self.status_label.config(text="Scanning for ECUs...")
        
        try:
            ecus = self.ecu_programmer.scan_ecus()
            
            if ecus:
                ecu_list = list(ecus.keys())
                self.ecu_combo['values'] = ecu_list
                if ecu_list:
                    self.ecu_combo.set(ecu_list[0])
                
                self.status_label.config(text=f"Found {len(ecus)} ECUs")
                
                # Display ECU info
                info_text = f"Found {len(ecus)} ECUs:\n\n"
                for address, ecu_info in ecus.items():
                    info_text += f"ECU {address}:\n"
                    info_text += f"  Name: {ecu_info.name}\n"
                    info_text += f"  Part Number: {ecu_info.part_number}\n"
                    info_text += f"  Software Version: {ecu_info.software_version}\n\n"
                
                self.programming_status_text.delete(1.0, tk.END)
                self.programming_status_text.insert(tk.END, info_text)
            else:
                messagebox.showinfo("ECU Scan", "No ECUs found")
                self.status_label.config(text="No ECUs found")
                
        except Exception as e:
            self.logger.error(f"ECU scan error: {e}")
            messagebox.showerror("Error", f"ECU scan failed: {str(e)}")
            self.status_label.config(text="ECU scan failed")
    
    def detect_protocol(self):
        """Detect vehicle protocol"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        try:
            protocol = self.protocol_manager.detect_protocol()
            if protocol:
                protocol_info = self.protocol_manager.get_protocol_info(protocol)
                messagebox.showinfo("Protocol Detection", 
                    f"Detected Protocol: {protocol_info['name']}\n"
                    f"Speed: {protocol_info['speed']}\n"
                    f"Description: {protocol_info['description']}")
            else:
                messagebox.showerror("Error", "Failed to detect protocol")
        except Exception as e:
            messagebox.showerror("Error", f"Protocol detection failed: {str(e)}")
    
    def clear_all_dtcs(self):
        """Clear all DTCs from all modules"""
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        result = messagebox.askyesno("Clear All DTCs", 
            "This will clear DTCs from all modules. Are you sure?")
        if result:
            try:
                success = self.dtc_manager.clear_dtcs("all")
                if success:
                    messagebox.showinfo("Success", "All DTCs cleared successfully")
                else:
                    messagebox.showerror("Error", "Failed to clear all DTCs")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to clear DTCs: {str(e)}")
    
    def enter_programming_mode(self):
        """Enter ECU programming mode"""
        ecu_address = self.ecu_var.get()
        if not ecu_address:
            messagebox.showerror("Error", "Please select an ECU first")
            return
        
        try:
            if self.ecu_programmer.enter_programming_mode(ecu_address):
                messagebox.showinfo("Success", "Entered programming mode successfully")
                self.programming_status_text.insert(tk.END, f"Entered programming mode for ECU {ecu_address}\n")
            else:
                messagebox.showerror("Error", "Failed to enter programming mode")
        except Exception as e:
            messagebox.showerror("Error", f"Programming mode failed: {str(e)}")
    
    def exit_programming_mode(self):
        """Exit ECU programming mode"""
        try:
            if self.ecu_programmer.exit_programming_mode():
                messagebox.showinfo("Success", "Exited programming mode successfully")
                self.programming_status_text.insert(tk.END, "Exited programming mode\n")
            else:
                messagebox.showerror("Error", "Failed to exit programming mode")
        except Exception as e:
            messagebox.showerror("Error", f"Exit programming mode failed: {str(e)}")
    
    def backup_firmware(self):
        """Backup ECU firmware"""
        if not self.ecu_programmer.programming_session_active:
            messagebox.showerror("Error", "Programming session not active")
            return
        
        filename = filedialog.asksaveasfilename(
            defaultextension=".bin",
            filetypes=[("Binary files", "*.bin"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                if self.ecu_programmer.backup_ecu_firmware(filename):
                    messagebox.showinfo("Success", f"Firmware backed up to {filename}")
                else:
                    messagebox.showerror("Error", "Firmware backup failed")
            except Exception as e:
                messagebox.showerror("Error", f"Backup failed: {str(e)}")
    
    def flash_firmware(self):
        """Flash firmware to ECU"""
        if not self.ecu_programmer.programming_session_active:
            messagebox.showerror("Error", "Programming session not active")
            return
        
        filename = filedialog.askopenfilename(
            filetypes=[("Binary files", "*.bin"), ("All files", "*.*")]
        )
        
        if filename:
            result = messagebox.askyesno("Flash Firmware", 
                "This will overwrite the ECU firmware. Are you sure?")
            if result:
                try:
                    firmware_data = self.ecu_programmer.load_firmware_file(filename)
                    if firmware_data:
                        if self.ecu_programmer.flash_firmware(firmware_data):
                            messagebox.showinfo("Success", "Firmware flashed successfully")
                        else:
                            messagebox.showerror("Error", "Firmware flash failed")
                    else:
                        messagebox.showerror("Error", "Failed to load firmware file")
                except Exception as e:
                    messagebox.showerror("Error", f"Flash failed: {str(e)}")
    
    def on_procedure_selected(self, event):
        """Handle procedure selection"""
        procedure_name = self.procedure_var.get()
        if procedure_name:
            procedure_info = self.relearn_manager.get_procedure_info(procedure_name)
            if procedure_info:
                info_text = f"Procedure: {procedure_info.name}\n"
                info_text += f"Description: {procedure_info.description}\n"
                info_text += f"Estimated Time: {procedure_info.estimated_time} minutes\n"
                info_text += f"Difficulty: {procedure_info.difficulty}\n\n"
                
                info_text += "Vehicle Requirements:\n"
                for req in procedure_info.vehicle_requirements:
                    info_text += f"• {req}\n"
                
                info_text += "\nPreconditions:\n"
                for precond in procedure_info.preconditions:
                    info_text += f"• {precond}\n"
                
                self.procedure_status_text.delete(1.0, tk.END)
                self.procedure_status_text.insert(tk.END, info_text)
    
    def check_preconditions(self):
        """Check preconditions for selected procedure"""
        procedure_name = self.procedure_var.get()
        if not procedure_name:
            messagebox.showerror("Error", "Please select a procedure first")
            return
        
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        try:
            results = self.relearn_manager.check_preconditions(procedure_name)
            
            status_text = "Precondition Check Results:\n\n"
            all_passed = True
            
            for condition, result in results.items():
                if result is True:
                    status_text += f"✓ {condition}\n"
                elif result is False:
                    status_text += f"✗ {condition}\n"
                    all_passed = False
                else:
                    status_text += f"? {condition} (manual check required)\n"
            
            status_text += f"\nOverall Status: {'PASS' if all_passed else 'FAIL'}\n"
            
            self.procedure_status_text.delete(1.0, tk.END)
            self.procedure_status_text.insert(tk.END, status_text)
            
        except Exception as e:
            messagebox.showerror("Error", f"Precondition check failed: {str(e)}")
    
    def start_procedure(self):
        """Start selected relearn procedure"""
        procedure_name = self.procedure_var.get()
        if not procedure_name:
            messagebox.showerror("Error", "Please select a procedure first")
            return
        
        if not self.is_connected:
            messagebox.showerror("Error", "Not connected to vehicle")
            return
        
        try:
            if self.relearn_manager.start_procedure(procedure_name):
                self.start_procedure_btn.config(state=tk.DISABLED)
                self.next_step_btn.config(state=tk.NORMAL)
                self.cancel_procedure_btn.config(state=tk.NORMAL)
                
                # Add status callback
                self.relearn_manager.add_status_callback(self._update_procedure_status)
                
                # Initialize progress bar
                procedure_info = self.relearn_manager.get_procedure_info(procedure_name)
                self.procedure_progress['maximum'] = len(procedure_info.steps)
                self.procedure_progress['value'] = 0
                
                self.procedure_status_text.insert(tk.END, f"\nStarted procedure: {procedure_name}\n")
            else:
                messagebox.showerror("Error", "Failed to start procedure")
                
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start procedure: {str(e)}")
    
    def next_step(self):
        """Execute next step in procedure"""
        try:
            if self.relearn_manager.execute_next_step():
                status = self.relearn_manager.get_procedure_status()
                self.procedure_progress['value'] = status['current_step']
                
                if status['status'] == 'completed':
                    self._procedure_completed()
                elif status['status'] == 'failed':
                    self._procedure_failed()
            else:
                messagebox.showerror("Error", "Step execution failed")
                
        except Exception as e:
            messagebox.showerror("Error", f"Step execution error: {str(e)}")
    
    def cancel_procedure(self):
        """Cancel current procedure"""
        result = messagebox.askyesno("Cancel Procedure", "Are you sure you want to cancel the procedure?")
        if result:
            try:
                if self.relearn_manager.cancel_procedure():
                    self._procedure_cancelled()
            except Exception as e:
                messagebox.showerror("Error", f"Cancel failed: {str(e)}")
    
    def _update_procedure_status(self, status):
        """Update procedure status display"""
        def update_gui():
            if status['current_step_info']:
                step_info = status['current_step_info']
                step_text = f"Step {step_info['step_number']}: {step_info['description']}\n"
                step_text += f"Instructions: {step_info['instruction']}\n"
                if step_info['is_manual']:
                    step_text += "This step requires manual action.\n"
                
                self.procedure_status_text.insert(tk.END, step_text)
                self.procedure_status_text.see(tk.END)
        
        self.root.after(0, update_gui)
    
    def _procedure_completed(self):
        """Handle procedure completion"""
        self.start_procedure_btn.config(state=tk.NORMAL)
        self.next_step_btn.config(state=tk.DISABLED)
        self.cancel_procedure_btn.config(state=tk.DISABLED)
        self.procedure_progress['value'] = self.procedure_progress['maximum']
        
        messagebox.showinfo("Success", "Procedure completed successfully!")
        self.procedure_status_text.insert(tk.END, "\nProcedure completed successfully!\n")
    
    def _procedure_failed(self):
        """Handle procedure failure"""
        self.start_procedure_btn.config(state=tk.NORMAL)
        self.next_step_btn.config(state=tk.DISABLED)
        self.cancel_procedure_btn.config(state=tk.DISABLED)
        
        messagebox.showerror("Error", "Procedure failed!")
        self.procedure_status_text.insert(tk.END, "\nProcedure failed!\n")
    
    def _procedure_cancelled(self):
        """Handle procedure cancellation"""
        self.start_procedure_btn.config(state=tk.NORMAL)
        self.next_step_btn.config(state=tk.DISABLED)
        self.cancel_procedure_btn.config(state=tk.DISABLED)
        
        self.procedure_status_text.insert(tk.END, "\nProcedure cancelled.\n")
    
    def export_report(self):
        """Export diagnostic report"""
        filename = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        
        if filename:
            try:
                with open(filename, 'w') as f:
                    f.write("OBD-II Diagnostic Report\n")
                    f.write("=" * 50 + "\n\n")
                    
                    # Connection info
                    f.write(f"Connection Status: {'Connected' if self.is_connected else 'Disconnected'}\n")
                    if self.is_connected:
                        f.write(f"Protocol: {self.protocol_manager.get_current_protocol_name()}\n")
                    f.write("\n")
                    
                    # Vehicle info
                    vehicle_info = self.vehicle_info_text.get(1.0, tk.END)
                    f.write("Vehicle Information:\n")
                    f.write(vehicle_info)
                    f.write("\n")
                    
                    # DTC info
                    f.write("Diagnostic Trouble Codes:\n")
                    for item in self.dtc_tree.get_children():
                        values = self.dtc_tree.item(item)['values']
                        f.write(f"Code: {values[0]} - {values[1]} (Severity: {values[2]})\n")
                    
                messagebox.showinfo("Success", f"Report exported to {filename}")
                
            except Exception as e:
                messagebox.showerror("Error", f"Export failed: {str(e)}")
    
    def show_about(self):
        """Show about dialog"""
        messagebox.showinfo("About", 
            "OBD-II Diagnostics and Programming Tool\n\n"
            "Version 1.0.0\n"
            "Copyright (c) 2025 THETECHYSASQUATCH\n\n"
            "Advanced OBD-II diagnostics, programming, and relearn procedures.")
    
    def show_help(self):
        """Show help dialog"""
        help_text = """
OBD-II Diagnostics Tool Help

1. Connection:
   - Select COM port and connect to OBD adapter
   - Tool will auto-detect protocol

2. Diagnostics:
   - Read/clear DTCs
   - View detailed error descriptions
   - Get suggested solutions

3. Live Data:
   - Monitor real-time vehicle parameters
   - Add custom PIDs
   - Export data to CSV

4. ECU Programming:
   - Scan for ECUs
   - Enter programming mode
   - Backup/flash firmware

5. Relearn Procedures:
   - Select procedure type
   - Check preconditions
   - Follow step-by-step instructions
        """
        
        help_window = tk.Toplevel(self.root)
        help_window.title("Help")
        help_window.geometry("500x400")
        
        help_text_widget = tk.Text(help_window, wrap=tk.WORD)
        help_scrollbar = tk.Scrollbar(help_window, orient=tk.VERTICAL, command=help_text_widget.yview)
        help_text_widget.configure(yscrollcommand=help_scrollbar.set)
        
        help_text_widget.insert(tk.END, help_text)
        help_text_widget.config(state=tk.DISABLED)
        
        help_text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        help_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def update_status(self):
        """Update status periodically"""
        try:
            # Update connection status
            if self.is_connected and self.obd_interface.is_vehicle_connected():
                self.connection_label.config(text="Connected", fg="green")
            elif self.is_connected:
                self.connection_label.config(text="Adapter Connected", fg="orange")
            else:
                self.connection_label.config(text="Disconnected", fg="red")
        except:
            pass
        
        # Schedule next update
        self.root.after(5000, self.update_status)
    
    def run(self):
        """Run the application"""
        self.root.mainloop()

def main():
    """Main entry point"""
    app = MainWindow()
    app.run()

if __name__ == "__main__":
    main()