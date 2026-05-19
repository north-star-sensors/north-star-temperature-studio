import 'dart:math';

import 'package:temperature_studio/src/features/kona_game/models/kona_game_models.dart';

class KonaGameEngine {
  KonaGameEngine() : _random = Random();

  final Random _random;

  // Physics constants (positive y = up)
  static const double gravity = 1800;
  static const double jumpVelocity = 650;
  static const double baseSpeed = 200;
  static const double speedAcceleration = 5;
  static const double maxSpeed = 600;

  // Spawning constants (generous gaps for sensor input lag)
  static const double minGap = 440;
  static const double gapVariance = 500;

  // Kona dimensions (for collision)
  static const double konaX = 80;
  static const double konaWidth = 50;
  static const double konaHeight = 38;
  // Hitbox insets (forgiving collision)
  static const double hitboxInset = 6;

  KonaGameState startGame(KonaGameState current) {
    return KonaGameState(
      phase: GamePhase.playing,
      kona: KonaState.initial(),
      obstacles: [],
      groundScrollOffset: 0,
      score: 0,
      highScore: current.highScore,
      gameSpeed: baseSpeed,
      elapsedSeconds: 0,
      distanceSinceLastSpawn: 0,
    );
  }

  KonaGameState jump(KonaGameState state) {
    if (state.kona.isJumping) return state;
    return state.copyWith(
      kona: state.kona.copyWith(
        velocityY: jumpVelocity,
        isJumping: true,
      ),
    );
  }

  KonaGameState update(KonaGameState state, double dt, double canvasWidth) {
    if (state.phase != GamePhase.playing) return state;

    // Update speed
    final elapsed = state.elapsedSeconds + dt;
    final speed = (baseSpeed + elapsed * speedAcceleration).clamp(0, maxSpeed).toDouble();

    // Update Kona physics (positive y = up, gravity pulls down)
    var vy = state.kona.velocityY - gravity * dt;
    var y = state.kona.y + vy * dt;
    var jumping = state.kona.isJumping;
    if (y <= 0) {
      y = 0;
      vy = 0;
      jumping = false;
    }

    // Update run animation
    final runFrame = jumping ? state.kona.runFrame : (state.kona.runFrame + dt * 10) % 4;

    final kona = KonaState(
      y: y,
      velocityY: vy,
      isJumping: jumping,
      runFrame: runFrame,
    );

    // Move obstacles and check scoring
    final scrollDist = speed * dt;
    final obstacles = <Obstacle>[];
    var score = state.score;

    for (final obs in state.obstacles) {
      obs.x -= scrollDist;
      // Remove if offscreen left
      if (obs.x + obs.width < -20) continue;
      // Score if passed Kona
      if (!obs.scored && obs.x + obs.width < konaX) {
        obs.scored = true;
        score++;
      }
      obstacles.add(obs);
    }

    // Spawn new obstacles
    var distSinceSpawn = state.distanceSinceLastSpawn + scrollDist;
    // Skew toward longer gaps: squaring a uniform random biases toward 1.0
    final r = _random.nextDouble();
    final spawnThreshold = minGap + r * r * gapVariance;
    if (distSinceSpawn >= spawnThreshold) {
      final type = ObstacleType.values[_random.nextInt(ObstacleType.values.length)];
      obstacles.add(Obstacle(type: type, x: canvasWidth + 20));
      distSinceSpawn = 0;
    }

    // Collision detection (AABB with insets)
    final konaLeft = konaX + hitboxInset;
    final konaRight = konaX + konaWidth - hitboxInset;
    final konaTop = kona.y + hitboxInset;
    final konaBottom = kona.y + konaHeight - hitboxInset;

    for (final obs in obstacles) {
      final obsLeft = obs.x + hitboxInset;
      final obsRight = obs.x + obs.width - hitboxInset;
      const obsBottom = 0.0; // Obstacles sit on ground
      final obsTop = obs.height - hitboxInset;

      if (konaLeft < obsRight &&
          konaRight > obsLeft &&
          konaTop < obsTop &&
          konaBottom > obsBottom) {
        // Collision!
        final newHigh = score > state.highScore ? score : state.highScore;
        return state.copyWith(
          phase: GamePhase.gameOver,
          kona: kona,
          obstacles: obstacles,
          score: score,
          highScore: newHigh,
          gameSpeed: speed,
          elapsedSeconds: elapsed,
        );
      }
    }

    // Update ground scroll
    final groundScroll = (state.groundScrollOffset + scrollDist) % 40;

    return KonaGameState(
      phase: GamePhase.playing,
      kona: kona,
      obstacles: obstacles,
      groundScrollOffset: groundScroll,
      score: score,
      highScore: score > state.highScore ? score : state.highScore,
      gameSpeed: speed,
      elapsedSeconds: elapsed,
      distanceSinceLastSpawn: distSinceSpawn,
    );
  }
}
