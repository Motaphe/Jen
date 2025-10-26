import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  static Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'dark';
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? false;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }
}
