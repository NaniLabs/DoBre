import 'package:dobre/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to dark and restores the selected theme', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final theme = ThemeProvider(preferences);
    expect(theme.themeMode, ThemeMode.dark);
    await theme.cambiarTema(false);
    expect(ThemeProvider(preferences).themeMode, ThemeMode.light);
    await theme.cambiarTema(true);
    expect(ThemeProvider(preferences).themeMode, ThemeMode.dark);
  });
}
