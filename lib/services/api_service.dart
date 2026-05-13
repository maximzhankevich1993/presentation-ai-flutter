import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/presentation.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://presentation-ai-backend.onrender.com/api';
  
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static void clearAuthToken() {
    _authToken = null;
  }
  
  static String? get token => _authToken;
  
  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // AUTH
  // ───────────────────────────────────────────────────────────────────────────
  
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
        _authToken = data['token'];
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
        _authToken = data['token'];
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Ошибка входа');
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
      _authToken = null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GENERATION
  // ───────────────────────────────────────────────────────────────────────────
  
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
  
  // ───────────────────────────────────────────────────────────────────────────
  // VIP STATS
  // ───────────────────────────────────────────────────────────────────────────
  
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
  
  // ───────────────────────────────────────────────────────────────────────────
  // HEALTH CHECK
  // ───────────────────────────────────────────────────────────────────────────
  
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