import 'dart:math';

import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';

class TemperatureSimulator {
  static const double baselineCelsius = 22.0;

  double valueFor(SimulatorScenario scenario, Duration elapsed) {
    final seconds = elapsed.inMilliseconds / 1000.0;
    switch (scenario) {
      case SimulatorScenario.noise:
        return _noiseOnly(seconds);
      case SimulatorScenario.tap:
        return _tapScenario(seconds);
      case SimulatorScenario.hold:
        return _holdScenario(seconds);
      case SimulatorScenario.drift:
        return _driftScenario(seconds);
      case SimulatorScenario.mixed:
        return _mixedScenario(seconds);
    }
  }

  double _noiseOnly(double t) {
    return baselineCelsius + _noise(t);
  }

  double _tapScenario(double t) {
    final local = t % 4.0;
    var pulse = 0.0;
    if (local >= 1.0 && local < 1.55) {
      final x = (local - 1.0) / 0.55;
      pulse = 1.8 * sin(pi * x);
    }
    return baselineCelsius + _noise(t) + pulse;
  }

  double _holdScenario(double t) {
    final local = t % 7.0;
    var hold = 0.0;
    if (local >= 1.0 && local < 1.8) {
      hold = 1.9 * ((local - 1.0) / 0.8);
    } else if (local >= 1.8 && local < 4.8) {
      hold = 1.9;
    } else if (local >= 4.8 && local < 5.7) {
      hold = 1.9 * (1.0 - ((local - 4.8) / 0.9));
    }
    return baselineCelsius + _noise(t) + hold;
  }

  double _driftScenario(double t) {
    final drift = 0.02 * t;
    final slowWave = 0.12 * sin(2 * pi * 0.05 * t);
    final local = t % 9.0;
    var touch = 0.0;
    if (local > 3.0 && local < 3.8) {
      final x = (local - 3.0) / 0.8;
      touch = 0.35 * sin(pi * x);
    }
    return baselineCelsius + _noise(t) + drift + slowWave + touch;
  }

  double _mixedScenario(double t) {
    const segment = 20.0;
    final index = ((t / segment).floor()) % 4;
    final local = t % segment;
    switch (index) {
      case 0:
        return _noiseOnly(local);
      case 1:
        return _tapScenario(local);
      case 2:
        return _holdScenario(local);
      default:
        return _driftScenario(local);
    }
  }

  double _noise(double t) {
    return (0.04 * sin(2 * pi * 1.7 * t)) +
        (0.03 * sin(2 * pi * 0.47 * t + 0.9)) +
        (0.02 * sin(2 * pi * 3.1 * t + 1.8));
  }
}
