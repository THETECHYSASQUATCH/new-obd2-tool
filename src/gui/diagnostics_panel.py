"""
Diagnostics panel for DTC management
"""

import tkinter as tk
from tkinter import ttk, messagebox
import logging
from typing import List, Optional
from datetime import datetime

logger = logging.getLogger(__name__)


class DiagnosticsPanel:
    """Panel for diagnostic operations and DTC management"""
    
    def __init__(self, parent, main_app):
        """
        Initialize diagnostics panel.
        
        Args:
            parent: Parent widget
            main_app: Reference to main application
        """
        self.parent = parent
        self.main_app = main_app
        
        self.current_dtcs = []
        self.pending_dtcs = []
        self.permanent_dtcs = []
        
        self._create_widgets()
    
    def _create_widgets(self) -> None:
        """Create panel widgets."""
        # Control frame
        control_frame = ttk.Frame(self.parent)
        control_frame.pack(fill=tk.X, padx=5, pady=5)
        
        ttk.Button(control_frame, text="Read Current DTCs", command=self._read_current_dtcs).pack(side=tk.LEFT, padx=2)
        ttk.Button(control_frame, text="Read Pending DTCs", command=self._read_pending_dtcs).pack(side=tk.LEFT, padx=2)
        ttk.Button(control_frame, text="Read Permanent DTCs", command=self._read_permanent_dtcs).pack(side=tk.LEFT, padx=2)
        ttk.Button(control_frame, text="Clear DTCs", command=self._clear_dtcs).pack(side=tk.LEFT, padx=10)
        ttk.Button(control_frame, text="Export DTCs", command=self._export_dtcs).pack(side=tk.RIGHT, padx=2)
        
        # Create notebook for different DTC types
        self.dtc_notebook = ttk.Notebook(self.parent)
        self.dtc_notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Current DTCs tab
        self._create_current_dtcs_tab()
        
        # Pending DTCs tab
        self._create_pending_dtcs_tab()
        
        # Permanent DTCs tab
        self._create_permanent_dtcs_tab()
        
        # History tab
        self._create_history_tab()
    
    def _create_current_dtcs_tab(self) -> None:
        """Create current DTCs tab."""
        current_frame = ttk.Frame(self.dtc_notebook)
        self.dtc_notebook.add(current_frame, text="Current DTCs")
        
        # Info label
        info_label = ttk.Label(current_frame, text="Current DTCs are active fault codes stored in the ECU")
        info_label.pack(anchor=tk.W, padx=5, pady=2)
        
        # Create treeview for current DTCs
        columns = ("Code", "Description", "Status", "Detected")
        self.current_tree = ttk.Treeview(current_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.current_tree.heading(col, text=col)
            if col == "Code":
                self.current_tree.column(col, width=80)
            elif col == "Status":
                self.current_tree.column(col, width=80)
            elif col == "Detected":
                self.current_tree.column(col, width=120)
            else:
                self.current_tree.column(col, width=300)
        
        # Add scrollbars
        current_scrollbar_v = ttk.Scrollbar(current_frame, orient=tk.VERTICAL, command=self.current_tree.yview)
        current_scrollbar_h = ttk.Scrollbar(current_frame, orient=tk.HORIZONTAL, command=self.current_tree.xview)
        self.current_tree.configure(yscrollcommand=current_scrollbar_v.set, xscrollcommand=current_scrollbar_h.set)
        
        self.current_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        current_scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        current_scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Bind double-click event
        self.current_tree.bind("<Double-1>", self._on_dtc_double_click)
    
    def _create_pending_dtcs_tab(self) -> None:
        """Create pending DTCs tab."""
        pending_frame = ttk.Frame(self.dtc_notebook)
        self.dtc_notebook.add(pending_frame, text="Pending DTCs")
        
        # Info label
        info_label = ttk.Label(pending_frame, text="Pending DTCs are fault codes that have been detected but not yet confirmed")
        info_label.pack(anchor=tk.W, padx=5, pady=2)
        
        # Create treeview for pending DTCs
        columns = ("Code", "Description", "Status", "Detected")
        self.pending_tree = ttk.Treeview(pending_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.pending_tree.heading(col, text=col)
            if col == "Code":
                self.pending_tree.column(col, width=80)
            elif col == "Status":
                self.pending_tree.column(col, width=80)
            elif col == "Detected":
                self.pending_tree.column(col, width=120)
            else:
                self.pending_tree.column(col, width=300)
        
        # Add scrollbars
        pending_scrollbar_v = ttk.Scrollbar(pending_frame, orient=tk.VERTICAL, command=self.pending_tree.yview)
        pending_scrollbar_h = ttk.Scrollbar(pending_frame, orient=tk.HORIZONTAL, command=self.pending_tree.xview)
        self.pending_tree.configure(yscrollcommand=pending_scrollbar_v.set, xscrollcommand=pending_scrollbar_h.set)
        
        self.pending_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        pending_scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        pending_scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Bind double-click event
        self.pending_tree.bind("<Double-1>", self._on_dtc_double_click)
    
    def _create_permanent_dtcs_tab(self) -> None:
        """Create permanent DTCs tab."""
        permanent_frame = ttk.Frame(self.dtc_notebook)
        self.dtc_notebook.add(permanent_frame, text="Permanent DTCs")
        
        # Info label
        info_label = ttk.Label(permanent_frame, text="Permanent DTCs cannot be cleared with scan tools and require proper repair")
        info_label.pack(anchor=tk.W, padx=5, pady=2)
        
        # Create treeview for permanent DTCs
        columns = ("Code", "Description", "Status", "Detected")
        self.permanent_tree = ttk.Treeview(permanent_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.permanent_tree.heading(col, text=col)
            if col == "Code":
                self.permanent_tree.column(col, width=80)
            elif col == "Status":
                self.permanent_tree.column(col, width=80)
            elif col == "Detected":
                self.permanent_tree.column(col, width=120)
            else:
                self.permanent_tree.column(col, width=300)
        
        # Add scrollbars
        permanent_scrollbar_v = ttk.Scrollbar(permanent_frame, orient=tk.VERTICAL, command=self.permanent_tree.yview)
        permanent_scrollbar_h = ttk.Scrollbar(permanent_frame, orient=tk.HORIZONTAL, command=self.permanent_tree.xview)
        self.permanent_tree.configure(yscrollcommand=permanent_scrollbar_v.set, xscrollcommand=permanent_scrollbar_h.set)
        
        self.permanent_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        permanent_scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        permanent_scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Bind double-click event
        self.permanent_tree.bind("<Double-1>", self._on_dtc_double_click)
    
    def _create_history_tab(self) -> None:
        """Create DTC history tab."""
        history_frame = ttk.Frame(self.dtc_notebook)
        self.dtc_notebook.add(history_frame, text="History")
        
        # Info label
        info_label = ttk.Label(history_frame, text="DTC history shows all codes that have been read during this session")
        info_label.pack(anchor=tk.W, padx=5, pady=2)
        
        # Control frame for history
        history_control_frame = ttk.Frame(history_frame)
        history_control_frame.pack(fill=tk.X, padx=5, pady=2)
        
        ttk.Button(history_control_frame, text="Refresh History", command=self._refresh_history).pack(side=tk.LEFT, padx=2)
        ttk.Button(history_control_frame, text="Clear History", command=self._clear_history).pack(side=tk.LEFT, padx=2)
        
        # Create treeview for DTC history
        columns = ("Code", "Description", "First Seen", "Last Seen", "Count")
        self.history_tree = ttk.Treeview(history_frame, columns=columns, show="headings", height=12)
        
        for col in columns:
            self.history_tree.heading(col, text=col)
            if col == "Code":
                self.history_tree.column(col, width=80)
            elif col in ["First Seen", "Last Seen"]:
                self.history_tree.column(col, width=120)
            elif col == "Count":
                self.history_tree.column(col, width=60)
            else:
                self.history_tree.column(col, width=300)
        
        # Add scrollbars
        history_scrollbar_v = ttk.Scrollbar(history_frame, orient=tk.VERTICAL, command=self.history_tree.yview)
        history_scrollbar_h = ttk.Scrollbar(history_frame, orient=tk.HORIZONTAL, command=self.history_tree.xview)
        self.history_tree.configure(yscrollcommand=history_scrollbar_v.set, xscrollcommand=history_scrollbar_h.set)
        
        self.history_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        history_scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        history_scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)
    
    def _read_current_dtcs(self) -> None:
        """Read current DTCs."""
        if not self.main_app.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            dtc_manager = self.main_app.obd_manager.get_dtc_manager()
            self.current_dtcs = dtc_manager.read_current_dtcs()
            self._populate_dtc_tree(self.current_tree, self.current_dtcs)
            
            # Update history
            self._refresh_history()
            
            messagebox.showinfo("Read DTCs", f"Read {len(self.current_dtcs)} current DTCs")
            
        except Exception as e:
            logger.error(f"Error reading current DTCs: {e}")
            messagebox.showerror("Error", f"Failed to read current DTCs: {e}")
    
    def _read_pending_dtcs(self) -> None:
        """Read pending DTCs."""
        if not self.main_app.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            dtc_manager = self.main_app.obd_manager.get_dtc_manager()
            self.pending_dtcs = dtc_manager.read_pending_dtcs()
            self._populate_dtc_tree(self.pending_tree, self.pending_dtcs)
            
            messagebox.showinfo("Read DTCs", f"Read {len(self.pending_dtcs)} pending DTCs")
            
        except Exception as e:
            logger.error(f"Error reading pending DTCs: {e}")
            messagebox.showerror("Error", f"Failed to read pending DTCs: {e}")
    
    def _read_permanent_dtcs(self) -> None:
        """Read permanent DTCs."""
        if not self.main_app.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            dtc_manager = self.main_app.obd_manager.get_dtc_manager()
            self.permanent_dtcs = dtc_manager.read_permanent_dtcs()
            self._populate_dtc_tree(self.permanent_tree, self.permanent_dtcs)
            
            messagebox.showinfo("Read DTCs", f"Read {len(self.permanent_dtcs)} permanent DTCs")
            
        except Exception as e:
            logger.error(f"Error reading permanent DTCs: {e}")
            messagebox.showerror("Error", f"Failed to read permanent DTCs: {e}")
    
    def _clear_dtcs(self) -> None:
        """Clear DTCs."""
        if not self.main_app.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        result = messagebox.askyesno("Confirm", 
                                   "Clear all diagnostic trouble codes?\n\n"
                                   "Warning: This will also reset:\n"
                                   "- Readiness monitors\n"
                                   "- Freeze frame data\n"
                                   "- O2 sensor test results")
        if not result:
            return
        
        try:
            dtc_manager = self.main_app.obd_manager.get_dtc_manager()
            success = dtc_manager.clear_dtcs()
            
            if success:
                # Clear displays
                self._clear_all_trees()
                self.current_dtcs.clear()
                self.pending_dtcs.clear()
                # Note: permanent DTCs cannot be cleared
                
                messagebox.showinfo("Clear DTCs", "DTCs cleared successfully")
            else:
                messagebox.showerror("Clear DTCs", "Failed to clear DTCs")
                
        except Exception as e:
            logger.error(f"Error clearing DTCs: {e}")
            messagebox.showerror("Error", f"Failed to clear DTCs: {e}")
    
    def _export_dtcs(self) -> None:
        """Export DTCs to file."""
        if not self.main_app.connected:
            messagebox.showwarning("Warning", "Not connected to vehicle")
            return
        
        try:
            from tkinter import filedialog
            
            filename = filedialog.asksaveasfilename(
                defaultextension=".json",
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
            )
            
            if filename:
                dtc_manager = self.main_app.obd_manager.get_dtc_manager()
                success = dtc_manager.export_dtcs(filename)
                
                if success:
                    messagebox.showinfo("Export", f"DTCs exported to {filename}")
                else:
                    messagebox.showerror("Export", "Failed to export DTCs")
                    
        except Exception as e:
            logger.error(f"Error exporting DTCs: {e}")
            messagebox.showerror("Error", f"Failed to export DTCs: {e}")
    
    def _populate_dtc_tree(self, tree: ttk.Treeview, dtcs: List) -> None:
        """Populate treeview with DTCs."""
        # Clear existing items
        for item in tree.get_children():
            tree.delete(item)
        
        # Add DTCs
        for dtc in dtcs:
            detected_time = dtc.detected_time.strftime("%Y-%m-%d %H:%M:%S") if dtc.detected_time else "Unknown"
            tree.insert("", "end", values=(
                dtc.code,
                dtc.description,
                dtc.status,
                detected_time
            ))
    
    def _clear_all_trees(self) -> None:
        """Clear all DTC trees."""
        for tree in [self.current_tree, self.pending_tree, self.permanent_tree]:
            for item in tree.get_children():
                tree.delete(item)
    
    def _refresh_history(self) -> None:
        """Refresh DTC history display."""
        try:
            if not self.main_app.obd_manager:
                return
            
            dtc_manager = self.main_app.obd_manager.get_dtc_manager()
            history = dtc_manager.get_dtc_history()
            
            # Clear history tree
            for item in self.history_tree.get_children():
                self.history_tree.delete(item)
            
            # Group DTCs by code and count occurrences
            dtc_counts = {}
            for dtc in history:
                if dtc.code not in dtc_counts:
                    dtc_counts[dtc.code] = {
                        'description': dtc.description,
                        'first_seen': dtc.detected_time,
                        'last_seen': dtc.detected_time,
                        'count': 1
                    }
                else:
                    dtc_counts[dtc.code]['count'] += 1
                    if dtc.detected_time:
                        if not dtc_counts[dtc.code]['first_seen'] or dtc.detected_time < dtc_counts[dtc.code]['first_seen']:
                            dtc_counts[dtc.code]['first_seen'] = dtc.detected_time
                        if not dtc_counts[dtc.code]['last_seen'] or dtc.detected_time > dtc_counts[dtc.code]['last_seen']:
                            dtc_counts[dtc.code]['last_seen'] = dtc.detected_time
            
            # Populate history tree
            for code, info in dtc_counts.items():
                first_seen = info['first_seen'].strftime("%Y-%m-%d %H:%M:%S") if info['first_seen'] else "Unknown"
                last_seen = info['last_seen'].strftime("%Y-%m-%d %H:%M:%S") if info['last_seen'] else "Unknown"
                
                self.history_tree.insert("", "end", values=(
                    code,
                    info['description'],
                    first_seen,
                    last_seen,
                    info['count']
                ))
                
        except Exception as e:
            logger.error(f"Error refreshing history: {e}")
    
    def _clear_history(self) -> None:
        """Clear DTC history."""
        result = messagebox.askyesno("Confirm", "Clear DTC history?")
        if result:
            try:
                if self.main_app.obd_manager:
                    dtc_manager = self.main_app.obd_manager.get_dtc_manager()
                    dtc_manager.dtc_history.clear()
                    self._refresh_history()
                    
            except Exception as e:
                logger.error(f"Error clearing history: {e}")
    
    def _on_dtc_double_click(self, event) -> None:
        """Handle double-click on DTC item."""
        tree = event.widget
        selection = tree.selection()
        
        if selection:
            item = selection[0]
            values = tree.item(item, "values")
            
            if values:
                dtc_code = values[0]
                description = values[1]
                
                # Show detailed DTC information
                self._show_dtc_details(dtc_code, description)
    
    def _show_dtc_details(self, dtc_code: str, description: str) -> None:
        """Show detailed DTC information."""
        detail_window = tk.Toplevel(self.parent)
        detail_window.title(f"DTC Details - {dtc_code}")
        detail_window.geometry("500x400")
        detail_window.transient(self.parent)
        
        # DTC info frame
        info_frame = ttk.LabelFrame(detail_window, text="DTC Information", padding="5")
        info_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(info_frame, text=f"Code: {dtc_code}", font=("TkDefaultFont", 10, "bold")).pack(anchor=tk.W)
        ttk.Label(info_frame, text=f"Description: {description}").pack(anchor=tk.W, pady=(5, 0))
        
        # Additional info (placeholder for future enhancement)
        details_frame = ttk.LabelFrame(detail_window, text="Additional Information", padding="5")
        details_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        details_text = tk.Text(details_frame, wrap=tk.WORD, height=10)
        details_text.pack(fill=tk.BOTH, expand=True)
        
        # Add some general information
        info_text = f"""DTC Code: {dtc_code}
Description: {description}

General Information:
- This is a diagnostic trouble code detected by the vehicle's on-board diagnostic system
- The code indicates a specific fault condition or malfunction
- Proper diagnosis requires additional testing and inspection
- Refer to vehicle service manual for detailed troubleshooting procedures

Note: This tool provides basic DTC information. For complete diagnosis and repair procedures, consult qualified service personnel or vehicle documentation."""
        
        details_text.insert(1.0, info_text)
        details_text.config(state=tk.DISABLED)
        
        # Close button
        ttk.Button(detail_window, text="Close", command=detail_window.destroy).pack(pady=10)
    
    def update_dtcs(self, dtcs: List) -> None:
        """Update DTC display (called from main window)."""
        self.current_dtcs = dtcs
        self._populate_dtc_tree(self.current_tree, dtcs)
        self._refresh_history()
    
    def clear(self) -> None:
        """Clear all displays (called from main window)."""
        self._clear_all_trees()
        for item in self.history_tree.get_children():
            self.history_tree.delete(item)
        
        self.current_dtcs.clear()
        self.pending_dtcs.clear()
        self.permanent_dtcs.clear()