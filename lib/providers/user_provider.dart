import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  String? _avatarUrl;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get avatarUrl => _avatarUrl;
  
  bool get isLoggedIn => _user != null && _token != null;
  bool get isPremium => _user?.isPremium ?? false;
  bool get isVip => _user?.isVip ?? false;
  int get freeGenerationsLeft => _user?.freeGenerationsLeft ?? 5;
  int get monthlyGenerationsLeft => _user?.monthlyGenerationsLeft ?? 5;
  String get userName => _user?.name ?? '';
  String get userEmail => _user?.email ?? '';

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

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setAvatarUrl(String url) {
    _avatarUrl = url;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = null;
    _avatarUrl = null;
    notifyListeners();
  }

  void setUserName(String name) {
    if (_user != null) {
      _user = _user!.copyWith(name: name);
      notifyListeners();
    }
  }

  void setUserEmail(String email) {
    if (_user != null) {
      _user = _user!.copyWith(email: email);
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    if (_token == null) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final user = await ApiService.getProfile();
      _user = user;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      print('Ошибка загрузки пользователя: $e');
    }
  }

  Future<void> refreshUser() async {
    await loadUser();
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      clearUser();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}