import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sim/temperature_simulator.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sources/simulated_temperature_source.dart';

void main() {
  group('TemperatureSimulator', () {
    test('simulated source emits near 10Hz cadence', () async {
      final source = SimulatedTemperatureSource(
        simulator: TemperatureSimulator(),
        scenario: SimulatorScenario.noise,
        sampleRateHz: 10,
      );

      final timestamps = <DateTime>[];
      final done = Completer<void>();
      late StreamSubscription sub;
      sub = source.stream().listen((sample) {
        timestamps.add(sample.timestamp);
        if (timestamps.length >= 12 && !done.isCompleted) {
          done.complete();
        }
      });

      await source.start();
      await done.future.timeout(const Duration(seconds: 3));

      await sub.cancel();
      await source.dispose();

      final intervalsMs = <int>[];
      for (var i = 1; i < timestamps.length; i += 1) {
        intervalsMs.add(
          timestamps[i].difference(timestamps[i - 1]).inMilliseconds,
        );
      }
      final averageMs =
          intervalsMs.reduce((a, b) => a + b) / intervalsMs.length;
      expect(averageMs, inInclusiveRange(70, 150));
    });

    test('scenario envelopes match expected behavior', () {
      final simulator = TemperatureSimulator();
      final baseline = TemperatureSimulator.baselineCelsius;

      final tapIdle = simulator.valueFor(
        SimulatorScenario.tap,
        const Duration(milliseconds: 200),
      );
      final tapPeak = simulator.valueFor(
        SimulatorScenario.tap,
        const Duration(milliseconds: 1250),
      );
      expect(tapPeak, greaterThan(tapIdle + 1.0));

      final holdHigh = simulator.valueFor(
        SimulatorScenario.hold,
        const Duration(milliseconds: 2600),
      );
      final holdStillHigh = simulator.valueFor(
        SimulatorScenario.hold,
        const Duration(milliseconds: 4200),
      );
      expect(holdHigh, greaterThan(baseline + 1.2));
      expect(holdStillHigh, greaterThan(baseline + 1.1));

      final driftEarly = simulator.valueFor(
        SimulatorScenario.drift,
        const Duration(seconds: 5),
      );
      final driftLate = simulator.valueFor(
        SimulatorScenario.drift,
        const Duration(seconds: 25),
      );
      expect(driftLate, greaterThan(driftEarly + 0.25));
    });
  });
}
