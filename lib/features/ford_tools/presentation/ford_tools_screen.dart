import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ford_service.dart';
import '../../../core/services/obd_service.dart';
import '../../../shared/models/vehicle_info.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/action_button.dart';

/// Ford-specific tools and diagnostics screen
class FordToolsScreen extends ConsumerStatefulWidget {
  const FordToolsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FordToolsScreen> createState() => _FordToolsScreenState();
}

class _FordToolsScreenState extends ConsumerState<FordToolsScreen> {
  late FordService _fordService;
  Map<String, dynamic> _liveData = {};
  bool _isConnected = false;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _fordService = FordService(OBDService());
    _checkConnection();
  }

  void _checkConnection() {
    // Check if connected to Ford vehicle
    // This would integrate with the main OBD connection service
    setState(() {
      _isConnected = true; // Simulated
    });
  }

  Future<void> _initializeFordService() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing Ford service...';
      });

      // In a real implementation, this would get the current vehicle from a provider
      final vehicle = const VehicleInfo(
        make: 'Ford',
        model: 'F-150',
        year: 2023,
        trim: 'XLT',
      );

      _fordService.initialize(vehicle);
      
      setState(() {
        _statusMessage = 'Ford service initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize Ford service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getFordLiveData() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Retrieving Ford live data...';
      });

      final liveData = await _fordService.getFordLiveData();
      
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

  Future<void> _runFordServiceTool(String toolName) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Running $toolName...';
      });

      final result = await _fordService.runFordServiceTool(toolName, {});
      
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
        title: const Text('Ford Tools'),
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
                      _isConnected ? 'Connected to Ford Vehicle' : 'Not Connected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (!_isConnected)
                      ElevatedButton(
                        onPressed: _initializeFordService,
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

            // Ford Live Data Section
            if (_isConnected) ...[
              Row(
                children: [
                  Text(
                    'Ford Live Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _getFordLiveData,
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

              // Ford Service Tools
              Text(
                'Ford Service Tools',
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
                      title: 'PCM Health Check',
                      icon: Icons.health_and_safety,
                      onPressed: _isLoading ? null : () => _runFordServiceTool('pcm_health_check'),
                    ),
                    ActionButton(
                      title: 'Transmission Learn',
                      icon: Icons.settings,
                      onPressed: _isLoading ? null : () => _runFordServiceTool('transmission_adaptive_learn'),
                    ),
                    ActionButton(
                      title: 'SYNC System Test',
                      icon: Icons.bluetooth,
                      onPressed: _isLoading ? null : () => _runFordServiceTool('sync_system_test'),
                    ),
                    ActionButton(
                      title: 'EcoBoost Diagnostic',
                      icon: Icons.eco,
                      onPressed: _isLoading ? null : () => _runFordServiceTool('ecoboost_diagnostic'),
                    ),
                    ActionButton(
                      title: 'DEF System Service',
                      icon: Icons.local_gas_station,
                      onPressed: _isLoading ? null : () => _runFordServiceTool('def_system_service'),
                    ),
                    ActionButton(
                      title: 'Key Programming',
                      icon: Icons.vpn_key,
                      onPressed: _isLoading ? null : () => _runFordServiceTool('key_programming'),
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
                        'Connect to a Ford vehicle to access Ford-specific tools',
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
      case 'turbo boost pressure':
        return 'PSI';
      case 'egr valve position':
        return '%';
      case 'def level':
        return '%';
      case 'transmission temperature':
        return '°F';
      case 'engine rpm':
        return 'RPM';
      case 'vehicle speed':
        return 'MPH';
      case 'coolant temperature':
        return '°F';
      case 'fuel level':
        return '%';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _fordService.dispose();
    super.dispose();
  }
}