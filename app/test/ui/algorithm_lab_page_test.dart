import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/live_temperature_gateway.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/algorithm_lab_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Mode switch updates source controls', (tester) async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scan Devices'), findsOneWidget);
    await tester.tap(find.text('Simulator').first);
    await tester.pump(const Duration(milliseconds: 180));
    expect(find.text('Simulator Scenario'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await gateway.dispose();
  });

  testWidgets('Recalibrate quickly resets baseline-driven outputs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    final controller = container.read(algorithmLabControllerProvider.notifier);
    await controller.setInputSource(AlgorithmLabInputSource.live);
    await tester.pumpAndSettle();

    var timestamp = DateTime(2026, 1, 1, 0, 0, 0);
    for (var i = 0; i < 8; i += 1) {
      controller.processSample(
        TemperatureSample(timestamp: timestamp, rawCelsius: 22.0),
      );
      timestamp = timestamp.add(const Duration(milliseconds: 100));
    }
    for (var i = 0; i < 12; i += 1) {
      controller.processSample(
        TemperatureSample(timestamp: timestamp, rawCelsius: 24.2),
      );
      timestamp = timestamp.add(const Duration(milliseconds: 100));
    }
    await tester.pump();

    final before = container.read(algorithmLabControllerProvider).latestFrame;
    expect(before, isNotNull);
    expect(before!.deltaCelsius, greaterThan(0.2));

    await tester.scrollUntilVisible(
      find.text('Advanced Manual Tuning'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Advanced Manual Tuning'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Recalibrate'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Recalibrate'));
    await tester.pump();

    final after = container.read(algorithmLabControllerProvider).latestFrame;
    expect(after, isNotNull);
    expect(after!.deltaCelsius.abs(), lessThan(0.0001));
    expect(after.thermalInfluenceLevel, 0);
    expect(after.buttonIsPressed, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await gateway.dispose();
  });

  testWidgets('Calibration controls render and polarity mode toggles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Capture Ambient Seed'), findsOneWidget);
    expect(find.text('Ambient Auto'), findsOneWidget);
    expect(find.text('Thermal Influence Level'), findsOneWidget);
    expect(find.text('Button State'), findsOneWidget);
    expect(find.textContaining('Polarity switch pending:'), findsOneWidget);
    expect(find.text('Ambient Quiet Slope Max (C/s)'), findsOneWidget);
    expect(find.text('Ambient Quiet Accel Max (C/s^2)'), findsOneWidget);
    expect(find.text('Release Confidence'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Manual').first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Manual').first);
    await tester.pump();
    final state = container.read(algorithmLabControllerProvider);
    expect(state.config.polarityMode, PolarityMode.manualOverride);
    expect(find.text('Warm-up=Press'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Advanced Manual Tuning'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Advanced Manual Tuning'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Button Accel Threshold (C/s^2)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Button Accel Threshold (C/s^2)'), findsOneWidget);
    expect(find.text('Button Debounce (ms)'), findsOneWidget);
    expect(find.text('Button Response Preset'), findsNothing);
    expect(find.text('Guided Button Calibration'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await gateway.dispose();
  });

  testWidgets('button tuning updates via controller', (tester) async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    var state = container.read(algorithmLabControllerProvider);
    final previousAccel = state.config.buttonAccelThresholdCps2;
    final previousDebounce = state.config.buttonDebounceMs;

    container
        .read(algorithmLabControllerProvider.notifier)
        .updateButtonAccelThresholdCps2((previousAccel + 0.1).clamp(0.01, 1.0));
    container
        .read(algorithmLabControllerProvider.notifier)
        .updateButtonDebounceMs((previousDebounce + 100).clamp(200, 1500));
    await tester.pump();

    state = container.read(algorithmLabControllerProvider);
    expect(state.config.buttonAccelThresholdCps2, isNot(previousAccel));
    expect(state.config.buttonDebounceMs, isNot(previousDebounce));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await gateway.dispose();
  });

  testWidgets('Persisted settings reload after widget rebuild', (tester) async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container1 = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container1,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    final controller1 = container1.read(
      algorithmLabControllerProvider.notifier,
    );
    controller1.updateSmoothAlpha(0.71);
    controller1.updateSkinReferenceC(34.2);
    controller1.updateButtonAccelThresholdCps2(0.42);
    controller1.updateButtonDebounceMs(900);
    await tester.pump(const Duration(milliseconds: 400));

    container1.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final container2 = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container2,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    final reloaded = container2.read(algorithmLabControllerProvider).config;
    expect(reloaded.smoothAlpha, closeTo(0.71, 0.001));
    expect(reloaded.skinReferenceC, closeTo(34.2, 0.001));
    expect(reloaded.buttonAccelThresholdCps2, closeTo(0.42, 0.001));
    expect(reloaded.buttonDebounceMs, 900);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container2.dispose();
    await gateway.dispose();
  });

  testWidgets('guided calibration panel and preset controls are removed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'algorithm_lab.inputSource': 0});
    final gateway = _FakeLiveTemperatureGateway();
    final container = ProviderContainer(
      overrides: [liveTemperatureGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(() async {
      container.dispose();
      await gateway.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AlgorithmLabPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Guided Button Calibration'), findsNothing);
    expect(find.text('Start Guided Calibration'), findsNothing);
    expect(find.text('Button Response Preset'), findsNothing);
    expect(find.text('Advanced Manual Tuning'), findsOneWidget);
    expect(find.text('Smoothing Alpha'), findsNothing);
  });
}

class _FakeLiveTemperatureGateway implements LiveTemperatureGateway {
  final StreamController<TemperatureSample> _controller =
      StreamController<TemperatureSample>.broadcast();

  bool _connected = false;

  @override
  Stream<TemperatureSample> get samples => _controller.stream;

  @override
  Future<List<String>> getDevices() async => const ['FAKE-1'];

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

  Future<void> dispose() async {
    await _controller.close();
  }
}
