import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/gm_service.dart';
import '../../../core/services/obd_service.dart';
import '../../../shared/models/vehicle_info.dart';
import '../../../shared/widgets/data_card.dart';
import '../../../shared/widgets/action_button.dart';

/// GM-specific tools and diagnostics screen
/// Supports Chevrolet, Cadillac, GMC, and other GM brands
class GMToolsScreen extends ConsumerStatefulWidget {
  const GMToolsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GMToolsScreen> createState() => _GMToolsScreenState();
}

class _GMToolsScreenState extends ConsumerState<GMToolsScreen> {
  late GMService _gmService;
  Map<String, dynamic> _liveData = {};
  bool _isConnected = false;
  bool _isLoading = false;
  String? _statusMessage;
  String _selectedBrand = 'Chevrolet';

  @override
  void initState() {
    super.initState();
    _gmService = GMService(OBDService());
    _checkConnection();
  }

  void _checkConnection() {
    // Check if connected to GM vehicle
    // This would integrate with the main OBD connection service
    setState(() {
      _isConnected = true; // Simulated
    });
  }

  Future<void> _initializeGMService() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing GM service for $_selectedBrand...';
      });

      // In a real implementation, this would get the current vehicle from a provider
      final vehicle = VehicleInfo(
        make: _selectedBrand,
        model: _getDefaultModelForBrand(_selectedBrand),
        year: 2023,
        trim: 'LTZ',
      );

      _gmService.initialize(vehicle);
      
      setState(() {
        _statusMessage = 'GM service initialized successfully for $_selectedBrand';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize GM service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDefaultModelForBrand(String brand) {
    switch (brand.toLowerCase()) {
      case 'chevrolet':
        return 'Silverado 1500';
      case 'cadillac':
        return 'Escalade';
      case 'gmc':
        return 'Sierra 1500';
      default:
        return 'Unknown';
    }
  }

  Future<void> _getGMLiveData() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Retrieving GM live data...';
      });

      final liveData = await _gmService.getGMLiveData();
      
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

  Future<void> _runGMServiceTool(String toolName) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Running $toolName...';
      });

      final result = await _gmService.runGMServiceTool(toolName, {});
      
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

  List<Widget> _getBrandSpecificTools() {
    switch (_selectedBrand.toLowerCase()) {
      case 'chevrolet':
        return [
          ActionButton(
            title: 'AFM Disable',
            icon: Icons.build,
            onPressed: _isLoading ? null : () => _runGMServiceTool('afm_disable'),
          ),
          ActionButton(
            title: 'DFM Calibration',
            icon: Icons.tune,
            onPressed: _isLoading ? null : () => _runGMServiceTool('dfm_calibration'),
          ),
        ];
      case 'cadillac':
        return [
          ActionButton(
            title: 'Super Cruise Update',
            icon: Icons.auto_awesome,
            onPressed: _isLoading ? null : () => _runGMServiceTool('super_cruise_update'),
          ),
          ActionButton(
            title: 'Magnetic Ride Cal.',
            icon: Icons.linear_scale,
            onPressed: _isLoading ? null : () => _runGMServiceTool('magnetic_ride_calibration'),
          ),
        ];
      case 'gmc':
        return [
          ActionButton(
            title: 'MultiPro Service',
            icon: Icons.car_rental,
            onPressed: _isLoading ? null : () => _runGMServiceTool('multipro_service'),
          ),
          ActionButton(
            title: 'AT4 Calibration',
            icon: Icons.terrain,
            onPressed: _isLoading ? null : () => _runGMServiceTool('at4_calibration'),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GM Tools'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Brand selector
          PopupMenuButton<String>(
            initialValue: _selectedBrand,
            onSelected: (brand) {
              setState(() {
                _selectedBrand = brand;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Chevrolet', child: Text('Chevrolet')),
              const PopupMenuItem(value: 'Cadillac', child: Text('Cadillac')),
              const PopupMenuItem(value: 'GMC', child: Text('GMC')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedBrand),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
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
                      _isConnected ? 'Connected to $_selectedBrand Vehicle' : 'Not Connected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (!_isConnected)
                      ElevatedButton(
                        onPressed: _initializeGMService,
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

            // GM Live Data Section
            if (_isConnected) ...[
              Row(
                children: [
                  Text(
                    'GM Live Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _getGMLiveData,
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

              // GM Service Tools
              Row(
                children: [
                  Text(
                    'GM Service Tools',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(_selectedBrand),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    // Common GM tools
                    ActionButton(
                      title: 'ECM Health Check',
                      icon: Icons.health_and_safety,
                      onPressed: _isLoading ? null : () => _runGMServiceTool('ecm_health_check'),
                    ),
                    ActionButton(
                      title: 'Transmission Relearn',
                      icon: Icons.settings,
                      onPressed: _isLoading ? null : () => _runGMServiceTool('transmission_relearn'),
                    ),
                    ActionButton(
                      title: 'BCM Configuration',
                      icon: Icons.electrical_services,
                      onPressed: _isLoading ? null : () => _runGMServiceTool('bcm_configuration'),
                    ),
                    ActionButton(
                      title: 'OnStar Activation',
                      icon: Icons.satellite,
                      onPressed: _isLoading ? null : () => _runGMServiceTool('onstar_activation'),
                    ),
                    ActionButton(
                      title: 'Key Learning',
                      icon: Icons.vpn_key,
                      onPressed: _isLoading ? null : () => _runGMServiceTool('key_learning'),
                    ),
                    ..._getBrandSpecificTools(),
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
                        'Connect to a GM vehicle to access GM-specific tools',
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
      case 'afm cylinder deactivation status':
        return '';
      case 'transmission adaptive pressure':
        return 'PSI';
      case 'supercharger boost pressure':
        return 'PSI';
      case 'air suspension height':
        return 'in';
      case 'engine rpm':
        return 'RPM';
      case 'vehicle speed':
        return 'MPH';
      case 'coolant temperature':
        return '°F';
      case 'fuel level':
        return '%';
      case 'fuel management efficiency':
        return '%';
      case 'suspension performance score':
        return '/100';
      case 'super cruise readiness':
        return '%';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _gmService.dispose();
    super.dispose();
  }
}