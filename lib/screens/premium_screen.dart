import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Premium'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Icon(Icons.crown, color: Colors.white, size: 40.sp),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Разблокируй всё',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Создавай профессиональные презентации\nбез ограничений',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 40.h),
            _buildComparisonTable(context),
            SizedBox(height: 40.h),
            Text(
              'Выбери план',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            _buildPlanCard(
              context,
              plan: 'monthly',
              title: 'Месяц',
              price: '299 ₽',
              period: 'мес',
              onTap: () => _showPaymentOptions(context, 'monthly'),
            ),
            SizedBox(height: 12.h),
            _buildPlanCard(
              context,
              plan: 'halfyear',
              title: 'Полгода',
              price: '199 ₽',
              period: 'мес',
              total: '1 194 ₽ за 6 мес',
              discount: '33%',
              isPopular: true,
              onTap: () => _showPaymentOptions(context, 'halfyear'),
            ),
            SizedBox(height: 12.h),
            _buildPlanCard(
              context,
              plan: 'yearly',
              title: 'Год',
              price: '149 ₽',
              period: 'мес',
              total: '1 788 ₽ за год',
              discount: '50%',
              onTap: () => _showPaymentOptions(context, 'yearly'),
            ),
            SizedBox(height: 24.h),
            Center(
              child: TextButton.icon(
                onPressed: () => _showTrialDialog(context),
                icon: const Icon(Icons.card_giftcard),
                label: const Text('🎁 Попробовать 3 дня бесплатно'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: TextButton(
                onPressed: () => _restorePurchases(context),
                child: Text(
                  'Восстановить покупки',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            _buildTrustBadges(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildCompareRow('Генерации презентаций', '5', '∞'),
          _buildDivider(),
          _buildCompareRow('Слайдов в презентации', '10', '50'),
          _buildDivider(),
          _buildCompareRow('Автоматические картинки', '10', '50'),
          _buildDivider(),
          _buildCompareRow('Свой фон', '❌', '✅'),
          _buildDivider(),
          _buildCompareRow('Цветовые схемы', '2', '8+'),
          _buildDivider(),
          _buildCompareRow('Шрифтовые пары', '2', '6+'),
          _buildDivider(),
          _buildCompareRow('Анимированные переходы', '2', '10+'),
          _buildDivider(),
          _buildCompareRow('ИИ-улучшение текста', '❌', '✅'),
          _buildDivider(),
          _buildCompareRow('Экспорт в PDF', '❌', '✅'),
          _buildDivider(),
          _buildCompareRow('Водяной знак', 'Есть', 'Нет'),
        ],
      ),
    );
  }

  Widget _buildCompareRow(String feature, String free, String premium) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(feature)),
          Expanded(
            child: Text(free, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: Colors.grey.withOpacity(0.15), height: 1);

  Widget _buildPlanCard(
    BuildContext context, {
    required String plan,
    required String title,
    required String price,
    required String period,
    String? total,
    String? discount,
    bool isPopular = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isPopular
              ? const Color(0xFF4F46E5).withOpacity(0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPopular
                ? const Color(0xFF4F46E5)
                : Colors.grey.withOpacity(0.2),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isPopular)
              Container(
                margin: EdgeInsets.only(right: 12.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ПОПУЛЯРНЫЙ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (total != null) Text(total),
                ],
              ),
            ),
            Text('$price /$period'),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, String plan) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Stripe'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, plan, 'stripe');
              },
            ),
            ListTile(
              title: const Text('PayPal'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, plan, 'paypal');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(
      BuildContext context, String plan, String method) async {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final email = await AuthService.getEmail() ?? 'user@example.com';

      final result = method == 'stripe'
          ? await PaymentService.simulateStripePayment(
              plan: plan, email: email)
          : await PaymentService.simulatePayPalPayment(
              plan: plan, email: email);

      if (!context.mounted) return;

      Navigator.pop(context);

      if (result['success'] == true) {
        Provider.of<UserProvider>(context, listen: false)
            .activatePremium();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium активирован!')),
        );

        Navigator.pop(context);
      } else {
        _showError(context, 'Ошибка платежа');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showError(context, 'Ошибка: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock, size: 16),
        SizedBox(width: 8),
        Text('Безопасная оплата'),
      ],
    );
  }
}