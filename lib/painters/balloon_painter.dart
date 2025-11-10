import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/game_constants.dart';

/// Paints a beautiful cartoon balloon with thick outlines
class BalloonPainter extends CustomPainter {
  final Color color;
  final double size;
  final String skin;

  BalloonPainter({
    required this.color,
    required this.size,
    this.skin = 'classic',
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = GameColors.balloonShadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      center + const Offset(5, 5),
      radius,
      shadowPaint,
    );

    // Draw balloon body based on skin
    _drawBalloonBody(canvas, center, radius);

    // Draw thick black outline
    final outlinePaint = Paint()
      ..color = GameColors.textBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameBorders.outlineWidth;
    canvas.drawCircle(center, radius, outlinePaint);

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
      center + Offset(-radius * 0.25, -radius * 0.25),
      radius * 0.3,
      highlightPaint,
    );

    // Draw string
    _drawString(canvas, center, radius, canvasSize.height);
  }

  void _drawBalloonBody(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..style = PaintingStyle.fill;

    switch (skin) {
      case 'rainbow':
        _drawRainbowBalloon(canvas, center, radius);
        break;
      case 'fire':
        _drawFireBalloon(canvas, center, radius);
        break;
      case 'ice':
        _drawIceBalloon(canvas, center, radius);
        break;
      case 'gold':
        _drawGoldBalloon(canvas, center, radius);
        break;
      case 'neon':
        _drawNeonBalloon(canvas, center, radius);
        break;
      default:
        // Classic - solid color
        paint.color = color;
        canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawRainbowBalloon(Canvas canvas, Offset center, double radius) {
    final sweepAngle = (2 * math.pi) / GameColors.rainbowColors.length;
    for (int i = 0; i < GameColors.rainbowColors.length; i++) {
      final paint = Paint()
        ..color = GameColors.rainbowColors[i]
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          i * sweepAngle - math.pi / 2,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  void _drawFireBalloon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFF00), // Yellow center
          const Color(0xFFFF8C00), // Orange
          const Color(0xFFFF0000), // Red edge
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawIceBalloon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFB0E0E6), // Powder Blue
          const Color(0xFF87CEEB), // Sky Blue
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    // Draw ice crystals
    final crystalPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final x = center.dx + math.cos(angle) * radius * 0.5;
      final y = center.dy + math.sin(angle) * radius * 0.5;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.cos(angle) * radius * 0.3, y + math.sin(angle) * radius * 0.3),
        crystalPaint,
      );
    }
  }

  void _drawGoldBalloon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD700), // Gold
          const Color(0xFFDAA520), // Goldenrod
          const Color(0xFFB8860B), // Dark Goldenrod
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawNeonBalloon(Canvas canvas, Offset center, double radius) {
    // Neon glow effect
    final glowPaint = Paint()
      ..color = GameColors.powerUpGreen.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius + 15, glowPaint);

    // Main neon body
    final paint = Paint()..color = GameColors.powerUpGreen;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawString(Canvas canvas, Offset center, double radius, double canvasHeight) {
    final stringPaint = Paint()
      ..color = GameColors.textBlack
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(center.dx, center.dy + radius);

    // Wavy string
    final stringLength = canvasHeight - (center.dy + radius);
    final segments = 8;
    final segmentHeight = stringLength / segments;

    for (int i = 0; i <= segments; i++) {
      final y = center.dy + radius + (i * segmentHeight);
      final x = center.dx + math.sin(i * 0.5) * 10;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, stringPaint);

    // String knot at balloon
    final knotPaint = Paint()
      ..color = GameColors.textBlack
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius),
      5,
      knotPaint,
    );
  }

  @override
  bool shouldRepaint(BalloonPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.size != size ||
      oldDelegate.skin != skin;
}
