import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;

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

  void setUser(User user, {String? token}) {
    _user = user;
    if (token != null) {
      _token = token;
      ApiService.setAuthToken(token);
      ApiService.saveToken(token);
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
      _saveUserToServer();
    }
  }

  void setUserName(String name) {
    if (_user != null) {
      _user = _user!.copyWith(name: name);
      notifyListeners();
      _saveUserToServer();
    }
  }

  void useFreeGeneration() {
    if (_user != null && !_user!.isPremium && _user!.freeGenerationsLeft > 0) {
      _user = _user!.copyWith(freeGenerationsLeft: _user!.freeGenerationsLeft - 1);
      notifyListeners();
      _saveUserToServer();
    }
  }

  void incrementGenerations(int amount) {
    if (_user != null) {
      _user = _user!.copyWith(freeGenerationsLeft: _user!.freeGenerationsLeft + amount);
      notifyListeners();
      _saveUserToServer();
    }
  }

  Future<void> _saveUserToServer() async {
    if (_user == null) return;
    try {
      await ApiService.updateUser(_user!);
    } catch (e) {
      debugPrint('Error saving user to server: $e');
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await ApiService.getProfile();
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _token = null;
    notifyListeners();
  }

  void setPremium(bool isPremium, {DateTime? until}) {
    if (_user != null) {
      _user = _user!.copyWith(
        isPremium: isPremium,
        premiumUntil: until,
      );
      notifyListeners();
      _saveUserToServer();
    }
  }
}