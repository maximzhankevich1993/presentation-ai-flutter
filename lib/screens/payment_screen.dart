import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../providers/user_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String planId;
  final double price;
  final String period;
  
  const PaymentScreen({
    super.key,
    required this.planId,
    required this.price,
    required this.period,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _openCryptoCloudPayment() async {
    setState(() => _isLoading = true);
    
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Получаем email пользователя
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userEmail = userProvider.isLoggedIn ? userProvider.userEmail : '';
    
    // Определяем план для передачи в колбэк
    String planParam = 'monthly';
    if (widget.planId.toLowerCase().contains('год') || widget.planId.toLowerCase().contains('year')) {
      planParam = 'year';
    } else if (widget.planId.toLowerCase().contains('полгода') || widget.planId.toLowerCase().contains('half') || widget.planId.toLowerCase().contains('6')) {
      planParam = 'half_year';
    } else if (widget.planId.toLowerCase().contains('школ') || widget.planId.toLowerCase().contains('school')) {
      planParam = 'school';
    } else if (widget.planId.toLowerCase().contains('университет') || widget.planId.toLowerCase().contains('university')) {
      planParam = 'university';
    } else if (widget.planId.toLowerCase().contains('бизнес') || widget.planId.toLowerCase().contains('business')) {
      planParam = 'business';
    } else if (widget.planId.toLowerCase().contains('корпоратив') || widget.planId.toLowerCase().contains('corporate')) {
      planParam = 'corporate';
    }
    
    // Формируем URL с параметрами
    final paymentUrl = 'https://pay.cryptocloud.plus/pos/L1dhlsPbHiuNO7Fv'
        '?amount=${widget.price.toStringAsFixed(2)}'
        '&order_id=$orderId'
        '&plan=$planParam'
        '&email=${Uri.encodeComponent(userEmail)}';
    
    print('💰 Opening CryptoCloud payment: $paymentUrl');
    
    html.window.open(paymentUrl, '_blank');
    
    setState(() => _isLoading = false);
    
    // Показываем подсказку
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💸 After payment, subscription activates in 1-2 minutes. Promo code CRYPTO10 gives second month free!'),
        backgroundColor: Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: Duration(seconds: 5),
      ),
    );
  }

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
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 32),
              Text(
                '${widget.planId} — \$${widget.price.toStringAsFixed(2)} ${widget.period}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'You will be redirected to a secure payment page',
                style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF627EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF627EEA).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text('💡 Pay with USDT (cryptocurrency)', style: TextStyle(color: Color(0xFF627EEA), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('No fees, no banks — secure payment via CryptoCloud', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    const SizedBox(height: 4),
                    const Text('🎁 Promo code CRYPTO10 → second month free for first 10 paying users', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openCryptoCloudPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Pay with USDT', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF9A9A9A))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}