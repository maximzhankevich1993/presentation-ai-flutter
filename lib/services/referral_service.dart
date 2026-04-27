import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class ReferralTier {
  final String name;
  final String emoji;
  final int requiredReferrals;
  final String reward;
  final int freeMonths;

  const ReferralTier({
    required this.name,
    required this.emoji,
    required this.requiredReferrals,
    required this.reward,
    required this.freeMonths,
  });
}

class ReferralService {
  static const String _referralCodeKey = 'referral_code';
  static const String _referredByKey = 'referred_by';
  static const String _referralCountKey = 'referral_count';
  static const String _referralListKey = 'referral_list';
  static const String _freeMonthsEarnedKey = 'free_months_earned';
  static const String _freeMonthsRemainingKey = 'free_months_remaining';

  static final List<ReferralTier> tiers = [
    const ReferralTier(name: 'Новичок', emoji: '🌱', requiredReferrals: 0, reward: 'Пригласите 1 друга', freeMonths: 0),
    const ReferralTier(name: 'Бронза', emoji: '🥉', requiredReferrals: 1, reward: '1 месяц Premium', freeMonths: 1),
    const ReferralTier(name: 'Серебро', emoji: '🥈', requiredReferrals: 3, reward: '+2 месяца Premium', freeMonths: 3),
    const ReferralTier(name: 'Золото', emoji: '🥇', requiredReferrals: 5, reward: '+3 месяца Premium', freeMonths: 6),
    const ReferralTier(name: 'Платина', emoji: '💎', requiredReferrals: 10, reward: 'Год Premium', freeMonths: 12),
    const ReferralTier(name: 'Легенда', emoji: '👑', requiredReferrals: 25, reward: 'Пожизненный Premium', freeMonths: 999),
  ];

  static Future<String> generateReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_referralCodeKey);
    if (existing != null) return existing;

    final random = SecurityService.generateToken(length: 4).toUpperCase();
    final code = 'FRIEND-$random';
    await prefs.setString(_referralCodeKey, code);
    return code;
  }

  static Future<Map<String, dynamic>> applyReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_referredByKey)) {
      return {'success': false, 'message': 'Вы уже использовали реферальный код'};
    }

    final myCode = prefs.getString(_referralCodeKey);
    if (myCode == code) {
      return {'success': false, 'message': 'Нельзя использовать свой код'};
    }

    await prefs.setString(_referredByKey, code);
    await prefs.setInt(_freeMonthsRemainingKey, 1);

    return {
      'success': true,
      'message': 'Реферальный код применён! Вы получили 1 месяц Premium',
      'free_months': 1,
    };
  }

  static Future<Map<String, dynamic>> incrementReferral(String friendName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_referralCountKey) ?? 0;
    final newCount = current + 1;
    await prefs.setInt(_referralCountKey, newCount);

    final referralList = prefs.getStringList(_referralListKey) ?? [];
    referralList.add('$friendName|${DateTime.now().toIso8601String()}');
    await prefs.setStringList(_referralListKey, referralList);

    final tier = getCurrentTier(newCount);
    final previousTier = getCurrentTier(current);

    final existingMonths = prefs.getInt(_freeMonthsEarnedKey) ?? 0;
    final newMonths = tier.freeMonths - existingMonths;
    if (newMonths > 0) {
      await prefs.setInt(_freeMonthsEarnedKey, tier.freeMonths);
      final remaining = (prefs.getInt(_freeMonthsRemainingKey) ?? 0) + newMonths;
      await prefs.setInt(_freeMonthsRemainingKey, remaining);
    }

    return {
      'success': true,
      'count': newCount,
      'tier': tier.name,
      'tier_emoji': tier.emoji,
      'new_months': newMonths > 0 ? newMonths : 0,
      'level_up': tier.name != previousTier.name,
    };
  }

  static ReferralTier getCurrentTier(int referralCount) {
    for (int i = tiers.length - 1; i >= 0; i--) {
      if (referralCount >= tiers[i].requiredReferrals) return tiers[i];
    }
    return tiers.first;
  }

  static Future<int> getReferralCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_referralCountKey) ?? 0;
  }

  static Future<List<Map<String, String>>> getReferralList() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_referralListKey) ?? [];
    return list.map((entry) {
      final parts = entry.split('|');
      return {'name': parts[0], 'date': parts.length > 1 ? parts[1] : ''};
    }).toList();
  }

  static Future<int> getFreeMonthsRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_freeMonthsRemainingKey) ?? 0;
  }

  static Future<bool> useFreeMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final remaining = prefs.getInt(_freeMonthsRemainingKey) ?? 0;
    if (remaining <= 0) return false;
    await prefs.setInt(_freeMonthsRemainingKey, remaining - 1);
    return true;
  }

  static String getShareText(String referralCode, String referrerName) {
    return '🎨 Я создаю крутые презентации с помощью ИИ за 1 минуту!\n\n'
        'Попробуй Презентатор ИИ бесплатно:\n'
        '• 5 презентаций до 10 слайдов\n'
        '• Авто-подбор картинок\n'
        '• Планы уроков для учителей\n'
        '• Генерация КП для бизнеса\n\n'
        '🎁 Используй мой код $referralCode и получи 1 МЕСЯЦ Premium БЕСПЛАТНО!\n\n'
        '👉 https://prezentator-ai.com/ref/$referralCode';
  }
}