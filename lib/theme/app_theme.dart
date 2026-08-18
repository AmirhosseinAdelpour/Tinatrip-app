import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colors = AppColors.light;
    final colorScheme = ColorScheme.dark(
      primary: colors.primary,
      onPrimary: colors.background,
      secondary: colors.secondary,
      onSecondary: colors.background,
      surface: colors.surface,
      onSurface: colors.onBackground,
      error: colors.error,
      outline: colors.line,
      outlineVariant: colors.line,
    );

    final textTheme = GoogleFonts.vazirmatnTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.vazirmatn(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        color: colors.onBackground,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.vazirmatn(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        color: colors.onBackground,
      ),
      displaySmall: GoogleFonts.vazirmatn(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: colors.onBackground,
        letterSpacing: 0.8,
      ),
      headlineLarge: GoogleFonts.vazirmatn(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
      ),
      headlineMedium: GoogleFonts.vazirmatn(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
      ),
      headlineSmall: GoogleFonts.vazirmatn(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
      ),
      titleLarge: GoogleFonts.vazirmatn(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.onBackground,
      ),
      titleMedium: GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      titleSmall: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      bodyLarge: GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.onBackground,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.onBackground,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.muted,
      ),
      labelLarge: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.onBackground,
      ),
      labelMedium: GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.muted,
      ),
      labelSmall: GoogleFonts.vazirmatn(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      fontFamily: 'Vazirmatn',
      extensions: const [AppColors.light, AppSpacing()],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withAlpha(60),
        selectionHandleColor: colors.primary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.onBackground,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withAlpha(30),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? colors.primary : colors.muted,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 1.6),
        ),
        hintStyle: GoogleFonts.vazirmatn(
          fontSize: 14,
          color: colors.muted.withAlpha(150),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.background,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.vazirmatn(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceElevated,
        contentTextStyle: GoogleFonts.vazirmatn(
          fontSize: 14,
          color: colors.onBackground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.surface,
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
