import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Enhanced data visualization widget for live OBD-II data
/// Supports multiple chart types: line, gauge, bar
class AdvancedDataVisualizationWidget extends ConsumerWidget {
  final String title;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final DataVisualizationType visualizationType;
  final List<double> historicalData;
  final double? currentValue;
  final Color? accentColor;
  final bool showLegend;
  final Duration dataUpdateInterval;

  const AdvancedDataVisualizationWidget({
    super.key,
    required this.title,
    required this.unit,
    this.minValue,
    this.maxValue,
    this.visualizationType = DataVisualizationType.gauge,
    this.historicalData = const [],
    this.currentValue,
    this.accentColor,
    this.showLegend = true,
    this.dataUpdateInterval = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: _buildVisualization(context),
            ),
            if (showLegend && currentValue != null) ...[
              const SizedBox(height: 16),
              _buildLegend(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (currentValue != null) ...[
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatValue(currentValue!),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getValueColor(context, currentValue!),
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
                ),
              ],
            ],
          ),
        ),
        PopupMenuButton<DataVisualizationType>(
          icon: const Icon(Icons.more_vert),
          onSelected: (type) {
            // TODO: Implement visualization type switching
            // This would require a callback to parent widget
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: DataVisualizationType.gauge,
              child: ListTile(
                leading: Icon(Icons.speed),
                title: Text('Gauge'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: DataVisualizationType.line,
              child: ListTile(
                leading: Icon(Icons.show_chart),
                title: Text('Line Chart'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: DataVisualizationType.bar,
              child: ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('Bar Chart'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: DataVisualizationType.area,
              child: ListTile(
                leading: Icon(Icons.area_chart),
                title: Text('Area Chart'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualization(BuildContext context) {
    switch (visualizationType) {
      case DataVisualizationType.gauge:
        return _buildGaugeChart(context);
      case DataVisualizationType.line:
        return _buildLineChart(context);
      case DataVisualizationType.bar:
        return _buildBarChart(context);
      case DataVisualizationType.area:
        return _buildAreaChart(context);
      default:
        return _buildGaugeChart(context);
    }
  }

  Widget _buildGaugeChart(BuildContext context) {
    if (currentValue == null || minValue == null || maxValue == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: minValue!,
          maximum: maxValue!,
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: minValue!,
              endValue: (maxValue! - minValue!) * 0.6 + minValue!,
              color: Colors.green,
              startWidth: 10,
              endWidth: 10,
            ),
            GaugeRange(
              startValue: (maxValue! - minValue!) * 0.6 + minValue!,
              endValue: (maxValue! - minValue!) * 0.8 + minValue!,
              color: Colors.orange,
              startWidth: 10,
              endWidth: 10,
            ),
            GaugeRange(
              startValue: (maxValue! - minValue!) * 0.8 + minValue!,
              endValue: maxValue!,
              color: Colors.red,
              startWidth: 10,
              endWidth: 10,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: currentValue!,
              needleColor: _getValueColor(context, currentValue!),
              knobStyle: KnobStyle(
                color: _getValueColor(context, currentValue!),
              ),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatValue(currentValue!),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart(BuildContext context) {
    if (historicalData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No historical data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxValue! - minValue!) / 5,
          verticalInterval: historicalData.length / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: historicalData.length / 4,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}s',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxValue! - minValue!) / 4,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatValue(value),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        minX: 0,
        maxX: historicalData.length.toDouble() - 1,
        minY: minValue,
        maxY: maxValue,
        lineBarsData: [
          LineChartBarData(
            spots: historicalData.asMap().entries.map(
              (entry) => FlSpot(entry.key.toDouble(), entry.value),
            ).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                (accentColor ?? Theme.of(context).primaryColor).withOpacity(0.8),
                accentColor ?? Theme.of(context).primaryColor,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (accentColor ?? Theme.of(context).primaryColor).withOpacity(0.3),
                  (accentColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    if (historicalData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Take last 10 data points for bar chart
    final recentData = historicalData.take(10).toList().reversed.toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        minY: minValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_formatValue(rod.toY)} $unit',
                Theme.of(context).textTheme.bodyMedium!,
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatValue(value),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        barGroups: recentData.asMap().entries.map(
          (entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: _getValueColor(context, entry.value),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildAreaChart(BuildContext context) {
    if (historicalData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.area_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No historical data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        minimum: minValue,
        maximum: maxValue,
      ),
      series: <ChartSeries<double, int>>[
        AreaSeries<double, int>(
          dataSource: historicalData.asMap().entries.toList(),
          xValueMapper: (data, _) => data.key,
          yValueMapper: (data, _) => data.value,
          name: title,
          color: (accentColor ?? Theme.of(context).primaryColor).withOpacity(0.3),
          borderColor: accentColor ?? Theme.of(context).primaryColor,
          borderWidth: 2,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.y $unit',
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            context,
            'Current',
            _formatValue(currentValue!),
            _getValueColor(context, currentValue!),
          ),
          if (minValue != null)
            _buildLegendItem(
              context,
              'Min',
              _formatValue(minValue!),
              Colors.green,
            ),
          if (maxValue != null)
            _buildLegendItem(
              context,
              'Max',
              _formatValue(maxValue!),
              Colors.red,
            ),
          if (historicalData.isNotEmpty)
            _buildLegendItem(
              context,
              'Avg',
              _formatValue(historicalData.reduce((a, b) => a + b) / historicalData.length),
              Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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

  Color _getValueColor(BuildContext context, double value) {
    if (accentColor != null) return accentColor!;
    
    if (minValue != null && maxValue != null) {
      final normalizedValue = (value - minValue!) / (maxValue! - minValue!);
      if (normalizedValue <= 0.6) return Colors.green;
      if (normalizedValue <= 0.8) return Colors.orange;
      return Colors.red;
    }
    
    return Theme.of(context).primaryColor;
  }
}

enum DataVisualizationType {
  gauge,
  line,
  bar,
  area,
}