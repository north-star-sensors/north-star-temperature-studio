import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_studio/src/features/algorithm_lab/state/algorithm_lab_controller.dart';
import 'package:temperature_studio/src/features/kona_game/engine/kona_game_engine.dart';
import 'package:temperature_studio/src/features/kona_game/models/kona_game_models.dart';
import 'package:temperature_studio/src/features/kona_game/ui/game_painter.dart';

class KonaGamePage extends ConsumerStatefulWidget {
  const KonaGamePage({super.key});

  static const String routeName = '/kona-game';

  @override
  ConsumerState<KonaGamePage> createState() => _KonaGamePageState();
}

class _KonaGamePageState extends ConsumerState<KonaGamePage>
    with SingleTickerProviderStateMixin {
  static const _highScoreKey = 'kona_game.highScore';

  final _engine = KonaGameEngine();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late KonaGameState _gameState;
  double _canvasWidth = 400;

  @override
  void initState() {
    super.initState();
    _gameState = KonaGameState.initial();
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
    // Cap dt to avoid huge jumps on tab switch / resume
    if (dt <= 0 || dt > 0.1) return;
    setState(() {
      _gameState = _engine.update(_gameState, dt, _canvasWidth);
    });
    // Check if game just ended. The engine already folds the run's score into
    // highScore, so persist that (a no-op when it wasn't a new record).
    if (_gameState.phase == GamePhase.gameOver) {
      _ticker.stop();
      _saveHighScore(_gameState.highScore);
    }
  }

  void _handleInput() {
    switch (_gameState.phase) {
      case GamePhase.waiting:
        setState(() {
          _gameState = _engine.startGame(_gameState);
        });
        _lastElapsed = Duration.zero;
        _ticker.start();
      case GamePhase.playing:
        setState(() {
          _gameState = _engine.jump(_gameState);
        });
      case GamePhase.gameOver:
        setState(() {
          _gameState = KonaGameState.initial(highScore: _gameState.highScore);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for sensor button presses (false→true transition)
    ref.listen<AlgorithmLabState>(algorithmLabControllerProvider,
        (previous, next) {
      if (previous != null && !previous.buttonIsPressed && next.buttonIsPressed) {
        _handleInput();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kona Run!'),
      ),
      body: GestureDetector(
        onTapDown: (_) => _handleInput(),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _canvasWidth = constraints.maxWidth;
            return CustomPaint(
              painter: GamePainter(_gameState),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
        ),
      ),
    );
  }
}
