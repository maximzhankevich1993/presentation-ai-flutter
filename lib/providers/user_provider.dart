import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  String? _avatarUrl;
  
  // Флаг для отслеживания, был ли уже показан оффер в этой сессии
  bool _hasShownUpgradeOffer = false;

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
    _hasShownUpgradeOffer = false; // Сброс флага при новом пользователе
    notifyListeners();
  }

  void updateUser(User user) {
    final int oldFreeLeft = _user?.freeGenerationsLeft ?? 5;
    _user = user;
    
    // Проверка: нужно ли показать оффер?
    // Оффер показываем, если:
    // 1. Пользователь НЕ Premium и НЕ VIP
    // 2. Ещё не показывали в этой сессии
    // 3. Старое значение было 3 (то есть было 3 бесплатных оставалось), а новое = 2 
    //    ИЛИ старое было 4, а новое = 3 (использовал 2 из 5 -> осталось 3)
    //    ИЛИ напрямую после генерации осталось 2 генерации (использовал 3 из 5)
    if (!isPremium && !isVip && !_hasShownUpgradeOffer) {
      final int newFreeLeft = _user?.freeGenerationsLeft ?? 5;
      // Если осталось 2 бесплатные генерации (использовано 3 из 5) — показываем оффер
      if (newFreeLeft == 2 || (oldFreeLeft == 3 && newFreeLeft == 2)) {
        _hasShownUpgradeOffer = true;
        // Уведомляем подписчиков о необходимости показать оффер
        notifyListeners(); 
      } else {
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
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
    _hasShownUpgradeOffer = false;
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
  
  // Сброс флага оффера (например, после его показа)
  void resetUpgradeOfferFlag() {
    _hasShownUpgradeOffer = false;
    notifyListeners();
  }
  
  // Проверка, нужно ли показать оффер (для использования в HomeScreen)
  bool get shouldShowUpgradeOffer {
    return !isPremium && !isVip && !_hasShownUpgradeOffer && (freeGenerationsLeft == 2);
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