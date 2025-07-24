import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../core/services/obd_service.dart';
import '../providers/app_providers.dart';
import '../models/connection_config.dart';

class ConnectionWidget extends ConsumerStatefulWidget {
  const ConnectionWidget({super.key});

  @override
  ConsumerState<ConnectionWidget> createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends ConsumerState<ConnectionWidget> {
  final _formKey = GlobalKey<FormState>();
  ConnectionType _selectedType = ConnectionType.bluetooth;
  String _deviceAddress = '';
  String _deviceName = '';
  int _baudRate = 38400;

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final availableDevices = ref.watch(availableDevicesProvider);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionStatusCard(connectionStatus),
          const SizedBox(height: 20),
          _buildConnectionForm(availableDevices, isMobile),
          const SizedBox(height: 20),
          _buildConnectionHistory(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard(AsyncValue<ConnectionStatus> connectionStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            connectionStatus.when(
              data: (status) => _buildStatusRow(status),
              loading: () => const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Checking connection...'),
                ],
              ),
              error: (error, _) => Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Error: $error')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildConnectionActions(connectionStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(ConnectionStatus status) {
    IconData icon;
    Color color;
    String text;
    String description;

    switch (status) {
      case ConnectionStatus.connected:
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Connected';
        description = 'OBD-II device is connected and ready';
        break;
      case ConnectionStatus.connecting:
        icon = Icons.sync;
        color = Colors.orange;
        text = 'Connecting';
        description = 'Attempting to connect to OBD-II device';
        break;
      case ConnectionStatus.error:
        icon = Icons.error;
        color = Colors.red;
        text = 'Error';
        description = 'Failed to connect to OBD-II device';
        break;
      case ConnectionStatus.disconnected:
      default:
        icon = Icons.bluetooth_disabled;
        color = Colors.grey;
        text = 'Disconnected';
        description = 'No OBD-II device connected';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildConnectionActions(AsyncValue<ConnectionStatus> connectionStatus) {
    return connectionStatus.when(
      data: (status) {
        if (status == ConnectionStatus.connected) {
          return ElevatedButton.icon(
            onPressed: () => _disconnect(),
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Disconnect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          );
        } else if (status == ConnectionStatus.connecting) {
          return ElevatedButton(
            onPressed: null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Connecting...'),
              ],
            ),
          );
        } else {
          return ElevatedButton.icon(
            onPressed: () => _connect(),
            icon: const Icon(Icons.bluetooth_connected),
            label: const Text('Connect'),
          );
        }
      },
      loading: () => const ElevatedButton(
        onPressed: null,
        child: Text('Loading...'),
      ),
      error: (_, __) => ElevatedButton.icon(
        onPressed: () => _connect(),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
    );
  }

  Widget _buildConnectionForm(AsyncValue<List<String>> availableDevices, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _buildConnectionTypeSelector(),
              const SizedBox(height: 16),
              _buildDeviceSelector(availableDevices),
              if (_selectedType == ConnectionType.serial) ...[
                const SizedBox(height: 16),
                _buildBaudRateSelector(),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => ref.refresh(availableDevicesProvider),
                    child: const Text('Scan Devices'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canConnect() ? () => _connect() : null,
                      icon: const Icon(Icons.bluetooth_connected),
                      label: const Text('Connect to Device'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ConnectionType.values.map((type) {
            return FilterChip(
              label: Text(_getConnectionTypeLabel(type)),
              selected: _selectedType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeviceSelector(AsyncValue<List<String>> availableDevices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Devices',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        availableDevices.when(
          data: (devices) {
            if (devices.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('No devices found. Try scanning again.'),
                  ],
                ),
              );
            }
            return DropdownButtonFormField<String>(
              value: _deviceAddress.isEmpty ? null : _deviceAddress,
              decoration: const InputDecoration(
                labelText: 'Select Device',
                border: OutlineInputBorder(),
              ),
              items: devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _deviceAddress = value ?? '';
                  _deviceName = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a device';
                }
                return null;
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('Error scanning devices: $error')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaudRateSelector() {
    final baudRates = [9600, 19200, 38400, 57600, 115200];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Baud Rate',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _baudRate,
          decoration: const InputDecoration(
            labelText: 'Select Baud Rate',
            border: OutlineInputBorder(),
          ),
          items: baudRates.map((rate) {
            return DropdownMenuItem(
              value: rate,
              child: Text('$rate bps'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _baudRate = value ?? 38400);
          },
        ),
      ],
    );
  }

  Widget _buildConnectionHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Connections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text('ELM327 Bluetooth'),
              subtitle: Text('Last connected: 2 hours ago'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.usb),
              title: Text('Serial USB Adapter'),
              subtitle: Text('Last connected: 1 day ago'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  String _getConnectionTypeLabel(ConnectionType type) {
    switch (type) {
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.usb:
        return 'USB';
      case ConnectionType.serial:
        return 'Serial';
    }
  }

  bool _canConnect() {
    return _deviceAddress.isNotEmpty && _formKey.currentState?.validate() == true;
  }

  Future<void> _connect() async {
    if (!_canConnect()) return;

    final config = ConnectionConfig(
      type: _selectedType,
      name: _deviceName,
      address: _deviceAddress,
      baudRate: _selectedType == ConnectionType.serial ? _baudRate : null,
    );

    final connectionActions = ref.read(connectionActionsProvider);
    final success = await connectionActions.connect(config);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to device'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    final connectionActions = ref.read(connectionActionsProvider);
    await connectionActions.disconnect();
  }
}