import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  static ThemeData light() =>
      _theme(brightness: Brightness.light, palette: AppPalette.light);

  static ThemeData dark() =>
      _theme(brightness: Brightness.dark, palette: AppPalette.dark);

  static ThemeData _theme({
    required Brightness brightness,
    required AppPalette palette,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.accent,
          brightness: brightness,
          surface: palette.surfacePrimary,
        ).copyWith(
          primary: palette.accent,
          onPrimary: Colors.white,
          secondary: palette.accent,
          onSecondary: Colors.white,
          tertiary: palette.success,
          onTertiary: Colors.white,
          error: palette.danger,
          onError: Colors.white,
          surface: palette.surfacePrimary,
          onSurface: palette.textPrimary,
          surfaceContainerHighest: palette.surfaceSecondary,
          outline: palette.stroke,
          outlineVariant: palette.strokeSoft,
          inverseSurface: palette.textPrimary,
          onInverseSurface: palette.surfacePrimary,
          shadow: palette.shadow,
          scrim: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.62 : 0.14,
          ),
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      extensions: [palette],
    );

    return base.copyWith(
      splashFactory: NoSplash.splashFactory,
      dividerColor: palette.strokeSoft,
      hoverColor: palette.hover,
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.9,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          height: 1.45,
          color: palette.textPrimary,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          height: 1.4,
          color: palette.textSecondary,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          height: 1.35,
          color: palette.textMuted,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surfacePrimary,
        margin: EdgeInsets.zero,
        shadowColor: palette.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.strokeSoft),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: palette.surfaceSecondary,
        side: BorderSide(color: palette.strokeSoft),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textSecondary,
          backgroundColor: palette.surfaceSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: palette.strokeSoft),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSecondary,
        hintStyle: TextStyle(color: palette.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.strokeSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.strokeSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.accent.withValues(alpha: 0.42)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: palette.strokeSoft)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.surfacePrimary;
            }
            return palette.surfaceSecondary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.textPrimary;
            }
            return palette.textSecondary;
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.surfaceTertiary,
        contentTextStyle: TextStyle(color: palette.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
