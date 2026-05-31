import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

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
    
    // Ваш публичный ключ CryptoCloud
    final publicKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1dWlkIjoiTVRBek1qUXoiLCJ0eXBlIjoicHJvamVjdCIsInYiOiJkYjAxNDYyNjkxZGJkOWY0YTBmMTdmNTFjZTZkMzJiNTc0ZTJmMzdiZmE5YTcwODQ0MjllYjJmMTUxZTFjYWE1IiwiZXhwIjo4ODE3OTg2ODgzNn0.gVi4uAU_3XCccqBRpy3e1loNxKHNuzEKsIIv_K7fuos';
    
    // Формируем ссылку на оплату
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final paymentUrl = 'https://cryptocloud.plus/process/${publicKey}?amount=${widget.price}&order_id=$orderId&plan=${widget.planId}';
    
    // Открываем в новой вкладке
    html.window.open(paymentUrl, '_blank');
    
    setState(() => _isLoading = false);
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
        title: const Text('Оплата', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
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
                '${widget.planId} — ${widget.price.toStringAsFixed(2)} \$ ${widget.period}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const Text(
                'Вы будете перенаправлены на защищённую страницу оплаты',
                style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                textAlign: TextAlign.center,
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
                      : const Text('Оплатить криптовалютой', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(color: Color(0xFF9A9A9A))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}