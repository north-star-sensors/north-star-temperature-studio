import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/live_temperature_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('capture ambient computes median and inferred polarity', () async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(() async {
      container.dispose();
      await gateway.dispose();
    });

    final controller = container.read(algorithmLabControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await controller.setInputSource(AlgorithmLabInputSource.live);
    await controller.scanDevices();
    controller.selectDevice('FAKE-1');
    await controller.connectSelectedDevice();

    controller.captureAmbient();
    var now = DateTime(2026, 1, 1, 0, 0, 0);
    final ambientValues = <double>[
      30.1,
      30.0,
      30.2,
      30.1,
      29.9,
      30.0,
      30.2,
      30.0,
      30.1,
      29.8,
      30.3,
      30.1,
      30.0,
      30.2,
      29.9,
      30.0,
      30.1,
      30.2,
      30.0,
      30.1,
    ];
    for (final value in ambientValues) {
      gateway.push(TemperatureSample(timestamp: now, rawCelsius: value));
      now = now.add(const Duration(milliseconds: 100));
    }

    await Future<void>.delayed(const Duration(milliseconds: 150));
    final state = container.read(algorithmLabControllerProvider);
    expect(state.calibration, isNotNull);
    expect(state.calibration!.ambientC, closeTo(30.1, 0.2));
    expect(state.calibration!.inferredPolarity, PressPolarity.warmingIsPress);
    expect(state.activePolarity, PressPolarity.warmingIsPress);
  });

  test('manual override supersedes auto inferred polarity', () async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(() async {
      container.dispose();
      await gateway.dispose();
    });

    final controller = container.read(algorithmLabControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await controller.setInputSource(AlgorithmLabInputSource.live);
    await controller.scanDevices();
    controller.selectDevice('FAKE-1');
    await controller.connectSelectedDevice();

    controller.captureAmbient();
    var now = DateTime(2026, 1, 1, 0, 0, 0);
    for (var i = 0; i < 20; i += 1) {
      gateway.push(TemperatureSample(timestamp: now, rawCelsius: 39.0));
      now = now.add(const Duration(milliseconds: 100));
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));

    controller.updatePolarityMode(PolarityMode.manualOverride);
    controller.updateManualPolarity(PressPolarity.warmingIsPress);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final state = container.read(algorithmLabControllerProvider);
    expect(state.calibration, isNotNull);
    expect(state.calibration!.inferredPolarity, PressPolarity.coolingIsPress);
    expect(state.calibration!.effectivePolarity, PressPolarity.warmingIsPress);
    expect(state.activePolarity, PressPolarity.warmingIsPress);
  });

  test(
    'per-device calibration profile restores after device switch and restart',
    () async {
      SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
      final gateway = _FakeLiveTemperatureGateway();
      final container1 = ProviderContainer(
        overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
      );

      final controller1 = container1.read(
        algorithmLabControllerProvider.notifier,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await controller1.setInputSource(AlgorithmLabInputSource.live);
      await controller1.scanDevices();
      controller1.selectDevice('FAKE-1');
      await controller1.connectSelectedDevice();

      controller1.captureAmbient();
      var now = DateTime(2026, 1, 1, 0, 0, 0);
      for (var i = 0; i < 20; i += 1) {
        gateway.push(TemperatureSample(timestamp: now, rawCelsius: 39.0));
        now = now.add(const Duration(milliseconds: 100));
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));

      controller1.selectDevice('FAKE-2');
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(
        container1.read(algorithmLabControllerProvider).calibration,
        isNull,
      );

      controller1.selectDevice('FAKE-1');
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(
        container1.read(algorithmLabControllerProvider).calibration?.ambientC,
        closeTo(39.0, 0.2),
      );

      container1.dispose();

      final container2 = ProviderContainer(
        overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(() async {
        container2.dispose();
        await gateway.dispose();
      });

      final controller2 = container2.read(
        algorithmLabControllerProvider.notifier,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await controller2.setInputSource(AlgorithmLabInputSource.live);
      await controller2.scanDevices();
      controller2.selectDevice('FAKE-1');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final reloaded = container2.read(algorithmLabControllerProvider);
      expect(reloaded.calibration, isNotNull);
      expect(reloaded.calibration!.ambientC, closeTo(39.0, 0.2));
    },
  );

  test('adaptive ambient monitor tracks slow +2C drift', () async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(() async {
      container.dispose();
      await gateway.dispose();
    });

    final controller = container.read(algorithmLabControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await controller.setInputSource(AlgorithmLabInputSource.live);
    await controller.scanDevices();
    controller.selectDevice('FAKE-1');
    await controller.connectSelectedDevice();

    var now = DateTime(2026, 1, 1, 0, 0, 0);
    const totalSamples = 6000; // 10 minutes at 10Hz
    for (var i = 0; i < totalSamples; i += 1) {
      final raw = 22.0 + (2.0 * (i / (totalSamples - 1)));
      controller.processSample(TemperatureSample(timestamp: now, rawCelsius: raw));
      now = now.add(const Duration(milliseconds: 100));
    }

    final state = container.read(algorithmLabControllerProvider);
    expect(state.calibration, isNotNull);
    expect(state.calibration!.ambientEstimateC, closeTo(24.0, 0.3));
  });

  test('auto polarity switches to cooling after sustained hot ambient', () async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(() async {
      container.dispose();
      await gateway.dispose();
    });

    final controller = container.read(algorithmLabControllerProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await controller.setInputSource(AlgorithmLabInputSource.live);
    await controller.scanDevices();
    controller.selectDevice('FAKE-1');
    await controller.connectSelectedDevice();
    controller.updatePolaritySwitchConfirmSamples(5);

    var now = DateTime(2026, 1, 1, 0, 0, 0);
    for (var i = 0; i < 60; i += 1) {
      controller.processSample(
        TemperatureSample(timestamp: now, rawCelsius: 34.0),
      );
      now = now.add(const Duration(milliseconds: 100));
    }
    expect(
      container.read(algorithmLabControllerProvider).activePolarity,
      PressPolarity.warmingIsPress,
    );

    for (var i = 0; i < 20; i += 1) {
      controller.processSample(
        TemperatureSample(timestamp: now, rawCelsius: 39.0),
      );
      now = now.add(const Duration(milliseconds: 100));
    }
    controller.recalibrate();

    for (var i = 0; i < 320; i += 1) {
      controller.processSample(
        TemperatureSample(timestamp: now, rawCelsius: 39.0),
      );
      now = now.add(const Duration(milliseconds: 100));
    }

    final state = container.read(algorithmLabControllerProvider);
    expect(state.calibration, isNotNull);
    expect(state.activePolarity, PressPolarity.coolingIsPress);
    expect(state.latestFrame, isNotNull);
    expect(state.latestFrame!.polarityPendingSwitch, isFalse);
  });
}

class _FakeLiveTemperatureGateway implements LiveTemperatureGateway {
  final StreamController<TemperatureSample> _controller =
      StreamController<TemperatureSample>.broadcast();

  bool _connected = false;

  @override
  Stream<TemperatureSample> get samples => _controller.stream;

  @override
  Future<List<String>> getDevices() async => const ['FAKE-1', 'FAKE-2'];

  @override
  Future<void> connect(String deviceId) async {
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  bool get isConnected => _connected;

  void push(TemperatureSample sample) {
    _controller.add(sample);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
