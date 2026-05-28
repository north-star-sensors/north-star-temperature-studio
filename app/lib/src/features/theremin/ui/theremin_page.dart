import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart' show WaveForm;
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/theremin/audio/scale_quantizer.dart';
import 'package:temperature_studio/src/features/theremin/audio/theremin_audio_controller.dart';
import 'package:temperature_studio/src/features/theremin/ui/theremin_painter.dart';

const Map<WaveForm, String> _waveformLabels = {
  WaveForm.sin: 'Sine',
  WaveForm.triangle: 'Triangle',
  WaveForm.saw: 'Saw',
  WaveForm.square: 'Square',
};

class ThereminPage extends ConsumerStatefulWidget {
  const ThereminPage({super.key});

  static const String routeName = '/theremin';

  @override
  ConsumerState<ThereminPage> createState() => _ThereminPageState();
}

class _ThereminPageState extends ConsumerState<ThereminPage>
    with SingleTickerProviderStateMixin {
  final _audio = ThereminAudioController();
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _audio.init().then((_) {
      if (mounted) _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _audio.tick();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AlgorithmLabState>(algorithmLabControllerProvider,
        (previous, next) {
      final frame = next.latestFrame;
      if (frame != null) {
        _audio.setTarget(frame.pitchHz, frame.volumeNorm);
      }
    });

    final config = ref.watch(algorithmLabControllerProvider).config;
    final pitchRange = config.pitchMaxHz - config.pitchMinHz;
    final pitchNorm = pitchRange > 0
        ? ((_audio.currentPitchHz - config.pitchMinHz) / pitchRange)
            .clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theremin'),
        actions: [
          IconButton(
            icon: Icon(
              _audio.isMuted ? Icons.volume_off : Icons.volume_up,
            ),
            onPressed: () => setState(() => _audio.toggleMute()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: ThereminPainter(
                    pitchHz: _audio.currentPitchHz,
                    pitchNorm: pitchNorm,
                    volumeNorm: _audio.currentVolume,
                    pitchMinHz: config.pitchMinHz,
                    pitchMaxHz: config.pitchMaxHz,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            ),
          ),
          _buildControlBar(),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: const Color(0xFF14141F),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.piano, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<ThereminScale>(
                value: _audio.scale,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E2C),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox.shrink(),
                items: [
                  for (final scale in ThereminScale.values)
                    DropdownMenuItem(value: scale, child: Text(scale.label)),
                ],
                onChanged: (scale) {
                  if (scale != null) setState(() => _audio.setScale(scale));
                },
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.graphic_eq, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<WaveForm>(
                value: _audio.waveform,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E2C),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox.shrink(),
                items: [
                  for (final entry in _waveformLabels.entries)
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                ],
                onChanged: (waveform) {
                  if (waveform != null) {
                    setState(() => _audio.setWaveform(waveform));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
