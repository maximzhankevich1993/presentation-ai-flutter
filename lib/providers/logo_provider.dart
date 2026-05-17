import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrandKitProvider extends ChangeNotifier {
  String? _logoUrl;
  String? get logoUrl => _logoUrl;
  
  static const String _logoKey = 'brand_logo_url';

  BrandKitProvider() {
    _loadSavedLogo();
  }

  Future<void> _loadSavedLogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _logoUrl = prefs.getString(_logoKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading logo: $e');
    }
  }

  Future<void> setLogo(String url) async {
    _logoUrl = url;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoKey, url);
    } catch (e) {
      debugPrint('Error saving logo: $e');
    }
    notifyListeners();
  }

  Future<void> clear() async {
    _logoUrl = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logoKey);
    } catch (e) {
      debugPrint('Error clearing logo: $e');
    }
    notifyListeners();
  }
}