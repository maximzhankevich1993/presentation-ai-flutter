import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'User';
  String _userEmail = '';

  bool _isPremium = false;
  bool _isLoggedIn = true;

  int _freeGenerationsLeft = 5;

  // GETTERS
  String get userName => _userName;
  String get userEmail => _userEmail;

  bool get isPremium => _isPremium;
  bool get isLoggedIn => _isLoggedIn;

  int get freeGenerationsLeft => _freeGenerationsLeft;

  // USERNAME
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // EMAIL
  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  // PREMIUM
  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // LOGIN
  void login({
    required String name,
    required String email,
    bool premium = false,
  }) {
    _userName = name;
    _userEmail = email;
    _isPremium = premium;
    _isLoggedIn = true;

    notifyListeners();
  }

  // USE FREE GENERATION
  void useFreeGeneration() {
    if (_freeGenerationsLeft > 0) {
      _freeGenerationsLeft--;
      notifyListeners();
    }
  }

  // RESET FREE GENERATIONS
  void resetFreeGenerations() {
    _freeGenerationsLeft = 5;
    notifyListeners();
  }

  // LOGOUT
  void logout() {
    _userName = 'User';
    _userEmail = '';

    _isPremium = false;
    _isLoggedIn = false;

    _freeGenerationsLeft = 5;

    notifyListeners();
  }

  // RESET
  void reset() {
    logout();
  }
}