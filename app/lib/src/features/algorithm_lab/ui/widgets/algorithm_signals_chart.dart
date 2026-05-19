import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/ui/theme/app_theme.dart';

class AlgorithmSignalsChart extends StatelessWidget {
  const AlgorithmSignalsChart({super.key, required this.frames});

  final List<AlgorithmFrame> frames;

  @override
  Widget build(BuildContext context) {
    if (frames.isEmpty) {
      return const Center(child: Text('Waiting for samples...'));
    }

    final rawSpots = <FlSpot>[];
    final smoothSpots = <FlSpot>[];
    final baselineSpots = <FlSpot>[];
    final deltaSpots = <FlSpot>[];
    final values = <double>[];

    for (var i = 0; i < frames.length; i += 1) {
      final x = i.toDouble();
      final frame = frames[i];
      rawSpots.add(FlSpot(x, frame.rawCelsius));
      smoothSpots.add(FlSpot(x, frame.smoothedCelsius));
      baselineSpots.add(FlSpot(x, frame.baselineCelsius));
      deltaSpots.add(FlSpot(x, frame.deltaCelsius));

      values.add(frame.rawCelsius);
      values.add(frame.smoothedCelsius);
      values.add(frame.baselineCelsius);
      values.add(frame.deltaCelsius);
    }

    var minY = values.reduce(math.min);
    var maxY = values.reduce(math.max);
    final pad = math.max((maxY - minY) * 0.08, 0.1);
    minY -= pad;
    maxY += pad;

    final cs = Theme.of(context).colorScheme;
    final gridColor = cs.outlineVariant;
    final axisLabelStyle = TextStyle(
      color: cs.onSurfaceVariant,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (frames.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              lineTouchData: const LineTouchData(enabled: true),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: gridColor,
                  strokeWidth: 0.6,
                  dashArray: const [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: axisLabelStyle,
                      ),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        value.toStringAsFixed(1),
                        style: axisLabelStyle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: gridColor, width: 1),
              ),
              lineBarsData: [
                _line(rawSpots, AppColors.signalPrimary, 1.5),
                _line(smoothSpots, AppColors.signalSecondary, 2.0),
                _line(baselineSpots, AppColors.signalTertiary, 2.0),
                _line(deltaSpots, AppColors.signalNeutral, 1.5),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _LegendItem(color: AppColors.signalPrimary, label: 'Raw'),
            _LegendItem(color: AppColors.signalSecondary, label: 'Smoothed'),
            _LegendItem(color: AppColors.signalTertiary, label: 'Baseline'),
            _LegendItem(color: AppColors.signalNeutral, label: 'Delta'),
          ],
        ),
      ],
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color, double width) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: width,
      dotData: const FlDotData(show: false),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
