import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../shared/widgets/custom_dashboard_widget.dart';
import '../../../shared/widgets/advanced_data_visualization_widget.dart';
import '../../../shared/models/pid_config.dart';
import '../../../core/constants/app_constants.dart';

/// Enhanced custom dashboard screen with widget management
class CustomDashboardScreen extends ConsumerStatefulWidget {
  const CustomDashboardScreen({super.key});

  @override
  ConsumerState<CustomDashboardScreen> createState() => _CustomDashboardScreenState();
}

class _CustomDashboardScreenState extends ConsumerState<CustomDashboardScreen> {
  List<DashboardWidgetConfig> _widgets = [];
  bool _isEditMode = false;
  DashboardLayout _currentLayout = DashboardLayout.grid;

  @override
  void initState() {
    super.initState();
    _loadDefaultWidgets();
  }

  void _loadDefaultWidgets() {
    // Create default dashboard widgets
    _widgets = [
      DashboardWidgetConfig(
        id: 'rpm_gauge',
        title: 'Engine RPM',
        widgetType: DashboardWidgetType.gauge,
        pidConfigs: [
          PidDisplayConfig(
            pid: '010C',
            displayName: 'Engine RPM',
            isEnabled: true,
            displayOrder: 1,
          ),
        ],
        gridWidth: 2,
        gridHeight: 2,
        accentColor: Colors.blue.value,
      ),
      DashboardWidgetConfig(
        id: 'speed_chart',
        title: 'Vehicle Speed',
        widgetType: DashboardWidgetType.chart,
        pidConfigs: [
          PidDisplayConfig(
            pid: '010D',
            displayName: 'Vehicle Speed',
            isEnabled: true,
            displayOrder: 2,
          ),
        ],
        gridWidth: 2,
        gridHeight: 2,
        chartType: DataVisualizationType.line,
        accentColor: Colors.green.value,
      ),
      DashboardWidgetConfig(
        id: 'engine_summary',
        title: 'Engine Summary',
        widgetType: DashboardWidgetType.summary,
        pidConfigs: [
          PidDisplayConfig(
            pid: '0105',
            displayName: 'Coolant Temp',
            isEnabled: true,
            displayOrder: 3,
          ),
          PidDisplayConfig(
            pid: '0104',
            displayName: 'Engine Load',
            isEnabled: true,
            displayOrder: 4,
          ),
        ],
        gridWidth: 1,
        gridHeight: 2,
      ),
      DashboardWidgetConfig(
        id: 'quick_actions',
        title: 'Quick Actions',
        widgetType: DashboardWidgetType.quickActions,
        gridWidth: 1,
        gridHeight: 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
            tooltip: _isEditMode ? 'Exit Edit Mode' : 'Edit Dashboard',
          ),
          if (!_isEditMode) ...[
            PopupMenuButton<DashboardLayout>(
              onSelected: (layout) => setState(() => _currentLayout = layout),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: DashboardLayout.grid,
                  child: ListTile(
                    leading: Icon(
                      Icons.grid_view,
                      color: _currentLayout == DashboardLayout.grid 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    title: const Text('Grid Layout'),
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: DashboardLayout.list,
                  child: ListTile(
                    leading: Icon(
                      Icons.view_list,
                      color: _currentLayout == DashboardLayout.list 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    title: const Text('List Layout'),
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: DashboardLayout.staggered,
                  child: ListTile(
                    leading: Icon(
                      Icons.view_quilt,
                      color: _currentLayout == DashboardLayout.staggered 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    title: const Text('Staggered Layout'),
                    dense: true,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_widget',
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add Widget'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset_layout',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Reset Layout'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_config',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Export Config'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'import_config',
                  child: ListTile(
                    leading: Icon(Icons.upload),
                    title: Text('Import Config'),
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _widgets.isEmpty
          ? _buildEmptyState()
          : _buildDashboardContent(isMobile),
      floatingActionButton: _isEditMode
          ? FloatingActionButton(
              onPressed: _showAddWidgetDialog,
              child: const Icon(Icons.add),
              tooltip: 'Add Widget',
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Dashboard Widgets',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add widgets to customize your dashboard',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddWidgetDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Widget'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(bool isMobile) {
    switch (_currentLayout) {
      case DashboardLayout.grid:
        return _buildGridLayout(isMobile);
      case DashboardLayout.list:
        return _buildListLayout();
      case DashboardLayout.staggered:
        return _buildStaggeredLayout(isMobile);
      default:
        return _buildGridLayout(isMobile);
    }
  }

  Widget _buildGridLayout(bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: _widgets.length,
        itemBuilder: (context, index) {
          final config = _widgets[index];
          return _buildDashboardWidget(config);
        },
      ),
    );
  }

  Widget _buildListLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _widgets.length,
      itemBuilder: (context, index) {
        final config = _widgets[index];
        return Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildDashboardWidget(config),
        );
      },
    );
  }

  Widget _buildStaggeredLayout(bool isMobile) {
    // For a more advanced staggered layout, you'd use packages like flutter_staggered_grid_view
    // For now, we'll create a simplified version
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _widgets.map((config) {
          final width = isMobile ? 
              (MediaQuery.of(context).size.width - 48) / 2 : 
              200.0 * config.gridWidth;
          final height = 150.0 * config.gridHeight;
          
          return SizedBox(
            width: width,
            height: height,
            child: _buildDashboardWidget(config),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardWidget(DashboardWidgetConfig config) {
    return CustomDashboardWidget(
      config: config,
      isEditing: _isEditMode,
      onEdit: () => _editWidget(config),
      onDelete: () => _deleteWidget(config.id),
    );
  }

  // Event handlers
  void _handleMenuAction(String action) {
    switch (action) {
      case 'add_widget':
        _showAddWidgetDialog();
        break;
      case 'reset_layout':
        _resetLayout();
        break;
      case 'export_config':
        _exportConfiguration();
        break;
      case 'import_config':
        _importConfiguration();
        break;
    }
  }

  void _showAddWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddWidgetDialog(
        onWidgetAdded: (config) {
          setState(() => _widgets.add(config));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editWidget(DashboardWidgetConfig config) {
    showDialog(
      context: context,
      builder: (context) => EditWidgetDialog(
        config: config,
        onWidgetUpdated: (updatedConfig) {
          setState(() {
            final index = _widgets.indexWhere((w) => w.id == config.id);
            if (index != -1) {
              _widgets[index] = updatedConfig;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteWidget(String widgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: const Text('Are you sure you want to delete this widget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _widgets.removeWhere((w) => w.id == widgetId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Widget deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _resetLayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Layout'),
        content: const Text('This will reset the dashboard to default widgets. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loadDefaultWidgets();
                _isEditMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard reset to default')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportConfiguration() {
    // TODO: Implement configuration export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export configuration coming soon')),
    );
  }

  void _importConfiguration() {
    // TODO: Implement configuration import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import configuration coming soon')),
    );
  }
}

/// Dialog for adding new widgets to the dashboard
class AddWidgetDialog extends StatefulWidget {
  final Function(DashboardWidgetConfig) onWidgetAdded;

  const AddWidgetDialog({
    super.key,
    required this.onWidgetAdded,
  });

  @override
  State<AddWidgetDialog> createState() => _AddWidgetDialogState();
}

class _AddWidgetDialogState extends State<AddWidgetDialog> {
  DashboardWidgetType _selectedType = DashboardWidgetType.liveData;
  String _title = '';
  final List<String> _selectedPids = [];
  Color _accentColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Widget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Widget Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _title = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DashboardWidgetType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Widget Type',
                border: OutlineInputBorder(),
              ),
              items: DashboardWidgetType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getWidgetTypeName(type)),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() => _selectedType = type);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Select PIDs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getAvailablePids().map((pidInfo) {
                final pid = pidInfo['pid'] as String;
                final name = pidInfo['name'] as String;
                final isSelected = _selectedPids.contains(pid);
                
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPids.add(pid);
                      } else {
                        _selectedPids.remove(pid);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedPids.isNotEmpty ? _createWidget : null,
                  child: const Text('Add Widget'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createWidget() {
    final config = DashboardWidgetConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.isNotEmpty ? _title : _getWidgetTypeName(_selectedType),
      widgetType: _selectedType,
      pidConfigs: _selectedPids.map((pid) => _createPidConfig(pid)).toList(),
      accentColor: _accentColor.value,
    );
    
    widget.onWidgetAdded(config);
  }

  PidDisplayConfig _createPidConfig(String pid) {
    final pidInfo = AppConstants.standardPids[pid];
    return PidDisplayConfig(
      pid: pid,
      displayName: pidInfo?['name'] ?? 'Unknown PID',
      isEnabled: true,
      displayOrder: 0,
    );
  }

  String _getWidgetTypeName(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.liveData:
        return 'Live Data';
      case DashboardWidgetType.chart:
        return 'Chart';
      case DashboardWidgetType.gauge:
        return 'Gauge';
      case DashboardWidgetType.summary:
        return 'Summary';
      case DashboardWidgetType.quickActions:
        return 'Quick Actions';
    }
  }

  List<Map<String, String>> _getAvailablePids() {
    return AppConstants.standardPids.entries
        .where((entry) => entry.value['canDisplay'] == true)
        .take(10) // Limit for demo
        .map((entry) => {
          'pid': entry.key,
          'name': entry.value['name'] as String,
        })
        .toList();
  }
}

/// Dialog for editing existing widgets
class EditWidgetDialog extends StatefulWidget {
  final DashboardWidgetConfig config;
  final Function(DashboardWidgetConfig) onWidgetUpdated;

  const EditWidgetDialog({
    super.key,
    required this.config,
    required this.onWidgetUpdated,
  });

  @override
  State<EditWidgetDialog> createState() => _EditWidgetDialogState();
}

class _EditWidgetDialogState extends State<EditWidgetDialog> {
  late String _title;
  late DashboardWidgetType _selectedType;
  late Color _accentColor;
  late bool _showProgressBar;
  late bool _showLegend;
  late DataVisualizationType? _chartType;

  @override
  void initState() {
    super.initState();
    _title = widget.config.title ?? '';
    _selectedType = widget.config.widgetType;
    _accentColor = widget.config.accentColor != null 
        ? Color(widget.config.accentColor!) 
        : Colors.blue;
    _showProgressBar = widget.config.showProgressBar;
    _showLegend = widget.config.showLegend;
    _chartType = widget.config.chartType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Widget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(
                labelText: 'Widget Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _title = value,
            ),
            const SizedBox(height: 16),
            if (_selectedType == DashboardWidgetType.chart) ...[
              DropdownButtonFormField<DataVisualizationType>(
                value: _chartType,
                decoration: const InputDecoration(
                  labelText: 'Chart Type',
                  border: OutlineInputBorder(),
                ),
                items: DataVisualizationType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (type) => setState(() => _chartType = type),
              ),
              const SizedBox(height: 16),
            ],
            SwitchListTile(
              title: const Text('Show Progress Bar'),
              value: _showProgressBar,
              onChanged: (value) => setState(() => _showProgressBar = value),
            ),
            SwitchListTile(
              title: const Text('Show Legend'),
              value: _showLegend,
              onChanged: (value) => setState(() => _showLegend = value),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _updateWidget,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateWidget() {
    final updatedConfig = widget.config.copyWith(
      title: _title.isNotEmpty ? _title : null,
      accentColor: _accentColor.value,
      showProgressBar: _showProgressBar,
      showLegend: _showLegend,
      chartType: _chartType,
    );
    
    widget.onWidgetUpdated(updatedConfig);
  }
}

enum DashboardLayout {
  grid,
  list,
  staggered,
}