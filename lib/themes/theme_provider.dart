import 'package:flutter/material.dart';
import 'package:pinatacao/themes/my_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get themeData => _isDarkMode ? darkMode : lightMode;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
