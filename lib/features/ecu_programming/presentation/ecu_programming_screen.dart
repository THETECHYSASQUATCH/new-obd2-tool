import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/models/ecu_programming.dart';
import '../../../shared/models/vehicle_info.dart';

class EcuProgrammingScreen extends ConsumerStatefulWidget {
  const EcuProgrammingScreen({super.key});

  @override
  ConsumerState<EcuProgrammingScreen> createState() => _EcuProgrammingScreenState();
}

class _EcuProgrammingScreenState extends ConsumerState<EcuProgrammingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECU Programming'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ECU Discovery', icon: Icon(Icons.search)),
            Tab(text: 'Programming', icon: Icon(Icons.memory)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EcuDiscoveryTab(),
          _ProgrammingTab(),
        ],
      ),
    );
  }
}

class _EcuDiscoveryTab extends ConsumerWidget {
  const _EcuDiscoveryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final discoveredEcus = ref.watch(discoveredEcusProvider);
    final ecuNotifier = ref.read(discoveredEcusProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (selectedVehicle != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedVehicle.displayName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Engine: ${selectedVehicle.engine ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Supported Protocols: ${selectedVehicle.supportedProtocols.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('No vehicle selected'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to vehicle selection
                            Navigator.of(context).pushNamed('/settings');
                          },
                          child: const Text('Select Vehicle'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ECU Discovery Section
          Row(
            children: [
              Text(
                'Discovered ECUs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: selectedVehicle != null 
                    ? () => ecuNotifier.discoverEcus()
                    : null,
                icon: const Icon(Icons.search),
                label: const Text('Discover ECUs'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ECU List
          Expanded(
            child: discoveredEcus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.memory,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedVehicle != null 
                              ? 'No ECUs discovered yet.\nTap "Discover ECUs" to scan for available ECUs.'
                              : 'Please select a vehicle first to discover ECUs.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: discoveredEcus.length,
                    itemBuilder: (context, index) {
                      final ecu = discoveredEcus[index];
                      return _EcuCard(ecu: ecu);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EcuCard extends StatelessWidget {
  final EcuInfo ecu;

  const _EcuCard({required this.ecu});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getEcuIcon(ecu.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ecu.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Address: ${ecu.address}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (ecu.programmingSupported)
                  const Chip(
                    label: Text('Programmable'),
                    backgroundColor: Colors.green,
                  )
                else
                  const Chip(
                    label: Text('Read Only'),
                    backgroundColor: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (ecu.partNumber != null || ecu.softwareVersion != null) ...[
              Row(
                children: [
                  if (ecu.partNumber != null) ...[
                    Text(
                      'P/N: ${ecu.partNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (ecu.softwareVersion != null)
                    Text(
                      'SW: ${ecu.softwareVersion}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (ecu.supportedModes.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: ecu.supportedModes.map((mode) {
                  return Chip(
                    label: Text(mode.name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getEcuIcon(EcuType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case EcuType.engine:
        iconData = Icons.settings;
        color = Colors.red;
        break;
      case EcuType.transmission:
        iconData = Icons.sync_alt;
        color = Colors.blue;
        break;
      case EcuType.abs:
        iconData = Icons.disc_full;
        color = Colors.orange;
        break;
      case EcuType.airbag:
        iconData = Icons.security;
        color = Colors.purple;
        break;
      case EcuType.body:
        iconData = Icons.directions_car;
        color = Colors.green;
        break;
      case EcuType.climate:
        iconData = Icons.ac_unit;
        color = Colors.cyan;
        break;
      case EcuType.infotainment:
        iconData = Icons.radio;
        color = Colors.indigo;
        break;
      case EcuType.hybrid:
        iconData = Icons.electric_car;
        color = Colors.lightGreen;
        break;
      case EcuType.other:
        iconData = Icons.memory;
        color = Colors.grey;
        break;
    }

    return Icon(iconData, color: color, size: 24);
  }
}

class _ProgrammingTab extends ConsumerStatefulWidget {
  const _ProgrammingTab();

  @override
  ConsumerState<_ProgrammingTab> createState() => _ProgrammingTabState();
}

class _ProgrammingTabState extends ConsumerState<_ProgrammingTab> {
  EcuInfo? selectedEcu;
  ProgrammingMode? selectedMode;
  String? selectedFilePath;

  @override
  Widget build(BuildContext context) {
    final discoveredEcus = ref.watch(discoveredEcusProvider);
    final activeSessions = ref.watch(activeSessionsProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Sessions
          if (activeSessions.isNotEmpty) ...[
            Text(
              'Active Programming Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...activeSessions.map((session) => _SessionCard(session: session)),
            const SizedBox(height: 16),
          ],

          // Programming Setup
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Programming Session',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // ECU Selection
                  DropdownButtonFormField<EcuInfo>(
                    decoration: const InputDecoration(
                      labelText: 'Select ECU',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedEcu,
                    items: discoveredEcus
                        .where((ecu) => ecu.programmingSupported)
                        .map((ecu) {
                      return DropdownMenuItem(
                        value: ecu,
                        child: Text('${ecu.name} (${ecu.address})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEcu = value;
                        selectedMode = null; // Reset mode when ECU changes
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Programming Mode Selection
                  if (selectedEcu != null) ...[
                    DropdownButtonFormField<ProgrammingMode>(
                      decoration: const InputDecoration(
                        labelText: 'Programming Mode',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMode,
                      items: selectedEcu!.supportedModes.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(_getModeDisplayName(mode)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // File Selection
                  if (selectedMode != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Programming File',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: selectedFilePath ?? '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _selectFile,
                          child: const Text('Browse'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Start Programming Button
                  if (selectedEcu != null && 
                      selectedMode != null && 
                      selectedFilePath != null) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Warning: ECU programming can affect vehicle operation. '
                            'Ensure the vehicle is in a safe environment and the '
                            'programming file is compatible.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startProgramming,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Programming'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModeDisplayName(ProgrammingMode mode) {
    switch (mode) {
      case ProgrammingMode.flash:
        return 'Flash Programming';
      case ProgrammingMode.calibration:
        return 'Calibration Update';
      case ProgrammingMode.adaptation:
        return 'Adaptation Values';
      case ProgrammingMode.coding:
        return 'Coding/Configuration';
      case ProgrammingMode.configuration:
        return 'Configuration Only';
    }
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin', 'hex', 'cal', 'ecu'],
    );

    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    }
  }

  void _startProgramming() {
    if (selectedEcu == null || selectedMode == null || selectedFilePath == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Programming'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to start ECU programming?'),
            const SizedBox(height: 16),
            Text('ECU: ${selectedEcu!.name}'),
            Text('Mode: ${_getModeDisplayName(selectedMode!)}'),
            Text('File: ${selectedFilePath!.split('/').last}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This operation cannot be undone without a backup.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Start actual programming session
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Programming session started'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ProgrammingSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(session.status),
                  color: _getStatusColor(session.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ECU: ${session.ecuId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(session.status.name),
                  backgroundColor: _getStatusColor(session.status).withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Mode: ${session.mode.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (session.filePath != null)
              Text(
                'File: ${session.filePath!.split('/').last}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: session.progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(session.status),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.progress.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (session.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ProgrammingStatus status) {
    switch (status) {
      case ProgrammingStatus.idle:
        return Icons.pause;
      case ProgrammingStatus.connecting:
        return Icons.link;
      case ProgrammingStatus.authenticating:
        return Icons.security;
      case ProgrammingStatus.reading:
        return Icons.download;
      case ProgrammingStatus.erasing:
        return Icons.clear;
      case ProgrammingStatus.programming:
        return Icons.memory;
      case ProgrammingStatus.verifying:
        return Icons.verified;
      case ProgrammingStatus.completed:
        return Icons.check_circle;
      case ProgrammingStatus.error:
        return Icons.error;
      case ProgrammingStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(ProgrammingStatus status) {
    switch (status) {
      case ProgrammingStatus.idle:
        return Colors.grey;
      case ProgrammingStatus.connecting:
      case ProgrammingStatus.authenticating:
      case ProgrammingStatus.reading:
      case ProgrammingStatus.erasing:
      case ProgrammingStatus.programming:
      case ProgrammingStatus.verifying:
        return Colors.blue;
      case ProgrammingStatus.completed:
        return Colors.green;
      case ProgrammingStatus.error:
        return Colors.red;
      case ProgrammingStatus.cancelled:
        return Colors.orange;
    }
  }
}