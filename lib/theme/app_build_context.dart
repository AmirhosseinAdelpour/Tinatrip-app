import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

extension AppBuildContextExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
