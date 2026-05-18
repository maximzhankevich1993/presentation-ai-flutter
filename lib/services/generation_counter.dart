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
      return newCount;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<bool> canGenerate(bool isLoggedIn, bool isPremium) async {
    if (isPremium) return true;
    if (isLoggedIn) return true;
    
    final count = await getCount();
    return count < 5;
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
    } catch (e) {
      // ignore
    }
  }
}