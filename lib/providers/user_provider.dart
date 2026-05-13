import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'User';
  String _userEmail = '';
  bool _isPremium = false;
  bool _isLoggedIn = true;

  // GETTERS
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isPremium => _isPremium;
  bool get isLoggedIn => _isLoggedIn;

  // SET USERNAME
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // SET EMAIL
  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  // SET PREMIUM
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

  // LOGOUT
  void logout() {
    _userName = 'User';
    _userEmail = '';
    _isPremium = false;
    _isLoggedIn = false;

    notifyListeners();
  }

  // RESET
  void reset() {
    _userName = 'User';
    _userEmail = '';
    _isPremium = false;
    _isLoggedIn = false;

    notifyListeners();
  }
}