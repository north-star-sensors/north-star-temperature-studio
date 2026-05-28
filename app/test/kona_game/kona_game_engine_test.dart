import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/features/kona_game/engine/kona_game_engine.dart';
import 'package:temperature_studio/src/features/kona_game/models/kona_game_models.dart';

/// A `playing` state carrying [obstacles], with spawning suppressed for the
/// next step (fresh `distanceSinceLastSpawn`).
KonaGameState _playing({
  List<Obstacle> obstacles = const [],
  int score = 0,
  int highScore = 0,
}) {
  return KonaGameState.initial(highScore: highScore).copyWith(
    phase: GamePhase.playing,
    obstacles: obstacles,
    score: score,
  );
}

void main() {
  late KonaGameEngine engine;

  setUp(() => engine = KonaGameEngine());

  group('update', () {
    test('is a no-op outside the playing phase', () {
      final waiting = KonaGameState.initial();
      expect(engine.update(waiting, 0.016, 400), same(waiting));
    });

    test('obstacles scroll left at the current speed', () {
      final obstacle = Obstacle(type: ObstacleType.fence, x: 300);
      final next = engine.update(
        _playing(obstacles: [obstacle]),
        0.01,
        400,
      );
      final moved = next.obstacles.firstWhere((o) => o.x < 300);
      // gameSpeed starts at baseSpeed (200): 200 * 0.01 = 2px.
      expect(moved.x, closeTo(298, 0.5));
    });

    test('culls obstacles once they leave the left edge', () {
      final offscreen = Obstacle(type: ObstacleType.fence, x: -60);
      final next = engine.update(
        _playing(obstacles: [offscreen]),
        0.01,
        400,
      );
      expect(next.obstacles, isEmpty);
    });
  });

  group('scoring', () {
    test('an obstacle that passes Kona scores exactly once', () {
      // fence width 28; placed so it sits left of konaX (80) after moving.
      final obstacle = Obstacle(type: ObstacleType.fence, x: 45);
      final afterFirst = engine.update(
        _playing(obstacles: [obstacle]),
        0.01,
        400,
      );
      expect(afterFirst.score, 1);
      expect(afterFirst.obstacles.single.scored, isTrue);

      // A second tick must not double-count the same obstacle.
      final afterSecond = engine.update(afterFirst, 0.01, 400);
      expect(afterSecond.score, 1);
    });
  });

  group('jump', () {
    test('launches Kona upward from the ground', () {
      final jumped = engine.jump(_playing());
      expect(jumped.kona.isJumping, isTrue);
      expect(jumped.kona.velocityY, KonaGameEngine.jumpVelocity);
    });

    test('ignores a jump while already airborne', () {
      final airborne = _playing().copyWith(
        kona: const KonaState(
          y: 50,
          velocityY: 200,
          isJumping: true,
          runFrame: 0,
        ),
      );
      expect(engine.jump(airborne), same(airborne));
    });

    test('gravity returns Kona to the ground after a jump', () {
      var state = engine.jump(_playing());
      // Simulate ~1s at 60fps; the arc (v=650, g=1800) lasts ~0.72s.
      for (var i = 0; i < 60; i++) {
        state = engine.update(state, 1 / 60, 400);
      }
      expect(state.kona.y, 0);
      expect(state.kona.isJumping, isFalse);
    });
  });

  group('collision', () {
    test('hitting an obstacle ends the game and banks the high score', () {
      // A bush (width 36, height 28) overlapping Kona's hitbox at the ground.
      final obstacle = Obstacle(type: ObstacleType.bush, x: 90);
      final next = engine.update(
        _playing(obstacles: [obstacle], score: 7, highScore: 3),
        0.001, // tiny dt: obstacle barely moves, stays overlapping
        400,
      );
      expect(next.phase, GamePhase.gameOver);
      expect(next.highScore, 7); // max(score 7, previous best 3)
    });
  });
}
