import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_studio/src/features/lunar_lander/engine/lunar_lander_engine.dart';
import 'package:temperature_studio/src/features/lunar_lander/models/lunar_lander_models.dart';

/// A `playing` state with a lander positioned [altitude] metres up, descending
/// at [velocity] m/s, with [fuel] (0..1) remaining.
LunarLanderState _playing({
  required double altitude,
  required double velocity,
  double fuel = 1.0,
  int highScore = 0,
}) {
  return LunarLanderState.initial(highScore: highScore).copyWith(
    phase: LunarLanderPhase.playing,
    lander: LanderState(
      altitude: altitude,
      velocity: velocity,
      fuel: fuel,
      thrustLevel: 0,
    ),
  );
}

void main() {
  late LunarLanderEngine engine;

  setUp(() => engine = LunarLanderEngine());

  group('update', () {
    test('is a no-op outside the playing phase', () {
      final waiting = LunarLanderState.initial();
      expect(engine.update(waiting, 0.1, 1.0), same(waiting));

      final landed = waiting.copyWith(phase: LunarLanderPhase.landed);
      expect(engine.update(landed, 0.1, 1.0), same(landed));
    });

    test('gravity pulls the lander down when not thrusting', () {
      final next = engine.update(
        _playing(altitude: 50, velocity: -2),
        0.1,
        0.0,
      );
      // velocity becomes more negative, altitude drops, fuel untouched.
      expect(next.lander.velocity, lessThan(-2));
      expect(next.lander.altitude, lessThan(50));
      expect(next.lander.fuel, 1.0);
      expect(next.elapsedSeconds, closeTo(0.1, 1e-9));
    });

    test('full thrust produces net upward acceleration and burns fuel', () {
      final start = _playing(altitude: 50, velocity: -2);
      final next = engine.update(start, 0.1, 1.0);
      // thrustAccel (3.5) > gravity (1.62), so velocity increases.
      expect(next.lander.velocity, greaterThan(start.lander.velocity));
      expect(next.lander.fuel, lessThan(1.0));
      expect(next.lander.thrustLevel, 1.0);
    });

    test('thrust is ignored once fuel is exhausted', () {
      final next = engine.update(
        _playing(altitude: 50, velocity: -2, fuel: 0),
        0.1,
        1.0, // full thrust requested, but no fuel
      );
      // Only gravity applies; fuel stays at zero.
      expect(next.lander.velocity, closeTo(-2 - 1.62 * 0.1, 1e-9));
      expect(next.lander.fuel, 0);
      expect(next.lander.thrustLevel, 0);
    });
  });

  group('landing classification', () {
    test('a gentle touchdown lands and scores the perfect-landing bonus', () {
      final next = engine.update(
        _playing(altitude: 0.001, velocity: -0.5),
        0.01,
        0.0,
      );
      expect(next.phase, LunarLanderPhase.landed);
      // base (100) + full-fuel bonus (300) + a perfect-landing bonus on top.
      expect(next.score, greaterThan(400));
      expect(next.landingVelocity, closeTo(0.5, 0.1));
    });

    test('a firm-but-safe landing scores base + fuel bonus only', () {
      // ~3 m/s impact: above the perfect threshold (2) but below crash (4).
      final next = engine.update(
        _playing(altitude: 0.001, velocity: -3.0),
        0.001,
        0.0,
      );
      expect(next.phase, LunarLanderPhase.landed);
      // 100 base + round(1.0 * 300) fuel, no perfect bonus.
      expect(next.score, 400);
    });

    test('a fast impact crashes and scores nothing', () {
      final next = engine.update(
        _playing(altitude: 0.001, velocity: -5.0),
        0.001,
        0.0,
      );
      expect(next.phase, LunarLanderPhase.crashed);
      expect(next.score, 0);
      expect(next.landingVelocity, greaterThan(4.0));
    });
  });

  group('high score', () {
    test('keeps the larger of the run score and the previous best', () {
      final next = engine.update(
        _playing(altitude: 0.001, velocity: -3.0, highScore: 1000),
        0.001,
        0.0,
      );
      expect(next.score, 400);
      expect(next.highScore, 1000); // previous best preserved
    });

    test('is raised when the run beats the previous best', () {
      final next = engine.update(
        _playing(altitude: 0.001, velocity: -3.0, highScore: 50),
        0.001,
        0.0,
      );
      expect(next.highScore, next.score);
    });
  });
}
