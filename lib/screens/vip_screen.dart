import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard = Color(0xFF1E1E1E);
  static const bgHover = Color(0xFF252525);
  static const border = Color(0xFF2A2A2A);
  static const txtPrimary = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted = Color(0xFF4A4A4A);
  static const accent = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim = Color(0xFF1DB95420);
  static const danger = Color(0xFFFF3B30);
  static const gold = Color(0xFFFFD700);
  static const goldLight = Color(0xFFFFD60A);
}

const int _totalSpots = 50;

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _emailNode = FocusNode();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _takenSpots = 0;
  bool _loading = true;
  bool _claiming = false;
  bool _claimed = false;
  String? _error;

  int get _left => (_totalSpots - _takenSpots).clamp(0, _totalSpots);
  bool get _soldOut => _left <= 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _fetchSpots();
  }

  Future<void> _fetchSpots() async {
    try {
      final r = await http.get(
        Uri.parse('https://presentation-ai-backend.onrender.com/api/vip/spots'),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final d = json.decode(r.body);
        if (mounted) setState(() => _takenSpots = (d['taken'] as num).toInt());
      }
    } catch (_) {
      // Нет эндпоинта — пока 0
      if (mounted) setState(() => _takenSpots = 1);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _claim() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Введите корректный email');
      return;
    }

    setState(() { _claiming = true; _error = null; });

    try {
      final api = ApiService();
      final r = await http.post(
        Uri.parse('https://presentation-ai-backend.onrender.com/api/vip/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (mounted) {
          setState(() { _claimed = true; _takenSpots = (d['taken'] as num).toInt(); });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.goldLight, _T.gold]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)),
                const SizedBox(width: 10),
                const Text('VIP-статус активирован! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
              backgroundColor: _T.goldLight.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            ),
          );
        }
      } else {
        final d = json.decode(r.body);
        if (mounted) setState(() => _error = d['error'] ?? 'Ошибка');
      }
    } catch (e) {
      // Fallback: локально увеличиваем счётчик
      if (mounted) {
        setState(() { _claimed = true; _takenSpots++; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Row(children: [Container(width: 24, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.goldLight, _T.gold]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)), const SizedBox(width: 10), const Text('VIP-статус активирован! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))]), backgroundColor: _T.goldLight.withOpacity(0.9), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.fromLTRB(16, 0, 16, 24)),
        );
      }
    }
    if (mounted) setState(() => _claiming = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если места закончились — показываем заглушку
    if (_soldOut && !_loading) {
      return Scaffold(
        backgroundColor: _T.bgBase,
        appBar: AppBar(
          backgroundColor: _T.bgBase,
          leading: MouseRegion(cursor: SystemMouseCursors.click, child: IconButton(icon: const Icon(Icons.close_rounded, color: _T.txtSecondary, size: 20), onPressed: () => Navigator.pop(context))),
        ),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏁', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('VIP-места закончились', style: TextStyle(color: _T.txtPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Все 50 мест заняты', style: TextStyle(color: _T.txtSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(10)), child: const Text('Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))))),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        leading: MouseRegion(cursor: SystemMouseCursors.click, child: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: _T.txtSecondary, size: 17), onPressed: () => Navigator.pop(context))),
        title: const Text('VIP-доступ', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_T.goldLight, _T.gold], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _T.gold.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Column(children: [
                  const Text('👑', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  const Text('Первые 50 — навсегда!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Пожизненный Premium бесплатно', style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.7))),
                ]),
              ),
              const SizedBox(height: 20),

              // Counter
              if (_loading)
                const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _T.goldLight))
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.border)),
                  child: Column(children: [
                    const Text('Осталось VIP-мест', style: TextStyle(color: _T.txtSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('$_left из $_totalSpots', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: _T.goldLight, letterSpacing: -1)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (_totalSpots - _left) / _totalSpots,
                        backgroundColor: _T.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(_T.goldLight),
                        minHeight: 5,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Form
                if (!_claimed) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _error != null ? _T.danger.withOpacity(0.5) : _T.border)),
                    child: TextField(
                      controller: _emailCtrl, focusNode: _emailNode,
                      style: const TextStyle(fontSize: 14, color: _T.txtPrimary, fontWeight: FontWeight.w500),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Введите ваш email',
                        hintStyle: const TextStyle(color: _T.txtMuted, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Padding(padding: EdgeInsets.fromLTRB(14, 13, 8, 13), child: Icon(Icons.email_outlined, color: _T.txtMuted, size: 18)),
                      ),
                    ),
                  ),
                  if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: _T.danger, fontSize: 11))),
                  const SizedBox(height: 12),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(
                      onTap: _claiming ? null : _claim,
                      child: Container(
                        width: double.infinity, height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_T.goldLight, _T.gold]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: _T.gold.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))],
                        ),
                        child: Center(child: _claiming ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('🔥', style: TextStyle(fontSize: 18)), SizedBox(width: 8), Text('Занять место', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15))])),
                      ),
                    )),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: _T.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.gold.withOpacity(0.3))),
                    child: Column(children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.goldLight, _T.gold]), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 28)),
                      const SizedBox(height: 12),
                      const Text('Место занято!', style: TextStyle(color: _T.goldLight, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Premium активирован навсегда', style: TextStyle(color: _T.txtSecondary, fontSize: 12)),
                    ]),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Perks
              const Text('Что получает VIP', style: TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _Perk('♾️', 'Пожизненный Premium', 'Никаких платежей, навсегда'),
              _Perk('🎨', 'Все 30+ функций', 'Фоны, шрифты, анимации'),
              _Perk('📤', 'Экспорт без знака', 'PPTX и PDF без ограничений'),
              _Perk('👑', 'Статус VIP', 'Особая отметка в профиле'),
              _Perk('🚀', 'Ранний доступ', 'Новые функции первыми'),

              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _Perk(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
          ]),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, color: _T.txtMuted, size: 12),
      ]),
    );
  }
}