import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/presentation.dart';
import '../models/user.dart';
import '../models/social_user.dart';

class ApiService {
  static const String baseUrl = 'https://presentation-ai-backend.onrender.com/api';
  
  static String? _authToken;
  
  // ============================================
  // УПРАВЛЕНИЕ ТОКЕНОМ (С СОХРАНЕНИЕМ)
  // ============================================
  
  static Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      print('✅ Токен загружен: ${_authToken != null ? "есть" : "нет"}');
    } catch (e) {
      print('❌ Ошибка загрузки токена: $e');
    }
  }
  
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _authToken = token;
      print('✅ Токен сохранён');
    } catch (e) {
      print('❌ Ошибка сохранения токена: $e');
    }
  }
  
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _authToken = null;
      print('✅ Токен удалён');
    } catch (e) {
      print('❌ Ошибка удаления токена: $e');
    }
  }
  
  static String? get token => _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static void clearAuthToken() {
    _authToken = null;
  }
  
  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ============================================
  // ОБЫЧНАЯ АВТОРИЗАЦИЯ
  // ============================================
  
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    
    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data.containsKey('token')) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Ошибка регистрации');
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      if (data.containsKey('token')) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Ошибка входа');
    }
  }
  
  // ============================================
  // СОЦИАЛЬНАЯ АВТОРИЗАЦИЯ
  // ============================================
  
  static Future<Map<String, dynamic>> socialLogin(SocialUser socialUser) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/social'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(socialUser.toJson()),
    );
    
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      if (data.containsKey('token')) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Ошибка социального входа');
    }
  }
  
  // ============================================
  // ПРОФИЛЬ
  // ============================================
  
  static Future<User> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Сессия истекла');
    } else {
      throw Exception('Ошибка загрузки профиля');
    }
  }
  
  static Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _getHeaders(),
      body: json.encode(user.toJson()),
    );
    
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Ошибка обновления профиля');
    }
  }
  
  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Ошибка сброса пароля');
    }
  }
  
  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Logout error on server: ${response.statusCode}');
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await clearToken();
    }
  }

  // ============================================
  // ГЕНЕРАЦИЯ ПРЕЗЕНТАЦИИ
  // ============================================
  
  static Future<Presentation> generate({
    required String topic,
    required int slideCount,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: _getHeaders(),
        body: json.encode({
          'topic': topic,
          'slideCount': slideCount,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Presentation.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Требуется авторизация');
      } else if (response.statusCode == 429) {
        throw Exception('Превышен лимит генераций');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка генерации');
      }
    } catch (e) {
      throw Exception('Ошибка соединения: $e');
    }
  }
  
  static Future<String> improveText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/improve'),
      headers: _getHeaders(),
      body: json.encode({'text': text}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['improvedText'] ?? data['text'] ?? text;
    } else if (response.statusCode == 401) {
      throw Exception('Требуется авторизация');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Ошибка улучшения текста');
    }
  }

  // ============================================
  // ⭐ НОВЫЙ МЕТОД: ГЕНЕРАЦИЯ ПЛАНА УРОКА ⭐
  // ============================================
  
  static Future<Map<String, dynamic>> generateLessonPlan({
    required String topic,
    required String subject,
    required String standard,
    required String grade,
    required int durationMinutes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lesson-plan/generate'),
        headers: _getHeaders(),
        body: json.encode({
          'topic': topic,
          'subject': subject,
          'standard': standard,
          'grade': grade,
          'durationMinutes': durationMinutes,
        }),
      );
      
      print('📚 Lesson Plan API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Lesson Plan получен успешно');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Требуется авторизация');
      } else if (response.statusCode == 429) {
        throw Exception('Превышен лимит генераций');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка генерации плана урока');
      }
    } catch (e) {
      print('❌ Ошибка генерации плана урока: $e');
      throw Exception('Ошибка соединения: $e');
    }
  }
  
  // ============================================
  // ШАБЛОНЫ
  // ============================================
  
  static Future<Map<String, dynamic>> getTemplates({bool includePremium = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/templates?include_premium=$includePremium'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки шаблонов');
    }
  }
  
  static Future<Map<String, dynamic>> getFreeTemplates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/templates/free'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки шаблонов');
    }
  }
  
  static Future<Map<String, dynamic>> getPremiumTemplates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/templates/premium'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Premium доступ только для подписчиков');
    } else {
      throw Exception('Ошибка загрузки премиум шаблонов');
    }
  }
  
  // ============================================
  // VIP СТАТИСТИКА
  // ============================================
  
  static Future<Map<String, dynamic>> getVipStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/vip/stats'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки VIP статистики');
    }
  }
  
  // ============================================
  // ЭКСПОРТ
  // ============================================
  
  static Future<Map<String, dynamic>> exportToPPTX(Map<String, dynamic> presentationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/export/pptx'),
      headers: _getHeaders(),
      body: json.encode(presentationData),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка экспорта в PPTX');
    }
  }
  
  static Future<Map<String, dynamic>> exportToPDF(Map<String, dynamic> presentationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/export/pdf'),
      headers: _getHeaders(),
      body: json.encode(presentationData),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Premium доступ required');
    } else {
      throw Exception('Ошибка экспорта в PDF');
    }
  }
  
  // ============================================
  // HEALTH CHECK
  // ============================================
  
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}