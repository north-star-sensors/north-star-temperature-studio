import 'dart:math';
import 'package:flutter/material.dart';

class ThereminPainter extends CustomPainter {
  ThereminPainter({
    required this.pitchHz,
    required this.pitchNorm,
    required this.volumeNorm,
    required this.pitchMinHz,
    required this.pitchMaxHz,
  });

  final double pitchHz;
  final double pitchNorm;
  final double volumeNorm;
  final double pitchMinHz;
  final double pitchMaxHz;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGlowOrb(canvas, size);
    _drawLabels(canvas, size);
    _drawVolumeBar(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0A0A14),
    );
  }

  void _drawGlowOrb(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final top = size.height * 0.08;
    final bottom = size.height * 0.88;
    final centerY = bottom - pitchNorm.clamp(0.0, 1.0) * (bottom - top);

    final baseRadius = min(size.width, size.height) * 0.06;
    final radius = baseRadius + volumeNorm * baseRadius * 2.5;

    // Hue: 0 (red, low) -> 270 (violet, high)
    final hue = pitchNorm.clamp(0.0, 1.0) * 270.0;
    final color = HSLColor.fromAHSL(1.0, hue, 0.85, 0.55).toColor();

    // Glow rings
    for (int i = 4; i >= 0; i--) {
      final glowRadius = radius + i * 18.0 * volumeNorm;
      final alpha = (0.12 - i * 0.02) * volumeNorm;
      if (alpha <= 0) continue;
      canvas.drawCircle(
        Offset(centerX, centerY),
        glowRadius,
        Paint()..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }

    // Radial gradient fill
    final gradient = RadialGradient(
      colors: [
        color,
        color.withValues(alpha: 0.3),
      ],
    );
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        ),
    );

    // Bright core
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.4 + volumeNorm * 0.4),
    );
  }

  void _drawLabels(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Frequency label
    final freqTp = TextPainter(
      text: TextSpan(
        text: '${pitchHz.round()} Hz',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 28,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    freqTp.paint(
      canvas,
      Offset(centerX - freqTp.width / 2, size.height * 0.92),
    );

    // Volume percentage
    final volTp = TextPainter(
      text: TextSpan(
        text: '${(volumeNorm * 100).round()}%',
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    volTp.paint(
      canvas,
      Offset(centerX - volTp.width / 2, size.height * 0.92 + 34),
    );
  }

  void _drawVolumeBar(Canvas canvas, Size size) {
    final right = size.width - 30;
    final top = size.height * 0.08;
    final bottom = size.height * 0.88;
    final barWidth = 6.0;

    // Track
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(right - barWidth / 2, top, barWidth, bottom - top),
      const Radius.circular(3),
    );
    canvas.drawRRect(trackRect, Paint()..color = Colors.white10);

    // Fill
    final fillHeight = volumeNorm.clamp(0.0, 1.0) * (bottom - top);
    if (fillHeight > 0) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          right - barWidth / 2,
          bottom - fillHeight,
          barWidth,
          fillHeight,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        fillRect,
        Paint()..color = Colors.deepOrange.withValues(alpha: 0.7),
      );
    }

    // Label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'VOL',
        style: TextStyle(color: Colors.white24, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(right - tp.width / 2, bottom + 6));
  }

  @override
  bool shouldRepaint(ThereminPainter old) => true;
}
