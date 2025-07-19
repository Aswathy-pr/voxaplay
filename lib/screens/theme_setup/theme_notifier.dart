import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  final String _themeKey = 'theme';

  ThemeNotifier(this._themeData) {
    _loadTheme();
  }

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
    await _saveTheme(themeData);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeData = isDark ? darkTheme : lightTheme;
    notifyListeners();
  }

  Future<void> _saveTheme(ThemeData themeData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, themeData == darkTheme);
  }
}