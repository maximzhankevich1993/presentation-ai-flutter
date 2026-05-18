import 'package:flutter/material.dart';

class RegisterPaymentScreen extends StatelessWidget {
  final String planId;
  final double price;
  final String period;

  const RegisterPaymentScreen({
    super.key,
    required this.planId,
    required this.price,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Регистрация и оплата',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.payment_rounded, color: Color(0xFF1DB954), size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Premium ${_getPlanName()}',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${price.toStringAsFixed(2)} $period',
              style: const TextStyle(color: Color(0xFF1DB954), fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            const Text(
              'Платёжный модуль в разработке',
              style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Premium доступ будет активирован после оплаты',
              style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Назад', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanName() {
    switch (planId) {
      case 'monthly': return 'Месячная подписка';
      case 'semiannual': return 'Полугодовая подписка';
      case 'annual': return 'Годовая подписка';
      default: return 'Подписка';
    }
  }
}