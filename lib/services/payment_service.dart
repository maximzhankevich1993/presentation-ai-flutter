import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class PaymentService {
  static const String _premiumKey = 'is_premium';
  static const String _expiryKey = 'premium_expiry';
  static const String _planKey = 'premium_plan';

  // ===== ТАРИФЫ =====

  static const Map<String, Map<String, dynamic>> plans = {
    'monthly': {
      'name': 'Месяц',
      'price': 299,
      'currency': 'RUB',
      'period': 'мес',
      'stripeId': 'price_monthly',
      'paypalId': 'PP-MONTHLY',
    },
    'halfyear': {
      'name': 'Полгода',
      'price': 199,
      'currency': 'RUB',
      'period': 'мес',
      'total': 1194,
      'discount': '33%',
      'stripeId': 'price_halfyear',
      'paypalId': 'PP-HALFYEAR',
    },
    'yearly': {
      'name': 'Год',
      'price': 149,
      'currency': 'RUB',
      'period': 'мес',
      'total': 1788,
      'discount': '50%',
      'stripeId': 'price_yearly',
      'paypalId': 'PP-YEARLY',
    },
    'trial': {
      'name': 'Триал 3 дня',
      'price': 0,
      'currency': 'RUB',
      'period': '3 дня',
      'stripeId': 'price_trial',
      'paypalId': 'PP-TRIAL',
    },
  };

  // ===== АКТИВАЦИЯ PREMIUM =====

  static Future<bool> activatePremium({
    required String plan,
    String? transactionId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // защита от несуществующего тарифа
      if (!plans.containsKey(plan)) return false;

      await prefs.setBool(_premiumKey, true);
      await prefs.setString(_planKey, plan);

      final expiry = _calculateExpiry(plan);
      await prefs.setString(_expiryKey, expiry.toIso8601String());

      if (transactionId != null) {
        await SecurityService.saveSecureValue(
          'last_transaction',
          transactionId,
        );
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();

    // безопасное удаление (даже если ключей нет)
    await prefs.setBool(_premiumKey, false);
    await prefs.remove(_planKey);
    await prefs.remove(_expiryKey);
  }

  // ===== ПРОВЕРКА СТАТУСА =====

  static Future<bool> isPremiumActive() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;

    if (!isPremium) return false;

    final expiryStr = prefs.getString(_expiryKey);
    if (expiryStr == null) return true;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return true;

    if (DateTime.now().isAfter(expiry)) {
      await deactivatePremium();
      return false;
    }

    return true;
  }

  static Future<String?> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planKey);
  }

  static Future<DateTime?> getExpiryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_expiryKey);

    if (expiryStr == null) return null;

    return DateTime.tryParse(expiryStr);
  }

  // ===== СИМУЛЯЦИЯ ПЛАТЕЖЕЙ =====

  static Future<Map<String, dynamic>> simulateStripePayment({
    required String plan,
    required String email,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final planData = plans[plan] ?? plans['monthly']!;
    final transactionId =
        'stripe_${SecurityService.generateToken(length: 16)}';

    final success = await activatePremium(
      plan: plan,
      transactionId: transactionId,
    );

    return {
      'success': success,
      'transaction_id': transactionId,
      'plan': planData['name'],
      'amount': planData['price'],
      'currency': planData['currency'],
    };
  }

  static Future<Map<String, dynamic>> simulatePayPalPayment({
    required String plan,
    required String email,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final planData = plans[plan] ?? plans['monthly']!;
    final transactionId =
        'paypal_${SecurityService.generateToken(length: 16)}';

    final success = await activatePremium(
      plan: plan,
      transactionId: transactionId,
    );

    return {
      'success': success,
      'transaction_id': transactionId,
      'plan': planData['name'],
      'amount': planData['price'],
      'currency': planData['currency'],
    };
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====

  static DateTime _calculateExpiry(String plan) {
    switch (plan) {
      case 'monthly':
        return DateTime.now().add(const Duration(days: 30));
      case 'halfyear':
        return DateTime.now().add(const Duration(days: 180));
      case 'yearly':
        return DateTime.now().add(const Duration(days: 365));
      case 'trial':
        return DateTime.now().add(const Duration(days: 3));
      default:
        return DateTime.now().add(const Duration(days: 30));
    }
  }

  static String formatPrice(int price, {String currency = 'RUB'}) {
    switch (currency) {
      case 'RUB':
        return '${price.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]} ',
            )} ₽';

      case 'USD':
        return '\$$price';

      default:
        return '$price $currency';
    }
  }
}