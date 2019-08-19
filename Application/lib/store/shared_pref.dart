import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Utility to get access to settings value, stored in persistent memory via shared preference. <br>
/// Warning: do not used for sensitive data
class Settings {
  /// Store variables in shared preference (not secured so for non-sensitive data)
  static Future<bool> getSwitchValue(String key, bool defaultValue) async {
    final SharedPreferences settings = await SharedPreferences.getInstance();

    return settings.getBool(key) ?? defaultValue;
  }

  static Future<bool> setSwitchValue(String key, bool value) async {
    final SharedPreferences settings = await SharedPreferences.getInstance();

    return settings.setBool(key, value);
  }
}
