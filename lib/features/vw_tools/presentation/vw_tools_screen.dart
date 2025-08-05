import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/vw_service.dart';
import '../../../core/services/obd_service.dart';
import '../../../shared/models/vehicle_info.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/action_button.dart';

/// VW Group-specific tools and diagnostics screen
class VWToolsScreen extends ConsumerStatefulWidget {
  const VWToolsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VWToolsScreen> createState() => _VWToolsScreenState();
}

class _VWToolsScreenState extends ConsumerState<VWToolsScreen> {
  late VWService _vwService;
  Map<String, dynamic> _liveData = {};
  bool _isConnected = false;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _vwService = VWService(OBDService());
    _checkConnection();
  }

  void _checkConnection() {
    // Check if connected to VW Group vehicle
    // This would integrate with the main OBD connection service
    setState(() {
      _isConnected = true; // Simulated
    });
  }

  Future<void> _initializeVWService() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing VW service...';
      });

      // In a real implementation, this would get the current vehicle from a provider
      final vehicle = const VehicleInfo(
        make: 'Volkswagen',
        model: 'Golf',
        year: 2023,
        trim: 'GTI',
      );

      _vwService.initialize(vehicle);
      
      setState(() {
        _statusMessage = 'VW service initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize VW service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getVWLiveData() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Retrieving VW live data...';
      });

      final liveData = await _vwService.getVWLiveData();
      
      setState(() {
        _liveData = liveData;
        _statusMessage = 'Live data updated successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to get live data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runVWServiceTool(String toolName) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Running $toolName...';
      });

      final result = await _vwService.runVWServiceTool(toolName, {});
      
      _showServiceToolResult(toolName, result);
      
      setState(() {
        _statusMessage = '$toolName completed successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to run $toolName: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showServiceToolResult(String toolName, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$toolName Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('${entry.key}: ${entry.value}'),
              )
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VW Group Tools'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected to VW Group Vehicle' : 'Not Connected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (!_isConnected)
                      ElevatedButton(
                        onPressed: _initializeVWService,
                        child: const Text('Initialize'),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Status Message
            if (_statusMessage != null)
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      if (_isLoading) 
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (_isLoading) const SizedBox(width: 12),
                      Expanded(child: Text(_statusMessage!)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // VW Live Data Section
            if (_isConnected) ...[
              Row(
                children: [
                  Text(
                    'VW Live Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _getVWLiveData,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Live Data Grid
              if (_liveData.isNotEmpty)
                Expanded(
                  flex: 2,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _liveData.length.clamp(0, 8), // Show max 8 items
                    itemBuilder: (context, index) {
                      final entry = _liveData.entries.elementAt(index);
                      return DataCard(
                        title: entry.key,
                        value: entry.value.toString(),
                        unit: _getUnitForDataType(entry.key),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // VW Service Tools
              Text(
                'VW Service Tools',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              const SizedBox(height: 12),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    ActionButton(
                      title: 'VCDS Scan',
                      icon: Icons.search,
                      onPressed: _isLoading ? null : () => _runVWServiceTool('vcds_scan'),
                    ),
                    ActionButton(
                      title: 'DSG Service',
                      icon: Icons.settings,
                      onPressed: _isLoading ? null : () => _runVWServiceTool('dsg_service'),
                    ),
                    ActionButton(
                      title: 'DPF Regeneration',
                      icon: Icons.cleaning_services,
                      onPressed: _isLoading ? null : () => _runVWServiceTool('dpf_regeneration'),
                    ),
                    ActionButton(
                      title: 'AdBlue Reset',
                      icon: Icons.local_gas_station,
                      onPressed: _isLoading ? null : () => _runVWServiceTool('adblue_reset'),
                    ),
                    ActionButton(
                      title: 'Oil Service Reset',
                      icon: Icons.oil_barrel,
                      onPressed: _isLoading ? null : () => _runVWServiceTool('oil_service_reset'),
                    ),
                    ActionButton(
                      title: 'Air Suspension Cal.',
                      icon: Icons.height,
                      onPressed: _isLoading ? null : () => _runVWServiceTool('air_suspension_calibration'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.car_rental,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Connect to a VW Group vehicle to access VW-specific tools\n(Volkswagen, Audi, Bentley, Porsche, Skoda, SEAT)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getUnitForDataType(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'dsg transmission temperature':
        return '°C';
      case 'adblue/def level':
        return '%';
      case 'turbo wastegate position':
        return '%';
      case 'egr valve position':
        return '%';
      case 'dsg health score':
        return '%';
      case 'awd system efficiency':
        return '%';
      case 'adblue service range':
        return 'mi';
      case 'engine rpm':
        return 'RPM';
      case 'vehicle speed':
        return 'MPH';
      case 'coolant temperature':
        return '°C';
      case 'fuel level':
        return '%';
      default:
        return '';
    }
  }
}