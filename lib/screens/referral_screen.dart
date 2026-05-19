import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _referralCode = '';
  int _referralsCount = 0;
  int _bonusGenerations = 0;
  bool _isLoading = true;
  bool _isCopied = false;
  
  List<Map<String, dynamic>> _friends = [];

  final List<Map<String, dynamic>> _referralRules = [
    {
      'icon': Icons.person_add_rounded,
      'title': 'Пригласи друга',
      'description': 'Отправь реферальную ссылку другу',
      'reward': '+1 генерация',
    },
    {
      'icon': Icons.group_rounded,
      'title': 'Регистрация друга',
      'description': 'Друг зарегистрируется по твоей ссылке',
      'reward': '+2 генерации',
    },
    {
      'icon': Icons.rocket_launch_rounded,
      'title': 'Активация Premium',
      'description': 'Друг купит Premium тариф',
      'reward': '+10 генераций',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isLoggedIn) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    await _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final response = await http.get(
        Uri.parse('https://presentation-ai-backend.onrender.com/api/referral/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _referralCode = data['code'] ?? _generateReferralCode();
          _referralsCount = data['referralsCount'] ?? 0;
          _bonusGenerations = data['bonusGenerations'] ?? 0;
          _friends = List<Map<String, dynamic>>.from(data['friends'] ?? []);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Токен невалидный
        setState(() => _isLoading = false);
      } else {
        _loadLocalMockData();
      }
    } catch (e) {
      print('Error loading referral data: $e');
      _loadLocalMockData();
    }
  }
  
  void _loadLocalMockData() {
    // Временные данные для демо (только для теста, в продакшене убрать)
    setState(() {
      _referralCode = _generateReferralCode();
      _referralsCount = 0;
      _bonusGenerations = 0;
      _friends = [];
      _isLoading = false;
    });
  }
  
  String _generateReferralCode() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    if (userId.isNotEmpty && userId.length > 6) {
      return 'REF${userId.substring(0, 6).toUpperCase()}';
    }
    return 'REF${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}';
  }

  Future<void> _copyCode() async {
    if (_referralCode.isEmpty) return;
    
    try {
      await Clipboard.setData(ClipboardData(text: _referralCode));
      setState(() => _isCopied = true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Код скопирован!'),
          backgroundColor: Color(0xFF1DB954),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isCopied = false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка копирования'),
          backgroundColor: Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _shareCode() {
    final shareUrl = 'https://presentator.ai/ref/$_referralCode';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ссылка: $shareUrl'),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;
    
    // Если не авторизован — показываем предложение войти
    if (!isLoggedIn && !_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Друзья', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('Реферальная программа', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('Приглашайте друзей и получайте бонусы', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 48),
                        const SizedBox(height: 16),
                        const Text('Войдите в аккаунт', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Реферальная программа доступна только авторизованным пользователям', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14), textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Войти', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Друзья', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 16),
                            const Text('Приведи друга', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Получи бонусные генерации', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.people_rounded,
                              value: '$_referralsCount',
                              label: 'Приглашений',
                              color: const Color(0xFF1DB954),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.card_giftcard_rounded,
                              value: '+$_bonusGenerations',
                              label: 'Бонусов получено',
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Referral code
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ВАШ РЕФЕРАЛЬНЫЙ КОД', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF121212),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2A2A2A)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _referralCode,
                                      style: const TextStyle(color: Color(0xFF1DB954), fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _copyCode,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: _isCopied ? null : const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                                        color: _isCopied ? const Color(0xFF2A2A2A) : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(_isCopied ? Icons.check_rounded : Icons.copy_rounded, color: _isCopied ? const Color(0xFF1DB954) : Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(_isCopied ? 'Скопировано!' : 'Копировать', style: TextStyle(color: _isCopied ? const Color(0xFF1DB954) : Colors.white, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _shareCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Пригласить друзей', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // How it works
                      const Text('КАК ЭТО РАБОТАЕТ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ..._referralRules.map((rule) => _buildRuleCard(rule)),
                      const SizedBox(height: 24),

                      // Invited friends
                      if (_friends.isNotEmpty) ...[
                        const Text('ПРИГЛАШЁННЫЕ ДРУЗЬЯ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _friends.length,
                            separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2A2A), height: 1, indent: 52),
                            itemBuilder: (_, i) {
                              final friend = _friends[i];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: friend['status'] == 'activated' ? const Color(0xFF1DB95420) : const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    friend['status'] == 'activated' ? Icons.check_rounded : Icons.person_outline_rounded,
                                    color: friend['status'] == 'activated' ? const Color(0xFF1DB954) : const Color(0xFF9A9A9A),
                                    size: 20,
                                  ),
                                ),
                                title: Text(friend['name'] ?? friend['email']?.split('@')[0] ?? 'Пользователь', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                subtitle: Text(friend['date'] ?? '', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                                trailing: friend['reward'] != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF1DB95420), borderRadius: BorderRadius.circular(12)),
                                        child: Text('+${friend['reward']}', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 12, fontWeight: FontWeight.w700)),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
                                        child: const Text('Ожидает', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF1DB95420), borderRadius: BorderRadius.circular(12)),
            child: Icon(rule['icon'], color: const Color(0xFF1DB954), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule['title'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(rule['description'], style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF1DB95420), borderRadius: BorderRadius.circular(12)),
            child: Text(rule['reward'], style: const TextStyle(color: Color(0xFF1DB954), fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}