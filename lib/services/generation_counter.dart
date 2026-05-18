import 'package:shared_preferences/shared_preferences.dart';

class GenerationCounter {
  static const String _key = 'guest_generation_count';
  
  static Future<int> getCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key) ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<int> increment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_key) ?? 0;
      final newCount = current + 1;
      await prefs.setInt(_key, newCount);
      print('📊 Счётчик генераций: $current → $newCount');
      return newCount;
    } catch (e) {
      print('❌ Ошибка увеличения счётчика: $e');
      return 0;
    }
  }
  
  static Future<bool> canGenerate(bool isLoggedIn, bool isPremium) async {
    // Premium пользователи — без лимита
    if (isPremium) return true;
    
    // Авторизованные пользователи — без лимита
    if (isLoggedIn) return true;
    
    // Гости — только 5 генераций
    final count = await getCount();
    final can = count < 5;
    print('🔍 Проверка лимита: гость, использовано $count из 5, можно: $can');
    return can;
  }
  
  static Future<int> getRemainingForGuest() async {
    final count = await getCount();
    final remaining = 5 - count;
    return remaining > 0 ? remaining : 0;
  }
  
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      print('🔄 Счётчик сброшен');
    } catch (e) {
      print('❌ Ошибка сброса счётчика: $e');
    }
  }
}