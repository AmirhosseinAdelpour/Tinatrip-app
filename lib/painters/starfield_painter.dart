import 'dart:math' as math;
import 'package:flutter/material.dart';

class StarfieldPainter extends CustomPainter {
  const StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final paint = Paint()..color = Colors.white.withAlpha(45);
    for (var i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.55;
      final r = 0.4 + rng.nextDouble() * 0.8;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
