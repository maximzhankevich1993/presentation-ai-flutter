import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'loading_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'features_screen.dart';
import 'workspace_screen.dart';
import 'teacher_screen.dart';
import 'corporate_screen.dart';
import 'referral_screen.dart';
import 'vip_screen.dart';
import 'login_screen.dart';
import '../services/surprise_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _topicController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _orbController;
  final List<String> _examples = ['🤖 ИИ', '📈 Бизнес', '🌍 Экология', '🚀 Космос', '📱 IT'];

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    final up = Provider.of<UserProvider>(context, listen: false);
    if (!up.canGenerate) { Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingScreen(topic: topic)));
  }

  void _showPremium() => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
  void _showSettings() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  void _showProfile() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  void _showWorkspace() => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkspaceScreen()));
  void _showTeacher() => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherScreen(countryCode: 'RU')));
  void _showCorporate() => Navigator.push(context, MaterialPageRoute(builder: (_) => CorporateScreen(countryCode: 'RU')));
  void _showVip() => Navigator.push(context, MaterialPageRoute(builder: (_) => const VipScreen()));
  void _showLogin() => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  void _surprise() async {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (!up.canUseSurpriseMe) { _showPremium(); return; }
    await up.useSurpriseMe();
    final s = SurpriseService.generateRandomStyle();
    if (mounted) SurpriseService.showSurpriseAnimation(context, () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Стиль: ${s.themeName} 🎉'), backgroundColor: s.primaryColor)));
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]).createShader(b), child: const Text('Презентатор ИИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showVip, icon: const Icon(Icons.diamond, color: Color(0xFFF59E0B))),
          IconButton(onPressed: _showLogin, icon: const Icon(Icons.person_outline, color: Color(0xFF6366F1))),
        ],
      ),
      body: Stack(children: [
        ...List.generate(3, (i) => AnimatedBuilder(
          animation: _orbController,
          builder: (_, __) {
            final t = _orbController.value + i * 0.33;
            final x = 200 + sin(t * 2 * pi) * 100;
            final y = 300 + cos(t * 2 * pi) * 150;
            return Positioned(left: x, top: y, child: Container(width: 200 + i * 100, height: 200 + i * 100, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF6366F1).withOpacity(0.1 + i * 0.05), Colors.transparent]))));
          },
        )),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(height: 20.h),
              _vipBadge(),
              SizedBox(height: 32.h),
              Text('Создай презентацию', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 4.h),
              ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]).createShader(b), child: Text('за 1 минуту', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white))),
              SizedBox(height: 8.h),
              Text('с помощью Искусственного Интеллекта', style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
              SizedBox(height: 40.h),
              // Поле ввода
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: TextField(
                  controller: _topicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: 'О чём презентация?', hintStyle: TextStyle(color: Colors.grey[500]), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h)),
                  onSubmitted: (_) => _generate(),
                ),
              ),
              SizedBox(height: 16.h),
              // Кнопка
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('✨', style: TextStyle(fontSize: 18)), SizedBox(width: 8), Text('Создать', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
              )),
              SizedBox(height: 20.h),
              // Примеры
              Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: _examples.map((e) => ActionChip(label: Text(e, style: const TextStyle(fontSize: 12)), onPressed: () { _topicController.text = e.substring(2); }, backgroundColor: Colors.white.withOpacity(0.05))).toList()),
              SizedBox(height: 24.h),
              // Счётчик
              _counter(up),
              SizedBox(height: 16.h),
              TextButton.icon(onPressed: _surprise, icon: const Text('🎲'), label: const Text('Удиви меня', style: TextStyle(color: Color(0xFF7C3AED)))),
              SizedBox(height: 32.h),
              // Кнопки секций
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _sectionBtn('🏫', 'Учителям', _showTeacher),
                _sectionBtn('💼', 'Бизнесу', _showCorporate),
                _sectionBtn('👥', 'Команда', _showWorkspace),
                _sectionBtn('👤', 'Профиль', _showProfile),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _vipBadge() => Container(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)), borderRadius: BorderRadius.circular(30), color: const Color(0xFFF59E0B).withOpacity(0.1)), child: const Text('👑 Первые 50 — Premium навсегда!', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600, fontSize: 13)));

  Widget _counter(UserProvider up) {
    if (up.isPremium) return Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, color: Colors.amber, size: 20), SizedBox(width: 8), Text('Premium активен', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)), Spacer(), Text('∞', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]));
    final left = up.freeGenerationsLeft;
    return Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Осталось генераций', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])), Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('$left из 5', style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.bold)))],),);
  }

  Widget _sectionBtn(String icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(icon, style: TextStyle(fontSize: 24.sp)), SizedBox(height: 4.h), Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.white70))])),
  );
}