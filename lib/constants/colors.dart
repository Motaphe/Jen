import 'package:flutter/material.dart';

/// Catppuccin color palette: Mocha (dark) and Latte (light) variants.
/// Includes semantic colors for mood tracking (green=happy, red=sad).
class AppColors {
  // Dark theme - Base colors
  static const Color base = Color(0xFF1e1e2e);
  static const Color mantle = Color(0xFF181825);
  static const Color crust = Color(0xFF11111b);

  // Dark theme - Surface colors
  static const Color surface0 = Color(0xFF313244);
  static const Color surface1 = Color(0xFF45475a);
  static const Color surface2 = Color(0xFF585b70);

  // Dark theme - Overlay colors
  static const Color overlay0 = Color(0xFF6c7086);
  static const Color overlay1 = Color(0xFF7f849c);
  static const Color overlay2 = Color(0xFF9399b2);

  // Dark theme - Text colors
  static const Color text = Color(0xFFcdd6f4);
  static const Color subtext0 = Color(0xFFa6adc8);
  static const Color subtext1 = Color(0xFFbac2de);

  // Light theme - Catppuccin Latte colors
  static const Color latteBase = Color(0xFFF7F9FE);
  static const Color latteMantle = Color(0xFFF0F3FA);
  static const Color latteCrust = Color(0xFFE7EBF6);

  static const Color latteSurface0 = Color(0xFFFFFFFF);
  static const Color latteSurface1 = Color(0xFFF2F5FC);
  static const Color latteSurface2 = Color(0xFFE8ECF8);

  static const Color latteOverlay0 = Color(0xFF868AA6);
  static const Color latteOverlay1 = Color(0xFF6F7394);
  static const Color latteOverlay2 = Color(0xFF595E85);

  static const Color latteText = Color(0xFF252A48);
  static const Color latteSubtext0 = Color(0xFF41476A);
  static const Color latteSubtext1 = Color(0xFF3A4061);

  // Accent colors
  static const Color lavender = Color(0xFFb4befe);
  static const Color blue = Color(0xFF89b4fa);
  static const Color sapphire = Color(0xFF74c7ec);
  static const Color sky = Color(0xFF89dceb);
  static const Color teal = Color(0xFF94e2d5);
  static const Color green = Color(0xFFa6e3a1);
  static const Color yellow = Color(0xFFf9e2af);
  static const Color peach = Color(0xFFfab387);
  static const Color maroon = Color(0xFFeba0ac);
  static const Color red = Color(0xFFf38ba8);
  static const Color mauve = Color(0xFFcba6f7);
  static const Color pink = Color(0xFFf5c2e7);
  static const Color flamingo = Color(0xFFf2cdcd);
  static const Color rosewater = Color(0xFFf5e0dc);

  // Mood-specific colors
  static const Color moodVeryHappy = green;
  static const Color moodHappy = teal;
  static const Color moodNeutral = yellow;
  static const Color moodSad = peach;
  static const Color moodVerySad = red;
}
