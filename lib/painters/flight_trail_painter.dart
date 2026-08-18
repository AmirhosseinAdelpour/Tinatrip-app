import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlightTrailPainter extends CustomPainter {
  const FlightTrailPainter({
    required this.progress,
    required this.baseColor,
    required this.glowColor,
  });

  final double progress;
  final Color baseColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.02, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.08,
        size.width * 0.98,
        size.height * 0.34,
      );

    final metric = path.computeMetrics().first;
    final visible = metric.extractPath(0, metric.length * progress);

    final base = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _drawDashed(canvas, visible, base, dashLength: 3, gap: 10);

    if (progress > 0.02) {
      final end = metric.getTangentForOffset(metric.length * progress)!;
      canvas.save();
      canvas.translate(end.position.dx, end.position.dy);
      canvas.rotate(math.atan2(end.vector.dy, end.vector.dx));
      canvas.drawPath(_planeGlyph(), glow);
      canvas.restore();
    }
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dashLength, metric.length),
          ),
          paint,
        );
        distance += dashLength + gap;
      }
    }
  }

  Path _planeGlyph() {
    final p = Path();
    p.moveTo(-10, -3);
    p.lineTo(10, -3);
    p.lineTo(12, 0);
    p.lineTo(10, 3);
    p.lineTo(-10, 3);
    p.lineTo(-12, 0);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant FlightTrailPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.glowColor != glowColor;
}
