import 'package:shared_preferences/shared_preferences.dart';

class GenerationCounter {
  // Ключи для хранения в SharedPreferences
  static const String _keyPresentation = 'guest_generation_count_presentation';
  static const String _keyReport = 'guest_generation_count_report';
  
  // Лимиты
  static const int _presentationLimit = 5;  // 5 бесплатных презентаций для гостей
  static const int _reportLimit = 3;        // 3 бесплатных отчёта для гостей
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ПРЕЗЕНТАЦИИ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Получить количество использованных генераций презентаций
  static Future<int> getPresentationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyPresentation) ?? 0;
    } catch (e) {
      print('❌ Ошибка получения счётчика презентаций: $e');
      return 0;
    }
  }
  
  /// Увеличить счётчик презентаций на 1
  static Future<int> incrementPresentation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyPresentation) ?? 0;
      final newCount = current + 1;
      await prefs.setInt(_keyPresentation, newCount);
      print('📊 Счётчик презентаций: $current → $newCount');
      return newCount;
    } catch (e) {
      print('❌ Ошибка увеличения счётчика презентаций: $e');
      return 0;
    }
  }
  
  /// Проверить, может ли пользователь создать презентацию
  static Future<bool> canGeneratePresentation(bool isLoggedIn, bool isPremium) async {
    // Premium пользователи — без лимита
    if (isPremium) return true;
    
    // Авторизованные пользователи — без лимита
    if (isLoggedIn) return true;
    
    // Гости — только 5 презентаций
    final count = await getPresentationCount();
    final can = count < _presentationLimit;
    print('🔍 Проверка лимита презентаций: гость, использовано $count из $_presentationLimit, можно: $can');
    return can;
  }
  
  /// Получить остаток бесплатных презентаций для гостя
  static Future<int> getRemainingPresentationsForGuest() async {
    final count = await getPresentationCount();
    final remaining = _presentationLimit - count;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Сбросить счётчик презентаций (для тестирования)
  static Future<void> resetPresentationCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPresentation);
      print('🔄 Счётчик презентаций сброшен');
    } catch (e) {
      print('❌ Ошибка сброса счётчика презентаций: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ОТЧЁТЫ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Получить количество использованных генераций отчётов
  static Future<int> getReportCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyReport) ?? 0;
    } catch (e) {
      print('❌ Ошибка получения счётчика отчётов: $e');
      return 0;
    }
  }
  
  /// Увеличить счётчик отчётов на 1
  static Future<int> incrementReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyReport) ?? 0;
      final newCount = current + 1;
      await prefs.setInt(_keyReport, newCount);
      print('📊 Счётчик отчётов: $current → $newCount');
      return newCount;
    } catch (e) {
      print('❌ Ошибка увеличения счётчика отчётов: $e');
      return 0;
    }
  }
  
  /// Проверить, может ли пользователь создать отчёт
  static Future<bool> canGenerateReport(bool isLoggedIn, bool isPremium) async {
    // Premium пользователи — без лимита
    if (isPremium) return true;
    
    // Авторизованные пользователи — без лимита
    if (isLoggedIn) return true;
    
    // Гости — только 3 отчёта
    final count = await getReportCount();
    final can = count < _reportLimit;
    print('🔍 Проверка лимита отчётов: гость, использовано $count из $_reportLimit, можно: $can');
    return can;
  }
  
  /// Получить остаток бесплатных отчётов для гостя
  static Future<int> getRemainingReportsForGuest() async {
    final count = await getReportCount();
    final remaining = _reportLimit - count;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Сбросить счётчик отчётов (для тестирования)
  static Future<void> resetReportCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyReport);
      print('🔄 Счётчик отчётов сброшен');
    } catch (e) {
      print('❌ Ошибка сброса счётчика отчётов: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ОБЩИЕ МЕТОДЫ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Получить все счётчики (для отладки)
  static Future<Map<String, int>> getAllCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'presentations': prefs.getInt(_keyPresentation) ?? 0,
        'reports': prefs.getInt(_keyReport) ?? 0,
      };
    } catch (e) {
      print('❌ Ошибка получения всех счётчиков: $e');
      return {'presentations': 0, 'reports': 0};
    }
  }
  
  /// Полный сброс всех счётчиков (для тестирования)
  static Future<void> resetAllCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPresentation);
      await prefs.remove(_keyReport);
      print('🔄 Все счётчики сброшены');
    } catch (e) {
      print('❌ Ошибка сброса всех счётчиков: $e');
    }
  }
}