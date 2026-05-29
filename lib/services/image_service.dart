import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  static Future<String?> searchImage(String query) async {
    try {
      // Пробуем Unsplash search API (публичный, без ключа)
      final response = await http.get(
        Uri.parse('https://unsplash.com/napi/search/photos?query=$query&per_page=1'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final urls = results[0]['urls'] as Map<String, dynamic>?;
          if (urls != null) {
            return urls['regular'] as String?;
          }
        }
      }
    } catch (e) {
      // Ничего не делаем
    }
    
    // Если Unsplash не ответил — возвращаем null (не показывать картинку)
    return null;
  }
}