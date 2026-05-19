import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/live_temperature_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'live mode processes incoming stream samples into frames and events',
    () async {
      SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
      final gateway = _FakeLiveTemperatureGateway();
      final container = ProviderContainer(
        overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(() async {
        container.dispose();
        await gateway.dispose();
      });

      final controller = container.read(
        algorithmLabControllerProvider.notifier,
      );
      for (var i = 0; i < 50; i += 1) {
        if (container.read(algorithmLabControllerProvider).isInitialized) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      await controller.setInputSource(AlgorithmLabInputSource.live);
      await controller.scanDevices();
      controller.selectDevice('FAKE-1');
      await controller.connectSelectedDevice();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(
        container.read(algorithmLabControllerProvider).isInitialized,
        isTrue,
      );
      expect(
        container.read(algorithmLabControllerProvider).isLiveConnected,
        isTrue,
      );

      var now = DateTime(2026, 1, 1, 0, 0, 0);
      for (var i = 0; i < 12; i += 1) {
        gateway.push(TemperatureSample(timestamp: now, rawCelsius: 22.0));
        now = now.add(const Duration(milliseconds: 100));
      }
      // Ramp up steadily to keep slope above press threshold.
      for (var i = 0; i < 12; i += 1) {
        gateway.push(
          TemperatureSample(
            timestamp: now,
            rawCelsius: 22.0 + ((i + 1) * 0.18),
          ),
        );
        now = now.add(const Duration(milliseconds: 100));
      }

      await Future<void>.delayed(const Duration(milliseconds: 120));
      final state = container.read(algorithmLabControllerProvider);
      expect(state.errorMessage, isNull);
      expect(state.latestFrame, isNotNull);
      expect(state.frames, isNotEmpty);
      expect(state.lastThermalContactEvent, isNotNull);
      expect(state.latestFrame!.thermalInfluenceLevel, greaterThan(0));
      expect(state.lastButtonEvent, isNotNull);
      expect(state.lastButtonEvent!.type, ButtonEventType.buttonDown);
      expect(state.frames.any((frame) => frame.buttonIsPressed), isTrue);

      await controller.disconnectLiveDevice();
      expect(
        container.read(algorithmLabControllerProvider).isLiveConnected,
        isFalse,
      );
    },
  );
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
