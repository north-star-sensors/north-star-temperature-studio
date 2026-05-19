import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/features/recording/recording_service.dart';

class CurrentTemperatureWidget extends ConsumerStatefulWidget {
  const CurrentTemperatureWidget({super.key});

  @override
  ConsumerState<CurrentTemperatureWidget> createState() =>
      _CurrentTemperatureWidgetState();
}

class _CurrentTemperatureWidgetState
    extends ConsumerState<CurrentTemperatureWidget> {
  double? _currentValue;
  StreamSubscription? _subscription;

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
        _currentValue = reading.value;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentValue == null) {
      return const SizedBox.shrink(); // Hide if no data yet
    }

    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      color: cs.surfaceContainerHighest,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Current Temperature',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentValue!.toStringAsFixed(2)}°C',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: cs.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
