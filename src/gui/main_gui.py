"""
Main GUI Application for OBD-II Diagnostics and Programming Tool
"""

import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import threading
import json
from typing import Dict, Optional
import sys
import os

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

from vehicle_detection import VehicleDetector
from diagnostics import DiagnosticsEngine  
from programming import ProgrammingEngine


class OBD2ToolGUI:
    """Main GUI application for OBD-II tool"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("OBD-II Diagnostics and Programming Tool")
        self.root.geometry("1000x700")
        
        # Initialize engines
        self.vehicle_detector = VehicleDetector()
        self.diagnostics_engine = DiagnosticsEngine()
        self.programming_engine = ProgrammingEngine()
        
        # Current state
        self.current_vehicle = None
        self.obd_connection = None
        
        self.setup_gui()
        
    def setup_gui(self):
        """Setup the main GUI layout"""
        # Create main notebook for tabs
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Create tabs
        self.create_vehicle_tab()
        self.create_diagnostics_tab()
        self.create_programming_tab()
        self.create_live_data_tab()
        
        # Status bar
        self.status_var = tk.StringVar()
        self.status_var.set("Ready")
        status_bar = ttk.Label(self.root, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)
    
    def create_vehicle_tab(self):
        """Create vehicle detection and selection tab"""
        self.vehicle_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.vehicle_frame, text="Vehicle Detection")
        
        # Auto-detection section
        auto_frame = ttk.LabelFrame(self.vehicle_frame, text="Automatic Detection", padding=10)
        auto_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Button(auto_frame, text="Auto-Detect Vehicle", 
                  command=self.auto_detect_vehicle).pack(side=tk.LEFT, padx=5)
        ttk.Button(auto_frame, text="Connect OBD", 
                  command=self.connect_obd).pack(side=tk.LEFT, padx=5)
        ttk.Button(auto_frame, text="Disconnect", 
                  command=self.disconnect_obd).pack(side=tk.LEFT, padx=5)
        
        # Connection status
        self.connection_status = tk.StringVar()
        self.connection_status.set("Disconnected")
        ttk.Label(auto_frame, textvariable=self.connection_status).pack(side=tk.RIGHT, padx=5)
        
        # Manual selection section
        manual_frame = ttk.LabelFrame(self.vehicle_frame, text="Manual Selection", padding=10)
        manual_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(manual_frame, text="Manufacturer:").grid(row=0, column=0, sticky=tk.W, padx=5)
        self.manufacturer_var = tk.StringVar()
        manufacturer_combo = ttk.Combobox(manual_frame, textvariable=self.manufacturer_var,
                                        values=self.vehicle_detector.get_supported_manufacturers(),
                                        state="readonly")
        manufacturer_combo.grid(row=0, column=1, padx=5, pady=2, sticky=tk.W)
        manufacturer_combo.bind("<<ComboboxSelected>>", self.on_manufacturer_selected)
        
        ttk.Label(manual_frame, text="VIN:").grid(row=1, column=0, sticky=tk.W, padx=5)
        self.vin_var = tk.StringVar()
        vin_entry = ttk.Entry(manual_frame, textvariable=self.vin_var, width=20)
        vin_entry.grid(row=1, column=1, padx=5, pady=2, sticky=tk.W)
        
        ttk.Button(manual_frame, text="Decode VIN", 
                  command=self.decode_vin_manual).grid(row=1, column=2, padx=5)
        
        # Vehicle information display
        info_frame = ttk.LabelFrame(self.vehicle_frame, text="Vehicle Information", padding=10)
        info_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        self.vehicle_info_text = tk.Text(info_frame, height=15, width=80)
        scrollbar = ttk.Scrollbar(info_frame, orient=tk.VERTICAL, command=self.vehicle_info_text.yview)
        self.vehicle_info_text.configure(yscrollcommand=scrollbar.set)
        
        self.vehicle_info_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_diagnostics_tab(self):
        """Create diagnostics tab"""
        self.diagnostics_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.diagnostics_frame, text="Diagnostics")
        
        # Controls section
        controls_frame = ttk.LabelFrame(self.diagnostics_frame, text="Diagnostic Controls", padding=10)
        controls_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Button(controls_frame, text="Read DTCs", 
                  command=self.read_dtcs).pack(side=tk.LEFT, padx=5)
        ttk.Button(controls_frame, text="Clear DTCs", 
                  command=self.clear_dtcs).pack(side=tk.LEFT, padx=5)
        ttk.Button(controls_frame, text="Readiness Tests", 
                  command=self.read_readiness).pack(side=tk.LEFT, padx=5)
        
        # Module selection
        ttk.Label(controls_frame, text="Module:").pack(side=tk.LEFT, padx=(20, 5))
        self.module_var = tk.StringVar()
        module_combo = ttk.Combobox(controls_frame, textvariable=self.module_var,
                                   values=["ECM", "TCM", "ABS", "SRS", "BCM"],
                                   state="readonly", width=10)
        module_combo.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(controls_frame, text="Diagnose Module", 
                  command=self.diagnose_module).pack(side=tk.LEFT, padx=5)
        
        # Results display
        results_frame = ttk.LabelFrame(self.diagnostics_frame, text="Diagnostic Results", padding=10)
        results_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        self.diagnostics_text = tk.Text(results_frame, height=20, width=80)
        diag_scrollbar = ttk.Scrollbar(results_frame, orient=tk.VERTICAL, command=self.diagnostics_text.yview)
        self.diagnostics_text.configure(yscrollcommand=diag_scrollbar.set)
        
        self.diagnostics_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        diag_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_programming_tab(self):
        """Create programming and relearn tab"""
        self.programming_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.programming_frame, text="Programming")
        
        # Procedure selection
        selection_frame = ttk.LabelFrame(self.programming_frame, text="Procedure Selection", padding=10)
        selection_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(selection_frame, text="Available Procedures:").pack(anchor=tk.W)
        
        self.procedures_listbox = tk.Listbox(selection_frame, height=6)
        self.procedures_listbox.pack(fill=tk.X, pady=5)
        self.procedures_listbox.bind("<<ListboxSelect>>", self.on_procedure_selected)
        
        ttk.Button(selection_frame, text="Refresh Procedures", 
                  command=self.refresh_procedures).pack(side=tk.LEFT, padx=5)
        ttk.Button(selection_frame, text="Execute Procedure", 
                  command=self.execute_procedure).pack(side=tk.LEFT, padx=5)
        
        # Procedure details
        details_frame = ttk.LabelFrame(self.programming_frame, text="Procedure Details", padding=10)
        details_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        self.procedure_details_text = tk.Text(details_frame, height=15, width=80)
        proc_scrollbar = ttk.Scrollbar(details_frame, orient=tk.VERTICAL, command=self.procedure_details_text.yview)
        self.procedure_details_text.configure(yscrollcommand=proc_scrollbar.set)
        
        self.procedure_details_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        proc_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def create_live_data_tab(self):
        """Create live data monitoring tab"""
        self.live_data_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.live_data_frame, text="Live Data")
        
        # Controls
        controls_frame = ttk.LabelFrame(self.live_data_frame, text="Data Controls", padding=10)
        controls_frame.pack(fill=tk.X, padx=10, pady=5)
        
        self.monitoring = False
        self.monitor_button = ttk.Button(controls_frame, text="Start Monitoring", 
                                       command=self.toggle_monitoring)
        self.monitor_button.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(controls_frame, text="Read Once", 
                  command=self.read_live_data_once).pack(side=tk.LEFT, padx=5)
        
        # Data display
        data_frame = ttk.LabelFrame(self.live_data_frame, text="Live Data", padding=10)
        data_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Create treeview for live data
        self.live_data_tree = ttk.Treeview(data_frame, columns=("value", "unit", "time"), show="tree headings")
        self.live_data_tree.heading("#0", text="Parameter")
        self.live_data_tree.heading("value", text="Value")
        self.live_data_tree.heading("unit", text="Unit")
        self.live_data_tree.heading("time", text="Time")
        
        self.live_data_tree.column("#0", width=200)
        self.live_data_tree.column("value", width=100)
        self.live_data_tree.column("unit", width=80)
        self.live_data_tree.column("time", width=120)
        
        live_scrollbar = ttk.Scrollbar(data_frame, orient=tk.VERTICAL, command=self.live_data_tree.yview)
        self.live_data_tree.configure(yscrollcommand=live_scrollbar.set)
        
        self.live_data_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        live_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def auto_detect_vehicle(self):
        """Auto-detect vehicle using OBD connection"""
        self.status_var.set("Auto-detecting vehicle...")
        
        def detect():
            try:
                # Import OBD here to avoid issues if not installed
                import obd
                
                # Try to establish connection
                connection = obd.OBD()
                if connection.is_connected():
                    self.obd_connection = connection
                    self.connection_status.set("Connected")
                    
                    # Detect vehicle
                    vehicle_info = self.vehicle_detector.auto_detect_vehicle(connection)
                    if vehicle_info:
                        self.current_vehicle = vehicle_info
                        self.display_vehicle_info(vehicle_info)
                        self.status_var.set("Vehicle detected successfully")
                        self.refresh_procedures()
                    else:
                        self.status_var.set("Could not detect vehicle information")
                        messagebox.showwarning("Detection Failed", "Could not auto-detect vehicle. Try manual VIN entry.")
                else:
                    self.status_var.set("OBD connection failed")
                    messagebox.showerror("Connection Error", "Could not establish OBD connection. Check cable and vehicle.")
                    
            except ImportError:
                messagebox.showerror("Import Error", "python-obd library not installed. Please install requirements.")
            except Exception as e:
                self.status_var.set(f"Error: {e}")
                messagebox.showerror("Error", f"Auto-detection failed: {e}")
        
        # Run detection in background thread
        threading.Thread(target=detect, daemon=True).start()
    
    def connect_obd(self):
        """Connect to OBD interface"""
        try:
            import obd
            self.obd_connection = obd.OBD()
            if self.obd_connection.is_connected():
                self.connection_status.set("Connected")
                self.status_var.set("OBD connected")
                messagebox.showinfo("Connected", "OBD connection established")
            else:
                self.connection_status.set("Failed")
                self.status_var.set("OBD connection failed")
                messagebox.showerror("Connection Error", "Could not establish OBD connection")
        except ImportError:
            messagebox.showerror("Import Error", "python-obd library not installed")
        except Exception as e:
            messagebox.showerror("Error", f"Connection failed: {e}")
    
    def disconnect_obd(self):
        """Disconnect from OBD interface"""
        if self.obd_connection:
            self.obd_connection.close()
            self.obd_connection = None
        self.connection_status.set("Disconnected")
        self.status_var.set("OBD disconnected")
    
    def decode_vin_manual(self):
        """Decode VIN manually entered by user"""
        vin = self.vin_var.get().strip()
        if not vin:
            messagebox.showwarning("Input Error", "Please enter a VIN")
            return
        
        try:
            vehicle_info = self.vehicle_detector.decode_vin(vin)
            self.current_vehicle = vehicle_info
            self.display_vehicle_info(vehicle_info)
            self.refresh_procedures()
            self.status_var.set("VIN decoded successfully")
        except Exception as e:
            messagebox.showerror("VIN Error", f"Could not decode VIN: {e}")
    
    def on_manufacturer_selected(self, event):
        """Handle manufacturer selection"""
        manufacturer = self.manufacturer_var.get()
        if manufacturer:
            info = self.vehicle_detector.get_manufacturer_info(manufacturer)
            self.display_manufacturer_info(info, manufacturer)
    
    def display_vehicle_info(self, vehicle_info: Dict):
        """Display vehicle information in the text widget"""
        self.vehicle_info_text.delete(1.0, tk.END)
        
        info_text = "=== VEHICLE INFORMATION ===\n\n"
        for key, value in vehicle_info.items():
            if isinstance(value, list):
                info_text += f"{key.replace('_', ' ').title()}: {', '.join(value)}\n"
            else:
                info_text += f"{key.replace('_', ' ').title()}: {value}\n"
        
        # Add manufacturer-specific information
        manufacturer = vehicle_info.get("manufacturer")
        if manufacturer:
            mfg_info = self.vehicle_detector.get_manufacturer_info(manufacturer)
            if mfg_info:
                info_text += f"\n=== {manufacturer.upper()} SPECIFIC INFO ===\n\n"
                for key, value in mfg_info.items():
                    if isinstance(value, list):
                        info_text += f"{key.replace('_', ' ').title()}: {', '.join(value)}\n"
                    elif isinstance(value, dict):
                        info_text += f"{key.replace('_', ' ').title()}:\n"
                        for sub_key, sub_value in value.items():
                            info_text += f"  {sub_key}: {sub_value}\n"
                    else:
                        info_text += f"{key.replace('_', ' ').title()}: {value}\n"
        
        self.vehicle_info_text.insert(1.0, info_text)
    
    def display_manufacturer_info(self, info: Dict, manufacturer: str):
        """Display manufacturer-specific information"""
        self.vehicle_info_text.delete(1.0, tk.END)
        
        info_text = f"=== {manufacturer.upper()} INFORMATION ===\n\n"
        for key, value in info.items():
            if isinstance(value, list):
                info_text += f"{key.replace('_', ' ').title()}: {', '.join(value)}\n"
            elif isinstance(value, dict):
                info_text += f"{key.replace('_', ' ').title()}:\n"
                for sub_key, sub_value in value.items():
                    info_text += f"  {sub_key}: {sub_value}\n"
            else:
                info_text += f"{key.replace('_', ' ').title()}: {value}\n"
        
        self.vehicle_info_text.insert(1.0, info_text)
    
    def read_dtcs(self):
        """Read diagnostic trouble codes"""
        if not self.obd_connection:
            messagebox.showwarning("No Connection", "Please establish OBD connection first")
            return
        
        self.status_var.set("Reading DTCs...")
        
        def read():
            manufacturer = self.current_vehicle.get("manufacturer") if self.current_vehicle else None
            dtcs = self.diagnostics_engine.read_diagnostic_codes(self.obd_connection, manufacturer)
            
            result_text = "=== DIAGNOSTIC TROUBLE CODES ===\n\n"
            if dtcs:
                for dtc in dtcs:
                    result_text += f"Code: {dtc['code']}\n"
                    result_text += f"Description: {dtc['description']}\n"
                    result_text += f"System: {dtc['system']}\n"
                    result_text += f"Status: {dtc.get('status', 'Active')}\n"
                    if dtc.get('manufacturer_specific'):
                        result_text += "Type: Manufacturer Specific\n"
                    result_text += "-" * 50 + "\n"
            else:
                result_text += "No DTCs found or could not read DTCs\n"
            
            self.diagnostics_text.delete(1.0, tk.END)
            self.diagnostics_text.insert(1.0, result_text)
            self.status_var.set("DTCs read complete")
        
        threading.Thread(target=read, daemon=True).start()
    
    def clear_dtcs(self):
        """Clear diagnostic trouble codes"""
        if not self.obd_connection:
            messagebox.showwarning("No Connection", "Please establish OBD connection first")
            return
        
        if messagebox.askyesno("Confirm", "Are you sure you want to clear all DTCs?"):
            success = self.diagnostics_engine.clear_diagnostic_codes(self.obd_connection)
            if success:
                messagebox.showinfo("Success", "DTCs cleared successfully")
                self.status_var.set("DTCs cleared")
            else:
                messagebox.showerror("Error", "Failed to clear DTCs")
    
    def read_readiness(self):
        """Read readiness test status"""
        if not self.obd_connection:
            messagebox.showwarning("No Connection", "Please establish OBD connection first")
            return
        
        readiness = self.diagnostics_engine.get_readiness_tests(self.obd_connection)
        
        result_text = "=== READINESS TEST STATUS ===\n\n"
        for test, status in readiness.items():
            result_text += f"{test.replace('_', ' ').title()}: {status}\n"
        
        self.diagnostics_text.delete(1.0, tk.END)
        self.diagnostics_text.insert(1.0, result_text)
        self.status_var.set("Readiness tests complete")
    
    def diagnose_module(self):
        """Diagnose specific vehicle module"""
        module = self.module_var.get()
        if not module:
            messagebox.showwarning("Selection Error", "Please select a module to diagnose")
            return
        
        if not self.obd_connection:
            messagebox.showwarning("No Connection", "Please establish OBD connection first")
            return
        
        manufacturer = self.current_vehicle.get("manufacturer") if self.current_vehicle else None
        results = self.diagnostics_engine.perform_module_diagnosis(self.obd_connection, module, manufacturer)
        
        result_text = f"=== {module} MODULE DIAGNOSIS ===\n\n"
        result_text += f"Status: {results['status']}\n\n"
        
        if results['dtcs']:
            result_text += "DTCs:\n"
            for dtc in results['dtcs']:
                result_text += f"  {dtc['code']}: {dtc['description']}\n"
            result_text += "\n"
        
        if results['live_data']:
            result_text += "Live Data:\n"
            for pid, data in results['live_data'].items():
                result_text += f"  {pid}: {data['value']} {data['unit']}\n"
            result_text += "\n"
        
        if results['manufacturer_specific']:
            result_text += "Manufacturer Specific Commands:\n"
            for cmd, value in results['manufacturer_specific'].items():
                result_text += f"  {cmd}: {value}\n"
        
        self.diagnostics_text.delete(1.0, tk.END)
        self.diagnostics_text.insert(1.0, result_text)
        self.status_var.set(f"{module} diagnosis complete")
    
    def refresh_procedures(self):
        """Refresh available programming procedures"""
        self.procedures_listbox.delete(0, tk.END)
        
        if not self.current_vehicle:
            return
        
        manufacturer = self.current_vehicle.get("manufacturer")
        if manufacturer:
            procedures = self.programming_engine.get_available_procedures(manufacturer)
            for proc in procedures:
                self.procedures_listbox.insert(tk.END, proc['name'])
    
    def on_procedure_selected(self, event):
        """Handle procedure selection"""
        selection = self.procedures_listbox.curselection()
        if not selection or not self.current_vehicle:
            return
        
        procedure_name = self.procedures_listbox.get(selection[0])
        manufacturer = self.current_vehicle.get("manufacturer")
        
        # Find procedure ID from name
        procedures = self.programming_engine.get_available_procedures(manufacturer)
        procedure_id = None
        for proc in procedures:
            if proc['name'] == procedure_name:
                procedure_id = proc['id']
                break
        
        if procedure_id:
            details = self.programming_engine.get_procedure_details(manufacturer, procedure_id)
            if details:
                self.display_procedure_details(details)
    
    def display_procedure_details(self, details: Dict):
        """Display procedure details"""
        self.procedure_details_text.delete(1.0, tk.END)
        
        details_text = f"=== {details.get('name', 'PROCEDURE')} ===\n\n"
        
        if details.get('requirements'):
            details_text += "Requirements:\n"
            for req in details['requirements']:
                details_text += f"  • {req}\n"
            details_text += "\n"
        
        if details.get('steps'):
            details_text += "Steps:\n"
            for i, step in enumerate(details['steps'], 1):
                details_text += f"  {i}. {step}\n"
        
        self.procedure_details_text.insert(1.0, details_text)
    
    def execute_procedure(self):
        """Execute selected programming procedure"""
        selection = self.procedures_listbox.curselection()
        if not selection or not self.current_vehicle:
            messagebox.showwarning("Selection Error", "Please select a procedure")
            return
        
        procedure_name = self.procedures_listbox.get(selection[0])
        manufacturer = self.current_vehicle.get("manufacturer")
        
        # Find procedure ID
        procedures = self.programming_engine.get_available_procedures(manufacturer)
        procedure_id = None
        for proc in procedures:
            if proc['name'] == procedure_name:
                procedure_id = proc['id']
                break
        
        if not procedure_id:
            return
        
        # Confirm execution
        if not messagebox.askyesno("Confirm", f"Execute procedure: {procedure_name}?"):
            return
        
        # Execute procedure
        def execute():
            def progress_callback(result):
                # Update status in main thread
                self.root.after(0, lambda: self.status_var.set(
                    f"Step {result['current_step']}/{result['total_steps']}: {result['status']}"))
            
            result = self.programming_engine.execute_procedure(
                manufacturer, procedure_id, self.obd_connection, progress_callback)
            
            # Show result
            self.root.after(0, lambda: self.show_procedure_result(result))
        
        threading.Thread(target=execute, daemon=True).start()
    
    def show_procedure_result(self, result: Dict):
        """Show procedure execution result"""
        if result['success']:
            messagebox.showinfo("Success", f"Procedure completed successfully")
        else:
            messagebox.showerror("Failed", f"Procedure failed: {result.get('status', 'Unknown error')}")
        
        self.status_var.set("Ready")
    
    def toggle_monitoring(self):
        """Toggle live data monitoring"""
        if self.monitoring:
            self.monitoring = False
            self.monitor_button.config(text="Start Monitoring")
            self.status_var.set("Monitoring stopped")
        else:
            if not self.obd_connection:
                messagebox.showwarning("No Connection", "Please establish OBD connection first")
                return
            
            self.monitoring = True
            self.monitor_button.config(text="Stop Monitoring")
            self.status_var.set("Monitoring started")
            self.start_live_monitoring()
    
    def start_live_monitoring(self):
        """Start continuous live data monitoring"""
        def monitor():
            while self.monitoring:
                self.read_live_data_once()
                threading.Event().wait(1)  # Wait 1 second between reads
        
        threading.Thread(target=monitor, daemon=True).start()
    
    def read_live_data_once(self):
        """Read live data once"""
        if not self.obd_connection:
            messagebox.showwarning("No Connection", "Please establish OBD connection first")
            return
        
        live_data = self.diagnostics_engine.read_live_data(self.obd_connection)
        self.update_live_data_display(live_data)
    
    def update_live_data_display(self, live_data: Dict):
        """Update live data display"""
        # Clear existing items
        for item in self.live_data_tree.get_children():
            self.live_data_tree.delete(item)
        
        # Add new data
        for pid, data in live_data.items():
            value = data.get('value', 'N/A')
            unit = data.get('unit', '')
            time_str = data.get('time', '').strftime('%H:%M:%S') if data.get('time') else ''
            
            self.live_data_tree.insert('', 'end', text=pid.replace('_', ' ').title(),
                                     values=(value, unit, time_str))


def main():
    """Main application entry point"""
    root = tk.Tk()
    app = OBD2ToolGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()