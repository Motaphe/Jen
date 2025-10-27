import 'package:flutter/material.dart';
import '../services/preferences_helper.dart';

/// Provider for managing theme mode state using ChangeNotifier pattern.
/// Persists theme selection to SharedPreferences and notifies listeners on change.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Loads persisted theme mode from SharedPreferences on initialization.
  Future<void> _loadThemeMode() async {
    final savedMode = await PreferencesHelper.getThemeMode();
    _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Toggles between light and dark mode and persists the change.
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await PreferencesHelper.setThemeMode(
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await PreferencesHelper.setThemeMode(
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }
}
