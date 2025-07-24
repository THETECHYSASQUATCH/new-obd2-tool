import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveDataWidget extends ConsumerWidget {
  final String title;
  final StateNotifierProvider<dynamic, double?> provider;
  final String unit;
  final double? minValue;
  final double? maxValue;

  const LiveDataWidget({
    super.key,
    required this.title,
    required this.provider,
    required this.unit,
    this.minValue,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Request update for this specific parameter
                    ref.read(provider.notifier).requestUpdate();
                  },
                  tooltip: 'Refresh $title',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildValueDisplay(context, value),
            if (minValue != null && maxValue != null && value != null)
              ...[
                const SizedBox(height: 12),
                _buildProgressBar(value!, minValue!, maxValue!),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildValueDisplay(BuildContext context, double? value) {
    if (value == null) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Reading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _formatValue(value),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getValueColor(context, value),
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value, double min, double max) {
    final normalizedValue = ((value - min) / (max - min)).clamp(0.0, 1.0);
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: normalizedValue,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getValueColor(null, value),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatValue(min),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _formatValue(max),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  Color _getValueColor(BuildContext? context, double value) {
    // Define warning thresholds based on parameter type
    if (title.contains('RPM')) {
      if (value > 6000) return Colors.red;
      if (value > 4000) return Colors.orange;
      return Colors.green;
    } else if (title.contains('Speed')) {
      if (value > 120) return Colors.red;
      if (value > 80) return Colors.orange;
      return Colors.green;
    } else if (title.contains('Temp')) {
      if (value > 100) return Colors.red;
      if (value > 90) return Colors.orange;
      return Colors.green;
    } else if (title.contains('Load')) {
      if (value > 80) return Colors.red;
      if (value > 60) return Colors.orange;
      return Colors.green;
    }
    
    return context != null ? Theme.of(context).primaryColor : Colors.blue;
  }