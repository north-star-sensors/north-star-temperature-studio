import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/processing/temperature_signal_engine.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sim/temperature_simulator.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sources/live_temperature_source.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sources/simulated_temperature_source.dart';
import 'package:temperature_studio/src/features/algorithm_lab/sources/temperature_source.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/live_temperature_gateway.dart';

final algorithmLabControllerProvider =
    StateNotifierProvider<AlgorithmLabController, AlgorithmLabState>((ref) {
      return AlgorithmLabController(ref);
    });

class AlgorithmLabState {
  const AlgorithmLabState({
    required this.config,
    required this.inputSource,
    required this.simulatorScenario,
    required this.availableDevices,
    required this.selectedDevice,
    required this.isScanningDevices,
    required this.isLiveConnected,
    required this.frames,
    required this.latestFrame,
    required this.lastThermalContactEvent,
    required this.lastButtonEvent,
    required this.buttonIsPressed,
    required this.activePolarity,
    required this.calibration,
    required this.isCapturingAmbient,
    required this.advancedControlsExpanded,
    required this.errorMessage,
    required this.isInitialized,
  });

  factory AlgorithmLabState.initial() {
    return AlgorithmLabState(
      config: AlgorithmLabConfig.defaults(),
      inputSource: AlgorithmLabInputSource.simulator,
      simulatorScenario: SimulatorScenario.mixed,
      availableDevices: const <String>[],
      selectedDevice: null,
      isScanningDevices: false,
      isLiveConnected: false,
      frames: const <AlgorithmFrame>[],
      latestFrame: null,
      lastThermalContactEvent: null,
      lastButtonEvent: null,
      buttonIsPressed: false,
      activePolarity: PressPolarity.warmingIsPress,
      calibration: null,
      isCapturingAmbient: false,
      advancedControlsExpanded: false,
      errorMessage: null,
      isInitialized: false,
    );
  }

  final AlgorithmLabConfig config;
  final AlgorithmLabInputSource inputSource;
  final SimulatorScenario simulatorScenario;
  final List<String> availableDevices;
  final String? selectedDevice;
  final bool isScanningDevices;
  final bool isLiveConnected;
  final List<AlgorithmFrame> frames;
  final AlgorithmFrame? latestFrame;
  final ThermalContactEvent? lastThermalContactEvent;
  final ButtonEvent? lastButtonEvent;
  final bool buttonIsPressed;
  final PressPolarity activePolarity;
  final CalibrationProfile? calibration;
  final bool isCapturingAmbient;
  final bool advancedControlsExpanded;
  final String? errorMessage;
  final bool isInitialized;

  static const Object _noValue = Object();

  AlgorithmLabState copyWith({
    AlgorithmLabConfig? config,
    AlgorithmLabInputSource? inputSource,
    SimulatorScenario? simulatorScenario,
    List<String>? availableDevices,
    Object? selectedDevice = _noValue,
    bool? isScanningDevices,
    bool? isLiveConnected,
    List<AlgorithmFrame>? frames,
    Object? latestFrame = _noValue,
    Object? lastThermalContactEvent = _noValue,
    Object? lastButtonEvent = _noValue,
    bool? buttonIsPressed,
    PressPolarity? activePolarity,
    Object? calibration = _noValue,
    bool? isCapturingAmbient,
    bool? advancedControlsExpanded,
    Object? errorMessage = _noValue,
    bool? isInitialized,
  }) {
    return AlgorithmLabState(
      config: config ?? this.config,
      inputSource: inputSource ?? this.inputSource,
      simulatorScenario: simulatorScenario ?? this.simulatorScenario,
      availableDevices: availableDevices ?? this.availableDevices,
      selectedDevice: selectedDevice == _noValue
          ? this.selectedDevice
          : selectedDevice as String?,
      isScanningDevices: isScanningDevices ?? this.isScanningDevices,
      isLiveConnected: isLiveConnected ?? this.isLiveConnected,
      frames: frames ?? this.frames,
      latestFrame: latestFrame == _noValue
          ? this.latestFrame
          : latestFrame as AlgorithmFrame?,
      lastThermalContactEvent: lastThermalContactEvent == _noValue
          ? this.lastThermalContactEvent
          : lastThermalContactEvent as ThermalContactEvent?,
      lastButtonEvent: lastButtonEvent == _noValue
          ? this.lastButtonEvent
          : lastButtonEvent as ButtonEvent?,
      buttonIsPressed: buttonIsPressed ?? this.buttonIsPressed,
      activePolarity: activePolarity ?? this.activePolarity,
      calibration: calibration == _noValue
          ? this.calibration
          : calibration as CalibrationProfile?,
      isCapturingAmbient: isCapturingAmbient ?? this.isCapturingAmbient,
      advancedControlsExpanded:
          advancedControlsExpanded ?? this.advancedControlsExpanded,
      errorMessage: errorMessage == _noValue
          ? this.errorMessage
          : errorMessage as String?,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AlgorithmLabController extends StateNotifier<AlgorithmLabState> {
  AlgorithmLabController(this._ref) : super(AlgorithmLabState.initial()) {
    unawaited(_initialize());
  }

  static const int _maxFrames = 300;
  static const int _ambientCaptureSamples = 20;
  static const int _ambientTrackWindowSamples = 60;
  static const String _prefPrefix = 'algorithm_lab';
  static const int _binaryTuningRevision = 12;

  final Ref _ref;
  final TemperatureSignalEngine _engine = TemperatureSignalEngine();
  final TemperatureSimulator _simulator = TemperatureSimulator();

  SharedPreferences? _prefs;
  TemperatureSource? _source;
  StreamSubscription<TemperatureSample>? _sampleSubscription;
  Timer? _persistTimer;
  Timer? _calibrationPersistTimer;
  CalibrationProfile? _pendingCalibrationPersist;
  bool _isCapturingAmbient = false;
  final List<double> _ambientCaptureValues = <double>[];
  final List<double> _ambientTrackValues = <double>[];
  PressPolarity? _pendingPolarityCandidate;
  int _pendingPolaritySamples = 0;

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();

    if (state.inputSource == AlgorithmLabInputSource.live) {
      state = state.copyWith(
        isLiveConnected: _ref.read(liveTemperatureGatewayProvider).isConnected,
      );
      await scanDevices();
    }

    await _loadCalibrationForCurrentDevice();
    await _restartSource();
    if (mounted) {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<void> setInputSource(AlgorithmLabInputSource source) async {
    if (source == state.inputSource) return;

    _engine.reset();
    _isCapturingAmbient = false;
    _ambientCaptureValues.clear();
    _ambientTrackValues.clear();
    _pendingPolarityCandidate = null;
    _pendingPolaritySamples = 0;
    state = state.copyWith(
      inputSource: source,
      frames: const <AlgorithmFrame>[],
      latestFrame: null,
      lastThermalContactEvent: null,
      lastButtonEvent: null,
      buttonIsPressed: false,
      isCapturingAmbient: false,
      errorMessage: null,
    );
    _schedulePersist();

    await _loadCalibrationForCurrentDevice();
    await _restartSource();
    if (source == AlgorithmLabInputSource.live) {
      state = state.copyWith(
        isLiveConnected: _ref.read(liveTemperatureGatewayProvider).isConnected,
      );
      await scanDevices();
    }
  }

  void setSimulatorScenario(SimulatorScenario scenario) {
    if (scenario == state.simulatorScenario) return;

    state = state.copyWith(simulatorScenario: scenario, errorMessage: null);
    _schedulePersist();

    final source = _source;
    if (source is SimulatedTemperatureSource) {
      source.setScenario(scenario);
    }
  }

  Future<void> scanDevices() async {
    if (state.inputSource != AlgorithmLabInputSource.live) return;

    state = state.copyWith(isScanningDevices: true, errorMessage: null);
    try {
      final devices = await _ref
          .read(liveTemperatureGatewayProvider)
          .getDevices();
      final selected = devices.contains(state.selectedDevice)
          ? state.selectedDevice
          : (devices.isNotEmpty ? devices.first : null);
      if (!mounted) return;
      state = state.copyWith(
        availableDevices: devices,
        selectedDevice: selected,
        isScanningDevices: false,
      );
      await _loadCalibrationForCurrentDevice(selectedDeviceOverride: selected);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isScanningDevices: false,
        errorMessage: 'Device scan failed: $e',
      );
    }
  }

  void selectDevice(String? device) {
    state = state.copyWith(selectedDevice: device);
    unawaited(_loadCalibrationForCurrentDevice());
  }

  Future<void> connectSelectedDevice() async {
    if (state.inputSource != AlgorithmLabInputSource.live) return;
    final device = state.selectedDevice;
    if (device == null) return;

    state = state.copyWith(errorMessage: null);
    try {
      await _ref.read(liveTemperatureGatewayProvider).connect(device);
      if (!mounted) return;
      state = state.copyWith(isLiveConnected: true);
      await _loadCalibrationForCurrentDevice(selectedDeviceOverride: device);
      await _restartSource();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: 'Connect failed: $e');
    }
  }

  Future<void> disconnectLiveDevice() async {
    if (state.inputSource != AlgorithmLabInputSource.live) return;

    try {
      await _ref.read(liveTemperatureGatewayProvider).disconnect();
      if (!mounted) return;
      state = state.copyWith(isLiveConnected: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: 'Disconnect failed: $e');
    }
  }

  void captureAmbient() {
    _isCapturingAmbient = true;
    _ambientCaptureValues.clear();
    _ambientTrackValues.clear();
    _pendingPolarityCandidate = null;
    _pendingPolaritySamples = 0;
    state = state.copyWith(isCapturingAmbient: true, errorMessage: null);
  }

  void recalibrate() {
    final latest = state.latestFrame;
    if (latest == null) return;

    _engine.recalibrate(latest.smoothedCelsius);
    final neutralFrame = _buildNeutralFrame(
      baseline: latest.smoothedCelsius,
      raw: latest.rawCelsius,
      polarity: state.activePolarity,
    );

    state = state.copyWith(
      frames: _nextFramesWith(neutralFrame),
      latestFrame: neutralFrame,
      lastThermalContactEvent: null,
      lastButtonEvent: null,
      buttonIsPressed: false,
      errorMessage: null,
    );
  }

  void resetDefaults() {
    _engine.reset();
    _isCapturingAmbient = false;
    _ambientCaptureValues.clear();
    _ambientTrackValues.clear();
    _pendingPolarityCandidate = null;
    _pendingPolaritySamples = 0;
    final defaults = AlgorithmLabConfig.defaults();
    final refreshedCalibration = _refreshCalibrationForConfig(
      state.calibration,
      defaults,
    );
    _engine.setCalibrationProfile(refreshedCalibration);
    state = state.copyWith(
      config: defaults,
      calibration: refreshedCalibration,
      frames: const <AlgorithmFrame>[],
      latestFrame: null,
      lastThermalContactEvent: null,
      lastButtonEvent: null,
      buttonIsPressed: false,
      activePolarity: _effectivePolarityFromConfig(
        defaults,
        refreshedCalibration?.ambientEstimateC,
      ),
      isCapturingAmbient: false,
      errorMessage: null,
    );
    _schedulePersist();
    if (refreshedCalibration != null) {
      _scheduleCalibrationPersist(refreshedCalibration);
    }
  }

  void clearChart() {
    state = state.copyWith(
      frames: const <AlgorithmFrame>[],
      latestFrame: null,
      lastThermalContactEvent: null,
      lastButtonEvent: null,
      buttonIsPressed: false,
      errorMessage: null,
    );
  }

  void setAdvancedControlsExpanded(bool expanded) {
    if (state.advancedControlsExpanded == expanded) return;
    state = state.copyWith(advancedControlsExpanded: expanded);
    _schedulePersist();
  }

  void updateSmoothAlpha(double value) {
    _setConfig(state.config.copyWith(smoothAlpha: value));
  }

  void updateBaselineAlphaIdle(double value) {
    _setConfig(state.config.copyWith(baselineAlphaIdle: value));
  }

  void updateBaselineAlphaActive(double value) {
    _setConfig(state.config.copyWith(baselineAlphaActive: value));
  }

  void updateQuantileWindowSamples(int value) {
    _setConfig(state.config.copyWith(quantileWindowSamples: value));
  }

  void updateLevelHysteresis(double value) {
    _setConfig(state.config.copyWith(levelHysteresis: value));
  }

  void updateDebounceSamples(int value) {
    _setConfig(state.config.copyWith(debounceSamples: value));
  }

  void updateAccelGamma(double value) {
    _setConfig(state.config.copyWith(accelGamma: value));
  }

  void updatePitchGamma(double value) {
    _setConfig(state.config.copyWith(pitchGamma: value));
  }

  void updateVolumeGamma(double value) {
    _setConfig(state.config.copyWith(volumeGamma: value));
  }

  void updatePitchMinHz(double value) {
    _setConfig(state.config.copyWith(pitchMinHz: value));
  }

  void updatePitchMaxHz(double value) {
    _setConfig(state.config.copyWith(pitchMaxHz: value));
  }

  void updateSkinReferenceC(double value) {
    _setConfig(state.config.copyWith(skinReferenceC: value));
  }

  void updateAmbientDeadbandC(double value) {
    _setConfig(state.config.copyWith(ambientDeadbandC: value));
  }

  void updatePolarityMode(PolarityMode value) {
    _setConfig(state.config.copyWith(polarityMode: value));
  }

  void updateManualPolarity(PressPolarity value) {
    _setConfig(state.config.copyWith(manualPolarity: value));
  }

  void updateButtonDebounceMs(int value) {
    _setConfig(state.config.copyWith(buttonDebounceMs: value));
  }

  void updateButtonAccelThresholdCps2(double value) {
    _setConfig(state.config.copyWith(buttonAccelThresholdCps2: value));
  }

  void updateAmbientAutoEnabled(bool value) {
    _setConfig(state.config.copyWith(ambientAutoEnabled: value));
  }

  void updateAmbientTrackAlpha(double value) {
    _setConfig(state.config.copyWith(ambientTrackAlpha: value));
  }

  void updateAmbientTrackMotionNormMax(double value) {
    _setConfig(state.config.copyWith(ambientTrackMotionNormMax: value));
  }

  void updateAmbientTrackDeltaNormMax(double value) {
    _setConfig(state.config.copyWith(ambientTrackDeltaNormMax: value));
  }

  void updateAmbientTrackSlopeMaxCps(double value) {
    _setConfig(state.config.copyWith(ambientTrackSlopeMaxCps: value));
  }

  void updateAmbientTrackAccelMaxCps2(double value) {
    _setConfig(state.config.copyWith(ambientTrackAccelMaxCps2: value));
  }

  void updatePolaritySwitchHysteresisC(double value) {
    _setConfig(state.config.copyWith(polaritySwitchHysteresisC: value));
  }

  void updatePolaritySwitchConfirmSamples(int value) {
    _setConfig(state.config.copyWith(polaritySwitchConfirmSamples: value));
  }

  void processSample(TemperatureSample sample) {
    var frame = _engine.ingest(sample, state.config);

    if (_isCapturingAmbient) {
      _ambientCaptureValues.add(frame.smoothedCelsius);
      if (_ambientCaptureValues.length >= _ambientCaptureSamples) {
        _finishAmbientCapture();
        return;
      }
    }

    final adaptive = _applyAdaptiveAmbientMonitoring(
      frame: frame,
      sampleTimestamp: sample.timestamp,
    );
    frame = adaptive.frame;

    final frames = _nextFramesWith(frame);
    state = state.copyWith(
      frames: frames,
      latestFrame: frame,
      lastThermalContactEvent:
          frame.thermalContactEvent ?? state.lastThermalContactEvent,
      lastButtonEvent: frame.buttonEvent ?? state.lastButtonEvent,
      buttonIsPressed: frame.buttonIsPressed,
      activePolarity: adaptive.activePolarity,
      calibration: adaptive.calibration,
    );
  }

  Future<void> _restartSource() async {
    await _sampleSubscription?.cancel();
    _sampleSubscription = null;

    final previousSource = _source;
    if (previousSource is SimulatedTemperatureSource) {
      await previousSource.dispose();
    } else {
      await previousSource?.stop();
    }
    _source = null;

    final nextSource = state.inputSource == AlgorithmLabInputSource.live
        ? LiveTemperatureSource(
            _ref.read(liveTemperatureGatewayProvider).samples,
          )
        : SimulatedTemperatureSource(
            simulator: _simulator,
            scenario: state.simulatorScenario,
            sampleRateHz: state.config.sampleRateHz,
          );
    _source = nextSource;

    await nextSource.start();
    _sampleSubscription = nextSource.stream().listen(
      processSample,
      onError: (Object error) {
        if (!mounted) return;
        state = state.copyWith(errorMessage: 'Input stream error: $error');
      },
    );
  }

  Future<void> _loadCalibrationForCurrentDevice({
    String? selectedDeviceOverride,
  }) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final deviceKey = _currentDeviceKey(selectedDeviceOverride);
    if (deviceKey == null) {
      _engine.setCalibrationProfile(null);
      _ambientTrackValues.clear();
      _pendingPolarityCandidate = null;
      _pendingPolaritySamples = 0;
      if (!mounted) return;
      state = state.copyWith(
        calibration: null,
        activePolarity: _effectivePolarityFromConfig(state.config, null),
      );
      return;
    }

    final prefix = _calibrationPrefix(deviceKey);
    final ambientEstimate =
        prefs.getDouble('$prefix.ambientEstimateC') ??
        prefs.getDouble('$prefix.ambientC');
    if (ambientEstimate == null) {
      _engine.setCalibrationProfile(null);
      _ambientTrackValues.clear();
      _pendingPolarityCandidate = null;
      _pendingPolaritySamples = 0;
      if (!mounted) return;
      state = state.copyWith(
        calibration: null,
        activePolarity: _effectivePolarityFromConfig(state.config, null),
      );
      return;
    }

    final map = <String, Object?>{
      'deviceKey': prefs.getString('$prefix.deviceKey') ?? deviceKey,
      'ambientEstimateC': ambientEstimate,
      'ambientC': ambientEstimate,
      'skinReferenceC': prefs.getDouble('$prefix.skinReferenceC'),
      'deadbandC': prefs.getDouble('$prefix.deadbandC'),
      'inferredPolarity': prefs.getInt('$prefix.inferredPolarity'),
      'effectivePolarity': prefs.getInt('$prefix.effectivePolarity'),
      'mode': prefs.getInt('$prefix.mode'),
      'calibratedAt': prefs.getString('$prefix.calibratedAt'),
      'ambientUpdatedAt': prefs.getString('$prefix.ambientUpdatedAt'),
    };
    var loaded = CalibrationProfile.fromMap(map);
    loaded = _refreshCalibrationForConfig(loaded, state.config)!;

    _engine.setCalibrationProfile(loaded);
    _ambientTrackValues
      ..clear()
      ..add(loaded.ambientEstimateC);
    _pendingPolarityCandidate = null;
    _pendingPolaritySamples = 0;
    if (!mounted) return;
    state = state.copyWith(
      calibration: loaded,
      activePolarity: loaded.effectivePolarity,
    );
  }

  void _setConfig(AlgorithmLabConfig config) {
    final clamped = config.clamped();
    var refreshedCalibration = _refreshCalibrationForConfig(
      state.calibration,
      clamped,
    );
    _engine.setCalibrationProfile(refreshedCalibration);

    state = state.copyWith(
      config: clamped,
      calibration: refreshedCalibration,
      activePolarity: _effectivePolarityFromConfig(
        clamped,
        refreshedCalibration?.ambientEstimateC,
      ),
    );

    _schedulePersist();
    if (refreshedCalibration != null) {
      _scheduleCalibrationPersist(refreshedCalibration);
    }
  }

  void _scheduleCalibrationPersist(CalibrationProfile profile) {
    _pendingCalibrationPersist = profile;
    if (_calibrationPersistTimer != null) return;
    _calibrationPersistTimer = Timer(const Duration(milliseconds: 900), () {
      _calibrationPersistTimer = null;
      final pending = _pendingCalibrationPersist;
      _pendingCalibrationPersist = null;
      if (pending != null) {
        unawaited(_persistCalibration(pending));
      }
    });
  }

  _AdaptiveAmbientUpdate _applyAdaptiveAmbientMonitoring({
    required AlgorithmFrame frame,
    required DateTime sampleTimestamp,
  }) {
    final config = state.config;
    final deviceKey = _currentDeviceKey() ?? 'simulator';
    final existingCalibration = state.calibration;
    final baseCalibration =
        existingCalibration ??
        _buildCalibrationProfile(
          deviceKey: deviceKey,
          ambientEstimateC: frame.smoothedCelsius,
          config: config,
          calibratedAt: sampleTimestamp,
          ambientUpdatedAt: sampleTimestamp,
        );

    var ambientEstimate = baseCalibration.ambientEstimateC;
    final trackingActive =
        config.ambientAutoEnabled &&
        !frame.buttonIsPressed &&
        frame.thermalInfluenceLevel == 0 &&
        frame.motionNorm <= config.ambientTrackMotionNormMax &&
        frame.deltaNormSigned.abs() <= config.ambientTrackDeltaNormMax &&
        frame.directedSlopeCps.abs() <= config.ambientTrackSlopeMaxCps &&
        frame.directedAccelCps2.abs() <= config.ambientTrackAccelMaxCps2;

    if (trackingActive) {
      _ambientTrackValues.add(frame.smoothedCelsius);
      if (_ambientTrackValues.length > _ambientTrackWindowSamples) {
        _ambientTrackValues.removeRange(
          0,
          _ambientTrackValues.length - _ambientTrackWindowSamples,
        );
      }
      final ambientMedian = _median(_ambientTrackValues);
      ambientEstimate = _lerp(
        ambientEstimate,
        ambientMedian,
        config.ambientTrackAlpha,
      );
    } else if (_ambientTrackValues.length > _ambientTrackWindowSamples) {
      _ambientTrackValues.removeRange(
        0,
        _ambientTrackValues.length - _ambientTrackWindowSamples,
      );
    }

    var inferredPolarity = baseCalibration.inferredPolarity;
    final switchBand =
        config.ambientDeadbandC + config.polaritySwitchHysteresisC;
    PressPolarity? desiredPolarity;
    if (ambientEstimate < (config.skinReferenceC - switchBand)) {
      desiredPolarity = PressPolarity.warmingIsPress;
    } else if (ambientEstimate > (config.skinReferenceC + switchBand)) {
      desiredPolarity = PressPolarity.coolingIsPress;
    }

    if (!frame.buttonIsPressed &&
        desiredPolarity != null &&
        desiredPolarity != inferredPolarity) {
      if (_pendingPolarityCandidate == desiredPolarity) {
        _pendingPolaritySamples += 1;
      } else {
        _pendingPolarityCandidate = desiredPolarity;
        _pendingPolaritySamples = 1;
      }
      if (_pendingPolaritySamples >= config.polaritySwitchConfirmSamples) {
        inferredPolarity = desiredPolarity;
        _pendingPolarityCandidate = null;
        _pendingPolaritySamples = 0;
      }
    } else {
      _pendingPolarityCandidate = null;
      _pendingPolaritySamples = 0;
    }

    final polarityPendingSwitch = _pendingPolarityCandidate != null;
    final effectivePolarity = config.polarityMode == PolarityMode.manualOverride
        ? config.manualPolarity
        : inferredPolarity;

    final updatedCalibration = CalibrationProfile(
      deviceKey: baseCalibration.deviceKey,
      ambientEstimateC: ambientEstimate,
      skinReferenceC: config.skinReferenceC,
      deadbandC: config.ambientDeadbandC,
      inferredPolarity: inferredPolarity,
      effectivePolarity: effectivePolarity,
      mode: config.polarityMode,
      calibratedAt: baseCalibration.calibratedAt,
      ambientUpdatedAt: trackingActive
          ? sampleTimestamp
          : baseCalibration.ambientUpdatedAt,
    );

    if (_hasCalibrationChanged(existingCalibration, updatedCalibration)) {
      _engine.setCalibrationProfile(updatedCalibration);
      _scheduleCalibrationPersist(updatedCalibration);
    }

    final updatedFrame = frame.copyWith(
      activePolarity: effectivePolarity,
      ambientEstimateC: ambientEstimate,
      ambientTrackingActive: trackingActive,
      polarityPendingSwitch: polarityPendingSwitch,
    );

    return _AdaptiveAmbientUpdate(
      frame: updatedFrame,
      calibration: updatedCalibration,
      activePolarity: effectivePolarity,
    );
  }

  bool _hasCalibrationChanged(
    CalibrationProfile? previous,
    CalibrationProfile next,
  ) {
    if (previous == null) return true;
    if (previous.deviceKey != next.deviceKey) return true;
    if ((previous.ambientEstimateC - next.ambientEstimateC).abs() > 0.000001) {
      return true;
    }
    if (previous.skinReferenceC != next.skinReferenceC) return true;
    if (previous.deadbandC != next.deadbandC) return true;
    if (previous.inferredPolarity != next.inferredPolarity) return true;
    if (previous.effectivePolarity != next.effectivePolarity) return true;
    if (previous.mode != next.mode) return true;
    return false;
  }

  void _finishAmbientCapture() {
    if (!_isCapturingAmbient || _ambientCaptureValues.isEmpty) return;
    _isCapturingAmbient = false;

    final ambient = _median(_ambientCaptureValues);
    _ambientCaptureValues.clear();
    _ambientTrackValues
      ..clear()
      ..add(ambient);
    _pendingPolarityCandidate = null;
    _pendingPolaritySamples = 0;
    final deviceKey = _currentDeviceKey() ?? 'simulator';
    final updated = _buildCalibrationProfile(
      deviceKey: deviceKey,
      ambientEstimateC: ambient,
      config: state.config,
      calibratedAt: DateTime.now(),
    );

    _engine.setCalibrationProfile(updated);
    _engine.recalibrate(ambient);
    final neutralFrame = _buildNeutralFrame(
      baseline: ambient,
      raw: ambient,
      polarity: updated.effectivePolarity,
    );

    state = state.copyWith(
      calibration: updated,
      frames: <AlgorithmFrame>[neutralFrame],
      latestFrame: neutralFrame,
      lastThermalContactEvent: null,
      lastButtonEvent: null,
      buttonIsPressed: false,
      activePolarity: updated.effectivePolarity,
      isCapturingAmbient: false,
      errorMessage: null,
    );
    unawaited(_persistCalibration(updated));
  }

  CalibrationProfile _buildCalibrationProfile({
    required String deviceKey,
    required double ambientEstimateC,
    required AlgorithmLabConfig config,
    required DateTime calibratedAt,
    DateTime? ambientUpdatedAt,
  }) {
    final inferred = _inferPolarityFromAmbient(
      ambientEstimateC,
      config.skinReferenceC,
      config.ambientDeadbandC,
    );
    final effective = config.polarityMode == PolarityMode.manualOverride
        ? config.manualPolarity
        : inferred;

    return CalibrationProfile(
      deviceKey: deviceKey,
      ambientEstimateC: ambientEstimateC,
      skinReferenceC: config.skinReferenceC,
      deadbandC: config.ambientDeadbandC,
      inferredPolarity: inferred,
      effectivePolarity: effective,
      mode: config.polarityMode,
      calibratedAt: calibratedAt,
      ambientUpdatedAt: ambientUpdatedAt ?? calibratedAt,
    );
  }

  CalibrationProfile? _refreshCalibrationForConfig(
    CalibrationProfile? calibration,
    AlgorithmLabConfig config,
  ) {
    if (calibration == null) return null;
    final inferred = _inferPolarityFromAmbient(
      calibration.ambientEstimateC,
      config.skinReferenceC,
      config.ambientDeadbandC,
    );
    final effective = config.polarityMode == PolarityMode.manualOverride
        ? config.manualPolarity
        : inferred;
    return CalibrationProfile(
      deviceKey: calibration.deviceKey,
      ambientEstimateC: calibration.ambientEstimateC,
      skinReferenceC: config.skinReferenceC,
      deadbandC: config.ambientDeadbandC,
      inferredPolarity: inferred,
      effectivePolarity: effective,
      mode: config.polarityMode,
      calibratedAt: calibration.calibratedAt,
      ambientUpdatedAt: calibration.ambientUpdatedAt,
    );
  }

  PressPolarity _effectivePolarityFromConfig(
    AlgorithmLabConfig config,
    double? ambientC,
  ) {
    if (config.polarityMode == PolarityMode.manualOverride) {
      return config.manualPolarity;
    }
    if (ambientC == null) {
      return PressPolarity.warmingIsPress;
    }
    return _inferPolarityFromAmbient(
      ambientC,
      config.skinReferenceC,
      config.ambientDeadbandC,
    );
  }

  PressPolarity _inferPolarityFromAmbient(
    double ambientC,
    double skinReferenceC,
    double deadbandC,
  ) {
    if (ambientC < (skinReferenceC - deadbandC)) {
      return PressPolarity.warmingIsPress;
    }
    if (ambientC > (skinReferenceC + deadbandC)) {
      return PressPolarity.coolingIsPress;
    }
    return PressPolarity.warmingIsPress;
  }

  AlgorithmFrame _buildNeutralFrame({
    required double baseline,
    required double raw,
    required PressPolarity polarity,
  }) {
    return AlgorithmFrame(
      timestamp: DateTime.now(),
      rawCelsius: raw,
      smoothedCelsius: baseline,
      baselineCelsius: baseline,
      deltaCelsius: 0.0,
      deltaNormSigned: 0.0,
      levelNorm: 0.0,
      motionNorm: 0.0,
      thermalInfluenceLevel: 0,
      lunarAccelNorm: 0.0,
      pitchNorm: 0.0,
      pitchHz: state.config.pitchMinHz,
      volumeNorm: 0.0,
      buttonIsPressed: false,
      activePolarity: polarity,
      ambientEstimateC: baseline,
      ambientTrackingActive: false,
      polarityPendingSwitch: false,
      buttonDirectedDeltaC: 0.0,
      directedSlopeCps: 0.0,
      directedAccelCps2: 0.0,
      thermalContactEvent: null,
      buttonEvent: null,
    );
  }

  List<AlgorithmFrame> _nextFramesWith(AlgorithmFrame frame) {
    final next = List<AlgorithmFrame>.from(state.frames)..add(frame);
    if (next.length > _maxFrames) {
      next.removeRange(0, next.length - _maxFrames);
    }
    return next;
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    final defaults = AlgorithmLabConfig.defaults();
    var config = AlgorithmLabConfig.fromMap({
      'sampleRateHz': prefs.getInt('$_prefPrefix.sampleRateHz'),
      'smoothAlpha': prefs.getDouble('$_prefPrefix.smoothAlpha'),
      'baselineAlphaIdle': prefs.getDouble('$_prefPrefix.baselineAlphaIdle'),
      'baselineAlphaActive': prefs.getDouble(
        '$_prefPrefix.baselineAlphaActive',
      ),
      'quantileWindowSamples': prefs.getInt(
        '$_prefPrefix.quantileWindowSamples',
      ),
      'levelHysteresis': prefs.getDouble('$_prefPrefix.levelHysteresis'),
      'debounceSamples': prefs.getInt('$_prefPrefix.debounceSamples'),
      'accelGamma': prefs.getDouble('$_prefPrefix.accelGamma'),
      'pitchGamma': prefs.getDouble('$_prefPrefix.pitchGamma'),
      'volumeGamma': prefs.getDouble('$_prefPrefix.volumeGamma'),
      'pitchMinHz': prefs.getDouble('$_prefPrefix.pitchMinHz'),
      'pitchMaxHz': prefs.getDouble('$_prefPrefix.pitchMaxHz'),
      'skinReferenceC': prefs.getDouble('$_prefPrefix.skinReferenceC'),
      'ambientDeadbandC': prefs.getDouble('$_prefPrefix.ambientDeadbandC'),
      'polarityMode': prefs.getInt('$_prefPrefix.polarityMode'),
      'manualPolarity': prefs.getInt('$_prefPrefix.manualPolarity'),
      'buttonAccelThresholdCps2': prefs.getDouble(
        '$_prefPrefix.buttonAccelThresholdCps2',
      ),
      'buttonDebounceMs': prefs.getInt('$_prefPrefix.buttonDebounceMs'),
      'ambientAutoEnabled': prefs.getBool('$_prefPrefix.ambientAutoEnabled'),
      'ambientTrackAlpha': prefs.getDouble('$_prefPrefix.ambientTrackAlpha'),
      'ambientTrackMotionNormMax': prefs.getDouble(
        '$_prefPrefix.ambientTrackMotionNormMax',
      ),
      'ambientTrackDeltaNormMax': prefs.getDouble(
        '$_prefPrefix.ambientTrackDeltaNormMax',
      ),
      'ambientTrackSlopeMaxCps': prefs.getDouble(
        '$_prefPrefix.ambientTrackSlopeMaxCps',
      ),
      'ambientTrackAccelMaxCps2': prefs.getDouble(
        '$_prefPrefix.ambientTrackAccelMaxCps2',
      ),
      'polaritySwitchHysteresisC': prefs.getDouble(
        '$_prefPrefix.polaritySwitchHysteresisC',
      ),
      'polaritySwitchConfirmSamples': prefs.getInt(
        '$_prefPrefix.polaritySwitchConfirmSamples',
      ),
    }, fallback: defaults);
    final storedRevision =
        prefs.getInt('$_prefPrefix.binaryTuningRevision') ?? 0;
    if (storedRevision < _binaryTuningRevision) {
      config = config
          .copyWith(buttonAccelThresholdCps2: defaults.buttonAccelThresholdCps2)
          .clamped();
      unawaited(
        prefs.setInt(
          '$_prefPrefix.binaryTuningRevision',
          _binaryTuningRevision,
        ),
      );
      unawaited(prefs.remove('$_prefPrefix.buttonResponsePreset'));
      unawaited(prefs.remove('$_prefPrefix.buttonPressSlopeCps'));
      unawaited(prefs.remove('$_prefPrefix.buttonReleaseSlopeCps'));
      unawaited(prefs.remove('$_prefPrefix.buttonEdgeAlpha'));
      unawaited(prefs.remove('$_prefPrefix.buttonSlopeThresholdCps'));
      unawaited(prefs.remove('$_prefPrefix.buttonUseAccelOnly'));
    }

    final sourceIndex = prefs.getInt('$_prefPrefix.inputSource') ?? 1;
    final scenarioIndex = prefs.getInt('$_prefPrefix.simulatorScenario') ?? 4;
    final advancedControlsExpanded =
        prefs.getBool('$_prefPrefix.advancedControlsExpanded') ?? false;

    final source =
        AlgorithmLabInputSource.values[sourceIndex.clamp(
          0,
          AlgorithmLabInputSource.values.length - 1,
        )];
    final scenario = SimulatorScenario
        .values[scenarioIndex.clamp(0, SimulatorScenario.values.length - 1)];

    state = state.copyWith(
      config: config,
      inputSource: source,
      simulatorScenario: scenario,
      advancedControlsExpanded: advancedControlsExpanded,
      activePolarity: _effectivePolarityFromConfig(config, null),
    );
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(_persistToPrefs());
    });
  }

  Future<void> _persistToPrefs() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final config = state.config.toMap();
    await prefs.setInt(
      '$_prefPrefix.binaryTuningRevision',
      _binaryTuningRevision,
    );
    await prefs.setInt('$_prefPrefix.inputSource', state.inputSource.index);
    await prefs.setInt(
      '$_prefPrefix.simulatorScenario',
      state.simulatorScenario.index,
    );
    await prefs.setBool(
      '$_prefPrefix.advancedControlsExpanded',
      state.advancedControlsExpanded,
    );

    await prefs.setInt(
      '$_prefPrefix.sampleRateHz',
      config['sampleRateHz'] as int,
    );
    await prefs.setDouble(
      '$_prefPrefix.smoothAlpha',
      config['smoothAlpha'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.baselineAlphaIdle',
      config['baselineAlphaIdle'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.baselineAlphaActive',
      config['baselineAlphaActive'] as double,
    );
    await prefs.setInt(
      '$_prefPrefix.quantileWindowSamples',
      config['quantileWindowSamples'] as int,
    );
    await prefs.setDouble(
      '$_prefPrefix.levelHysteresis',
      config['levelHysteresis'] as double,
    );
    await prefs.setInt(
      '$_prefPrefix.debounceSamples',
      config['debounceSamples'] as int,
    );
    await prefs.setDouble(
      '$_prefPrefix.accelGamma',
      config['accelGamma'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.pitchGamma',
      config['pitchGamma'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.volumeGamma',
      config['volumeGamma'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.pitchMinHz',
      config['pitchMinHz'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.pitchMaxHz',
      config['pitchMaxHz'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.skinReferenceC',
      config['skinReferenceC'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.ambientDeadbandC',
      config['ambientDeadbandC'] as double,
    );
    await prefs.setInt(
      '$_prefPrefix.polarityMode',
      config['polarityMode'] as int,
    );
    await prefs.setInt(
      '$_prefPrefix.manualPolarity',
      config['manualPolarity'] as int,
    );
    await prefs.setDouble(
      '$_prefPrefix.buttonAccelThresholdCps2',
      config['buttonAccelThresholdCps2'] as double,
    );
    await prefs.setInt(
      '$_prefPrefix.buttonDebounceMs',
      config['buttonDebounceMs'] as int,
    );
    await prefs.setBool(
      '$_prefPrefix.ambientAutoEnabled',
      config['ambientAutoEnabled'] as bool,
    );
    await prefs.setDouble(
      '$_prefPrefix.ambientTrackAlpha',
      config['ambientTrackAlpha'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.ambientTrackMotionNormMax',
      config['ambientTrackMotionNormMax'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.ambientTrackDeltaNormMax',
      config['ambientTrackDeltaNormMax'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.ambientTrackSlopeMaxCps',
      config['ambientTrackSlopeMaxCps'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.ambientTrackAccelMaxCps2',
      config['ambientTrackAccelMaxCps2'] as double,
    );
    await prefs.setDouble(
      '$_prefPrefix.polaritySwitchHysteresisC',
      config['polaritySwitchHysteresisC'] as double,
    );
    await prefs.setInt(
      '$_prefPrefix.polaritySwitchConfirmSamples',
      config['polaritySwitchConfirmSamples'] as int,
    );
  }

  Future<void> _persistCalibration(CalibrationProfile profile) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final prefix = _calibrationPrefix(profile.deviceKey);
    final map = profile.toMap();
    await prefs.setString('$prefix.deviceKey', map['deviceKey'] as String);
    await prefs.setDouble(
      '$prefix.ambientEstimateC',
      map['ambientEstimateC'] as double,
    );
    await prefs.setDouble('$prefix.ambientC', map['ambientC'] as double);
    await prefs.setDouble(
      '$prefix.skinReferenceC',
      map['skinReferenceC'] as double,
    );
    await prefs.setDouble('$prefix.deadbandC', map['deadbandC'] as double);
    await prefs.setInt(
      '$prefix.inferredPolarity',
      map['inferredPolarity'] as int,
    );
    await prefs.setInt(
      '$prefix.effectivePolarity',
      map['effectivePolarity'] as int,
    );
    await prefs.setInt('$prefix.mode', map['mode'] as int);
    await prefs.setString(
      '$prefix.calibratedAt',
      map['calibratedAt'] as String,
    );
    await prefs.setString(
      '$prefix.ambientUpdatedAt',
      map['ambientUpdatedAt'] as String,
    );
  }

  String? _currentDeviceKey([String? selectedDeviceOverride]) {
    if (state.inputSource == AlgorithmLabInputSource.simulator) {
      return 'simulator';
    }
    final device = selectedDeviceOverride ?? state.selectedDevice;
    if (device == null || device.isEmpty) return null;
    return device;
  }

  String _calibrationPrefix(String deviceKey) {
    return '$_prefPrefix.calibration.${Uri.encodeComponent(deviceKey)}';
  }

  double _median(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle];
    }
    return (sorted[middle - 1] + sorted[middle]) / 2.0;
  }

  double _lerp(double from, double to, double alpha) {
    return from + ((to - from) * alpha.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _persistTimer?.cancel();
    _calibrationPersistTimer?.cancel();
    final pendingCalibration = _pendingCalibrationPersist;
    if (pendingCalibration != null) {
      unawaited(_persistCalibration(pendingCalibration));
      _pendingCalibrationPersist = null;
    }
    _sampleSubscription?.cancel();
    final source = _source;
    if (source is SimulatedTemperatureSource) {
      unawaited(source.dispose());
    } else {
      unawaited(source?.stop());
    }
    super.dispose();
  }
}

class _AdaptiveAmbientUpdate {
  const _AdaptiveAmbientUpdate({
    required this.frame,
    required this.calibration,
    required this.activePolarity,
  });

  final AlgorithmFrame frame;
  final CalibrationProfile calibration;
  final PressPolarity activePolarity;
}
