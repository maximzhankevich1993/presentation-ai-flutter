import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../providers/user_provider.dart';
import 'report_constructor_screen.dart';
import 'register_payment_screen.dart';
import 'payment_screen.dart';

// ═══════════════════════════════════════════════════════════════
// CRYPTO PAYMENT URL
// ═══════════════════════════════════════════════════════════════
const String CRYPTO_PAYMENT_URL = 'https://pay.cryptocloud.plus/pos/L1dhlsPbHiuNO7Fv';

class CorporateScreen extends StatefulWidget {
  final String countryCode;
  const CorporateScreen({super.key, required this.countryCode});

  @override
  State<CorporateScreen> createState() => _CorporateScreenState();
}

class _CorporateScreenState extends State<CorporateScreen> {
  String _selectedTariff = 'business';
  bool _isLoading = false;
  
  // Фиксированные цены в долларах (без конвертации)
  final double _businessPriceUSD = 49.99;
  final double _corporatePriceUSD = 149.99;

  @override
  void initState() {
    super.initState();
  }

  String _formatPrice(double usd) {
    if (usd == 0) return 'Бесплатно';
    return '\$${usd.toStringAsFixed(2)}';
  }
  
  void _openCryptoPayment(double amount, String planName) {
    final url = amount > 0 ? '$CRYPTO_PAYMENT_URL?amount=$amount' : CRYPTO_PAYMENT_URL;
    html.window.open(url, '_blank');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💸 After successful USDT payment, return to the app. Subscription activates in 1-2 min.\nPromo code CRYPTO10 → second month free!'),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _openReportConstructor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportConstructorScreen()),
    );
  }

  void _showPaymentDialog(String planId, double price, String period) {
    // Проверяем, залогинен ли пользователь
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to subscribe'),
          backgroundColor: Color(0xFFFFD700),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Открываем напрямую CryptoCloud
    _openCryptoPayment(price, _getPlanName(planId));
  }
  
  String _getPlanName(String planId) {
    switch (planId) {
      case 'business': return 'Business';
      case 'corporate': return 'Corporate';
      default: return 'Plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('For Business', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 20 : 32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                        ),
                        child: Column(
                          children: [
                            Container(width: isMobile ? 40 : 48, height: isMobile ? 40 : 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(isMobile ? 12 : 16)), child: Icon(Icons.business_center_rounded, color: Colors.white, size: isMobile ? 22 : 26)),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text('Corporate Plans', style: TextStyle(color: Colors.white, fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('For companies of any size — pay with USDT', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: isMobile ? 12 : 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text('CHOOSE YOUR PLAN', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                      const SizedBox(height: 12),
                      
                      // Crypto note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
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
                            Text('🎁 Promo code CRYPTO10 → second month free for first 10 paying users', style: TextStyle(color: const Color(0xFFFFD700), fontSize: 11)),
                          ],
                        ),
                      ),
                      
                      isMobile
                          ? Column(
                              children: [
                                _buildTariffCard(
                                  title: 'Business',
                                  price: _businessPriceUSD,
                                  period: 'month',
                                  description: 'For small business',
                                  features: const ['Up to 10 users', '∞ generations', 'Brand Kit', 'Priority Support', 'API Access', 'Report Builder'],
                                  isPopular: true,
                                  onTap: () => _showPaymentDialog('business', _businessPriceUSD, '/month'),
                                ),
                                const SizedBox(height: 12),
                                _buildTariffCard(
                                  title: 'Corporate',
                                  price: _corporatePriceUSD,
                                  period: 'month',
                                  description: 'For large companies',
                                  features: const ['Unlimited users', '∞ generations', 'Brand Kit', 'VIP Support 24/7', 'API + Webhook', 'Report Builder PRO'],
                                  isPopular: false,
                                  onTap: () => _showPaymentDialog('corporate', _corporatePriceUSD, '/month'),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildTariffCard(
                                  title: 'Business', price: _businessPriceUSD, period: 'month',
                                  description: 'For small business',
                                  features: const ['Up to 10 users', '∞ generations', 'Brand Kit', 'Priority Support', 'API Access', 'Report Builder'],
                                  isPopular: true,
                                  onTap: () => _showPaymentDialog('business', _businessPriceUSD, '/month'),
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTariffCard(
                                  title: 'Corporate', price: _corporatePriceUSD, period: 'month',
                                  description: 'For large companies',
                                  features: const ['Unlimited users', '∞ generations', 'Brand Kit', 'VIP Support 24/7', 'API + Webhook', 'Report Builder PRO'],
                                  isPopular: false,
                                  onTap: () => _showPaymentDialog('corporate', _corporatePriceUSD, '/month'),
                                )),
                              ],
                            ),
                      
                      const SizedBox(height: 32),
                      
                      GestureDetector(
                        onTap: _openReportConstructor,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description_rounded, color: Colors.white, size: isMobile ? 24 : 20),
                              const SizedBox(width: 10),
                              Flexible(child: Text('Open Report Builder', style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      GestureDetector(
                        onTap: _contactSales,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 16),
                          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(isMobile ? 12 : 16), border: Border.all(color: const Color(0xFF2A2A2A))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email_outlined, color: const Color(0xFF1DB954), size: isMobile ? 24 : 20),
                              const SizedBox(width: 10),
                              Flexible(child: Text('Contact Sales', style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTariffCard({
    required String title,
    required double price,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedTariff == title.toLowerCase();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final priceLabel = _formatPrice(price);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1DB95420) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          border: Border.all(color: isSelected ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A), width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isMobile ? 40 : 44, height: isMobile ? 40 : 44,
                  decoration: BoxDecoration(color: isPopular ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(10)),
                  child: Icon(title == 'Business' ? Icons.business_center_rounded : Icons.apartment_rounded, color: isPopular ? Colors.white : const Color(0xFF1DB954), size: isMobile ? 20 : 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w700)),
                      Text(description, style: TextStyle(color: const Color(0xFF9A9A9A), fontSize: isMobile ? 11 : 12)),
                    ],
                  ),
                ),
                if (isPopular) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(12)), child: Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: isMobile ? 9 : 10, fontWeight: FontWeight.w700))),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Row(
              children: [
                Text(priceLabel, style: TextStyle(color: const Color(0xFF1DB954), fontSize: isMobile ? 28 : 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                if (period.isNotEmpty && price > 0) ...[
                  const SizedBox(width: 4),
                  Text('/$period', style: TextStyle(color: const Color(0xFF9A9A9A), fontSize: isMobile ? 12 : 13)),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF627EEA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('USDT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            SizedBox(height: isMobile ? 12 : 16),
            Text('INCLUDED:', style: TextStyle(color: const Color(0xFF9A9A9A), fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            SizedBox(height: isMobile ? 8 : 10),
            ...features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 6 : 10),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                const SizedBox(width: 6),
                Expanded(child: Text(feature, style: TextStyle(color: Colors.white70, fontSize: isMobile ? 12 : 13))),
              ]),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF627EEA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                ),
                child: const Text('💳 Pay with USDT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSales() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.email_rounded, color: Color(0xFF1DB954), size: 26)),
              const SizedBox(height: 16),
              const Text('Sales Department', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Contact us for custom corporate pricing', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  // Копируем email в буфер
                  html.window.navigator.clipboard?.writeText('corp@presentator.ai');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied to clipboard'), backgroundColor: Color(0xFF1DB954)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: const Row(children: [Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 18), SizedBox(width: 10), Text('corp@presentator.ai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))]),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF252525), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}