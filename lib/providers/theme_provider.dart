import 'package:flutter/material.dart';
import '../theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}