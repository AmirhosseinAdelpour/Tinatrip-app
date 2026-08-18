import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassPainter extends CustomPainter {
  const CompassPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = math.min(size.width, size.height) / 2 - 4;

    final paint = Paint()
      ..color = color.withAlpha(178)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final r = i.isEven ? outer : outer * 0.35;
      final p = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = color.withAlpha(128)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final p = Offset(
        center.dx + math.cos(angle) * (outer + 8),
        center.dy + math.sin(angle) * (outer + 8),
      );
      canvas.drawCircle(p, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) =>
      oldDelegate.color != color;
}
