import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/features/recording/recording_service.dart';

class LiveChartWidget extends ConsumerStatefulWidget {
  const LiveChartWidget({super.key});

  @override
  ConsumerState<LiveChartWidget> createState() => _LiveChartWidgetState();
}

class _LiveChartWidgetState extends ConsumerState<LiveChartWidget> {
  final List<FlSpot> _points = [];
  final int _maxPoints = 100;
  StreamSubscription? _subscription;

  double _minX = 0;
  double _maxX = 100;
  double _minY = 0;
  double _maxY = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    final recordingService = ref.read(recordingServiceProvider.notifier);
    _subscription = recordingService.readingsStream.listen((reading) {
      if (!mounted) return;
      setState(() {
        final x = DateTime.now().millisecondsSinceEpoch.toDouble();
        final y = reading.value;

        _points.add(FlSpot(x, y));
        if (_points.length > _maxPoints) {
          _points.removeAt(0);
        }
        _recomputeBounds();
      });
    });
  }

  void _recomputeBounds() {
    if (_points.isEmpty) return;
    _minX = _points.first.x;
    _maxX = _points.last.x;
    if (_maxX - _minX < 5000) {
      _maxX = _minX + 5000;
    }

    var lo = _points.first.y;
    var hi = _points.first.y;
    for (final p in _points) {
      if (p.y < lo) lo = p.y;
      if (p.y > hi) hi = p.y;
    }
    _minY = lo;
    _maxY = hi;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_points.isEmpty) {
      return const Center(child: Text('Waiting for data...'));
    }
    final cs = Theme.of(context).colorScheme;
    final gridColor = cs.outlineVariant;
    final axisLabelStyle = TextStyle(
      color: cs.onSurfaceVariant,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    final yPad = math.max((_maxY - _minY) * 0.1, 0.2);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            clipData: const FlClipData.all(),
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
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
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
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: gridColor, width: 1),
            ),
            minX: _minX,
            maxX: _maxX,
            minY: _minY - yPad,
            maxY: _maxY + yPad,
            lineBarsData: [
              LineChartBarData(
                spots: _points,
                isCurved: false,
                color: cs.primary,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary.withValues(alpha: 0.18),
                      cs.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

