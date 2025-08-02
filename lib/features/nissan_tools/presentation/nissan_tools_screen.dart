import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/nissan_service.dart';
import '../../../core/services/obd_service.dart';
import '../../../shared/models/vehicle_info.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/action_button.dart';

/// Nissan-specific tools and diagnostics screen
class NissanToolsScreen extends ConsumerStatefulWidget {
  const NissanToolsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NissanToolsScreen> createState() => _NissanToolsScreenState();
}

class _NissanToolsScreenState extends ConsumerState<NissanToolsScreen> {
  late NissanService _nissanService;
  Map<String, dynamic> _liveData = {};
  bool _isConnected = false;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _nissanService = NissanService(OBDService());
    _checkConnection();
  }

  void _checkConnection() {
    // Check if connected to Nissan vehicle
    // This would integrate with the main OBD connection service
    setState(() {
      _isConnected = true; // Simulated
    });
  }

  Future<void> _initializeNissanService() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing Nissan service...';
      });

      // In a real implementation, this would get the current vehicle from a provider
      final vehicle = const VehicleInfo(
        make: 'Nissan',
        model: 'Altima',
        year: 2023,
        trim: 'SV',
      );

      _nissanService.initialize(vehicle);
      
      setState(() {
        _statusMessage = 'Nissan service initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize Nissan service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getNissanLiveData() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Retrieving Nissan live data...';
      });

      final liveData = await _nissanService.getNissanLiveData();
      
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

  Future<void> _runNissanServiceTool(String toolName) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Running $toolName...';
      });

      final result = await _nissanService.runNissanServiceTool(toolName, {});
      
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
        title: const Text('Nissan Tools'),
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
                      _isConnected ? 'Connected to Nissan Vehicle' : 'Not Connected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (!_isConnected)
                      ElevatedButton(
                        onPressed: _initializeNissanService,
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

            // Nissan Live Data Section
            if (_isConnected) ...[
              Row(
                children: [
                  Text(
                    'Nissan Live Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _getNissanLiveData,
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

              // Nissan Service Tools
              Text(
                'Nissan Service Tools',
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
                      title: 'CONSULT Scan',
                      icon: Icons.search,
                      onPressed: _isLoading ? null : () => _runNissanServiceTool('consult_scan'),
                    ),
                    ActionButton(
                      title: 'CVT Service',
                      icon: Icons.settings,
                      onPressed: _isLoading ? null : () => _runNissanServiceTool('cvt_service'),
                    ),
                    ActionButton(
                      title: 'ProPILOT Cal.',
                      icon: Icons.assistant_navigation,
                      onPressed: _isLoading ? null : () => _runNissanServiceTool('propilot_calibration'),
                    ),
                    ActionButton(
                      title: 'e-POWER Diagnostic',
                      icon: Icons.electric_car,
                      onPressed: _isLoading ? null : () => _runNissanServiceTool('epower_diagnostic'),
                    ),
                    ActionButton(
                      title: 'Intelligent Key',
                      icon: Icons.vpn_key,
                      onPressed: _isLoading ? null : () => _runNissanServiceTool('intelligent_key_programming'),
                    ),
                    ActionButton(
                      title: 'Throttle Cal.',
                      icon: Icons.speed,
                      onPressed: _isLoading ? null : () => _runNissanServiceTool('throttle_body_calibration'),
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
                        'Connect to a Nissan or Infiniti vehicle to access Nissan-specific tools',
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
      case 'cvt transmission temperature':
        return '°C';
      case 'cvt fluid pressure':
        return 'bar';
      case 'cvt pulley ratio':
        return ':1';
      case 'cvt health score':
        return '%';
      case 'propilot system readiness':
        return '%';
      case 'e-power efficiency':
        return '%';
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