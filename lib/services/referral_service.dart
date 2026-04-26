import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class ReferralService {
  static const String _referralCodeKey = 'referral_code';
  static const String _referredByKey = 'referred_by';
  static const String _referralCountKey = 'referral_count';
  static const String _referralBonusClaimedKey = 'referral_bonus_claimed';

  /// Генерирует уникальный реферальный код
  static Future<String> generateReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    
    final existing = prefs.getString(_referralCodeKey);
    if (existing != null) return existing;
    
    // Генерируем читаемый код: ПРЕЗЕНТ + 4 случайных символа
    const prefix = 'PREZENT';
    final random = SecurityService.generateToken(length: 4).toUpperCase();
    final code = '$prefix-$random';
    
    await prefs.setString(_referralCodeKey, code);
    return code;
  }

  /// Применяет реферальный код при регистрации
  static Future<bool> applyReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Проверяем, не использовал ли уже код
    if (prefs.containsKey(_referredByKey)) return false;
    
    // Сохраняем код
    await prefs.setString(_referredByKey, code);
    return true;
  }

  /// Возвращает количество приведённых друзей
  static Future<int> getReferralCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_referralCountKey) ?? 0;
  }

  /// Увеличивает счётчик рефералов
  static Future<void> incrementReferralCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_referralCountKey) ?? 0;
    await prefs.setInt(_referralCountKey, current + 1);
  }

  /// Проверяет, можно ли получить бонус за реферала
  static Future<bool> canClaimReferralBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_referralCountKey) ?? 0;
    final claimed = prefs.getBool(_referralBonusClaimedKey) ?? false;
    
    // Бонус за каждых 3 друзей
    return count >= 3 && !claimed;
  }

  /// Получает текст для шаринга
  static String getShareText(String referralCode) {
    return '''
🎨 Создавай крутые презентации с ИИ!

Попробуй Презентатор ИИ бесплатно:
• 5 презентаций до 10 слайдов
• Авто-подбор картинок
• Красивый дизайн

Используй мой код $referralCode и получи +1 бесплатную генерацию!

👉 https://prezentator-ai.com/ref/$referralCode
''';
  }

  /// Получает бонусы по уровням
  static Map<String, dynamic> getRewardTier(int referralCount) {
    if (referralCount >= 10) {
      return {'tier': 'Бриллиант', 'reward': 'Месяц Premium бесплатно', 'icon': '💎'};
    } else if (referralCount >= 5) {
      return {'tier': 'Золото', 'reward': '2 недели Premium', 'icon': '🥇'};
    } else if (referralCount >= 3) {
      return {'tier': 'Серебро', 'reward': '3 дополнительные генерации', 'icon': '🥈'};
    } else if (referralCount >= 1) {
      return {'tier': 'Бронза', 'reward': '1 дополнительная генерация', 'icon': '🥉'};
    }
    return {'tier': 'Начинающий', 'reward': 'Пригласите друзей', 'icon': '🌱'};
  }
}