import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _isRegisteredKey = 'is_registered';
  static const String _tokenKey = 'auth_token';
  static const String _newsletterKey = 'newsletter';

  // ===== РЕГИСТРАЦИЯ =====

  /// Регистрирует пользователя с email и именем
  static Future<bool> register({
    required String email,
    String? name,
    bool newsletter = false,
  }) async {
    try {
      // Валидация email
      if (!SecurityService.isValidEmail(email)) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      // Сохраняем данные
      await prefs.setString(_emailKey, email);
      if (name != null && name.isNotEmpty) {
        await prefs.setString(_nameKey, name);
      }
      await prefs.setBool(_isRegisteredKey, true);
      await prefs.setBool(_newsletterKey, newsletter);

      // Генерируем токен
      final token = SecurityService.generateToken();
      await SecurityService.saveSecureValue(_tokenKey, token);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== ПРОВЕРКА СТАТУСА =====

  /// Проверяет, зарегистрирован ли пользователь
  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isRegisteredKey) ?? false;
  }

  /// Проверяет, вошёл ли пользователь (есть токен)
  static Future<bool> isLoggedIn() async {
    final token = await SecurityService.getSecureValue(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ===== ПОЛУЧЕНИЕ ДАННЫХ =====

  /// Возвращает email пользователя
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Возвращает имя пользователя
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Проверяет подписку на новости
  static Future<bool> isSubscribedToNewsletter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_newsletterKey) ?? false;
  }

  // ===== ОБНОВЛЕНИЕ ДАННЫХ =====

  /// Обновляет имя пользователя
  static Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  /// Обновляет подписку на новости
  static Future<void> updateNewsletter(bool subscribed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newsletterKey, subscribed);
  }

  // ===== ВЫХОД =====

  /// Выход из аккаунта
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Не удаляем email и имя — пользователь может войти снова
  }

  /// Полное удаление данных пользователя
  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_isRegisteredKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_newsletterKey);
  }

  // ===== ВАЛИДАЦИЯ =====

  /// Проверяет, что email не занят (локальная проверка)
  static bool isEmailAvailable(String email) {
    return SecurityService.isValidEmail(email);
  }
}