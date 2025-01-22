import 'package:flutter/material.dart';

enum AppThemeMode { light, dark }

enum AppFontSize { small, medium, large }

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 14;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  double getFontSize(AppFontSize size) {
    switch (size) {
      case AppFontSize.small:
        return 14.0;
      case AppFontSize.medium:
        return 16.0;
      case AppFontSize.large:
        return 18.0;
    }
  }
}
