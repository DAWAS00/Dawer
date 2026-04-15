import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeNotifier extends ChangeNotifier {
  static const _key = 'theme_mode';
  final SharedPreferences _prefs;
  late ThemeMode _mode;

  AppThemeNotifier(this._prefs) {
    _mode = _loadMode(_prefs);
  }

  ThemeMode get mode => _mode;

  static ThemeMode _loadMode(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'light') return ThemeMode.light;
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    
    _mode = mode;
    notifyListeners();
    
    if (mode == ThemeMode.system) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
    }
  }
}
