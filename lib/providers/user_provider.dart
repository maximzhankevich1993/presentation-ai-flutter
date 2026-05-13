import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'User';
  String _email = '';
  bool _isPremium = false;

  // GETTERS
  String get userName => _userName;
  String get email => _email;
  bool get isPremium => _isPremium;

  // SET USERNAME
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // SET EMAIL
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  // SET PREMIUM
  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // RESET USER
  void reset() {
    _userName = 'User';
    _email = '';
    _isPremium = false;
    notifyListeners();
  }
}