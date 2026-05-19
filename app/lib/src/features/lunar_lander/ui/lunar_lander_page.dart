import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/lunar_lander/engine/lunar_lander_engine.dart';
import 'package:temperature_studio/src/features/lunar_lander/models/lunar_lander_models.dart';
import 'package:temperature_studio/src/features/lunar_lander/ui/lunar_lander_painter.dart';

class LunarLanderPage extends ConsumerStatefulWidget {
  const LunarLanderPage({super.key});

  static const String routeName = '/lunar-lander';

  @override
  ConsumerState<LunarLanderPage> createState() => _LunarLanderPageState();
}

class _LunarLanderPageState extends ConsumerState<LunarLanderPage>
    with SingleTickerProviderStateMixin {
  static const _highScoreKey = 'lunar_lander.highScore';

  final _engine = LunarLanderEngine();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late LunarLanderState _gameState;

  /// Continuous thrust 0.0–1.0.
  /// Driven by sensor levelNorm, or 1.0 while screen is tapped.
  double _thrustLevel = 0.0;
  bool _tapHeld = false;

  /// Cooldown: ignore sensor restarts for 3s after game ends so
  /// the player can see their score.
  DateTime? _gameEndedAt;
  static const _resultCooldown = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _gameState = LunarLanderState.initial(
      stars: _engine.generateStars(),
    );
    _ticker = createTicker(_onTick);
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final hi = prefs.getInt(_highScoreKey) ?? 0;
    if (mounted) {
      setState(() {
        _gameState = _gameState.copyWith(highScore: hi);
      });
    }
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    setState(() {
      _gameState = _engine.update(_gameState, dt, _thrustLevel);
    });

    // Game just ended — engine already updated highScore in state
    if (_gameState.phase == LunarLanderPhase.landed ||
        _gameState.phase == LunarLanderPhase.crashed) {
      _ticker.stop();
      _thrustLevel = 0.0;
      _gameEndedAt = DateTime.now();
      _saveHighScore(_gameState.highScore);
    }
  }

  void _handleTapDown() {
    _tapHeld = true;
    switch (_gameState.phase) {
      case LunarLanderPhase.waiting:
        setState(() {
          _gameState = _engine.startGame(_gameState);
          _thrustLevel = 1.0;
        });
        _lastElapsed = Duration.zero;
        _ticker.start();
      case LunarLanderPhase.playing:
        _thrustLevel = 1.0;
      case LunarLanderPhase.landed:
      case LunarLanderPhase.crashed:
        setState(() {
          _gameState = _engine.resetToWaiting(_gameState);
          _thrustLevel = 0.0;
          _tapHeld = false;
        });
    }
  }

  void _handleTapUp() {
    _tapHeld = false;
    // Only zero out thrust if sensor isn't also providing input
    final frame = ref.read(algorithmLabControllerProvider).latestFrame;
    _thrustLevel = frame?.levelNorm ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Read continuous levelNorm from sensor each frame
    ref.listen<AlgorithmLabState>(algorithmLabControllerProvider,
        (previous, next) {
      final frame = next.latestFrame;
      if (frame == null) return;

      final sensorLevel = frame.levelNorm;

      // If tap is held, keep thrust at 1.0 (tap overrides sensor)
      if (_tapHeld) return;

      // Start game on first significant sensor input from waiting state
      if (_gameState.phase == LunarLanderPhase.waiting && sensorLevel > 0.15) {
        setState(() {
          _gameState = _engine.startGame(_gameState);
          _thrustLevel = sensorLevel;
        });
        _lastElapsed = Duration.zero;
        _ticker.start();
        return;
      }

      // Reset from ended states — but only after cooldown so player sees score
      if ((_gameState.phase == LunarLanderPhase.landed ||
              _gameState.phase == LunarLanderPhase.crashed) &&
          sensorLevel > 0.15) {
        if (_gameEndedAt != null &&
            DateTime.now().difference(_gameEndedAt!) >= _resultCooldown) {
          setState(() {
            _gameState = _engine.resetToWaiting(_gameState);
            _thrustLevel = 0.0;
            _gameEndedAt = null;
          });
        }
        return;
      }

      _thrustLevel = sensorLevel;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunar Lander'),
      ),
      body: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: () => _handleTapUp(),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              painter: LunarLanderPainter(_gameState),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
        ),
      ),
    );
  }

}
