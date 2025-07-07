import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  bool _showPerformance = false;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get showPerformance => _showPerformance;

  static const _localeKey = 'locale_code';
  static const _themeKey = 'theme_mode';
  static const _perfKey = 'perf_overlay';

  SettingsViewModel() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(code);
    final tm = prefs.getString(_themeKey) ?? 'system';
    _themeMode = _strToThemeMode(tm);
    _showPerformance = prefs.getBool(_perfKey) ?? false;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToStr(mode));
  }

  Future<void> setShowPerformance(bool value) async {
    _showPerformance = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_perfKey, value);
  }

  ThemeMode _strToThemeMode(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToStr(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}