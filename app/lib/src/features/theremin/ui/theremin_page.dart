import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/theremin/audio/theremin_audio_controller.dart';
import 'package:temperature_studio/src/features/theremin/ui/theremin_painter.dart';

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
      body: LayoutBuilder(
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
    );
  }
}
