import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      text,
      style: context.textTheme.titleMedium?.copyWith(
        color: colors.onBackground,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
