import 'dart:math';

import 'package:flutter/material.dart';
import 'package:temperature_studio/src/features/kona_game/engine/kona_game_engine.dart';
import 'package:temperature_studio/src/features/kona_game/models/kona_game_models.dart';

class GamePainter extends CustomPainter {
  GamePainter(this.state);

  final KonaGameState state;

  // Layout
  double _groundY(Size size) => size.height - 60;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = _groundY(size);

    _drawSky(canvas, size);
    _drawClouds(canvas, size);
    _drawGround(canvas, size, groundY);
    for (final obs in state.obstacles) {
      _drawObstacle(canvas, obs, groundY);
    }
    _drawKona(canvas, state.kona, groundY);
    _drawScore(canvas, size);

    if (state.phase == GamePhase.waiting) {
      _drawCenterText(canvas, size, 'Tap to Start!', subtitle: 'or press the sensor button');
    } else if (state.phase == GamePhase.gameOver) {
      _drawCenterText(canvas, size, 'Game Over', subtitle: 'Score: ${state.score}  •  Tap to retry');
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF87CEEB), const Color(0xFFE0F0FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    // Clouds scroll slowly left using elapsed time (continuous, not wrapping)
    final t = state.elapsedSeconds;
    final wrap = size.width + 120;
    _drawCloud(canvas, (size.width * 0.3 - t * 20) % wrap - 60, 40, cloudPaint);
    _drawCloud(canvas, (size.width * 0.7 - t * 14) % wrap - 60, 70, cloudPaint);
    _drawCloud(canvas, (size.width * 1.1 - t * 24) % wrap - 60, 30, cloudPaint);
  }

  void _drawCloud(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawCircle(Offset(x, y), 16, paint);
    canvas.drawCircle(Offset(x + 18, y - 6), 20, paint);
    canvas.drawCircle(Offset(x + 38, y), 16, paint);
    canvas.drawCircle(Offset(x + 20, y + 4), 18, paint);
  }

  void _drawGround(Canvas canvas, Size size, double groundY) {
    // Ground fill
    final groundPaint = Paint()..color = const Color(0xFF8B7355);
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );

    // Ground line
    final linePaint = Paint()
      ..color = const Color(0xFF5C4033)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), linePaint);

    // Grass tufts
    final grassPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final offset = state.groundScrollOffset;
    for (double x = -offset % 40; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, groundY), Offset(x - 4, groundY - 8), grassPaint);
      canvas.drawLine(Offset(x, groundY), Offset(x + 4, groundY - 6), grassPaint);
    }
  }

  void _drawKona(Canvas canvas, KonaState kona, double groundY) {
    final x = KonaGameEngine.konaX;
    final baseY = groundY - kona.y;

    // 2-segment legs with knees — simple trot cycle
    final phase = kona.runFrame * pi / 2; // smooth 0..2π over one runFrame cycle
    final farLegPaint = Paint()
      ..color = const Color(0xFF6B2A12)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final nearLegPaint = Paint()
      ..color = const Color(0xFF8B3A1A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Body bottom edge: body rect is (x+4, baseY-36, 40, 24) → bottom at baseY-12
    const bodyBottom = -12.0;
    final backHipX = x + 12.0;
    final backHipY = baseY + bodyBottom;
    final frontHipX = x + 36.0;
    final frontHipY = baseY + bodyBottom;
    final footY = baseY;

    // Foot positions
    double backFootDx, frontFootDx, backFootFy, frontFootFy;

    if (kona.isJumping) {
      // Dynamic jump pose driven by velocity:
      //   t = +1 at launch, 0 at peak, -1 at landing
      final t = (kona.velocityY / KonaGameEngine.jumpVelocity).clamp(-1.0, 1.0);

      // Back legs: stretch behind on launch, tuck at peak, come forward to land
      backFootDx = -8.0 * t;
      // Back feet: near body at peak (most tuck), extending down at extremes
      backFootFy = backHipY + 4.0 + 6.0 * t.abs();

      // Front legs: reach forward on launch, tuck at peak, extend down to land
      frontFootDx = 6.0 * t.abs();
      // Front feet: tucked up at peak, reaching down at launch and landing
      frontFootFy = frontHipY + 4.0 + 6.0 * t.abs();
    } else {
      // Trot: back and front legs in opposite phase
      backFootDx = sin(phase) * 8;
      frontFootDx = sin(phase + pi) * 8;
      backFootFy = footY;
      frontFootFy = footY;
    }

    // Far-side legs (drawn first, behind body) — opposite phase from near-side
    _drawJointedLeg(canvas, farLegPaint, backHipX, backHipY,
        backHipX - backFootDx, backFootFy, 8, 8, true);
    _drawJointedLeg(canvas, farLegPaint, frontHipX, frontHipY,
        frontHipX - frontFootDx, frontFootFy, 8, 8, false);

    // Near-side legs (drawn on top, brighter)
    _drawJointedLeg(canvas, nearLegPaint, backHipX, backHipY,
        backHipX + backFootDx, backFootFy, 8, 8, true);
    _drawJointedLeg(canvas, nearLegPaint, frontHipX, frontHipY,
        frontHipX + frontFootDx, frontFootFy, 8, 8, false);

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFB5452A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 4, baseY - 36, 40, 24),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFFA03820)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailWag = sin(kona.runFrame * pi / 2) * 4;
    final tailPath = Path()
      ..moveTo(x + 4, baseY - 30)
      ..quadraticBezierTo(x - 6, baseY - 42 + tailWag, x - 2, baseY - 48 + tailWag);
    canvas.drawPath(tailPath, tailPaint);

    // Head
    final headPaint = Paint()..color = const Color(0xFFC25535);
    canvas.drawOval(Rect.fromLTWH(x + 34, baseY - 44, 20, 18), headPaint);

    // Ear (floppy)
    final earPaint = Paint()..color = const Color(0xFF8B3A1A);
    canvas.drawOval(Rect.fromLTWH(x + 36, baseY - 38, 8, 14), earPaint);

    // Eye
    canvas.drawCircle(Offset(x + 48, baseY - 38), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(x + 49, baseY - 38), 1.5, Paint()..color = Colors.black);

    // Nose
    canvas.drawOval(
      Rect.fromLTWH(x + 51, baseY - 34, 5, 3.5),
      Paint()..color = const Color(0xFF2C1810),
    );

    // Tongue (cute detail — only while running, not jumping)
    if (!kona.isJumping) {
      final tonguePaint = Paint()..color = const Color(0xFFFF6B8A);
      canvas.drawOval(Rect.fromLTWH(x + 50, baseY - 28, 4, 6), tonguePaint);
    }

    // Collar
    final collarPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromLTWH(x + 32, baseY - 36, 14, 10),
      0.3,
      2.5,
      false,
      collarPaint,
    );
  }

  /// Draws a 2-segment leg from hip to foot with a knee joint.
  /// [kneeForward] controls which side the knee bends toward:
  /// true = knee bends in +x (forward), false = knee bends in -x (backward).
  void _drawJointedLeg(Canvas canvas, Paint paint,
      double hipX, double hipY, double footX, double footY,
      double upperLen, double lowerLen, bool kneeForward) {
    final dx = footX - hipX;
    final dy = footY - hipY;
    var dist = sqrt(dx * dx + dy * dy);
    final maxReach = upperLen + lowerLen;
    if (dist > maxReach) dist = maxReach; // clamp to avoid NaN
    if (dist < 0.1) dist = 0.1;

    // Law of cosines: angle at hip between (hip→foot) line and upper leg
    final cosA = ((upperLen * upperLen + dist * dist - lowerLen * lowerLen) /
            (2 * upperLen * dist))
        .clamp(-1.0, 1.0);
    final a = acos(cosA);

    // Angle from hip to foot
    final baseAngle = atan2(dy, dx);

    // Choose knee side: +angle bends one way, -angle the other
    final sign = kneeForward ? -1.0 : 1.0;
    final kneeX = hipX + upperLen * cos(baseAngle + sign * a);
    final kneeY = hipY + upperLen * sin(baseAngle + sign * a);

    canvas.drawLine(Offset(hipX, hipY), Offset(kneeX, kneeY), paint);
    canvas.drawLine(Offset(kneeX, kneeY), Offset(footX, footY), paint);
    // Small knee dot
    canvas.drawCircle(Offset(kneeX, kneeY), 2.5, Paint()..color = paint.color);
  }

  void _drawObstacle(Canvas canvas, Obstacle obs, double groundY) {
    switch (obs.type) {
      case ObstacleType.fence:
        _drawFence(canvas, obs.x, groundY);
      case ObstacleType.bush:
        _drawBush(canvas, obs.x, groundY);
      case ObstacleType.trashCan:
        _drawTrashCan(canvas, obs.x, groundY);
    }
  }

  void _drawFence(Canvas canvas, double x, double groundY) {
    final postPaint = Paint()..color = const Color(0xFF8B6914);
    final plankPaint = Paint()..color = const Color(0xFFBB9944);

    // Posts
    canvas.drawRect(Rect.fromLTWH(x, groundY - 44, 5, 44), postPaint);
    canvas.drawRect(Rect.fromLTWH(x + 22, groundY - 44, 5, 44), postPaint);

    // Horizontal planks
    canvas.drawRect(Rect.fromLTWH(x - 1, groundY - 38, 30, 5), plankPaint);
    canvas.drawRect(Rect.fromLTWH(x - 1, groundY - 22, 30, 5), plankPaint);

    // Post tops (pointed)
    final topPaint = Paint()..color = const Color(0xFF7A5A10);
    final leftTop = Path()
      ..moveTo(x, groundY - 44)
      ..lineTo(x + 2.5, groundY - 50)
      ..lineTo(x + 5, groundY - 44)
      ..close();
    canvas.drawPath(leftTop, topPaint);
    final rightTop = Path()
      ..moveTo(x + 22, groundY - 44)
      ..lineTo(x + 24.5, groundY - 50)
      ..lineTo(x + 27, groundY - 44)
      ..close();
    canvas.drawPath(rightTop, topPaint);
  }

  void _drawBush(Canvas canvas, double x, double groundY) {
    final darkGreen = Paint()..color = const Color(0xFF2E7D32);
    final midGreen = Paint()..color = const Color(0xFF43A047);
    final lightGreen = Paint()..color = const Color(0xFF66BB6A);

    canvas.drawOval(Rect.fromLTWH(x - 2, groundY - 22, 18, 22), darkGreen);
    canvas.drawOval(Rect.fromLTWH(x + 10, groundY - 28, 20, 28), midGreen);
    canvas.drawOval(Rect.fromLTWH(x + 22, groundY - 20, 16, 20), darkGreen);
    // Highlights
    canvas.drawOval(Rect.fromLTWH(x + 12, groundY - 26, 10, 10), lightGreen);
  }

  void _drawTrashCan(Canvas canvas, double x, double groundY) {
    final bodyPaint = Paint()..color = const Color(0xFF757575);
    final lidPaint = Paint()..color = const Color(0xFF616161);
    final detailPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Body (slightly tapered)
    final bodyPath = Path()
      ..moveTo(x + 2, groundY)
      ..lineTo(x, groundY - 34)
      ..lineTo(x + 26, groundY - 34)
      ..lineTo(x + 24, groundY)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 2, groundY - 42, 30, 8),
        const Radius.circular(3),
      ),
      lidPaint,
    );

    // Lid handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 8, groundY - 46, 10, 5),
        const Radius.circular(2),
      ),
      lidPaint,
    );

    // Body ribs
    canvas.drawLine(Offset(x + 5, groundY - 6), Offset(x + 5, groundY - 30), detailPaint);
    canvas.drawLine(Offset(x + 12, groundY - 6), Offset(x + 12, groundY - 30), detailPaint);
    canvas.drawLine(Offset(x + 19, groundY - 6), Offset(x + 19, groundY - 30), detailPaint);
  }

  void _drawScore(Canvas canvas, Size size) {
    final scorePainter = TextPainter(
      text: TextSpan(
        text: 'Score: ${state.score}',
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scorePainter.paint(canvas, Offset(size.width - scorePainter.width - 16, 16));

    if (state.highScore > 0) {
      final highPainter = TextPainter(
        text: TextSpan(
          text: 'HI: ${state.highScore}',
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      highPainter.paint(canvas, Offset(size.width - highPainter.width - 16, 38));
    }
  }

  void _drawCenterText(Canvas canvas, Size size, String title, {String? subtitle}) {
    // Semi-transparent overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(
      canvas,
      Offset((size.width - titlePainter.width) / 2, size.height / 2 - 30),
    );

    if (subtitle != null) {
      final subPainter = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      subPainter.paint(
        canvas,
        Offset((size.width - subPainter.width) / 2, size.height / 2 + 12),
      );
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
