import 'dart:async';

import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sim/temperature_simulator.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sources/temperature_source.dart';

class SimulatedTemperatureSource implements TemperatureSource {
  SimulatedTemperatureSource({
    required TemperatureSimulator simulator,
    required SimulatorScenario scenario,
    required int sampleRateHz,
  }) : _simulator = simulator,
       _scenario = scenario,
       _sampleRateHz = sampleRateHz;

  final TemperatureSimulator _simulator;
  final int _sampleRateHz;
  final StreamController<TemperatureSample> _controller =
      StreamController<TemperatureSample>.broadcast();

  SimulatorScenario _scenario;
  Timer? _timer;
  DateTime? _scenarioStartedAt;

  @override
  Stream<TemperatureSample> stream() => _controller.stream;

  @override
  Future<void> start() async {
    if (_timer != null) return;
    _scenarioStartedAt = DateTime.now();
    _emit();
    _timer = Timer.periodic(
      Duration(milliseconds: (1000 / _sampleRateHz).round()),
      (_) => _emit(),
    );
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  void setScenario(SimulatorScenario scenario) {
    _scenario = scenario;
    _scenarioStartedAt = DateTime.now();
  }

  void _emit() {
    final startedAt = _scenarioStartedAt;
    if (startedAt == null || _controller.isClosed) return;

    final now = DateTime.now();
    final elapsed = now.difference(startedAt);
    final value = _simulator.valueFor(_scenario, elapsed);
    _controller.add(TemperatureSample(timestamp: now, rawCelsius: value));
  }
}
