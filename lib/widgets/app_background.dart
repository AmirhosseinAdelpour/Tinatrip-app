import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';
import '../painters/starfield_painter.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.background,
            colors.background,
            colors.surface,
          ],
        ),
      ),
      child: const RepaintBoundary(
        child: CustomPaint(painter: StarfieldPainter()),
      ),
    );
  }
}
