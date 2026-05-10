import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://presentation-ai-backend.onrender.com';
  
  String? _token;
  
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();
  
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  
  // ═══════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );
    
    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _token = data['token'];
      return data;
    }
    throw Exception(data['error'] ?? 'Ошибка регистрации');
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      _token = data['token'];
      return data;
    }
    throw Exception(data['error'] ?? 'Ошибка входа');
  }
  
  Future<void> logout() async {
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: _headers(),
      );
    } catch (_) {}
    _token = null;
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    return json.decode(response.body);
  }
  
  // ═══════════════════════════════════════
  // HEALTH
  // ═══════════════════════════════════════
  
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(Uri.parse('$baseUrl/api/health'));
    return json.decode(response.body);
  }
  
  // ═══════════════════════════════════════
  // GENERATE
  // ═══════════════════════════════════════
  
  Future<Map<String, dynamic>> generatePresentation({
    required String topic,
    int maxSlides = 5,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate'),
      headers: _headers(),
      body: json.encode({'topic': topic, 'maxSlides': maxSlides}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    
    final error = json.decode(response.body);
    throw Exception(error['error'] ?? 'Ошибка генерации');
  }
  
  // ═══════════════════════════════════════
  // IMPROVE
  // ═══════════════════════════════════════
  
  Future<String> improveText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/improve'),
      headers: _headers(),
      body: json.encode({'text': text}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['improved'] ?? text;
    }
    return text;
  }
  
  // ═══════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════
  
  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
}