import 'package:flutter/material.dart';
import '../models/user.dart';  // ← импортируем User из models

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;

  // GETTERS
  User? get user => _user;
  String? get token => _token;
  
  bool get isPremium => _user?.isPremium ?? false;
  int get freeGenerationsLeft => _user?.freeGenerationsLeft ?? 5;
  int get maxSlidesPerPresentation => _user?.maxSlidesPerPresentation ?? 10;
  bool get isLoggedIn => _user != null;
  
  String get userName => _user?.name ?? 'Гость';
  String get userEmail => _user?.email ?? '';
  String get userId => _user?.id ?? '';
  bool get hasAvatar => _user?.avatarUrl != null;
  String? get avatarUrl => _user?.avatarUrl;

  // SET USER (принимает User из models/user.dart)
  void setUser(User user, {String? token}) {
    _user = user;
    if (token != null) {
      _token = token;
    }
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setUserEmail(String email) {
    if (_user != null) {
      _user = _user!.copyWith(email: email);
      notifyListeners();
    }
  }

  void setUserName(String name) {
    if (_user != null) {
      _user = _user!.copyWith(name: name);
      notifyListeners();
    }
  }

  void setAvatarUrl(String? url) {
    if (_user != null) {
      _user = _user!.copyWith(avatarUrl: url);
      notifyListeners();
    }
  }

  void setPremium(bool value, {DateTime? until}) {
    if (_user != null) {
      _user = _user!.copyWith(isPremium: value, premiumUntil: until);
      notifyListeners();
    }
  }

  void useFreeGeneration() {
    if (_user != null && !_user!.isPremium && _user!.freeGenerationsLeft > 0) {
      _user = _user!.copyWith(freeGenerationsLeft: _user!.freeGenerationsLeft - 1);
      notifyListeners();
    }
  }

  void resetFreeGenerations() {
    if (_user != null) {
      _user = _user!.copyWith(freeGenerationsLeft: 5);
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }

  void reset() {
    logout();
  }
}