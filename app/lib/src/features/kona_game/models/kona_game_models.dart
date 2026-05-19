enum GamePhase { waiting, playing, gameOver }

enum ObstacleType { fence, bush, trashCan }

class KonaState {
  const KonaState({
    required this.y,
    required this.velocityY,
    required this.isJumping,
    required this.runFrame,
  });

  factory KonaState.initial() => const KonaState(
        y: 0,
        velocityY: 0,
        isJumping: false,
        runFrame: 0,
      );

  final double y; // Offset above ground (0 = on ground, positive = up)
  final double velocityY; // Negative = upward
  final bool isJumping;
  final double runFrame; // Cycles for leg animation

  KonaState copyWith({
    double? y,
    double? velocityY,
    bool? isJumping,
    double? runFrame,
  }) =>
      KonaState(
        y: y ?? this.y,
        velocityY: velocityY ?? this.velocityY,
        isJumping: isJumping ?? this.isJumping,
        runFrame: runFrame ?? this.runFrame,
      );
}

class Obstacle {
  Obstacle({
    required this.type,
    required this.x,
    this.scored = false,
  });

  final ObstacleType type;
  double x;
  bool scored;

  double get width {
    switch (type) {
      case ObstacleType.fence:
        return 28;
      case ObstacleType.bush:
        return 36;
      case ObstacleType.trashCan:
        return 26;
    }
  }

  double get height {
    switch (type) {
      case ObstacleType.fence:
        return 44;
      case ObstacleType.bush:
        return 28;
      case ObstacleType.trashCan:
        return 42;
    }
  }
}

class KonaGameState {
  const KonaGameState({
    required this.phase,
    required this.kona,
    required this.obstacles,
    required this.groundScrollOffset,
    required this.score,
    required this.highScore,
    required this.gameSpeed,
    required this.elapsedSeconds,
    required this.distanceSinceLastSpawn,
  });

  factory KonaGameState.initial({int highScore = 0}) => KonaGameState(
        phase: GamePhase.waiting,
        kona: KonaState.initial(),
        obstacles: const [],
        groundScrollOffset: 0,
        score: 0,
        highScore: highScore,
        gameSpeed: 200,
        elapsedSeconds: 0,
        distanceSinceLastSpawn: 0,
      );

  final GamePhase phase;
  final KonaState kona;
  final List<Obstacle> obstacles;
  final double groundScrollOffset;
  final int score;
  final int highScore;
  final double gameSpeed;
  final double elapsedSeconds;
  final double distanceSinceLastSpawn;

  KonaGameState copyWith({
    GamePhase? phase,
    KonaState? kona,
    List<Obstacle>? obstacles,
    double? groundScrollOffset,
    int? score,
    int? highScore,
    double? gameSpeed,
    double? elapsedSeconds,
    double? distanceSinceLastSpawn,
  }) =>
      KonaGameState(
        phase: phase ?? this.phase,
        kona: kona ?? this.kona,
        obstacles: obstacles ?? this.obstacles,
        groundScrollOffset: groundScrollOffset ?? this.groundScrollOffset,
        score: score ?? this.score,
        highScore: highScore ?? this.highScore,
        gameSpeed: gameSpeed ?? this.gameSpeed,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        distanceSinceLastSpawn:
            distanceSinceLastSpawn ?? this.distanceSinceLastSpawn,
      );
}
