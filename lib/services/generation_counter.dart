import 'package:shared_preferences/shared_preferences.dart';

class GenerationCounter {
  static const String _keyPresentation = 'guest_generation_count_presentation';
  static const String _keyReport = 'guest_generation_count_report';
  
  // Презентации (5 для гостей)
  static Future<int> getPresentationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyPresentation) ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<int> incrementPresentation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyPresentation) ?? 0;
      final newCount = current + 1;
      await prefs.setInt(_keyPresentation, newCount);
      return newCount;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<bool> canGeneratePresentation(bool isLoggedIn, bool isPremium) async {
    if (isPremium) return true;
    if (isLoggedIn) return true;
    final count = await getPresentationCount();
    return count < 5;
  }
  
  // Отчёты (3 для гостей)
  static Future<int> getReportCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyReport) ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<int> incrementReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyReport) ?? 0;
      final newCount = current + 1;
      await prefs.setInt(_keyReport, newCount);
      return newCount;
    } catch (e) {
      return 0;
    }
  }
  
  static Future<bool> canGenerateReport(bool isLoggedIn, bool isPremium) async {
    if (isPremium) return true;
    if (isLoggedIn) return true;
    final count = await getReportCount();
    return count < 3;  // ← 3 бесплатных отчёта
  }
  
  static Future<int> getRemainingForGuestReports() async {
    final count = await getReportCount();
    final remaining = 3 - count;
    return remaining > 0 ? remaining : 0;
  }
  
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPresentation);
      await prefs.remove(_keyReport);
    } catch (e) {
      // ignore
    }
  }
}