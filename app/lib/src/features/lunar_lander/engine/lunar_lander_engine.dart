import 'dart:math';

import 'package:temperature_studio/src/features/lunar_lander/models/lunar_lander_models.dart';

class LunarLanderEngine {
  LunarLanderEngine() : _random = Random();

  final Random _random;

  // Physics
  static const double gravity = 1.62; // m/s² (real lunar gravity)
  static const double thrustAccel = 3.5; // m/s² (~2.16× gravity)
  static const double startAltitude = 100.0;
  static const double startVelocity = -2.0; // slight initial descent

  // Fuel
  static const double fuelBurnRate = 0.08; // per second (~12.5 s total)

  // Landing thresholds
  static const double safeLandingSpeed = 2.0; // m/s — soft landing
  static const double hardLandingSpeed = 4.0; // m/s — survived but rough

  // Scoring
  static const int landingBaseScore = 100;
  static const int perfectLandingBonus = 200;
  static const int fuelBonusMax = 300;

  // Stars
  static const int starCount = 80;

  List<Star> generateStars() => List.generate(
        starCount,
        (_) => Star(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          brightness: 0.3 + _random.nextDouble() * 0.7,
        ),
      );

  LunarLanderState startGame(LunarLanderState current) =>
      current.copyWith(
        phase: LunarLanderPhase.playing,
        lander: LanderState.initial(
          altitude: startAltitude,
          velocity: startVelocity,
        ),
        score: 0,
        elapsedSeconds: 0.0,
        landingVelocity: 0.0,
      );

  /// [thrustLevel] is 0.0–1.0: continuous thrust from sensor (levelNorm)
  /// or 1.0 when tapping the screen.
  LunarLanderState update(
    LunarLanderState state,
    double dt,
    double thrustLevel,
  ) {
    if (state.phase != LunarLanderPhase.playing) return state;

    final lander = state.lander;
    final effectiveThrust =
        lander.fuel > 0 ? thrustLevel.clamp(0.0, 1.0) : 0.0;

    // Velocity: gravity pulls down, thrust pushes up proportionally
    var velocity = lander.velocity - gravity * dt;
    velocity += thrustAccel * effectiveThrust * dt;

    // Fuel consumption proportional to thrust
    var fuel = lander.fuel;
    if (effectiveThrust > 0) {
      fuel = (fuel - fuelBurnRate * effectiveThrust * dt).clamp(0.0, 1.0);
    }

    // Position
    var altitude = lander.altitude + velocity * dt;

    // Surface contact
    if (altitude <= 0) {
      altitude = 0;
      final impactSpeed = velocity.abs();
      final score = _computeScore(impactSpeed, fuel);
      final phase = impactSpeed <= hardLandingSpeed
          ? LunarLanderPhase.landed
          : LunarLanderPhase.crashed;
      final highScore = score > state.highScore ? score : state.highScore;
      return state.copyWith(
        phase: phase,
        lander: lander.copyWith(
          altitude: 0,
          velocity: 0,
          fuel: fuel,
          thrustLevel: 0,
        ),
        score: score,
        highScore: highScore,
        landingVelocity: impactSpeed,
        elapsedSeconds: state.elapsedSeconds + dt,
      );
    }

    return state.copyWith(
      lander: lander.copyWith(
        altitude: altitude,
        velocity: velocity,
        fuel: fuel,
        thrustLevel: effectiveThrust,
      ),
      elapsedSeconds: state.elapsedSeconds + dt,
    );
  }

  int _computeScore(double impactSpeed, double fuelRemaining) {
    if (impactSpeed > hardLandingSpeed) return 0;
    var score = landingBaseScore;
    if (impactSpeed <= safeLandingSpeed) {
      score +=
          (perfectLandingBonus * (1.0 - impactSpeed / safeLandingSpeed))
              .round();
    }
    score += (fuelRemaining * fuelBonusMax).round();
    return score;
  }

  LunarLanderState resetToWaiting(LunarLanderState current) =>
      LunarLanderState.initial(
        highScore: current.highScore,
        stars: generateStars(),
      );
}
