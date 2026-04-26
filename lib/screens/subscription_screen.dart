import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/payment_service.dart';
import 'premium_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _autoRenew = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Управление подпиской'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус подписки
            _buildStatusCard(userProvider),
            
            SizedBox(height: 24.h),
            
            // Автопродление
            _buildAutoRenewToggle(userProvider),
            
            SizedBox(height: 24.h),
            
            // Действия с подпиской
            _buildActions(userProvider),
            
            SizedBox(height: 24.h),
            
            // П платёжные данные
            _buildPaymentMethods(),
            
            SizedBox(height: 24.h),
            
            // История платежей
            _buildPaymentHistory(),
            
            SizedBox(height: 32.h),
            
            // Опасная зона
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(UserProvider userProvider) {
    final isPremium = userProvider.isPremium;
    
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)])
            : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[600]!]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? const Color(0xFF4F46E5) : Colors.grey).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isPremium ? Icons.crown : Icons.star_outline,
            color: Colors.white,
            size: 48.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            isPremium ? 'Premium активен' : 'Бесплатный тариф',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPremium) ...[
            SizedBox(height: 8.h),
            Text(
              'Действует до: 26.05.2026',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoRenewToggle(UserProvider userProvider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.autorenew, color: _autoRenew ? Colors.green : Colors.grey),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Автоматическое продление',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
              Switch(
                value: _autoRenew,
                onChanged: (value) {
                  setState(() => _autoRenew = value);
                  _showAutoRenewDialog(value);
                },
                activeColor: const Color(0xFF4F46E5),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _autoRenew
                ? 'Подписка продлится автоматически. Вы можете отключить это в любой момент.'
                : 'Автопродление отключено. Мы напомним вам о необходимости продлить подписку за 3 дня до окончания.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showAutoRenewDialog(bool newValue) {
    if (newValue) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Включить автопродление?'),
          content: const Text(
            'Подписка будет продлеваться автоматически. '
            'Деньги будут списываться в день окончания текущего периода. '
            'Вы можете отключить автопродление в любой момент.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _autoRenew = false);
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Да, включить'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Отключить автопродление?'),
          content: const Text(
            'Ваша подписка не будет продлена автоматически. '
            'Мы пришлём вам напоминание за 3 дня до окончания. '
            'Вы сможете продлить подписку вручную в этом же разделе.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _autoRenew = true);
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Да, отключить'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActions(UserProvider userProvider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Действия', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 16.h),
          _buildActionTile(
            icon: Icons.upgrade,
            title: 'Сменить тариф',
            subtitle: 'Перейти с месячного на годовой',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
          ),
          _buildActionTile(
            icon: Icons.pause_circle_outline,
            title: 'Приостановить подписку',
            subtitle: 'Заморозить на 1-3 месяца',
            onTap: () => _showPauseDialog(),
          ),
          _buildActionTile(
            icon: Icons.receipt_long,
            title: 'История платежей',
            subtitle: 'Все ваши транзакции',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4F46E5)),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Приостановить подписку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите срок приостановки. В это время плата не списывается.'),
            SizedBox(height: 16.h),
            ListTile(
              title: const Text('1 месяц'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('2 месяца'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('3 месяца'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('П платёжные данные', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showDeletePaymentDialog(),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: const Text('Удалить', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 48.w, height: 32.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF635BFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12.w),
              const Text('Visa •••• 4242', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeletePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Удалить платёжные данные?'),
        content: const Text(
          'Ваша сохранённая карта будет удалена. '
          'Автопродление будет отключено. '
          'Вы сможете добавить новую карту в любой момент.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('История платежей', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          _buildPaymentRow('26.04.2026', '$4.99', 'Месячный Premium'),
          Divider(color: Colors.grey.withOpacity(0.1)),
          _buildPaymentRow('26.03.2026', '$4.99', 'Месячный Premium'),
          Divider(color: Colors.grey.withOpacity(0.1)),
          _buildPaymentRow('26.02.2026', '$0.00', 'Триал-период'),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String date, String amount, String plan) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Text(date, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          const Spacer(),
          Text(amount, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(width: 16.w),
          Text(plan, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Опасная зона', style: TextStyle(fontSize: 14.sp, color: Colors.red, fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCancelSubscriptionDialog(),
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text('Отменить подписку', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Отменить подписку?'),
        content: const Text(
          'Ваша Premium-подписка будет отменена. '
          'Вы сохраните доступ до конца оплаченного периода. '
          'После этого тариф переключится на Бесплатный.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Не отменять'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь будет логика отмены подписки
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Подписка отменена. Доступ сохранится до конца периода.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Отменить подписку'),
          ),
        ],
      ),
    );
  }
}