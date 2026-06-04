import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LanguageProvider extends ChangeNotifier {
  String _locale = 'ru';
  
  String get locale => _locale;
  
  LanguageProvider() {
    _detectLanguage();
  }
  
  Future<void> _detectLanguage() async {
    try {
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final country = data['country_code'] ?? 'US';
        
        // Страны СНГ — русский, остальные — английский
        final cisCountries = ['RU', 'BY', 'KZ', 'AM', 'KG', 'UZ', 'TJ', 'AZ', 'MD', 'UA'];
        
        if (cisCountries.contains(country)) {
          _locale = 'ru';
        } else {
          _locale = 'en';
        }
      } else {
        _locale = 'en';
      }
    } catch (e) {
      _locale = 'en';
    }
    notifyListeners();
  }
  
  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }
  
  String get currentLanguage => _locale;
}