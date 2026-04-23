import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeModeType _themeMode = ThemeModeType.system;
  
  ThemeModeType get themeModeType => _themeMode;
  
  ThemeMode get themeMode {
    switch (_themeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode') ?? 'system';
    
    _themeMode = ThemeModeType.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeModeType.system,
    );
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeType mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    
    notifyListeners();
  }
}