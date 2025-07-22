"""
Connection dialog for configuring OBD-II adapter connection
"""

import tkinter as tk
from tkinter import ttk, messagebox
import logging
from typing import Dict, Any, Optional

from ..hardware.connection_types import ConnectionType
from ..hardware.adapter_manager import AdapterType

logger = logging.getLogger(__name__)


class ConnectionDialog:
    """Dialog for configuring OBD-II adapter connection"""
    
    def __init__(self, parent, main_app):
        """
        Initialize connection dialog.
        
        Args:
            parent: Parent window
            main_app: Reference to main application
        """
        self.parent = parent
        self.main_app = main_app
        self.dialog = None
        self.result = None
        
        # Connection variables
        self.connection_type_var = tk.StringVar()
        self.adapter_type_var = tk.StringVar()
        self.port_var = tk.StringVar()
        self.baudrate_var = tk.StringVar()
        self.address_var = tk.StringVar()
        self.host_var = tk.StringVar()
        self.port_num_var = tk.StringVar()
        self.timeout_var = tk.StringVar()
        
        # Set defaults
        self.connection_type_var.set("USB/Serial")
        self.adapter_type_var.set("ELM327")
        self.port_var.set("auto")
        self.baudrate_var.set("38400")
        self.timeout_var.set("5.0")
        self.port_num_var.set("35000")
    
    def show(self) -> Optional[Dict[str, Any]]:
        """
        Show the connection dialog.
        
        Returns:
            Connection parameters if OK clicked, None if cancelled
        """
        self._create_dialog()
        self._populate_values()
        
        # Center dialog on parent
        self.dialog.transient(self.parent)
        self.dialog.grab_set()
        
        # Wait for dialog to close
        self.parent.wait_window(self.dialog)
        
        return self.result
    
    def _create_dialog(self) -> None:
        """Create the dialog window and widgets."""
        self.dialog = tk.Toplevel(self.parent)
        self.dialog.title("Connection Configuration")
        self.dialog.geometry("450x500")
        self.dialog.resizable(False, False)
        
        # Main frame
        main_frame = ttk.Frame(self.dialog, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Connection type frame
        conn_frame = ttk.LabelFrame(main_frame, text="Connection Type", padding="5")
        conn_frame.pack(fill=tk.X, pady=(0, 10))
        
        connection_types = ["USB/Serial", "Bluetooth", "Wi-Fi"]
        for i, conn_type in enumerate(connection_types):
            ttk.Radiobutton(
                conn_frame,
                text=conn_type,
                variable=self.connection_type_var,
                value=conn_type,
                command=self._on_connection_type_changed
            ).grid(row=0, column=i, sticky=tk.W, padx=5)
        
        # Adapter type frame
        adapter_frame = ttk.LabelFrame(main_frame, text="Adapter Type", padding="5")
        adapter_frame.pack(fill=tk.X, pady=(0, 10))
        
        adapter_types = ["ELM327", "Generic"]
        for i, adapter_type in enumerate(adapter_types):
            ttk.Radiobutton(
                adapter_frame,
                text=adapter_type,
                variable=self.adapter_type_var,
                value=adapter_type
            ).grid(row=0, column=i, sticky=tk.W, padx=5)
        
        # Connection parameters frame
        self.params_frame = ttk.LabelFrame(main_frame, text="Connection Parameters", padding="5")
        self.params_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Create parameter widgets (will be populated based on connection type)
        self._create_parameter_widgets()
        
        # Buttons frame
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Button(button_frame, text="Scan Ports", command=self._scan_ports).pack(side=tk.LEFT)
        ttk.Button(button_frame, text="Test", command=self._test_connection).pack(side=tk.LEFT, padx=(5, 0))
        
        ttk.Button(button_frame, text="Cancel", command=self._cancel).pack(side=tk.RIGHT)
        ttk.Button(button_frame, text="Connect", command=self._connect).pack(side=tk.RIGHT, padx=(0, 5))
        
        # Initially show USB/Serial parameters
        self._on_connection_type_changed()
    
    def _create_parameter_widgets(self) -> None:
        """Create parameter input widgets."""
        # USB/Serial parameters
        self.usb_frame = ttk.Frame(self.params_frame)
        
        ttk.Label(self.usb_frame, text="Port:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.port_combo = ttk.Combobox(self.usb_frame, textvariable=self.port_var, width=30)
        self.port_combo.grid(row=0, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(self.usb_frame, text="Baud Rate:").grid(row=1, column=0, sticky=tk.W, pady=2)
        baudrate_combo = ttk.Combobox(
            self.usb_frame,
            textvariable=self.baudrate_var,
            values=["9600", "19200", "38400", "57600", "115200"],
            width=30
        )
        baudrate_combo.grid(row=1, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        # Bluetooth parameters
        self.bluetooth_frame = ttk.Frame(self.params_frame)
        
        ttk.Label(self.bluetooth_frame, text="Address:").grid(row=0, column=0, sticky=tk.W, pady=2)
        ttk.Entry(self.bluetooth_frame, textvariable=self.address_var, width=32).grid(row=0, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(self.bluetooth_frame, text="Port:").grid(row=1, column=0, sticky=tk.W, pady=2)
        ttk.Entry(self.bluetooth_frame, textvariable=self.port_num_var, width=32).grid(row=1, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        # Wi-Fi parameters
        self.wifi_frame = ttk.Frame(self.params_frame)
        
        ttk.Label(self.wifi_frame, text="Host:").grid(row=0, column=0, sticky=tk.W, pady=2)
        ttk.Entry(self.wifi_frame, textvariable=self.host_var, width=32).grid(row=0, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(self.wifi_frame, text="Port:").grid(row=1, column=0, sticky=tk.W, pady=2)
        ttk.Entry(self.wifi_frame, textvariable=self.port_num_var, width=32).grid(row=1, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        # Common parameters
        self.common_frame = ttk.Frame(self.params_frame)
        
        ttk.Label(self.common_frame, text="Timeout (s):").grid(row=0, column=0, sticky=tk.W, pady=2)
        ttk.Entry(self.common_frame, textvariable=self.timeout_var, width=32).grid(row=0, column=1, sticky=tk.W, padx=(5, 0), pady=2)
    
    def _on_connection_type_changed(self) -> None:
        """Handle connection type change."""
        # Hide all parameter frames
        self.usb_frame.pack_forget()
        self.bluetooth_frame.pack_forget()
        self.wifi_frame.pack_forget()
        self.common_frame.pack_forget()
        
        # Show appropriate frame
        conn_type = self.connection_type_var.get()
        
        if conn_type == "USB/Serial":
            self.usb_frame.pack(fill=tk.X, pady=2)
        elif conn_type == "Bluetooth":
            self.bluetooth_frame.pack(fill=tk.X, pady=2)
        elif conn_type == "Wi-Fi":
            self.wifi_frame.pack(fill=tk.X, pady=2)
        
        # Always show common parameters
        self.common_frame.pack(fill=tk.X, pady=2)
    
    def _populate_values(self) -> None:
        """Populate values from configuration."""
        try:
            config = self.main_app.config.get_connection_config()
            
            self.port_var.set(config.get('port', 'auto'))
            self.baudrate_var.set(str(config.get('baudrate', 38400)))
            self.timeout_var.set(str(config.get('timeout', 5.0)))
            
            # Update port list
            self._update_port_list()
            
        except Exception as e:
            logger.error(f"Error populating values: {e}")
    
    def _update_port_list(self) -> None:
        """Update the list of available ports."""
        try:
            ports = self.main_app.adapter_manager.scan_ports()
            port_names = [port['device'] for port in ports]
            port_names.insert(0, "auto")  # Add auto-detect option
            
            self.port_combo['values'] = port_names
            
        except Exception as e:
            logger.error(f"Error updating port list: {e}")
    
    def _scan_ports(self) -> None:
        """Scan for available ports."""
        try:
            self._update_port_list()
            messagebox.showinfo("Scan Complete", "Port list updated")
            
        except Exception as e:
            logger.error(f"Error scanning ports: {e}")
            messagebox.showerror("Error", f"Failed to scan ports: {e}")
    
    def _test_connection(self) -> None:
        """Test connection with current parameters."""
        try:
            params = self._get_connection_params()
            
            # Create temporary adapter manager for testing
            from ..hardware.adapter_manager import AdapterManager
            test_manager = AdapterManager(params)
            
            # Try to connect
            success = test_manager.connect(
                connection_type=self._get_connection_type(),
                connection_params=params,
                adapter_type=self._get_adapter_type()
            )
            
            if success:
                # Test communication
                comm_success = test_manager.test_communication()
                test_manager.disconnect()
                
                if comm_success:
                    messagebox.showinfo("Test Result", "Connection test successful!")
                else:
                    messagebox.showwarning("Test Result", "Connection established but no vehicle response")
            else:
                messagebox.showerror("Test Result", "Connection test failed")
                
        except Exception as e:
            logger.error(f"Error testing connection: {e}")
            messagebox.showerror("Error", f"Connection test error: {e}")
    
    def _connect(self) -> None:
        """Connect with current parameters."""
        try:
            params = self._get_connection_params()
            
            # Validate parameters
            if not self._validate_params(params):
                return
            
            # Try to connect
            connection_params = {
                'connection_type': self._get_connection_type(),
                'connection_params': params,
                'adapter_type': self._get_adapter_type()
            }
            
            success = self.main_app.connect(connection_params)
            
            if success:
                self.result = connection_params
                self.dialog.destroy()
            else:
                messagebox.showerror("Connection Failed", "Failed to connect to adapter")
                
        except Exception as e:
            logger.error(f"Error connecting: {e}")
            messagebox.showerror("Error", f"Connection error: {e}")
    
    def _cancel(self) -> None:
        """Cancel dialog."""
        self.result = None
        self.dialog.destroy()
    
    def _get_connection_type(self) -> ConnectionType:
        """Get selected connection type."""
        type_map = {
            "USB/Serial": ConnectionType.USB_SERIAL,
            "Bluetooth": ConnectionType.BLUETOOTH,
            "Wi-Fi": ConnectionType.WIFI
        }
        return type_map[self.connection_type_var.get()]
    
    def _get_adapter_type(self) -> AdapterType:
        """Get selected adapter type."""
        type_map = {
            "ELM327": AdapterType.ELM327,
            "Generic": AdapterType.GENERIC
        }
        return type_map[self.adapter_type_var.get()]
    
    def _get_connection_params(self) -> Dict[str, Any]:
        """Get connection parameters based on selected type."""
        params = {
            'timeout': float(self.timeout_var.get())
        }
        
        conn_type = self.connection_type_var.get()
        
        if conn_type == "USB/Serial":
            params.update({
                'port': self.port_var.get(),
                'baudrate': int(self.baudrate_var.get())
            })
        elif conn_type == "Bluetooth":
            params.update({
                'address': self.address_var.get(),
                'port': int(self.port_num_var.get())
            })
        elif conn_type == "Wi-Fi":
            params.update({
                'host': self.host_var.get(),
                'port': int(self.port_num_var.get())
            })
        
        return params
    
    def _validate_params(self, params: Dict[str, Any]) -> bool:
        """Validate connection parameters."""
        conn_type = self.connection_type_var.get()
        
        try:
            # Common validation
            if params['timeout'] <= 0:
                messagebox.showerror("Validation Error", "Timeout must be positive")
                return False
            
            if conn_type == "USB/Serial":
                if not params.get('port'):
                    messagebox.showerror("Validation Error", "Port must be specified")
                    return False
                if params['baudrate'] <= 0:
                    messagebox.showerror("Validation Error", "Baud rate must be positive")
                    return False
                    
            elif conn_type == "Bluetooth":
                if not params.get('address'):
                    messagebox.showerror("Validation Error", "Bluetooth address must be specified")
                    return False
                if params['port'] <= 0 or params['port'] > 65535:
                    messagebox.showerror("Validation Error", "Port must be between 1 and 65535")
                    return False
                    
            elif conn_type == "Wi-Fi":
                if not params.get('host'):
                    messagebox.showerror("Validation Error", "Host must be specified")
                    return False
                if params['port'] <= 0 or params['port'] > 65535:
                    messagebox.showerror("Validation Error", "Port must be between 1 and 65535")
                    return False
            
            return True
            
        except ValueError as e:
            messagebox.showerror("Validation Error", f"Invalid parameter value: {e}")
            return False
        except Exception as e:
            messagebox.showerror("Validation Error", f"Validation error: {e}")
            return False