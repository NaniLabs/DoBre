import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get modoOscuro => _themeMode == ThemeMode.dark;

  void cambiarTema(bool oscuro) {
    _themeMode = oscuro ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}
