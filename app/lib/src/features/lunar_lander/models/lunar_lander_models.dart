enum LunarLanderPhase { waiting, playing, landed, crashed }

class Star {
  const Star({required this.x, required this.y, required this.brightness});
  final double x; // 0.0–1.0 normalized
  final double y; // 0.0–1.0 normalized
  final double brightness; // 0.0–1.0
}

class LanderState {
  const LanderState({
    required this.altitude,
    required this.velocity,
    required this.fuel,
    required this.thrustLevel,
  });

  factory LanderState.initial({
    double altitude = 100.0,
    double velocity = -2.0,
  }) =>
      LanderState(
        altitude: altitude,
        velocity: velocity,
        fuel: 1.0,
        thrustLevel: 0.0,
      );

  final double altitude; // metres above surface (0 = surface)
  final double velocity; // m/s, negative = descending
  final double fuel; // 0.0–1.0
  final double thrustLevel; // 0.0–1.0, continuous thrust from sensor

  LanderState copyWith({
    double? altitude,
    double? velocity,
    double? fuel,
    double? thrustLevel,
  }) =>
      LanderState(
        altitude: altitude ?? this.altitude,
        velocity: velocity ?? this.velocity,
        fuel: fuel ?? this.fuel,
        thrustLevel: thrustLevel ?? this.thrustLevel,
      );
}

class LunarLanderState {
  const LunarLanderState({
    required this.phase,
    required this.lander,
    required this.score,
    required this.highScore,
    required this.elapsedSeconds,
    required this.landingVelocity,
    required this.stars,
  });

  factory LunarLanderState.initial({
    int highScore = 0,
    List<Star> stars = const [],
  }) =>
      LunarLanderState(
        phase: LunarLanderPhase.waiting,
        lander: LanderState.initial(),
        score: 0,
        highScore: highScore,
        elapsedSeconds: 0.0,
        landingVelocity: 0.0,
        stars: stars,
      );

  final LunarLanderPhase phase;
  final LanderState lander;
  final int score;
  final int highScore;
  final double elapsedSeconds;
  final double landingVelocity; // abs velocity at moment of surface contact
  final List<Star> stars;

  LunarLanderState copyWith({
    LunarLanderPhase? phase,
    LanderState? lander,
    int? score,
    int? highScore,
    double? elapsedSeconds,
    double? landingVelocity,
    List<Star>? stars,
  }) =>
      LunarLanderState(
        phase: phase ?? this.phase,
        lander: lander ?? this.lander,
        score: score ?? this.score,
        highScore: highScore ?? this.highScore,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        landingVelocity: landingVelocity ?? this.landingVelocity,
        stars: stars ?? this.stars,
      );
}
