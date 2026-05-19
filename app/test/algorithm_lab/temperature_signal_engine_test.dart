import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/processing/temperature_signal_engine.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sim/temperature_simulator.dart';

void main() {
  group('TemperatureSignalEngine', () {
    test('noise scenario keeps thermal influence idle for at least 95%', () {
      final frames = _runScenario(
        scenario: SimulatorScenario.noise,
        seconds: 120,
      );
      final active = frames
          .where((frame) => frame.thermalInfluenceLevel > 0)
          .length;
      final idleRatio = 1.0 - (active / frames.length);
      expect(idleRatio, greaterThanOrEqualTo(0.95));
    });

    test(
      'tap scenario raises thermal influence within 3 samples after onset',
      () {
        final frames = _runScenario(
          scenario: SimulatorScenario.tap,
          seconds: 8,
        );
        const onsetIndex = 10; // 1.0s at 10Hz
        var index = -1;
        for (var i = onsetIndex; i < frames.length; i += 1) {
          if (frames[i].thermalInfluenceLevel > 0) {
            index = i;
            break;
          }
        }

        expect(index, isNot(-1));
        expect(index - onsetIndex, lessThanOrEqualTo(3));
      },
    );

    test(
      'hold scenario reaches and sustains higher thermal influence levels',
      () {
        final frames = _runScenario(
          scenario: SimulatorScenario.hold,
          seconds: 12,
        );
        final sustained = <AlgorithmFrame>[];
        for (var i = 22; i < 45; i += 1) {
          sustained.add(frames[i]);
        }

        final maxLevel = sustained
            .map((frame) => frame.thermalInfluenceLevel)
            .reduce((a, b) => a > b ? a : b);
        final activeRatio =
            sustained
                .where((frame) => frame.thermalInfluenceLevel >= 3)
                .length /
            sustained.length;

        expect(maxLevel, greaterThanOrEqualTo(4));
        expect(activeRatio, greaterThan(0.55));
      },
    );

    test('drift scenario does not stay permanently active', () {
      final frames = _runScenario(
        scenario: SimulatorScenario.drift,
        seconds: 120,
      );
      final tail = frames.sublist(900); // last 30 seconds
      final pressedRatio =
          tail.where((frame) => frame.thermalInfluenceLevel > 0).length /
          tail.length;
      expect(pressedRatio, lessThanOrEqualTo(0.65));
    });

    test('press triggers when accel threshold is met', () {
      final config = AlgorithmLabConfig.defaults().copyWith(
        smoothAlpha: 0.95,
        buttonAccelThresholdCps2: 1.0,
      );
      final values = <double>[
        ...List<double>.filled(20, 22.0),
        22.30,
        22.30,
        22.30,
      ];
      final frames = _runValues(
        values: values,
        engine: TemperatureSignalEngine(),
        config: config,
      );
      final downIndices = _downIndices(frames);

      expect(downIndices, hasLength(1));
      final downIndex = downIndices.first;
      expect(frames[downIndex].buttonIsPressed, isTrue);
      expect(frames[downIndex + 1].buttonIsPressed, isFalse);
    });

    test('press does not trigger when accel is below threshold', () {
      final config = AlgorithmLabConfig.defaults().copyWith(
        smoothAlpha: 0.95,
        buttonAccelThresholdCps2: 1.0,
      );
      final values = <double>[
        ...List<double>.filled(20, 22.0),
        ...List<double>.generate(40, (i) => 22.0 + ((i + 1) * 0.005)),
      ];
      final frames = _runValues(
        values: values,
        engine: TemperatureSignalEngine(),
        config: config,
      );

      expect(_downIndices(frames), isEmpty);
    });

    test(
      'press does not trigger when accel stays below threshold during cooling',
      () {
        final config = AlgorithmLabConfig.defaults().copyWith(
          smoothAlpha: 0.95,
          buttonAccelThresholdCps2: 1.0,
        );
        final values = <double>[
          ...List<double>.filled(20, 22.0),
          21.90,
          21.80,
          21.70,
          21.60,
          21.50,
          21.40,
          21.30,
          21.20,
        ];
        final frames = _runValues(
          values: values,
          engine: TemperatureSignalEngine(),
          config: config,
        );

        expect(_downIndices(frames), isEmpty);
      },
    );

    test('debounce blocks repeated presses inside cooldown window', () {
      final config = AlgorithmLabConfig.defaults().copyWith(
        smoothAlpha: 0.95,
        buttonAccelThresholdCps2: 1.0,
        buttonDebounceMs: 800,
      );
      final values = <double>[
        ...List<double>.filled(20, 22.0),
        22.30, // first press candidate
        22.30,
        22.30, // trigger drops false -> re-arm
        22.60, // second candidate, inside debounce window
        22.60,
        22.60,
      ];
      final frames = _runValues(
        values: values,
        engine: TemperatureSignalEngine(),
        config: config,
      );

      expect(_downIndices(frames), hasLength(1));
    });

    test('re-arm is required before a second press can fire', () {
      final config = AlgorithmLabConfig.defaults().copyWith(
        smoothAlpha: 0.95,
        buttonAccelThresholdCps2: 0.10,
        buttonDebounceMs: 200,
      );

      final values = <double>[...List<double>.filled(20, 22.0)];
      var temp = 22.0;
      var step = 0.02;
      for (var i = 0; i < 12; i += 1) {
        temp += step;
        step += 0.02;
        values.add(temp);
      }

      final frames = _runValues(
        values: values,
        engine: TemperatureSignalEngine(),
        config: config,
      );

      // Trigger condition stays true through the accelerating ramp,
      // so only the first armed press should emit.
      expect(_downIndices(frames), hasLength(1));
    });

    test('re-arm plus elapsed cooldown allows next press', () {
      final config = AlgorithmLabConfig.defaults().copyWith(
        smoothAlpha: 0.95,
        buttonAccelThresholdCps2: 1.0,
        buttonDebounceMs: 800,
      );
      final values = <double>[
        ...List<double>.filled(20, 22.0),
        22.30, // press 1
        ...List<double>.filled(10, 22.30), // re-arm + wait > 800ms
        22.65, // press 2
        22.65,
      ];
      final frames = _runValues(
        values: values,
        engine: TemperatureSignalEngine(),
        config: config,
      );

      expect(_downIndices(frames), hasLength(2));
    });

    test('noise scenario press rate remains bounded', () {
      final frames = _runScenario(
        scenario: SimulatorScenario.noise,
        seconds: 120,
        config: AlgorithmLabConfig.defaults().copyWith(
          smoothAlpha: 0.20,
          buttonAccelThresholdCps2: 1.0,
        ),
      );

      final spuriousDown = _downIndices(frames).length;
      expect(spuriousDown, lessThan(200));
    });

    test(
      'hot-day inversion (ambient > skin+deadband) uses cooling as press',
      () {
        final config = AlgorithmLabConfig.defaults();
        final engine = TemperatureSignalEngine();
        engine.setCalibrationProfile(
          CalibrationProfile(
            deviceKey: 'simulator',
            ambientC: 39.0,
            skinReferenceC: 35.0,
            deadbandC: 1.0,
            inferredPolarity: PressPolarity.coolingIsPress,
            effectivePolarity: PressPolarity.coolingIsPress,
            mode: PolarityMode.autoFromAmbient,
            calibratedAt: DateTime(2026, 1, 1),
          ),
        );

        final values = <double>[
          ...List<double>.filled(15, 39.0),
          38.6,
          38.1,
          37.5,
          37.0,
          36.8,
          36.5,
        ];
        final frames = _runValues(
          values: values,
          engine: engine,
          config: config,
        );

        expect(frames.last.activePolarity, PressPolarity.coolingIsPress);
        expect(_downIndices(frames), isNotEmpty);
      },
    );

    test('deadband fallback defaults to warming-as-press', () {
      final config = AlgorithmLabConfig.defaults();
      final engine = TemperatureSignalEngine();
      engine.setCalibrationProfile(
        CalibrationProfile(
          deviceKey: 'simulator',
          ambientC: 35.4,
          skinReferenceC: 35.0,
          deadbandC: 1.0,
          inferredPolarity: PressPolarity.warmingIsPress,
          effectivePolarity: PressPolarity.warmingIsPress,
          mode: PolarityMode.autoFromAmbient,
          calibratedAt: DateTime(2026, 1, 1),
        ),
      );

      final values = <double>[
        ...List<double>.filled(15, 35.4),
        36.2,
        36.9,
        37.3,
        37.5,
      ];
      final frames = _runValues(values: values, engine: engine, config: config);
      expect(frames.last.activePolarity, PressPolarity.warmingIsPress);
      expect(_downIndices(frames), isNotEmpty);
    });

    test('all output signals are clamped in valid ranges', () {
      final frames = _runScenario(
        scenario: SimulatorScenario.mixed,
        seconds: 120,
      );
      for (final frame in frames) {
        expect(frame.lunarAccelNorm, inInclusiveRange(-1.0, 1.0));
        expect(frame.pitchNorm, inInclusiveRange(0.0, 1.0));
        expect(frame.volumeNorm, inInclusiveRange(0.0, 1.0));
        expect(frame.thermalInfluenceLevel, inInclusiveRange(0, 5));
      }
    });
  });
}

List<AlgorithmFrame> _runScenario({
  required SimulatorScenario scenario,
  required int seconds,
  AlgorithmLabConfig? config,
}) {
  config ??= AlgorithmLabConfig.defaults();
  final engine = TemperatureSignalEngine();
  final simulator = TemperatureSimulator();
  final values = <double>[];
  final totalSamples = seconds * 10;
  for (var i = 0; i < totalSamples; i += 1) {
    final elapsed = Duration(milliseconds: i * 100);
    values.add(simulator.valueFor(scenario, elapsed));
  }
  return _runValues(values: values, engine: engine, config: config);
}

List<AlgorithmFrame> _runValues({
  required List<double> values,
  required TemperatureSignalEngine engine,
  required AlgorithmLabConfig config,
}) {
  final frames = <AlgorithmFrame>[];
  var timestamp = DateTime(2026, 1, 1, 0, 0, 0);
  for (final value in values) {
    final sample = TemperatureSample(timestamp: timestamp, rawCelsius: value);
    frames.add(engine.ingest(sample, config));
    timestamp = timestamp.add(const Duration(milliseconds: 100));
  }
  return frames;
}

List<int> _downIndices(List<AlgorithmFrame> frames) {
  return frames
      .asMap()
      .entries
      .where(
        (entry) => entry.value.buttonEvent?.type == ButtonEventType.buttonDown,
      )
      .map((entry) => entry.key)
      .toList();
}
