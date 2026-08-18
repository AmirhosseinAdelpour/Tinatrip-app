import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.muted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: colors.line),
        ),
      ],
    );
  }
}
