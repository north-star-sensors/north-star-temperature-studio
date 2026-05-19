import 'dart:math';

enum AlgorithmLabInputSource { live, simulator }

enum SimulatorScenario { noise, tap, hold, drift, mixed }

enum ThermalContactEventType { contactStart, intensityChange, contactEnd }

enum ButtonEventType { buttonDown }

enum PressPolarity { warmingIsPress, coolingIsPress }

enum PolarityMode { autoFromAmbient, manualOverride }

class AlgorithmLabConfig {
  const AlgorithmLabConfig({
    required this.sampleRateHz,
    required this.smoothAlpha,
    required this.baselineAlphaIdle,
    required this.baselineAlphaActive,
    required this.quantileWindowSamples,
    required this.levelHysteresis,
    required this.debounceSamples,
    required this.accelGamma,
    required this.pitchGamma,
    required this.volumeGamma,
    required this.pitchMinHz,
    required this.pitchMaxHz,
    required this.skinReferenceC,
    required this.ambientDeadbandC,
    required this.polarityMode,
    required this.manualPolarity,
    required this.buttonAccelThresholdCps2,
    required this.buttonDebounceMs,
    required this.ambientAutoEnabled,
    required this.ambientTrackAlpha,
    required this.ambientTrackMotionNormMax,
    required this.ambientTrackDeltaNormMax,
    required this.ambientTrackSlopeMaxCps,
    required this.ambientTrackAccelMaxCps2,
    required this.polaritySwitchHysteresisC,
    required this.polaritySwitchConfirmSamples,
  });

  final int sampleRateHz;
  final double smoothAlpha;
  final double baselineAlphaIdle;
  final double baselineAlphaActive;
  final int quantileWindowSamples;
  final double levelHysteresis;
  final int debounceSamples;
  final double accelGamma;
  final double pitchGamma;
  final double volumeGamma;
  final double pitchMinHz;
  final double pitchMaxHz;
  final double skinReferenceC;
  final double ambientDeadbandC;
  final PolarityMode polarityMode;
  final PressPolarity manualPolarity;
  final double buttonAccelThresholdCps2;
  final int buttonDebounceMs;
  final bool ambientAutoEnabled;
  final double ambientTrackAlpha;
  final double ambientTrackMotionNormMax;
  final double ambientTrackDeltaNormMax;
  final double ambientTrackSlopeMaxCps;
  final double ambientTrackAccelMaxCps2;
  final double polaritySwitchHysteresisC;
  final int polaritySwitchConfirmSamples;

  factory AlgorithmLabConfig.defaults() {
    return const AlgorithmLabConfig(
      sampleRateHz: 10,
      smoothAlpha: 0.24,
      baselineAlphaIdle: 0.04,
      baselineAlphaActive: 0.02,
      quantileWindowSamples: 120,
      levelHysteresis: 0.04,
      debounceSamples: 2,
      accelGamma: 1.0,
      pitchGamma: 1.2,
      volumeGamma: 1.1,
      pitchMinHz: 140.0,
      pitchMaxHz: 1100.0,
      skinReferenceC: 35.0,
      ambientDeadbandC: 1.0,
      polarityMode: PolarityMode.autoFromAmbient,
      manualPolarity: PressPolarity.warmingIsPress,
      buttonAccelThresholdCps2: 0.35,
      buttonDebounceMs: 800,
      ambientAutoEnabled: true,
      ambientTrackAlpha: 0.02,
      ambientTrackMotionNormMax: 0.20,
      ambientTrackDeltaNormMax: 0.20,
      ambientTrackSlopeMaxCps: 0.004,
      ambientTrackAccelMaxCps2: 0.020,
      polaritySwitchHysteresisC: 0.3,
      polaritySwitchConfirmSamples: 20,
    );
  }

  AlgorithmLabConfig copyWith({
    int? sampleRateHz,
    double? smoothAlpha,
    double? baselineAlphaIdle,
    double? baselineAlphaActive,
    int? quantileWindowSamples,
    double? levelHysteresis,
    int? debounceSamples,
    double? accelGamma,
    double? pitchGamma,
    double? volumeGamma,
    double? pitchMinHz,
    double? pitchMaxHz,
    double? skinReferenceC,
    double? ambientDeadbandC,
    PolarityMode? polarityMode,
    PressPolarity? manualPolarity,
    double? buttonAccelThresholdCps2,
    int? buttonDebounceMs,
    bool? ambientAutoEnabled,
    double? ambientTrackAlpha,
    double? ambientTrackMotionNormMax,
    double? ambientTrackDeltaNormMax,
    double? ambientTrackSlopeMaxCps,
    double? ambientTrackAccelMaxCps2,
    double? polaritySwitchHysteresisC,
    int? polaritySwitchConfirmSamples,
  }) {
    return AlgorithmLabConfig(
      sampleRateHz: sampleRateHz ?? this.sampleRateHz,
      smoothAlpha: smoothAlpha ?? this.smoothAlpha,
      baselineAlphaIdle: baselineAlphaIdle ?? this.baselineAlphaIdle,
      baselineAlphaActive: baselineAlphaActive ?? this.baselineAlphaActive,
      quantileWindowSamples:
          quantileWindowSamples ?? this.quantileWindowSamples,
      levelHysteresis: levelHysteresis ?? this.levelHysteresis,
      debounceSamples: debounceSamples ?? this.debounceSamples,
      accelGamma: accelGamma ?? this.accelGamma,
      pitchGamma: pitchGamma ?? this.pitchGamma,
      volumeGamma: volumeGamma ?? this.volumeGamma,
      pitchMinHz: pitchMinHz ?? this.pitchMinHz,
      pitchMaxHz: pitchMaxHz ?? this.pitchMaxHz,
      skinReferenceC: skinReferenceC ?? this.skinReferenceC,
      ambientDeadbandC: ambientDeadbandC ?? this.ambientDeadbandC,
      polarityMode: polarityMode ?? this.polarityMode,
      manualPolarity: manualPolarity ?? this.manualPolarity,
      buttonAccelThresholdCps2:
          buttonAccelThresholdCps2 ?? this.buttonAccelThresholdCps2,
      buttonDebounceMs: buttonDebounceMs ?? this.buttonDebounceMs,
      ambientAutoEnabled: ambientAutoEnabled ?? this.ambientAutoEnabled,
      ambientTrackAlpha: ambientTrackAlpha ?? this.ambientTrackAlpha,
      ambientTrackMotionNormMax:
          ambientTrackMotionNormMax ?? this.ambientTrackMotionNormMax,
      ambientTrackDeltaNormMax:
          ambientTrackDeltaNormMax ?? this.ambientTrackDeltaNormMax,
      ambientTrackSlopeMaxCps:
          ambientTrackSlopeMaxCps ?? this.ambientTrackSlopeMaxCps,
      ambientTrackAccelMaxCps2:
          ambientTrackAccelMaxCps2 ?? this.ambientTrackAccelMaxCps2,
      polaritySwitchHysteresisC:
          polaritySwitchHysteresisC ?? this.polaritySwitchHysteresisC,
      polaritySwitchConfirmSamples:
          polaritySwitchConfirmSamples ?? this.polaritySwitchConfirmSamples,
    );
  }

  AlgorithmLabConfig clamped() {
    final minPitch = pitchMinHz.clamp(60.0, 1600.0);
    final maxPitch = max(
      pitchMaxHz,
      minPitch + 50.0,
    ).clamp(minPitch + 50.0, 2400.0);
    return copyWith(
      sampleRateHz: sampleRateHz.clamp(10, 10),
      smoothAlpha: smoothAlpha.clamp(0.01, 0.95),
      baselineAlphaIdle: baselineAlphaIdle.clamp(0.001, 0.25),
      baselineAlphaActive: baselineAlphaActive.clamp(0.0001, 0.2),
      quantileWindowSamples: quantileWindowSamples.clamp(20, 500),
      levelHysteresis: levelHysteresis.clamp(0.0, 0.2),
      debounceSamples: debounceSamples.clamp(1, 8),
      accelGamma: accelGamma.clamp(0.2, 4.0),
      pitchGamma: pitchGamma.clamp(0.2, 4.0),
      volumeGamma: volumeGamma.clamp(0.2, 4.0),
      pitchMinHz: minPitch,
      pitchMaxHz: maxPitch,
      skinReferenceC: skinReferenceC.clamp(25.0, 45.0),
      ambientDeadbandC: ambientDeadbandC.clamp(0.0, 8.0),
      buttonAccelThresholdCps2: buttonAccelThresholdCps2.clamp(0.01, 1.0),
      buttonDebounceMs: buttonDebounceMs.clamp(200, 1500),
      ambientAutoEnabled: ambientAutoEnabled,
      ambientTrackAlpha: ambientTrackAlpha.clamp(0.001, 0.30),
      ambientTrackMotionNormMax: ambientTrackMotionNormMax.clamp(0.01, 1.0),
      ambientTrackDeltaNormMax: ambientTrackDeltaNormMax.clamp(0.01, 1.0),
      ambientTrackSlopeMaxCps: ambientTrackSlopeMaxCps.clamp(0.0005, 0.05),
      ambientTrackAccelMaxCps2: ambientTrackAccelMaxCps2.clamp(0.001, 0.2),
      polaritySwitchHysteresisC: polaritySwitchHysteresisC.clamp(0.0, 3.0),
      polaritySwitchConfirmSamples: polaritySwitchConfirmSamples.clamp(1, 300),
    );
  }

  Map<String, Object> toMap() {
    return {
      'sampleRateHz': sampleRateHz,
      'smoothAlpha': smoothAlpha,
      'baselineAlphaIdle': baselineAlphaIdle,
      'baselineAlphaActive': baselineAlphaActive,
      'quantileWindowSamples': quantileWindowSamples,
      'levelHysteresis': levelHysteresis,
      'debounceSamples': debounceSamples,
      'accelGamma': accelGamma,
      'pitchGamma': pitchGamma,
      'volumeGamma': volumeGamma,
      'pitchMinHz': pitchMinHz,
      'pitchMaxHz': pitchMaxHz,
      'skinReferenceC': skinReferenceC,
      'ambientDeadbandC': ambientDeadbandC,
      'polarityMode': polarityMode.index,
      'manualPolarity': manualPolarity.index,
      'buttonAccelThresholdCps2': buttonAccelThresholdCps2,
      'buttonDebounceMs': buttonDebounceMs,
      'ambientAutoEnabled': ambientAutoEnabled,
      'ambientTrackAlpha': ambientTrackAlpha,
      'ambientTrackMotionNormMax': ambientTrackMotionNormMax,
      'ambientTrackDeltaNormMax': ambientTrackDeltaNormMax,
      'ambientTrackSlopeMaxCps': ambientTrackSlopeMaxCps,
      'ambientTrackAccelMaxCps2': ambientTrackAccelMaxCps2,
      'polaritySwitchHysteresisC': polaritySwitchHysteresisC,
      'polaritySwitchConfirmSamples': polaritySwitchConfirmSamples,
    };
  }

  factory AlgorithmLabConfig.fromMap(
    Map<String, Object?> map, {
    AlgorithmLabConfig? fallback,
  }) {
    final defaults = fallback ?? AlgorithmLabConfig.defaults();
    final polarityModeIndex =
        _int(map['polarityMode']) ?? defaults.polarityMode.index;
    final manualPolarityIndex =
        _int(map['manualPolarity']) ?? defaults.manualPolarity.index;

    return AlgorithmLabConfig(
      sampleRateHz: _int(map['sampleRateHz']) ?? defaults.sampleRateHz,
      smoothAlpha: _double(map['smoothAlpha']) ?? defaults.smoothAlpha,
      baselineAlphaIdle:
          _double(map['baselineAlphaIdle']) ?? defaults.baselineAlphaIdle,
      baselineAlphaActive:
          _double(map['baselineAlphaActive']) ?? defaults.baselineAlphaActive,
      quantileWindowSamples:
          _int(map['quantileWindowSamples']) ?? defaults.quantileWindowSamples,
      levelHysteresis:
          _double(map['levelHysteresis']) ?? defaults.levelHysteresis,
      debounceSamples: _int(map['debounceSamples']) ?? defaults.debounceSamples,
      accelGamma: _double(map['accelGamma']) ?? defaults.accelGamma,
      pitchGamma: _double(map['pitchGamma']) ?? defaults.pitchGamma,
      volumeGamma: _double(map['volumeGamma']) ?? defaults.volumeGamma,
      pitchMinHz: _double(map['pitchMinHz']) ?? defaults.pitchMinHz,
      pitchMaxHz: _double(map['pitchMaxHz']) ?? defaults.pitchMaxHz,
      skinReferenceC: _double(map['skinReferenceC']) ?? defaults.skinReferenceC,
      ambientDeadbandC:
          _double(map['ambientDeadbandC']) ?? defaults.ambientDeadbandC,
      polarityMode: PolarityMode
          .values[polarityModeIndex.clamp(0, PolarityMode.values.length - 1)],
      manualPolarity:
          PressPolarity.values[manualPolarityIndex.clamp(
            0,
            PressPolarity.values.length - 1,
          )],
      buttonAccelThresholdCps2:
          _double(map['buttonAccelThresholdCps2']) ??
          defaults.buttonAccelThresholdCps2,
      buttonDebounceMs:
          _int(map['buttonDebounceMs']) ?? defaults.buttonDebounceMs,
      ambientAutoEnabled:
          _bool(map['ambientAutoEnabled']) ?? defaults.ambientAutoEnabled,
      ambientTrackAlpha:
          _double(map['ambientTrackAlpha']) ?? defaults.ambientTrackAlpha,
      ambientTrackMotionNormMax:
          _double(map['ambientTrackMotionNormMax']) ??
          defaults.ambientTrackMotionNormMax,
      ambientTrackDeltaNormMax:
          _double(map['ambientTrackDeltaNormMax']) ??
          defaults.ambientTrackDeltaNormMax,
      ambientTrackSlopeMaxCps:
          _double(map['ambientTrackSlopeMaxCps']) ??
          defaults.ambientTrackSlopeMaxCps,
      ambientTrackAccelMaxCps2:
          _double(map['ambientTrackAccelMaxCps2']) ??
          defaults.ambientTrackAccelMaxCps2,
      polaritySwitchHysteresisC:
          _double(map['polaritySwitchHysteresisC']) ??
          defaults.polaritySwitchHysteresisC,
      polaritySwitchConfirmSamples:
          _int(map['polaritySwitchConfirmSamples']) ??
          defaults.polaritySwitchConfirmSamples,
    ).clamped();
  }

  static double? _double(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _bool(Object? value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }
}

class TemperatureSample {
  const TemperatureSample({required this.timestamp, required this.rawCelsius});

  final DateTime timestamp;
  final double rawCelsius;
}

class ThermalContactEvent {
  const ThermalContactEvent({
    required this.timestamp,
    required this.type,
    required this.level,
  });

  final DateTime timestamp;
  final ThermalContactEventType type;
  final int level;
}

class ButtonEvent {
  const ButtonEvent({
    required this.timestamp,
    required this.type,
    required this.isPressed,
  });

  final DateTime timestamp;
  final ButtonEventType type;
  final bool isPressed;
}

class CalibrationProfile {
  const CalibrationProfile({
    required this.deviceKey,
    double? ambientEstimateC,
    double? ambientC,
    required this.skinReferenceC,
    required this.deadbandC,
    required this.inferredPolarity,
    required this.effectivePolarity,
    required this.mode,
    required this.calibratedAt,
    DateTime? ambientUpdatedAt,
  }) : ambientEstimateC = ambientEstimateC ?? ambientC ?? 0.0,
       ambientUpdatedAt = ambientUpdatedAt ?? calibratedAt;

  final String deviceKey;
  final double ambientEstimateC;
  final double skinReferenceC;
  final double deadbandC;
  final PressPolarity inferredPolarity;
  final PressPolarity effectivePolarity;
  final PolarityMode mode;
  final DateTime calibratedAt;
  final DateTime ambientUpdatedAt;

  double get ambientC => ambientEstimateC;

  Map<String, Object> toMap() {
    return {
      'deviceKey': deviceKey,
      'ambientC': ambientC,
      'ambientEstimateC': ambientEstimateC,
      'skinReferenceC': skinReferenceC,
      'deadbandC': deadbandC,
      'inferredPolarity': inferredPolarity.index,
      'effectivePolarity': effectivePolarity.index,
      'mode': mode.index,
      'calibratedAt': calibratedAt.toIso8601String(),
      'ambientUpdatedAt': ambientUpdatedAt.toIso8601String(),
    };
  }

  factory CalibrationProfile.fromMap(Map<String, Object?> map) {
    final inferredIndex = AlgorithmLabConfig._int(map['inferredPolarity']) ?? 0;
    final effectiveIndex =
        AlgorithmLabConfig._int(map['effectivePolarity']) ?? 0;
    final modeIndex = AlgorithmLabConfig._int(map['mode']) ?? 0;
    final calibratedAtRaw = map['calibratedAt'] as String?;
    final ambientUpdatedAtRaw = map['ambientUpdatedAt'] as String?;
    final fallbackDate = DateTime.fromMillisecondsSinceEpoch(0);
    final calibratedAt = calibratedAtRaw == null
        ? fallbackDate
        : (DateTime.tryParse(calibratedAtRaw) ?? fallbackDate);

    return CalibrationProfile(
      deviceKey: (map['deviceKey'] as String?) ?? '',
      ambientEstimateC:
          AlgorithmLabConfig._double(map['ambientEstimateC']) ??
          AlgorithmLabConfig._double(map['ambientC']) ??
          0,
      skinReferenceC: AlgorithmLabConfig._double(map['skinReferenceC']) ?? 35.0,
      deadbandC: AlgorithmLabConfig._double(map['deadbandC']) ?? 1.0,
      inferredPolarity: PressPolarity
          .values[inferredIndex.clamp(0, PressPolarity.values.length - 1)],
      effectivePolarity: PressPolarity
          .values[effectiveIndex.clamp(0, PressPolarity.values.length - 1)],
      mode: PolarityMode
          .values[modeIndex.clamp(0, PolarityMode.values.length - 1)],
      calibratedAt: calibratedAt,
      ambientUpdatedAt: ambientUpdatedAtRaw == null
          ? calibratedAt
          : (DateTime.tryParse(ambientUpdatedAtRaw) ?? calibratedAt),
    );
  }
}

class AlgorithmFrame {
  const AlgorithmFrame({
    required this.timestamp,
    required this.rawCelsius,
    required this.smoothedCelsius,
    required this.baselineCelsius,
    required this.deltaCelsius,
    required this.deltaNormSigned,
    required this.levelNorm,
    required this.motionNorm,
    required this.thermalInfluenceLevel,
    required this.lunarAccelNorm,
    required this.pitchNorm,
    required this.pitchHz,
    required this.volumeNorm,
    required this.buttonIsPressed,
    required this.activePolarity,
    required this.ambientEstimateC,
    required this.ambientTrackingActive,
    required this.polarityPendingSwitch,
    required this.buttonDirectedDeltaC,
    required this.directedSlopeCps,
    required this.directedAccelCps2,
    this.thermalContactEvent,
    this.buttonEvent,
  });

  final DateTime timestamp;
  final double rawCelsius;
  final double smoothedCelsius;
  final double baselineCelsius;
  final double deltaCelsius;
  final double deltaNormSigned;
  final double levelNorm;
  final double motionNorm;
  final int thermalInfluenceLevel;
  final double lunarAccelNorm;
  final double pitchNorm;
  final double pitchHz;
  final double volumeNorm;
  final bool buttonIsPressed;
  final PressPolarity activePolarity;
  final double ambientEstimateC;
  final bool ambientTrackingActive;
  final bool polarityPendingSwitch;
  final double buttonDirectedDeltaC;
  final double directedSlopeCps;
  final double directedAccelCps2;
  final ThermalContactEvent? thermalContactEvent;
  final ButtonEvent? buttonEvent;

  AlgorithmFrame copyWith({
    DateTime? timestamp,
    double? rawCelsius,
    double? smoothedCelsius,
    double? baselineCelsius,
    double? deltaCelsius,
    double? deltaNormSigned,
    double? levelNorm,
    double? motionNorm,
    int? thermalInfluenceLevel,
    double? lunarAccelNorm,
    double? pitchNorm,
    double? pitchHz,
    double? volumeNorm,
    bool? buttonIsPressed,
    PressPolarity? activePolarity,
    double? ambientEstimateC,
    bool? ambientTrackingActive,
    bool? polarityPendingSwitch,
    double? buttonDirectedDeltaC,
    double? directedSlopeCps,
    double? directedAccelCps2,
    ThermalContactEvent? thermalContactEvent,
    ButtonEvent? buttonEvent,
  }) {
    return AlgorithmFrame(
      timestamp: timestamp ?? this.timestamp,
      rawCelsius: rawCelsius ?? this.rawCelsius,
      smoothedCelsius: smoothedCelsius ?? this.smoothedCelsius,
      baselineCelsius: baselineCelsius ?? this.baselineCelsius,
      deltaCelsius: deltaCelsius ?? this.deltaCelsius,
      deltaNormSigned: deltaNormSigned ?? this.deltaNormSigned,
      levelNorm: levelNorm ?? this.levelNorm,
      motionNorm: motionNorm ?? this.motionNorm,
      thermalInfluenceLevel:
          thermalInfluenceLevel ?? this.thermalInfluenceLevel,
      lunarAccelNorm: lunarAccelNorm ?? this.lunarAccelNorm,
      pitchNorm: pitchNorm ?? this.pitchNorm,
      pitchHz: pitchHz ?? this.pitchHz,
      volumeNorm: volumeNorm ?? this.volumeNorm,
      buttonIsPressed: buttonIsPressed ?? this.buttonIsPressed,
      activePolarity: activePolarity ?? this.activePolarity,
      ambientEstimateC: ambientEstimateC ?? this.ambientEstimateC,
      ambientTrackingActive:
          ambientTrackingActive ?? this.ambientTrackingActive,
      polarityPendingSwitch:
          polarityPendingSwitch ?? this.polarityPendingSwitch,
      buttonDirectedDeltaC: buttonDirectedDeltaC ?? this.buttonDirectedDeltaC,
      directedSlopeCps: directedSlopeCps ?? this.directedSlopeCps,
      directedAccelCps2: directedAccelCps2 ?? this.directedAccelCps2,
      thermalContactEvent: thermalContactEvent ?? this.thermalContactEvent,
      buttonEvent: buttonEvent ?? this.buttonEvent,
    );
  }
}
