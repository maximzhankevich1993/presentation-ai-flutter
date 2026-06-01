import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import '../providers/user_provider.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════
// CRYPTO PAYMENT URL
// ═══════════════════════════════════════════════════════════════
const String CRYPTO_PAYMENT_URL = 'https://pay.cryptocloud.plus/pos/L1dhlsPbHiuNO7Fv';

// ═══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase    = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard    = Color(0xFF1E1E1E);
  static const bgHover   = Color(0xFF252525);
  static const border    = Color(0xFF2A2A2A);
  static const txtPrimary   = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted     = Color(0xFF4A4A4A);
  static const accent       = Color(0xFF1DB954);
  static const accentLight  = Color(0xFF1ED760);
  static const accentDim    = Color(0xFF1DB95420);
  static const gold         = Color(0xFFFFD700);
  static const goldLight    = Color(0xFFFFD60A);
  static const danger       = Color(0xFFFF3B30);
}

const Map<String, double> _usdPrices = {
  'month': 4.99,
  'half': 29.99,
  'year': 49.99,
};

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String? _selectedPlan;
  
  // Промокод
  final TextEditingController _promoController = TextEditingController();
  String _promoMessage = '';
  bool _isPromoApplied = false;
  String _appliedPromoCode = '';
  double? _discountedPrice;
  String _discountType = '';
  double _discountValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // Фиксированное форматирование цены в долларах
  String _formatPrice(double usdPrice) {
    return '\$${usdPrice.toStringAsFixed(2)}';
  }

  String _periodPrice(double usdPrice, int months) {
    final monthly = usdPrice / months;
    return '\$${monthly.toStringAsFixed(2)}/month';
  }

  void _openCryptoPayment(double amount) {
    final url = amount > 0 ? '$CRYPTO_PAYMENT_URL?amount=${amount.toStringAsFixed(2)}' : CRYPTO_PAYMENT_URL;
    html.window.open(url, '_blank');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💸 After payment, subscription activates in 1-2 minutes. Promo code CRYPTO10 gives second month free!'),
        backgroundColor: _T.accent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _promoMessage = 'Enter a promo code');
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      setState(() => _promoMessage = 'Please log in to use promo codes');
      return;
    }
    
    setState(() {
      _promoMessage = 'Checking...';
      _isPromoApplied = false;
    });
    
    try {
      final response = await ApiService.validatePromoCode(code);
      
      if (response['valid'] == true) {
        setState(() {
          _isPromoApplied = true;
          _appliedPromoCode = code;
          _discountType = response['discountType'] ?? 'percent';
          _discountValue = (response['discountValue'] ?? 0).toDouble();
          _promoMessage = '✓ ${response['description'] ?? 'Promo code applied!'}';
        });
      } else {
        setState(() => _promoMessage = response['message'] ?? 'Invalid promo code');
      }
    } catch (e) {
      setState(() => _promoMessage = 'Network error. Try again.');
    }
  }

  Future<void> _selectPlan(String plan) async {
    if (plan == 'trial') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trial period will be available after launch'),
          backgroundColor: _T.accent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to subscribe'),
          backgroundColor: _T.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    double originalPrice = _usdPrices[plan] ?? 4.99;
    double finalPrice = originalPrice;
    
    // Применяем промокод, если он есть
    if (_isPromoApplied && _appliedPromoCode.isNotEmpty) {
      setState(() => _promoMessage = 'Applying promo code...');
      
      try {
        final planMap = {'month': 'monthly', 'half': 'half_year', 'year': 'year'};
        final response = await ApiService.applyPromoCode(_appliedPromoCode, planMap[plan] ?? 'monthly');
        
        if (response['success'] == true) {
          finalPrice = response['finalPrice'].toDouble();
          setState(() {
            _discountedPrice = finalPrice;
            _promoMessage = '✓ ${response['message']}';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: _T.accent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          setState(() => _promoMessage = response['message'] ?? 'Failed to apply promo code');
          finalPrice = originalPrice;
        }
      } catch (e) {
        setState(() => _promoMessage = 'Error applying promo code');
        finalPrice = originalPrice;
      }
    }
    
    // Открываем оплату
    _openCryptoPayment(finalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;

    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _T.txtSecondary, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Premium',
          style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
        actions: [
          if (isPremium)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_T.goldLight, _T.gold], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: _T.gold.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),

              const Text('Unlock Everything',
                style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w800, fontSize: 26, letterSpacing: -0.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text('Prices in USD — pay with USDT', style: TextStyle(color: _T.txtSecondary, fontSize: 13)),
              const SizedBox(height: 28),

              // Comparison Table
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _T.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _T.border),
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _T.border.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(children: [
                      const Expanded(flex: 3, child: Text('Feature', style: TextStyle(color: _T.txtSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                      const Expanded(flex: 2, child: Text('Free', textAlign: TextAlign.center, style: TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.star_rounded, color: _T.gold, size: 13),
                        const SizedBox(width: 4),
                        const Text('Premium', style: TextStyle(color: _T.gold, fontSize: 11, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                  ),
                  _ComparisonRow('Presentations', '5', '∞'),
                  _ComparisonRow('Slides', '10', '50'),
                  _ComparisonRow('Backgrounds', '8', '16'),
                  _ComparisonRow('Fonts', 'Inter', '3 styles'),
                  _ComparisonRow('Animations', '2', '6'),
                  _ComparisonRow('PDF Export', '❌', '✅'),
                  _ComparisonRow('AI Improve', '❌', '✅'),
                  _ComparisonRow('Custom Images', '❌', '✅'),
                  _ComparisonRow('Watermark', 'Yes', 'No'),
                  _ComparisonRow('Payment', 'No', 'USDT'),
                ]),
              ),
              const SizedBox(height: 24),

              // Promo Code Field
              Container(
                decoration: BoxDecoration(
                  color: _T.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _T.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        style: const TextStyle(color: _T.txtPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Enter promo code',
                          hintStyle: TextStyle(color: _T.txtMuted, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    if (_isPromoApplied)
                      const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.check_circle, color: _T.accent, size: 20),
                      )
                    else
                      TextButton(
                        onPressed: _applyPromoCode,
                        style: TextButton.styleFrom(
                          foregroundColor: _T.accent,
                        ),
                        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              if (_promoMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _promoMessage,
                    style: TextStyle(
                      color: _promoMessage.startsWith('✓') ? _T.accent : _T.gold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Plan Cards
              _PlanCard(
                name: 'Monthly',
                price: _formatPrice(_usdPrices['month']!),
                period: '/month',
                popular: false,
                selected: _selectedPlan == 'month',
                discountedPrice: (_isPromoApplied && _discountedPrice != null && _selectedPlan == 'month') ? _formatPrice(_discountedPrice!) : null,
                onTap: () {
                  setState(() => _selectedPlan = 'month');
                  _selectPlan('month');
                },
              ),
              const SizedBox(height: 10),
              _PlanCard(
                name: '6 Months',
                price: _formatPrice(_usdPrices['half']!),
                period: _periodPrice(_usdPrices['half']!, 6),
                popular: true,
                badge: 'BEST VALUE',
                selected: _selectedPlan == 'half',
                discountedPrice: (_isPromoApplied && _discountedPrice != null && _selectedPlan == 'half') ? _formatPrice(_discountedPrice!) : null,
                onTap: () {
                  setState(() => _selectedPlan = 'half');
                  _selectPlan('half');
                },
              ),
              const SizedBox(height: 10),
              _PlanCard(
                name: 'Yearly',
                price: _formatPrice(_usdPrices['year']!),
                period: _periodPrice(_usdPrices['year']!, 12),
                popular: false,
                badge: 'SAVE 33%',
                selected: _selectedPlan == 'year',
                discountedPrice: (_isPromoApplied && _discountedPrice != null && _selectedPlan == 'year') ? _formatPrice(_discountedPrice!) : null,
                onTap: () {
                  setState(() => _selectedPlan = 'year');
                  _selectPlan('year');
                },
              ),

              const SizedBox(height: 20),
              
              // Crypto Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF627EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF627EEA).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text('💡 Pay with USDT (cryptocurrency)', style: TextStyle(color: Color(0xFF627EEA), fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('No fees, no banks — secure payment via CryptoCloud', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    const SizedBox(height: 4),
                    const Text('🎁 Promo code CRYPTO10 → second month free for first 10 paying users', style: TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectPlan('trial'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_T.goldLight, _T.gold]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: _T.gold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('3 days free', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 11),
                const SizedBox(width: 4),
                const Text('Secure payment', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
                const SizedBox(width: 12),
                const Icon(Icons.autorenew_rounded, color: _T.txtMuted, size: 11),
                const SizedBox(width: 4),
                const Text('Cancel anytime', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
              ]),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;

  const _ComparisonRow(this.feature, this.free, this.premium);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Expanded(flex: 3, child: Text(feature, style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(flex: 2, child: Text(free, textAlign: TextAlign.center, style: const TextStyle(color: _T.txtSecondary, fontSize: 13))),
        Expanded(flex: 2, child: Text(premium, textAlign: TextAlign.center, style: const TextStyle(color: _T.accentLight, fontSize: 13, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final bool popular;
  final String? badge;
  final bool selected;
  final String? discountedPrice;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.popular,
    this.badge,
    this.selected = false,
    this.discountedPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: popular ? _T.accentDim : _T.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _T.accent : (popular ? _T.accent.withOpacity(0.5) : _T.border),
            width: selected ? 2 : (popular ? 1.5 : 1),
          ),
          boxShadow: (popular || selected) ? [BoxShadow(color: _T.accent.withOpacity(0.1), blurRadius: 8)] : null,
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                ),
              Text(name, style: const TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(period, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
            ]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (discountedPrice != null)
                Text(
                  discountedPrice!,
                  style: const TextStyle(color: _T.accentLight, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              if (discountedPrice == null)
                Text(
                  price,
                  style: const TextStyle(color: _T.accentLight, fontSize: 22, fontWeight: FontWeight.w900),
                ),
              if (discountedPrice != null)
                Text(
                  price,
                  style: const TextStyle(color: _T.txtMuted, fontSize: 12, decoration: TextDecoration.lineThrough),
                ),
            ],
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: selected ? _T.accent : (popular ? _T.accent : _T.bgCard),
              shape: BoxShape.circle,
              border: Border.all(color: selected ? _T.accent : (popular ? _T.accent : _T.border)),
            ),
            child: Icon(
              selected ? Icons.check_rounded : Icons.arrow_forward_rounded,
              color: (selected || popular) ? Colors.white : _T.txtSecondary,
              size: 14,
            ),
          ),
        ]),
      ),
    );
  }
}