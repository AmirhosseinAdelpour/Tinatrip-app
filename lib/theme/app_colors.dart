import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.line,
    required this.primary,
    required this.primaryMuted,
    required this.secondary,
    required this.onBackground,
    required this.onBackgroundMuted,
    required this.muted,
    required this.error,
    required this.accent,
    required this.success,
    required this.warning,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color line;
  final Color primary;
  final Color primaryMuted;
  final Color secondary;
  final Color onBackground;
  final Color onBackgroundMuted;
  final Color muted;
  final Color error;
  final Color accent;
  final Color success;
  final Color warning;

  static const light = AppColors(
    background: Color(0xFF0A1929),
    surface: Color(0xFF112B3C),
    surfaceElevated: Color(0xFF17384D),
    line: Color(0xFF1E4558),
    primary: Color(0xFF40C4E8),
    primaryMuted: Color(0xFF2A8AA8),
    secondary: Color(0xFFE9AF4F),
    onBackground: Color(0xFFEAF2F4),
    onBackgroundMuted: Color(0xFFB0C4CE),
    muted: Color(0xFF7A97A5),
    error: Color(0xFFE0684E),
    accent: Color(0xFF97A6DD),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFC107),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? line,
    Color? primary,
    Color? primaryMuted,
    Color? secondary,
    Color? onBackground,
    Color? onBackgroundMuted,
    Color? muted,
    Color? error,
    Color? accent,
    Color? success,
    Color? warning,
  }) =>
      AppColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        line: line ?? this.line,
        primary: primary ?? this.primary,
        primaryMuted: primaryMuted ?? this.primaryMuted,
        secondary: secondary ?? this.secondary,
        onBackground: onBackground ?? this.onBackground,
        onBackgroundMuted: onBackgroundMuted ?? this.onBackgroundMuted,
        muted: muted ?? this.muted,
        error: error ?? this.error,
        accent: accent ?? this.accent,
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  AppColors lerp(AppColors? other, double t) => AppColors(
        background: Color.lerp(background, other?.background, t)!,
        surface: Color.lerp(surface, other?.surface, t)!,
        surfaceElevated: Color.lerp(surfaceElevated, other?.surfaceElevated, t)!,
        line: Color.lerp(line, other?.line, t)!,
        primary: Color.lerp(primary, other?.primary, t)!,
        primaryMuted: Color.lerp(primaryMuted, other?.primaryMuted, t)!,
        secondary: Color.lerp(secondary, other?.secondary, t)!,
        onBackground: Color.lerp(onBackground, other?.onBackground, t)!,
        onBackgroundMuted: Color.lerp(onBackgroundMuted, other?.onBackgroundMuted, t)!,
        muted: Color.lerp(muted, other?.muted, t)!,
        error: Color.lerp(error, other?.error, t)!,
        accent: Color.lerp(accent, other?.accent, t)!,
        success: Color.lerp(success, other?.success, t)!,
        warning: Color.lerp(warning, other?.warning, t)!,
      );
}
