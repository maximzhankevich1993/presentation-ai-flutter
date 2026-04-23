import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isPremium = false;
  int _freeGenerationsLeft = 5;
  String? _userEmail;
  
  bool get isPremium => _isPremium;
  int get freeGenerationsLeft => _freeGenerationsLeft;
  String? get userEmail => _userEmail;
  
  bool get canGenerate {
    if (_isPremium) return true;
    return _freeGenerationsLeft > 0;
  }
  
  int get maxSlidesPerPresentation => _isPremium ? 50 : 10;

  UserProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isPremium = prefs.getBool('isPremium') ?? false;
    _freeGenerationsLeft = prefs.getInt('freeGenerationsLeft') ?? 5;
    _userEmail = prefs.getString('userEmail');
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('isPremium', _isPremium);
    await prefs.setInt('freeGenerationsLeft', _freeGenerationsLeft);
    if (_userEmail != null) {
      await prefs.setString('userEmail', _userEmail!);
    }
    
    notifyListeners();
  }

  Future<bool> useGeneration() async {
    if (!canGenerate) return false;
    
    if (!_isPremium) {
      _freeGenerationsLeft--;
    }
    
    await _saveData();
    return true;
  }

  void setUserEmail(String email) {
    _userEmail = email;
    _saveData();
  }

  Future<void> activatePremium() async {
    _isPremium = true;
    await _saveData();
  }
}