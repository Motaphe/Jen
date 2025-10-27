import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.base,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lavender,
      surface: AppColors.surface0,
      error: AppColors.red,
    ).copyWith(
      secondary: AppColors.mauve,
      onSurface: AppColors.text,
      onPrimary: AppColors.base,
      onSecondary: AppColors.base,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.base,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.text,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.mantle,
      selectedItemColor: AppColors.lavender,
      unselectedItemColor: AppColors.overlay1,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    fontFamily: GoogleFonts.nunito().fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.latteBase,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lavender,
      surface: AppColors.latteSurface0,
      error: AppColors.red,
    ).copyWith(
      secondary: AppColors.mauve,
      onSurface: AppColors.latteText,
      onPrimary: AppColors.base,
      onSecondary: AppColors.base,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.latteBase,
      foregroundColor: AppColors.latteText,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.latteText,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.latteSurface1,
      selectedItemColor: AppColors.lavender,
      unselectedItemColor: AppColors.latteOverlay1,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).apply(
      bodyColor: AppColors.latteText,
      displayColor: AppColors.latteText,
    ),
    fontFamily: GoogleFonts.nunito().fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
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
