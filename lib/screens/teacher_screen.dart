import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../services/generation_counter.dart';
import '../providers/user_provider.dart';
import 'lesson_constructor_screen.dart';
import 'login_screen.dart';
import 'register_payment_screen.dart';
import 'payment_screen.dart';

// ═══════════════════════════════════════════════════════════════
// CRYPTO PAYMENT URL
// ═══════════════════════════════════════════════════════════════
const String CRYPTO_PAYMENT_URL = 'https://pay.cryptocloud.plus/pos/L1dhlsPbHiuNO7Fv';

class TeacherScreen extends StatefulWidget {
  final String countryCode;
  const TeacherScreen({super.key, required this.countryCode});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String _selectedTariff = 'teacher';
  bool _isLoading = false;
  
  // Фиксированные цены в долларах
  final double _teacherPriceUSD = 4.99;
  final double _schoolPriceUSD = 12.99;
  final double _universityPriceUSD = 24.99;

  @override
  void initState() {
    super.initState();
  }

  String _formatPrice(double usd) {
    if (usd == 0) return 'Free';
    return '\$${usd.toStringAsFixed(2)}';
  }
  
  void _openCryptoPayment(double amount, String planName) {
    final url = amount > 0 ? '$CRYPTO_PAYMENT_URL?amount=$amount' : CRYPTO_PAYMENT_URL;
    html.window.open(url, '_blank');
    
    // Исправленный SnackBar (убрана ошибка с const)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('💸 After payment, subscription activates in 1-2 minutes. Promo code CRYPTO10 → second month free!'),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _openConstructor() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isLoggedIn;
    final isPremium = userProvider.isPremium;
    
    final canGenerate = await GenerationCounter.canGeneratePresentation(isLoggedIn, isPremium);
    
    if (!canGenerate) {
      _showUpgradeDialog();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonConstructorScreen()),
    );
  }
  
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Limit reached', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text(
          'You have used all 5 free generations.\n\nChoose a plan to continue.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openCryptoPayment(_teacherPriceUSD, 'Teacher');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
      case 'teacher': return 'Teacher';
      case 'school': return 'School';
      case 'university': return 'University';
      default: return 'Premium';
    }
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
        title: const Text('For Teachers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openConstructor,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Lesson Builder', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.school_rounded, color: Colors.white, size: 26)),
                      const SizedBox(height: 16),
                      const Text('Educational Plans', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('For teachers and schools — pay with USDT', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
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
                      const Text('🎁 Promo code CRYPTO10 → second month free for first 10 paying users', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                    ],
                  ),
                ),
                
                const Text('CHOOSE YOUR PLAN', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                const SizedBox(height: 12),
                
                _buildTariffCard(
                  title: 'Teacher',
                  usd: _teacherPriceUSD,
                  period: '/month',
                  description: 'For individual teachers',
                  features: const [
                    '∞ generations',
                    '50 slides',
                    'All templates',
                    'PDF export',
                    'Lesson builder',
                    'Quiz generator',
                  ],
                  isPopular: true,
                  onTap: () => _showPaymentDialog('teacher', _teacherPriceUSD, '/month'),
                ),
                const SizedBox(height: 14),
                
                _buildTariffCard(
                  title: 'School',
                  usd: _schoolPriceUSD,
                  period: '/month',
                  description: 'For schools and classes',
                  features: const [
                    'Up to 30 teachers',
                    '∞ generations',
                    'Lesson builder PRO',
                    'Brand kit',
                    'Priority support',
                    'Quiz generator',
                  ],
                  isPopular: false,
                  onTap: () => _showPaymentDialog('school', _schoolPriceUSD, '/month'),
                ),
                const SizedBox(height: 14),
                
                _buildTariffCard(
                  title: 'University',
                  usd: _universityPriceUSD,
                  period: '/month',
                  description: 'For universities and colleges',
                  features: const [
                    'Unlimited teachers',
                    '∞ generations',
                    'Lesson builder PRO',
                    'VIP support 24/7',
                    'Custom settings',
                    'Analytics dashboard',
                  ],
                  isPopular: false,
                  onTap: () => _showPaymentDialog('university', _universityPriceUSD, '/month'),
                ),
                
                const SizedBox(height: 32),
                
                GestureDetector(
                  onTap: _openConstructor,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Open Lesson Builder', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                GestureDetector(
                  onTap: _contactSales,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 20),
                        SizedBox(width: 10),
                        Text('Contact Education Department', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
    required double usd,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedTariff == title.toLowerCase();
    final priceLabel = _formatPrice(usd);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1DB95420) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A), width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: isPopular ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
                    child: Icon(title == 'Teacher' ? Icons.person_outline_rounded : Icons.school_rounded, color: isPopular ? Colors.white : const Color(0xFF1DB954), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(description, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(12)),
                      child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(priceLabel, style: const TextStyle(color: Color(0xFF1DB954), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  if (period.isNotEmpty && usd > 0) ...[
                    const SizedBox(width: 4),
                    Text(period, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF627EEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('USDT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 16),
              const Text('INCLUDED:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12, runSpacing: 10,
                children: features.map((feature) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                    const SizedBox(width: 6),
                    Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                )).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF627EEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('💳 Pay with USDT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
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
              const Text('Education Department', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Contact us for custom educational pricing', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  html.window.navigator.clipboard?.writeText('edu@presentator.ai');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied to clipboard'), backgroundColor: Color(0xFF1DB954)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                  child: const Row(children: [Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 18), SizedBox(width: 10), Text('edu@presentator.ai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))]),
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