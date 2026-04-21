import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLangNotifier extends ChangeNotifier {
  static const _key = 'locale';
  final SharedPreferences _prefs;
  late Locale _locale;

  AppLangNotifier(this._prefs) {
    _locale = _loadLocale(_prefs);
  }

  Locale get locale => _locale;

  static Locale _loadLocale(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'en') return const Locale('en');
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _prefs.setString(_key, locale.languageCode);
  }
}
