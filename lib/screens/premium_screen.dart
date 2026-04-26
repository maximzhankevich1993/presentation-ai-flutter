import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
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
            // Корона
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
                    ),
                  ],
                ),
                child: Icon(Icons.crown, color: Colors.white, size: 40.sp),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'Разблокируй всё',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              'Создавай профессиональные презентации\nбез ограничений',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Таблица сравнения
            _buildComparisonTable(context),
            
            SizedBox(height: 40.h),
            
            // Планы подписки
            Text(
              'Выбери план',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            _buildPlanCard(
              context,
              title: 'Месяц',
              price: '299 ₽',
              period: 'мес',
              onTap: () => _showPaymentOptions(context, 'monthly'),
            ),
            
            SizedBox(height: 12.h),
            
            _buildPlanCard(
              context,
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
              title: 'Год',
              price: '149 ₽',
              period: 'мес',
              total: '1 788 ₽ за год',
              discount: '50%',
              onTap: () => _showPaymentOptions(context, 'yearly'),
            ),
            
            SizedBox(height: 24.h),
            
            // Триал
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
            
            // Восстановление покупок
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
            
            // Гарантии
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
          Expanded(
            flex: 2,
            child: Text(feature, style: TextStyle(fontSize: 14.sp)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.15), height: 1);
  }

  Widget _buildPlanCard(
    BuildContext context, {
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
            color: isPopular ? const Color(0xFF4F46E5) : Colors.grey.withOpacity(0.2),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isPopular)
              Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                  Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (total != null)
                    Text(
                      total,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(price, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                    Text(' /$period', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  ],
                ),
                if (discount != null)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Экономия $discount',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, String plan) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                Text(
                  'Способ оплаты',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                
                SizedBox(height: 24.h),
                
                ListTile(
                  leading: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF635BFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white),
                  ),
                  title: const Text('Stripe'),
                  subtitle: const Text('Visa, Mastercard, Apple Pay'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _processPayment(context, plan, 'stripe');
                  },
                ),
                
                SizedBox(height: 12.h),
                
                ListTile(
                  leading: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF009CDE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.paypal, color: Colors.white),
                  ),
                  title: const Text('PayPal'),
                  subtitle: const Text('Оплата через PayPal'),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _processPayment(context, plan, 'paypal');
                  },
                ),
                
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processPayment(BuildContext context, String plan, String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 24.h),
              const Text('Обработка платежа...'),
              SizedBox(height: 8.h),
              Text(
                'Через $method',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Имитация обработки платежа
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.activatePremium();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium активирован! Добро пожаловать! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showTrialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Color(0xFFF59E0B)),
            SizedBox(width: 12.w),
            const Text('Бесплатный триал'),
          ],
        ),
        content: const Text(
          'Получи 3 дня Premium бесплатно!\n\n'
          '• Безлимитные презентации\n'
          '• Все фоны и шрифты\n'
          '• Экспорт без водяного знака\n\n'
          'Отменить можно в любой момент.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.activatePremium();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Триал активирован! 3 дня Premium 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            child: const Text('Активировать'),
          ),
        ],
      ),
    );
  }

  void _restorePurchases(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Покупки восстановлены'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: 16, color: Colors.grey[400]),
        SizedBox(width: 8.w),
        Text(
          'Безопасная оплата через Stripe и PayPal',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        ),
      ],
    );
  }
}