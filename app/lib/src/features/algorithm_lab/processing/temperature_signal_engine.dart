import 'dart:math';

import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';

class TemperatureSignalEngine {
  DateTime? _lastTimestamp;
  double? _smoothed;
  double? _lastSmoothed;
  double? _lastButtonDirectedSlope;
  double? _baseline;
  double _motionEma = 0.0;
  double _lastLevelNorm = 0.0;
  int _stableThermalLevel = 0;
  int? _pendingLevel;
  int _pendingLevelSamples = 0;
  double _noiseGate = 0.15;
  bool _pressArmed = true;
  DateTime? _lastButtonDownAt;
  CalibrationProfile? _calibrationProfile;

  final _absDerivativeWindow = _RollingWindow();
  final _absDeltaWindow = _RollingWindow();
  final _positiveDeltaWindow = _RollingWindow();
  final _levelNormWindow = _RollingWindow();

  void setCalibrationProfile(CalibrationProfile? profile) {
    _calibrationProfile = profile;
  }

  AlgorithmFrame ingest(
    TemperatureSample sample,
    AlgorithmLabConfig rawConfig,
  ) {
    final config = rawConfig.clamped();
    final activePolarity = _resolvePolarity(config);
    final polaritySign = activePolarity == PressPolarity.warmingIsPress
        ? 1.0
        : -1.0;

    final dt = _computeDt(sample.timestamp, config.sampleRateHz);
    final smoothed = _smooth(sample.rawCelsius, config.smoothAlpha);
    final previousSmoothed = _lastSmoothed;
    _lastSmoothed = smoothed;
    _lastTimestamp = sample.timestamp;

    final dTdt = previousSmoothed == null
        ? 0.0
        : (smoothed - previousSmoothed) / dt;
    final absDerivative = dTdt.abs();
    _absDerivativeWindow.push(
      absDerivative,
      maxLength: config.quantileWindowSamples,
    );
    _motionEma = _motionEma == 0.0
        ? absDerivative
        : ((0.30 * absDerivative) + (0.70 * _motionEma));
    final derivativeScale = max(_absDerivativeWindow.quantile(0.95), 0.05);
    final motionNorm = _clamp01(_motionEma / derivativeScale);

    final buttonDirectedSlope = polaritySign * dTdt;
    final previousDirectedSlope = _lastButtonDirectedSlope;
    final buttonDirectedAccel = previousDirectedSlope == null
        ? 0.0
        : (buttonDirectedSlope - previousDirectedSlope) / dt;
    _lastButtonDirectedSlope = buttonDirectedSlope;

    _baseline ??= smoothed;
    final isActive = _lastLevelNorm > _noiseGate;
    final preUpdateDirectedDelta = polaritySign * (smoothed - _baseline!);
    var baselineAlpha = isActive
        ? config.baselineAlphaActive
        : config.baselineAlphaIdle;
    if (isActive && _motionEma < 0.35 && preUpdateDirectedDelta < 1.2) {
      baselineAlpha = max(baselineAlpha, config.baselineAlphaIdle * 0.85);
    }
    final baseline = _baseline! + (baselineAlpha * (smoothed - _baseline!));
    _baseline = baseline;

    final rawDelta = smoothed - baseline;
    final directedDelta = polaritySign * rawDelta;
    final buttonDirectedDelta = directedDelta;

    _absDeltaWindow.push(
      directedDelta.abs(),
      maxLength: config.quantileWindowSamples,
    );
    if (directedDelta > 0) {
      _positiveDeltaWindow.push(
        directedDelta,
        maxLength: config.quantileWindowSamples,
      );
    } else {
      _positiveDeltaWindow.trim(config.quantileWindowSamples);
    }

    final scaleAbsDelta = max(_absDeltaWindow.quantile(0.95), 0.08);
    final scalePosDelta = max(_positiveDeltaWindow.quantile(0.95), 0.28);
    final deltaNormSigned = (directedDelta / scaleAbsDelta)
        .clamp(-1.0, 1.0)
        .toDouble();
    final levelNorm = _clamp01(max(directedDelta, 0.0) / scalePosDelta);
    _lastLevelNorm = levelNorm;

    _levelNormWindow.push(levelNorm, maxLength: config.quantileWindowSamples);
    final thresholds = _buildThresholds(config.quantileWindowSamples);
    final motionAwareIdleFloor = _motionEma < 0.20 ? 0.35 : 0.15;
    _noiseGate = max(thresholds.q10, motionAwareIdleFloor);

    final targetLevel = _levelFromNorm(levelNorm, thresholds, _noiseGate);
    final hysteresisLevel = _applyHysteresis(
      currentLevel: _stableThermalLevel,
      targetLevel: targetLevel,
      levelNorm: levelNorm,
      thresholds: thresholds,
      hysteresis: config.levelHysteresis,
    );

    final previousLevel = _stableThermalLevel;
    final stableLevel = _applyDebounce(hysteresisLevel, config.debounceSamples);
    _stableThermalLevel = stableLevel;

    ThermalContactEvent? thermalContactEvent;
    if (stableLevel != previousLevel) {
      if (previousLevel == 0 && stableLevel > 0) {
        thermalContactEvent = ThermalContactEvent(
          timestamp: sample.timestamp,
          type: ThermalContactEventType.contactStart,
          level: stableLevel,
        );
      } else if (previousLevel > 0 && stableLevel == 0) {
        thermalContactEvent = ThermalContactEvent(
          timestamp: sample.timestamp,
          type: ThermalContactEventType.contactEnd,
          level: 0,
        );
      } else {
        thermalContactEvent = ThermalContactEvent(
          timestamp: sample.timestamp,
          type: ThermalContactEventType.intensityChange,
          level: stableLevel,
        );
      }
    }

    final buttonUpdate = _updateButtonState(
      sample: sample,
      config: config,
      directedAccel: buttonDirectedAccel,
    );
    final buttonEvent = buttonUpdate.event;

    final lunarAccelNorm = _signedPow(deltaNormSigned, config.accelGamma);
    final pitchNorm = _clamp01(pow(levelNorm, config.pitchGamma).toDouble());
    final pitchHz =
        config.pitchMinHz +
        (pitchNorm * (config.pitchMaxHz - config.pitchMinHz));
    final volumeNorm = _clamp01(pow(motionNorm, config.volumeGamma).toDouble());

    return AlgorithmFrame(
      timestamp: sample.timestamp,
      rawCelsius: sample.rawCelsius,
      smoothedCelsius: smoothed,
      baselineCelsius: baseline,
      deltaCelsius: rawDelta,
      deltaNormSigned: deltaNormSigned,
      levelNorm: levelNorm,
      motionNorm: motionNorm,
      thermalInfluenceLevel: stableLevel,
      lunarAccelNorm: lunarAccelNorm,
      pitchNorm: pitchNorm,
      pitchHz: pitchHz,
      volumeNorm: volumeNorm,
      buttonIsPressed: buttonUpdate.buttonIsPressed,
      activePolarity: activePolarity,
      ambientEstimateC: _calibrationProfile?.ambientEstimateC ?? smoothed,
      ambientTrackingActive: false,
      polarityPendingSwitch: false,
      buttonDirectedDeltaC: buttonDirectedDelta,
      directedSlopeCps: buttonDirectedSlope,
      directedAccelCps2: buttonDirectedAccel,
      thermalContactEvent: thermalContactEvent,
      buttonEvent: buttonEvent,
    );
  }

  void recalibrate(double currentTemp) {
    _smoothed = currentTemp;
    _lastSmoothed = currentTemp;
    _lastButtonDirectedSlope = 0.0;
    _baseline = currentTemp;
    _lastTimestamp = null;
    _motionEma = 0.0;
    _lastLevelNorm = 0.0;
    _stableThermalLevel = 0;
    _pendingLevel = null;
    _pendingLevelSamples = 0;
    _noiseGate = 0.15;
    _pressArmed = true;
    _lastButtonDownAt = null;
    _absDerivativeWindow.clear();
    _absDeltaWindow.clear();
    _positiveDeltaWindow.clear();
    _levelNormWindow.clear();
  }

  void reset() {
    _smoothed = null;
    _lastSmoothed = null;
    _lastButtonDirectedSlope = null;
    _baseline = null;
    _lastTimestamp = null;
    _motionEma = 0.0;
    _lastLevelNorm = 0.0;
    _stableThermalLevel = 0;
    _pendingLevel = null;
    _pendingLevelSamples = 0;
    _noiseGate = 0.15;
    _pressArmed = true;
    _lastButtonDownAt = null;
    _absDerivativeWindow.clear();
    _absDeltaWindow.clear();
    _positiveDeltaWindow.clear();
    _levelNormWindow.clear();
  }

  PressPolarity _resolvePolarity(AlgorithmLabConfig config) {
    if (config.polarityMode == PolarityMode.manualOverride) {
      return config.manualPolarity;
    }
    return _calibrationProfile?.effectivePolarity ??
        PressPolarity.warmingIsPress;
  }

  _ButtonUpdate _updateButtonState({
    required TemperatureSample sample,
    required AlgorithmLabConfig config,
    required double directedAccel,
  }) {
    final triggerCondition = directedAccel >= config.buttonAccelThresholdCps2;

    if (!_pressArmed && !triggerCondition) {
      _pressArmed = true;
    }

    if (!triggerCondition || !_pressArmed) {
      return const _ButtonUpdate(event: null, buttonIsPressed: false);
    }

    final lastDownAt = _lastButtonDownAt;
    final inDebounceLockout =
        lastDownAt != null &&
        sample.timestamp.difference(lastDownAt).inMilliseconds <
            config.buttonDebounceMs;
    if (inDebounceLockout) {
      return const _ButtonUpdate(event: null, buttonIsPressed: false);
    }

    _pressArmed = false;
    _lastButtonDownAt = sample.timestamp;
    return _ButtonUpdate(
      event: ButtonEvent(
        timestamp: sample.timestamp,
        type: ButtonEventType.buttonDown,
        isPressed: true,
      ),
      buttonIsPressed: true,
    );
  }

  double _computeDt(DateTime timestamp, int sampleRateHz) {
    final previous = _lastTimestamp;
    if (previous == null) {
      return 1.0 / sampleRateHz;
    }

    final raw = timestamp.difference(previous).inMicroseconds / 1000000.0;
    if (raw <= 0) {
      return 1.0 / sampleRateHz;
    }
    return raw.clamp(0.05, 0.25).toDouble();
  }

  double _smooth(double raw, double alpha) {
    if (_smoothed == null) {
      _smoothed = raw;
      return raw;
    }

    final smoothed = (alpha * raw) + ((1.0 - alpha) * _smoothed!);
    _smoothed = smoothed;
    return smoothed;
  }

  _Thresholds _buildThresholds(int quantileWindowSamples) {
    if (_levelNormWindow.length < max(20, quantileWindowSamples ~/ 4)) {
      return const _Thresholds(
        q10: 0.15,
        q30: 0.28,
        q50: 0.45,
        q70: 0.62,
        q90: 0.82,
      );
    }

    var q10 = max(_levelNormWindow.quantile(0.10), 0.15);
    var q30 = max(_levelNormWindow.quantile(0.30), q10 + 0.05);
    var q50 = max(_levelNormWindow.quantile(0.50), q30 + 0.05);
    var q70 = max(_levelNormWindow.quantile(0.70), q50 + 0.05);
    var q90 = max(_levelNormWindow.quantile(0.90), q70 + 0.05);

    q10 = q10.clamp(0.15, 0.70).toDouble();
    q30 = min(max(q30, q10 + 0.05), 0.80).toDouble();
    q50 = min(max(q50, q30 + 0.05), 0.88).toDouble();
    q70 = min(max(q70, q50 + 0.05), 0.94).toDouble();
    q90 = min(max(q90, q70 + 0.02), 0.99).toDouble();

    if (q90 <= q70) {
      q90 = min(q70 + 0.02, 0.99).toDouble();
    }
    if (q70 <= q50) {
      q70 = min(q50 + 0.02, q90 - 0.01).toDouble();
    }
    if (q50 <= q30) {
      q50 = min(q30 + 0.02, q70 - 0.01).toDouble();
    }
    if (q30 <= q10) {
      q30 = min(q10 + 0.02, q50 - 0.01).toDouble();
    }

    return _Thresholds(q10: q10, q30: q30, q50: q50, q70: q70, q90: q90);
  }

  int _levelFromNorm(
    double levelNorm,
    _Thresholds thresholds,
    double noiseGate,
  ) {
    if (levelNorm < max(thresholds.q10, noiseGate)) return 0;
    if (levelNorm < thresholds.q30) return 1;
    if (levelNorm < thresholds.q50) return 2;
    if (levelNorm < thresholds.q70) return 3;
    if (levelNorm < thresholds.q90) return 4;
    return 5;
  }

  int _applyHysteresis({
    required int currentLevel,
    required int targetLevel,
    required double levelNorm,
    required _Thresholds thresholds,
    required double hysteresis,
  }) {
    if (targetLevel == currentLevel) return currentLevel;

    if (targetLevel > currentLevel) {
      final nextLevel = min(currentLevel + 1, 5);
      final enterBoundary = _lowerBoundary(nextLevel, thresholds) + hysteresis;
      if (levelNorm >= enterBoundary) {
        return nextLevel;
      }
      return currentLevel;
    }

    final nextLevel = max(currentLevel - 1, 0);
    final exitBoundary = _upperBoundary(nextLevel, thresholds) - hysteresis;
    if (levelNorm <= exitBoundary) {
      return nextLevel;
    }
    return currentLevel;
  }

  int _applyDebounce(int proposedLevel, int debounceSamples) {
    if (proposedLevel == _stableThermalLevel) {
      _pendingLevel = null;
      _pendingLevelSamples = 0;
      return _stableThermalLevel;
    }

    if (debounceSamples <= 1) {
      _pendingLevel = null;
      _pendingLevelSamples = 0;
      return proposedLevel;
    }

    if (_pendingLevel == proposedLevel) {
      _pendingLevelSamples += 1;
    } else {
      _pendingLevel = proposedLevel;
      _pendingLevelSamples = 1;
    }

    if (_pendingLevelSamples >= debounceSamples) {
      _pendingLevel = null;
      _pendingLevelSamples = 0;
      return proposedLevel;
    }

    return _stableThermalLevel;
  }

  double _lowerBoundary(int level, _Thresholds thresholds) {
    switch (level) {
      case 0:
        return -double.infinity;
      case 1:
        return thresholds.q10;
      case 2:
        return thresholds.q30;
      case 3:
        return thresholds.q50;
      case 4:
        return thresholds.q70;
      case 5:
        return thresholds.q90;
      default:
        return thresholds.q90;
    }
  }

  double _upperBoundary(int level, _Thresholds thresholds) {
    switch (level) {
      case 0:
        return thresholds.q10;
      case 1:
        return thresholds.q30;
      case 2:
        return thresholds.q50;
      case 3:
        return thresholds.q70;
      case 4:
        return thresholds.q90;
      case 5:
        return double.infinity;
      default:
        return thresholds.q10;
    }
  }

  double _signedPow(double value, double gamma) {
    final sign = value.sign;
    final magnitude = pow(value.abs(), gamma).toDouble();
    return (sign * magnitude).clamp(-1.0, 1.0).toDouble();
  }

  double _clamp01(double value) => value.clamp(0.0, 1.0).toDouble();
}

class _Thresholds {
  const _Thresholds({
    required this.q10,
    required this.q30,
    required this.q50,
    required this.q70,
    required this.q90,
  });

  final double q10;
  final double q30;
  final double q50;
  final double q70;
  final double q90;
}

class _RollingWindow {
  final List<double> _values = <double>[];

  int get length => _values.length;

  void push(double value, {required int maxLength}) {
    _values.add(value);
    trim(maxLength);
  }

  void trim(int maxLength) {
    if (maxLength <= 0 || _values.length <= maxLength) return;
    _values.removeRange(0, _values.length - maxLength);
  }

  double quantile(double q) {
    if (_values.isEmpty) return 0.0;

    final clampedQ = q.clamp(0.0, 1.0).toDouble();
    final sorted = List<double>.from(_values)..sort();
    final index = ((sorted.length - 1) * clampedQ).round();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  void clear() {
    _values.clear();
  }
}

class _ButtonUpdate {
  const _ButtonUpdate({required this.event, required this.buttonIsPressed});

  final ButtonEvent? event;
  final bool buttonIsPressed;
}
