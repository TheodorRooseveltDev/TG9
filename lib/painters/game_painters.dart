import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/game_constants.dart';

/// Paints a falling pin hazard
class PinPainter extends CustomPainter {
  PinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Pin body (red)
    final bodyPaint = Paint()
      ..color = GameColors.pinRed
      ..style = PaintingStyle.fill;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - 10,
        20,
        20,
        size.height - 40,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Pin point (silver triangle)
    final pointPaint = Paint()
      ..color = GameColors.pinSilver
      ..style = PaintingStyle.fill;

    final pointPath = Path()
      ..moveTo(centerX, size.height) // Bottom point
      ..lineTo(centerX - 15, size.height - 30)
      ..lineTo(centerX + 15, size.height - 30)
      ..close();

    canvas.drawPath(pointPath, pointPaint);

    // Pin head (red circle)
    canvas.drawCircle(
      Offset(centerX, 15),
      15,
      bodyPaint,
    );

    // Black outlines
    final outlinePaint = Paint()
      ..color = GameColors.textBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameBorders.outlineWidth;

    // Outline body
    canvas.drawRRect(bodyRect, outlinePaint);

    // Outline point
    canvas.drawPath(pointPath, outlinePaint);

    // Outline head
    canvas.drawCircle(
      Offset(centerX, 15),
      15,
      outlinePaint,
    );

    // Warning shine effect (optional, can be used when close to balloon)
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - 5, 10),
      5,
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(PinPainter oldDelegate) => false;
}

/// Paints a golden coin
class CoinPainter extends CustomPainter {
  final double rotation;

  CoinPainter({this.rotation = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Glow effect
    final glowPaint = Paint()
      ..color = GameColors.coinOrange.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius + 5, glowPaint);

    // Coin body (gold)
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          GameColors.coinGold,
          GameColors.coinOrange,
          GameColors.coinGold,
        ],
        stops: const [0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    // Black outline
    final outlinePaint = Paint()
      ..color = GameColors.textBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, outlinePaint);

    // Dollar sign
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          fontSize: radius * 1.2,
          fontWeight: FontWeight.w900,
          color: GameColors.textBlack,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(CoinPainter oldDelegate) => oldDelegate.rotation != rotation;
}

/// Paints a fluffy cloud
class CloudPainter extends CustomPainter {
  final Color color;

  CloudPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Cloud made of overlapping circles
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.5), size.height * 0.4, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), size.height * 0.5, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), size.height * 0.4, paint);

    // Outline
    final outlinePaint = Paint()
      ..color = GameColors.textBlack.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.5), size.height * 0.4, outlinePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), size.height * 0.5, outlinePaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), size.height * 0.4, outlinePaint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => oldDelegate.color != color;
}

/// Paints a burst particle for pop animation
class BurstParticlePainter extends CustomPainter {
  final Color color;
  final double angle;

  BurstParticlePainter({required this.color, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Curved balloon piece
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Curved triangle shape
    path.moveTo(0, -radius);
    path.quadraticBezierTo(
      radius * 0.5,
      -radius * 0.5,
      radius,
      0,
    );
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Outline
    final outlinePaint = Paint()
      ..color = GameColors.textBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, outlinePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(BurstParticlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.angle != angle;
}

/// Paints a star particle for coin collect
class StarParticlePainter extends CustomPainter {
  final Color color;

  StarParticlePainter({this.color = Colors.yellow});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi) / points - math.pi / 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Outline
    final outlinePaint = Paint()
      ..color = GameColors.textBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(StarParticlePainter oldDelegate) => oldDelegate.color != color;
}
