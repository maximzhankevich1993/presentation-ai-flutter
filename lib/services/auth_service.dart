import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _isRegisteredKey = 'is_registered';
  static const String _tokenKey = 'auth_token';
  static const String _newsletterKey = 'newsletter';

  // ===== РЕГИСТРАЦИЯ =====

  static Future<bool> register({
    required String email,
    String? name,
    bool newsletter = false,
  }) async {
    try {
      if (!SecurityService.isValidEmail(email)) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_emailKey, email);

      if (name != null && name.isNotEmpty) {
        await prefs.setString(_nameKey, name);
      }

      await prefs.setBool(_isRegisteredKey, true);
      await prefs.setBool(_newsletterKey, newsletter);

      final token = SecurityService.generateToken();
      await SecurityService.saveSecureValue(_tokenKey, token);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== ПРОВЕРКА СТАТУСА =====

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isRegisteredKey) ?? false;
  }

  static Future<bool> isLoggedIn() async {
    final token = await SecurityService.getSecureValue(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ===== ПОЛУЧЕНИЕ ДАННЫХ =====

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<bool> isSubscribedToNewsletter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_newsletterKey) ?? false;
  }

  // ===== ОБНОВЛЕНИЕ ДАННЫХ =====

  static Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  static Future<void> updateNewsletter(bool subscribed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newsletterKey, subscribed);
  }

  // ===== ВЫХОД =====

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_isRegisteredKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_newsletterKey);
  }

  // ===== ВАЛИДАЦИЯ =====

  static bool isEmailAvailable(String email) {
    return SecurityService.isValidEmail(email);
  }
}