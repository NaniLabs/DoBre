import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider([SharedPreferences? preferences])
    : _preferences = preferences {
    if (_preferences != null) {
      final savedDark = _preferences.getBool(_themeKey);
      if (savedDark != null) {
        _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
      }
    }
  }

  static const _themeKey = 'app_theme_dark_mode';
  final SharedPreferences? _preferences;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get modoOscuro => _themeMode == ThemeMode.dark;

  Future<void> cambiarTema(bool oscuro) async {
    _themeMode = oscuro ? ThemeMode.dark : ThemeMode.light;
    await _preferences?.setBool(_themeKey, oscuro);
    notifyListeners();
  }
}

