import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveDataWidget extends ConsumerStatefulWidget {
  const LiveDataWidget({super.key});

  @override
  ConsumerState<LiveDataWidget> createState() => _LiveDataWidgetState();
}

class _LiveDataWidgetState extends ConsumerState<LiveDataWidget> {
  bool _isStreaming = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: _buildLiveDataGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Live Data Stream',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isStreaming = !_isStreaming;
            });
            // TODO: Implement live data streaming
          },
          icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
          label: Text(_isStreaming ? 'Stop' : 'Start'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isStreaming ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveDataGrid(BuildContext context) {
    // TODO: Replace with actual live data from state management
    final mockData = [
      _LiveDataItem(
        name: 'Engine RPM',
        value: '2150',
        unit: 'rpm',
        min: 0,
        max: 8000,
        current: 2150,
      ),
      _LiveDataItem(
        name: 'Vehicle Speed',
        value: '65',
        unit: 'mph',
        min: 0,
        max: 200,
        current: 65,
      ),
      _LiveDataItem(
        name: 'Engine Coolant Temp',
        value: '195',
        unit: '°F',
        min: 32,
        max: 250,
        current: 195,
      ),
      _LiveDataItem(
        name: 'Throttle Position',
        value: '25',
        unit: '%',
        min: 0,
        max: 100,
        current: 25,
      ),
      _LiveDataItem(
        name: 'Intake Air Temp',
        value: '75',
        unit: '°F',
        min: 32,
        max: 200,
        current: 75,
      ),
      _LiveDataItem(
        name: 'Fuel Pressure',
        value: '45',
        unit: 'psi',
        min: 0,
        max: 100,
        current: 45,
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: mockData.length,
      itemBuilder: (context, index) {
        final dataItem = mockData[index];
        return _buildDataCard(context, dataItem);
      },
    );
  }

  Widget _buildDataCard(BuildContext context, _LiveDataItem item) {
    final progress = (item.current - item.min) / (item.max - item.min);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isStreaming 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item.unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progress),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.min}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${item.max}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.green;
    if (progress < 0.7) return Colors.orange;
    return Colors.red;
  }
}

class _LiveDataItem {
  final String name;
  final String value;
  final String unit;
  final double min;
  final double max;
  final double current;

  _LiveDataItem({
    required this.name,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.current,
  });
}