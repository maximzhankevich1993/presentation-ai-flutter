import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  static const String _unsplashAccessKey = 'Zkb4SABqCLoQgrs8cqy1iPZYqlOgCeXNJRKfrBReVAM';
  static const String _baseUrl = 'https://api.unsplash.com';

  static Future<String?> searchImage(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/photos?query=$query&per_page=1&orientation=landscape'),
        headers: {'Authorization': 'Client-ID $_unsplashAccessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[0]['urls']['regular'] as String;
        }
      }
    } catch (e) {
      // Fallback: используем placeholder изображение
    }
    
    // Бесплатный placeholder если нет ключа Unsplash
    return 'https://images.unsplash.com/photo-${query.hashCode.abs().toString().substring(0, 6)}?w=600&fit=crop';
  }
}