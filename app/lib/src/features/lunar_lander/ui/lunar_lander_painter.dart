import 'dart:math';

import 'package:flutter/material.dart';
import 'package:temperature_studio/src/features/lunar_lander/engine/lunar_lander_engine.dart';
import 'package:temperature_studio/src/features/lunar_lander/models/lunar_lander_models.dart';

class LunarLanderPainter extends CustomPainter {
  LunarLanderPainter(this.state);

  final LunarLanderState state;

  static const double _groundHeight = 50;
  static const double _padWidthFraction = 0.25;
  static const double _maxDisplayAltitude = 120.0;
  static const double _landerW = 30;
  static const double _landerH = 22;
  static const double _padThickness = 4;
  // Distance from lander center to bottom of feet
  static const double _feetOffset = _landerH / 2 + 8;

  double _groundY(Size size) => size.height - _groundHeight;

  /// Maps game altitude to screen Y so that at altitude 0 the lander's
  /// feet rest exactly on the landing pad surface.
  double _altitudeToY(double altitude, Size size) {
    final groundY = _groundY(size);
    final padSurface = groundY - _padThickness; // top of landing pad
    final centerAtGround = padSurface - _feetOffset;
    final topMargin = 30.0;
    final t = (altitude / _maxDisplayAltitude).clamp(0.0, 1.0);
    return centerAtGround - t * (centerAtGround - topMargin);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawStars(canvas, size);
    _drawSurface(canvas, size);

    final landerY = _altitudeToY(state.lander.altitude, size);
    final landerX = size.width / 2;

    if (state.phase == LunarLanderPhase.crashed) {
      _drawCrash(canvas, landerX, landerY, size);
    } else {
      _drawLander(canvas, landerX, landerY);
      if (state.lander.thrustLevel > 0.01) {
        _drawFlame(canvas, landerX, landerY, state.lander.thrustLevel);
      }
    }

    _drawHud(canvas, size);

    if (state.phase != LunarLanderPhase.playing) {
      _drawOverlay(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0A1E),
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in state.stars) {
      paint.color = Colors.white.withValues(alpha: star.brightness);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.brightness * 1.5,
        paint,
      );
    }
  }

  void _drawSurface(Canvas canvas, Size size) {
    final groundY = _groundY(size);

    // Moon surface fill
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, _groundHeight),
      Paint()..color = const Color(0xFF3A3A3A),
    );

    // Jagged terrain line
    final terrainPaint = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, groundY);
    final rng = Random(42); // deterministic
    for (double x = 0; x <= size.width; x += 12) {
      path.lineTo(x, groundY - rng.nextDouble() * 6);
    }
    canvas.drawPath(path, terrainPaint);

    // Landing pad
    final padW = size.width * _padWidthFraction;
    final padX = (size.width - padW) / 2;
    final padTop = groundY - _padThickness;
    canvas.drawRect(
      Rect.fromLTWH(padX, padTop, padW, _padThickness),
      Paint()..color = const Color(0xFFCCCCCC),
    );
    // Pad markers
    final markerPaint = Paint()
      ..color = const Color(0xFFFFCC00)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(padX, padTop),
      Offset(padX, padTop - 7),
      markerPaint,
    );
    canvas.drawLine(
      Offset(padX + padW, padTop),
      Offset(padX + padW, padTop - 7),
      markerPaint,
    );
  }

  void _drawLander(Canvas canvas, double cx, double cy) {
    // Body
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: _landerW,
      height: _landerH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFD0D0D0),
    );

    // Cockpit window
    canvas.drawCircle(
      Offset(cx, cy - 3),
      5,
      Paint()..color = const Color(0xFF4488CC),
    );
    canvas.drawCircle(
      Offset(cx, cy - 3),
      5,
      Paint()
        ..color = const Color(0xFF88BBEE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Landing legs
    final legPaint = Paint()
      ..color = const Color(0xFF999999)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final bodyBottom = cy + _landerH / 2;
    // Left leg
    canvas.drawLine(
      Offset(cx - _landerW / 2 + 4, bodyBottom),
      Offset(cx - _landerW / 2 - 4, bodyBottom + 8),
      legPaint,
    );
    // Left foot
    canvas.drawLine(
      Offset(cx - _landerW / 2 - 8, bodyBottom + 8),
      Offset(cx - _landerW / 2, bodyBottom + 8),
      legPaint,
    );
    // Right leg
    canvas.drawLine(
      Offset(cx + _landerW / 2 - 4, bodyBottom),
      Offset(cx + _landerW / 2 + 4, bodyBottom + 8),
      legPaint,
    );
    // Right foot
    canvas.drawLine(
      Offset(cx + _landerW / 2, bodyBottom + 8),
      Offset(cx + _landerW / 2 + 8, bodyBottom + 8),
      legPaint,
    );

    // Nozzle
    final nozzlePath = Path()
      ..moveTo(cx - 5, bodyBottom)
      ..lineTo(cx - 7, bodyBottom + 4)
      ..lineTo(cx + 7, bodyBottom + 4)
      ..lineTo(cx + 5, bodyBottom)
      ..close();
    canvas.drawPath(nozzlePath, Paint()..color = const Color(0xFF888888));
  }

  void _drawFlame(Canvas canvas, double cx, double cy, double thrustLevel) {
    final bodyBottom = cy + _landerH / 2;
    final nozzleBottom = bodyBottom + 4;
    final t = state.elapsedSeconds;
    final flicker = sin(t * 30) * 4 + sin(t * 47) * 2;
    final flameLen = (14.0 + flicker) * thrustLevel;

    // Outer flame (yellow)
    final outerPath = Path()
      ..moveTo(cx - 6, nozzleBottom)
      ..lineTo(cx, nozzleBottom + flameLen)
      ..lineTo(cx + 6, nozzleBottom)
      ..close();
    canvas.drawPath(
      outerPath,
      Paint()..color = const Color(0xCCFFAA00),
    );

    // Inner flame (white-hot)
    final innerPath = Path()
      ..moveTo(cx - 3, nozzleBottom)
      ..lineTo(cx, nozzleBottom + flameLen * 0.6)
      ..lineTo(cx + 3, nozzleBottom)
      ..close();
    canvas.drawPath(
      innerPath,
      Paint()..color = const Color(0xCCFFEECC),
    );
  }

  void _drawCrash(Canvas canvas, double cx, double cy, Size size) {
    final rng = Random(state.elapsedSeconds.toInt());
    final paint = Paint()..strokeWidth = 2;

    // Scattered debris lines
    for (int i = 0; i < 12; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = 8.0 + rng.nextDouble() * 24;
      final color = i % 3 == 0
          ? const Color(0xFFFF6600)
          : i % 3 == 1
              ? const Color(0xFFFFAA00)
              : const Color(0xFF999999);
      paint.color = color;
      canvas.drawLine(
        Offset(cx + cos(angle) * 4, cy + sin(angle) * 4),
        Offset(cx + cos(angle) * dist, cy + sin(angle) * dist),
        paint,
      );
    }

    // Central glow
    canvas.drawCircle(
      Offset(cx, cy),
      10,
      Paint()..color = const Color(0x66FF4400),
    );
  }

  void _drawHud(Canvas canvas, Size size) {
    final lander = state.lander;

    // Altitude
    _drawHudText(
      canvas,
      'ALT  ${lander.altitude.toStringAsFixed(1)} m',
      const Offset(16, 16),
      Colors.white70,
      14,
    );

    // Velocity â€” color-coded
    final speed = lander.velocity.abs();
    final velColor = speed <= LunarLanderEngine.safeLandingSpeed
        ? const Color(0xFF66FF66)
        : speed <= LunarLanderEngine.hardLandingSpeed
            ? const Color(0xFFFFCC00)
            : const Color(0xFFFF4444);
    _drawHudText(
      canvas,
      'VEL  ${lander.velocity.toStringAsFixed(1)} m/s',
      const Offset(16, 36),
      velColor,
      14,
    );

    // Fuel bar
    final fuelBarX = 16.0;
    final fuelBarY = 58.0;
    final fuelBarW = 100.0;
    final fuelBarH = 10.0;
    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(fuelBarX, fuelBarY, fuelBarW, fuelBarH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0x44FFFFFF),
    );
    // Fill
    final fuelFrac = lander.fuel.clamp(0.0, 1.0);
    final fuelColor = fuelFrac > 0.4
        ? const Color(0xFF66FF66)
        : fuelFrac > 0.15
            ? const Color(0xFFFFCC00)
            : const Color(0xFFFF4444);
    if (fuelFrac > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(fuelBarX, fuelBarY, fuelBarW * fuelFrac, fuelBarH),
          const Radius.circular(3),
        ),
        Paint()..color = fuelColor,
      );
    }
    _drawHudText(
      canvas,
      'FUEL',
      Offset(fuelBarX + fuelBarW + 8, fuelBarY - 2),
      Colors.white54,
      12,
    );

    // Score + high score (top-right)
    if (state.score > 0 || state.phase == LunarLanderPhase.landed) {
      _drawHudText(
        canvas,
        'SCORE  ${state.score}',
        Offset(size.width - 16, 16),
        Colors.white,
        14,
        alignRight: true,
      );
    }
    if (state.highScore > 0) {
      _drawHudText(
        canvas,
        'HI  ${state.highScore}',
        Offset(size.width - 16, 36),
        Colors.white38,
        12,
        alignRight: true,
      );
    }
  }

  void _drawHudText(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    double fontSize, {
    bool alignRight = false,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset =
        alignRight ? Offset(position.dx - tp.width, position.dy) : position;
    tp.paint(canvas, offset);
  }

  void _drawOverlay(Canvas canvas, Size size) {
    switch (state.phase) {
      case LunarLanderPhase.waiting:
        _drawCenterText(
          canvas,
          size,
          'LUNAR LANDER',
          subtitle: 'Hold to thrust  â€¢  Land softly',
          subtitleLine2: 'Tap or use sensor to start',
        );
      case LunarLanderPhase.landed:
        final soft =
            state.landingVelocity <= LunarLanderEngine.safeLandingSpeed;
        _drawCenterText(
          canvas,
          size,
          soft ? 'PERFECT LANDING!' : 'LANDED!',
          titleColor: const Color(0xFF66FF66),
          subtitle:
              'Velocity: ${state.landingVelocity.toStringAsFixed(1)} m/s'
              '  â€¢  Fuel: ${(state.lander.fuel * 100).toStringAsFixed(0)}%',
          subtitleLine2: 'Score: ${state.score}  â€¢  Tap to play again',
        );
      case LunarLanderPhase.crashed:
        _drawCenterText(
          canvas,
          size,
          'CRASHED!',
          titleColor: const Color(0xFFFF4444),
          subtitle:
              'Impact: ${state.landingVelocity.toStringAsFixed(1)} m/s',
          subtitleLine2: 'Tap to try again',
        );
      case LunarLanderPhase.playing:
        break;
    }
  }

  void _drawCenterText(
    Canvas canvas,
    Size size,
    String title, {
    Color titleColor = Colors.white,
    String? subtitle,
    String? subtitleLine2,
  }) {
    // Dim overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x66000000),
    );

    final titleTp = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: titleColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titleTp.paint(
      canvas,
      Offset((size.width - titleTp.width) / 2, size.height / 2 - 40),
    );

    if (subtitle != null) {
      final subTp = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      subTp.paint(
        canvas,
        Offset((size.width - subTp.width) / 2, size.height / 2),
      );
    }

    if (subtitleLine2 != null) {
      final sub2Tp = TextPainter(
        text: TextSpan(
          text: subtitleLine2,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      sub2Tp.paint(
        canvas,
        Offset((size.width - sub2Tp.width) / 2, size.height / 2 + 24),
      );
    }
  }

  @override
  bool shouldRepaint(LunarLanderPainter oldDelegate) => true;
}
