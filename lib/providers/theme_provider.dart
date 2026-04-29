import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeModeType _themeMode = ThemeModeType.system;
  SharedPreferences? _prefs;
  bool _isLoaded = false;

  ThemeModeType get themeModeType => _themeMode;
  bool get isLoaded => _isLoaded;

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
    _prefs = await SharedPreferences.getInstance();

    final saved = _prefs?.getString('themeMode') ?? 'system';

    _themeMode = ThemeModeType.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeModeType.system,
    );

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeType mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('themeMode', mode.name);

    notifyListeners();
  }
}