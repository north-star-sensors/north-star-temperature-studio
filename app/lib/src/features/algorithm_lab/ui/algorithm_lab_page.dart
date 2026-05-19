import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/features/algorithm_lab/models/algorithm_lab_models.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/widgets/algorithm_signals_chart.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/widgets/labeled_slider.dart';
import 'package:temperature_studio/src/features/algorithm_lab/ui/widgets/output_metric_card.dart';
import 'package:temperature_studio/src/ui/theme/app_theme.dart';

class AlgorithmLabPage extends ConsumerWidget {
  const AlgorithmLabPage({super.key});

  static const String routeName = '/algorithm-lab';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(algorithmLabControllerProvider);
    final controller = ref.read(algorithmLabControllerProvider.notifier);
    final frame = state.latestFrame;

    return Scaffold(
      appBar: AppBar(title: const Text('Algorithm Lab')),
      body: SafeArea(
        child: state.isInitialized
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSourceSection(context, state, controller),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Card(
                      child: SizedBox(
                        height: 300,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AlgorithmSignalsChart(frames: state.frames),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOutputs(
                      context: context,
                      frame: frame,
                      lastThermalContactEvent: state.lastThermalContactEvent,
                      lastButtonEvent: state.lastButtonEvent,
                      activePolarity: state.activePolarity,
                    ),
                    const SizedBox(height: 12),
                    _buildCalibrationSection(state, controller),
                    const SizedBox(height: 12),
                    _buildControls(state, controller),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildSourceSection(
    BuildContext context,
    AlgorithmLabState state,
    AlgorithmLabController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Source',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<AlgorithmLabInputSource>(
              segments: const [
                ButtonSegment<AlgorithmLabInputSource>(
                  value: AlgorithmLabInputSource.simulator,
                  label: Text('Simulator'),
                  icon: Icon(Icons.memory),
                ),
                ButtonSegment<AlgorithmLabInputSource>(
                  value: AlgorithmLabInputSource.live,
                  label: Text('Live'),
                  icon: Icon(Icons.usb),
                ),
              ],
              selected: <AlgorithmLabInputSource>{state.inputSource},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  controller.setInputSource(selection.first);
                }
              },
            ),
            const SizedBox(height: 12),
            if (state.inputSource == AlgorithmLabInputSource.simulator)
              Row(
                children: [
                  const Text('Simulator Scenario'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<SimulatorScenario>(
                      key: ValueKey('scenario-${state.simulatorScenario.name}'),
                      initialValue: state.simulatorScenario,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: SimulatorScenario.values.map((scenario) {
                        return DropdownMenuItem(
                          value: scenario,
                          child: Text(_scenarioLabel(scenario)),
                        );
                      }).toList(),
                      onChanged: (scenario) {
                        if (scenario != null) {
                          controller.setSimulatorScenario(scenario);
                        }
                      },
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: state.isScanningDevices
                            ? null
                            : controller.scanDevices,
                        icon: state.isScanningDevices
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: const Text('Scan Devices'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        state.isLiveConnected ? 'Connected' : 'Not Connected',
                        style: TextStyle(
                          color: state.isLiveConnected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(
                            'device-${state.selectedDevice ?? 'none'}',
                          ),
                          initialValue:
                              state.availableDevices.contains(
                                state.selectedDevice,
                              )
                              ? state.selectedDevice
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Device',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: state.availableDevices.map((device) {
                            return DropdownMenuItem(
                              value: device,
                              child: Text(device),
                            );
                          }).toList(),
                          onChanged: controller.selectDevice,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: state.isLiveConnected
                            ? controller.disconnectLiveDevice
                            : (state.selectedDevice == null
                                  ? null
                                  : controller.connectSelectedDevice),
                        child: Text(
                          state.isLiveConnected ? 'Disconnect' : 'Connect',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputs({
    required BuildContext context,
    required AlgorithmFrame? frame,
    required ThermalContactEvent? lastThermalContactEvent,
    required ButtonEvent? lastButtonEvent,
    required PressPolarity activePolarity,
  }) {
    final pitchText = frame == null
        ? '--'
        : '${frame.pitchNorm.toStringAsFixed(2)}  (${frame.pitchHz.toStringAsFixed(0)} Hz)';
    final thermalEventText = lastThermalContactEvent == null
        ? 'None'
        : '${_thermalEventLabel(lastThermalContactEvent.type)} (level ${lastThermalContactEvent.level})';
    final buttonEventText = lastButtonEvent == null
        ? 'None'
        : _buttonEventLabel(lastButtonEvent.type);

    return Wrap(
      children: [
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Thermal Influence Level',
            value: frame?.thermalInfluenceLevel.toString() ?? '--',
            normalized: frame == null
                ? null
                : frame.thermalInfluenceLevel / 5.0,
            color: metricColor(context, MetricKind.thermalInfluence),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Button State',
            value: frame == null
                ? '--'
                : (frame.buttonIsPressed ? 'Press Detected' : 'Idle'),
            subtitle: 'Last press: $buttonEventText',
            normalized: frame == null
                ? null
                : (frame.buttonIsPressed ? 1.0 : 0.0),
            color: frame?.buttonIsPressed == true
                ? metricColor(context, MetricKind.buttonPressed)
                : metricColor(context, MetricKind.buttonIdle),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Active Polarity',
            value: _polarityLabel(activePolarity),
            subtitle: 'Calibration-driven direction',
            color: metricColor(context, MetricKind.polarity),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Ambient Monitor',
            value: frame == null
                ? '--'
                : frame.ambientEstimateC.toStringAsFixed(2),
            subtitle: frame == null
                ? 'Tracking: --'
                : 'Tracking: ${frame.ambientTrackingActive ? 'Active' : 'Paused'}  |  Pending: ${frame.polarityPendingSwitch ? 'Yes' : 'No'}',
            color: frame?.ambientTrackingActive == true
                ? metricColor(context, MetricKind.ambientActive)
                : metricColor(context, MetricKind.ambientPaused),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Directed Slope (C/s)',
            value: frame == null
                ? '--'
                : frame.directedSlopeCps.toStringAsFixed(4),
            color: metricColor(context, MetricKind.directedSlope),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Directed Accel (C/s^2)',
            value: frame == null
                ? '--'
                : frame.directedAccelCps2.toStringAsFixed(4),
            color: metricColor(context, MetricKind.directedAccel),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Lunar Accel',
            value: frame?.lunarAccelNorm.toStringAsFixed(2) ?? '--',
            subtitle: 'Range: -1..1',
            normalized: frame == null ? null : ((frame.lunarAccelNorm + 1) / 2),
            color: metricColor(context, MetricKind.lunarAccel),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Pitch',
            value: pitchText,
            normalized: frame?.pitchNorm,
            color: metricColor(context, MetricKind.pitch),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Volume',
            value: frame?.volumeNorm.toStringAsFixed(2) ?? '--',
            normalized: frame?.volumeNorm,
            subtitle: 'From motion envelope',
            color: metricColor(context, MetricKind.volume),
          ),
        ),
        SizedBox(
          width: 250,
          child: OutputMetricCard(
            title: 'Thermal Contact Event',
            value: thermalEventText,
            color: metricColor(context, MetricKind.thermalContact),
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationSection(
    AlgorithmLabState state,
    AlgorithmLabController controller,
  ) {
    final frame = state.latestFrame;
    final ambientEstimate =
        frame?.ambientEstimateC ?? state.calibration?.ambientEstimateC;
    final trackingActive = frame?.ambientTrackingActive ?? false;
    final pendingSwitch = frame?.polarityPendingSwitch ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calibration', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            LabeledSlider(
              label: 'Skin Reference (C)',
              value: state.config.skinReferenceC,
              min: 25.0,
              max: 45.0,
              onChanged: controller.updateSkinReferenceC,
              valueFormatter: (value) => value.toStringAsFixed(1),
            ),
            LabeledSlider(
              label: 'Ambient Deadband (C)',
              value: state.config.ambientDeadbandC,
              min: 0.0,
              max: 4.0,
              onChanged: controller.updateAmbientDeadbandC,
              valueFormatter: (value) => value.toStringAsFixed(2),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ambient Auto'),
              value: state.config.ambientAutoEnabled,
              onChanged: controller.updateAmbientAutoEnabled,
            ),
            LabeledSlider(
              label: 'Ambient Track Alpha',
              value: state.config.ambientTrackAlpha,
              min: 0.001,
              max: 0.20,
              onChanged: controller.updateAmbientTrackAlpha,
              valueFormatter: (value) => value.toStringAsFixed(3),
            ),
            LabeledSlider(
              label: 'Ambient Quiet Motion Max',
              value: state.config.ambientTrackMotionNormMax,
              min: 0.01,
              max: 0.8,
              onChanged: controller.updateAmbientTrackMotionNormMax,
              valueFormatter: (value) => value.toStringAsFixed(2),
            ),
            LabeledSlider(
              label: 'Ambient Quiet Delta Max',
              value: state.config.ambientTrackDeltaNormMax,
              min: 0.01,
              max: 0.8,
              onChanged: controller.updateAmbientTrackDeltaNormMax,
              valueFormatter: (value) => value.toStringAsFixed(2),
            ),
            LabeledSlider(
              label: 'Ambient Quiet Slope Max (C/s)',
              value: state.config.ambientTrackSlopeMaxCps,
              min: 0.0005,
              max: 0.03,
              onChanged: controller.updateAmbientTrackSlopeMaxCps,
              valueFormatter: (value) => value.toStringAsFixed(4),
            ),
            LabeledSlider(
              label: 'Ambient Quiet Accel Max (C/s^2)',
              value: state.config.ambientTrackAccelMaxCps2,
              min: 0.001,
              max: 0.12,
              onChanged: controller.updateAmbientTrackAccelMaxCps2,
              valueFormatter: (value) => value.toStringAsFixed(3),
            ),
            LabeledSlider(
              label: 'Polarity Switch Hysteresis (C)',
              value: state.config.polaritySwitchHysteresisC,
              min: 0.0,
              max: 1.5,
              onChanged: controller.updatePolaritySwitchHysteresisC,
              valueFormatter: (value) => value.toStringAsFixed(2),
            ),
            LabeledSlider(
              label: 'Polarity Switch Confirm Samples',
              value: state.config.polaritySwitchConfirmSamples.toDouble(),
              min: 1,
              max: 80,
              divisions: 79,
              onChanged: (value) {
                controller.updatePolaritySwitchConfirmSamples(value.round());
              },
              valueFormatter: (value) => value.round().toString(),
            ),
            const SizedBox(height: 4),
            SegmentedButton<PolarityMode>(
              segments: const [
                ButtonSegment<PolarityMode>(
                  value: PolarityMode.autoFromAmbient,
                  label: Text('Auto'),
                ),
                ButtonSegment<PolarityMode>(
                  value: PolarityMode.manualOverride,
                  label: Text('Manual'),
                ),
              ],
              selected: <PolarityMode>{state.config.polarityMode},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  controller.updatePolarityMode(selection.first);
                }
              },
            ),
            const SizedBox(height: 8),
            if (state.config.polarityMode == PolarityMode.manualOverride)
              SegmentedButton<PressPolarity>(
                segments: const [
                  ButtonSegment<PressPolarity>(
                    value: PressPolarity.warmingIsPress,
                    label: Text('Warm-up=Press'),
                  ),
                  ButtonSegment<PressPolarity>(
                    value: PressPolarity.coolingIsPress,
                    label: Text('Cool-down=Press'),
                  ),
                ],
                selected: <PressPolarity>{state.config.manualPolarity},
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    controller.updateManualPolarity(selection.first);
                  }
                },
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: state.isCapturingAmbient
                      ? null
                      : controller.captureAmbient,
                  icon: state.isCapturingAmbient
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.thermostat),
                  label: const Text('Capture Ambient Seed'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ambientEstimate == null
                        ? 'Ambient Estimate: --'
                        : 'Ambient Estimate: ${ambientEstimate.toStringAsFixed(2)} C',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Tracking: ${trackingActive ? 'Active' : 'Paused'}'),
            Text('Polarity: ${_polarityLabel(state.activePolarity)}'),
            Text('Polarity switch pending: ${pendingSwitch ? 'Yes' : 'No'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
    AlgorithmLabState state,
    AlgorithmLabController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Controls', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ExpansionTile(
              key: const PageStorageKey<String>(
                'algorithm-lab-advanced-controls',
              ),
              initiallyExpanded: state.advancedControlsExpanded,
              onExpansionChanged: controller.setAdvancedControlsExpanded,
              title: const Text('Advanced Manual Tuning'),
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              children: [
                LabeledSlider(
                  label: 'Smoothing Alpha',
                  value: state.config.smoothAlpha,
                  min: 0.01,
                  max: 0.8,
                  onChanged: controller.updateSmoothAlpha,
                  valueFormatter: (value) => value.toStringAsFixed(3),
                ),
                LabeledSlider(
                  label: 'Baseline Alpha (Idle)',
                  value: state.config.baselineAlphaIdle,
                  min: 0.001,
                  max: 0.2,
                  onChanged: controller.updateBaselineAlphaIdle,
                  valueFormatter: (value) => value.toStringAsFixed(3),
                ),
                LabeledSlider(
                  label: 'Baseline Alpha (Active)',
                  value: state.config.baselineAlphaActive,
                  min: 0.0001,
                  max: 0.05,
                  onChanged: controller.updateBaselineAlphaActive,
                  valueFormatter: (value) => value.toStringAsFixed(4),
                ),
                LabeledSlider(
                  label: 'Quantile Window Samples',
                  value: state.config.quantileWindowSamples.toDouble(),
                  min: 20,
                  max: 400,
                  divisions: 380,
                  onChanged: (value) {
                    controller.updateQuantileWindowSamples(value.round());
                  },
                  valueFormatter: (value) => value.round().toString(),
                ),
                LabeledSlider(
                  label: 'Level Hysteresis',
                  value: state.config.levelHysteresis,
                  min: 0.0,
                  max: 0.2,
                  onChanged: controller.updateLevelHysteresis,
                  valueFormatter: (value) => value.toStringAsFixed(3),
                ),
                LabeledSlider(
                  label: 'Debounce Samples',
                  value: state.config.debounceSamples.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  onChanged: (value) {
                    controller.updateDebounceSamples(value.round());
                  },
                  valueFormatter: (value) => value.round().toString(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Button Detection',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                LabeledSlider(
                  label: 'Button Debounce (ms)',
                  value: state.config.buttonDebounceMs.toDouble(),
                  min: 200,
                  max: 1500,
                  divisions: 65,
                  onChanged: (value) {
                    controller.updateButtonDebounceMs(value.round());
                  },
                  valueFormatter: (value) => value.round().toString(),
                ),
                LabeledSlider(
                  label: 'Button Accel Threshold (C/s^2)',
                  value: state.config.buttonAccelThresholdCps2,
                  min: 0.01,
                  max: 1.0,
                  onChanged: controller.updateButtonAccelThresholdCps2,
                  valueFormatter: (value) => value.toStringAsFixed(3),
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) => Text(
                    'Press trigger is based on directed acceleration.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Output Mapping',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                LabeledSlider(
                  label: 'Accel Gamma',
                  value: state.config.accelGamma,
                  min: 0.2,
                  max: 3.0,
                  onChanged: controller.updateAccelGamma,
                  valueFormatter: (value) => value.toStringAsFixed(2),
                ),
                LabeledSlider(
                  label: 'Pitch Gamma',
                  value: state.config.pitchGamma,
                  min: 0.2,
                  max: 3.0,
                  onChanged: controller.updatePitchGamma,
                  valueFormatter: (value) => value.toStringAsFixed(2),
                ),
                LabeledSlider(
                  label: 'Volume Gamma',
                  value: state.config.volumeGamma,
                  min: 0.2,
                  max: 3.0,
                  onChanged: controller.updateVolumeGamma,
                  valueFormatter: (value) => value.toStringAsFixed(2),
                ),
                LabeledSlider(
                  label: 'Pitch Min (Hz)',
                  value: state.config.pitchMinHz,
                  min: 60,
                  max: 1400,
                  onChanged: controller.updatePitchMinHz,
                  valueFormatter: (value) => value.toStringAsFixed(0),
                ),
                LabeledSlider(
                  label: 'Pitch Max (Hz)',
                  value: state.config.pitchMaxHz,
                  min: 120,
                  max: 2200,
                  onChanged: controller.updatePitchMaxHz,
                  valueFormatter: (value) => value.toStringAsFixed(0),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: controller.recalibrate,
                      child: const Text('Recalibrate'),
                    ),
                    OutlinedButton(
                      onPressed: controller.clearChart,
                      child: const Text('Clear Chart'),
                    ),
                    FilledButton.tonal(
                      onPressed: controller.resetDefaults,
                      child: const Text('Reset Defaults'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _thermalEventLabel(ThermalContactEventType type) {
    switch (type) {
      case ThermalContactEventType.contactStart:
        return 'contactStart';
      case ThermalContactEventType.intensityChange:
        return 'intensityChange';
      case ThermalContactEventType.contactEnd:
        return 'contactEnd';
    }
  }

  String _buttonEventLabel(ButtonEventType type) {
    switch (type) {
      case ButtonEventType.buttonDown:
        return 'buttonDown';
    }
  }

  String _polarityLabel(PressPolarity polarity) {
    switch (polarity) {
      case PressPolarity.warmingIsPress:
        return 'Warm-up=Press';
      case PressPolarity.coolingIsPress:
        return 'Cool-down=Press';
    }
  }

  String _scenarioLabel(SimulatorScenario scenario) {
    switch (scenario) {
      case SimulatorScenario.noise:
        return 'Noise';
      case SimulatorScenario.tap:
        return 'Tap';
      case SimulatorScenario.hold:
        return 'Hold';
      case SimulatorScenario.drift:
        return 'Drift';
      case SimulatorScenario.mixed:
        return 'Mixed';
    }
  }
}
