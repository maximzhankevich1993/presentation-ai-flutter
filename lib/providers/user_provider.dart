import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String email;
  final String? avatarUrl;

  UserModel({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class UserProvider extends ChangeNotifier {
  String _userName = 'User';
  String _userEmail = '';

  String? _avatarUrl;

  bool _isPremium = false;
  bool _isLoggedIn = true;

  int _freeGenerationsLeft = 5;

  // USER OBJECT
  UserModel get user => UserModel(
        name: _userName,
        email: _userEmail,
        avatarUrl: _avatarUrl,
      );

  // GETTERS
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get avatarUrl => _avatarUrl;

  bool get isPremium => _isPremium;
  bool get isLoggedIn => _isLoggedIn;

  int get freeGenerationsLeft => _freeGenerationsLeft;

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

  // SET AVATAR
  void setAvatarUrl(String? url) {
    _avatarUrl = url;
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
    String? avatarUrl,
    bool premium = false,
  }) {
    _userName = name;
    _userEmail = email;

    _avatarUrl = avatarUrl;

    _isPremium = premium;
    _isLoggedIn = true;

    notifyListeners();
  }

  // FREE GENERATIONS
  void useFreeGeneration() {
    if (_freeGenerationsLeft > 0) {
      _freeGenerationsLeft--;
      notifyListeners();
    }
  }

  void resetFreeGenerations() {
    _freeGenerationsLeft = 5;
    notifyListeners();
  }

  // LOGOUT
  void logout() {
    _userName = 'User';
    _userEmail = '';

    _avatarUrl = null;

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