import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.base,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lavender,
      surface: AppColors.surface0,
      error: AppColors.red,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.base,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.text),
      bodyMedium: TextStyle(color: AppColors.text),
      bodySmall: TextStyle(color: AppColors.subtext0),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.latteBase,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lavender,
      surface: AppColors.latteSurface0,
      error: AppColors.red,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.latteBase,
      foregroundColor: AppColors.latteText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.latteText),
      bodyMedium: TextStyle(color: AppColors.latteText),
      bodySmall: TextStyle(color: AppColors.latteSubtext0),
    ),
  );
}

// Extension to get theme-aware colors
extension ThemeAwareColors on BuildContext {
  Color get backgroundColor => Theme.of(this).brightness == Brightness.dark
      ? AppColors.base
      : AppColors.latteBase;

  Color get surfaceColor => Theme.of(this).brightness == Brightness.dark
      ? AppColors.surface0
      : AppColors.latteSurface0;

  Color get surface1Color => Theme.of(this).brightness == Brightness.dark
      ? AppColors.surface1
      : AppColors.latteSurface1;

  Color get textColor => Theme.of(this).brightness == Brightness.dark
      ? AppColors.text
      : AppColors.latteText;

  Color get subtextColor => Theme.of(this).brightness == Brightness.dark
      ? AppColors.subtext0
      : AppColors.latteSubtext0;

  Color get overlayColor => Theme.of(this).brightness == Brightness.dark
      ? AppColors.overlay0
      : AppColors.latteOverlay0;

  Color get overlay1Color => Theme.of(this).brightness == Brightness.dark
      ? AppColors.overlay1
      : AppColors.latteOverlay1;
}
