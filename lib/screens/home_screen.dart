import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'loading_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
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
  late AnimationController _orbController;
  final List<String> _examples = ['ИИ', 'Бизнес', 'Экология', 'Космос', 'IT'];

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
  void _showReferral() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
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
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]).createShader(b),
          child: const Text('Презентатор ИИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showVip, icon: const Icon(Icons.diamond, color: Color(0xFFF59E0B), size: 17)),
          IconButton(onPressed: _showLogin, icon: const Icon(Icons.person_outline, color: Colors.white54, size: 17)),
          IconButton(onPressed: _showSettings, icon: const Icon(Icons.settings_outlined, color: Colors.white38, size: 17)),
        ],
      ),
      body: Stack(children: [
        ...List.generate(3, (i) => AnimatedBuilder(
          animation: _orbController,
          builder: (_, __) {
            final t = _orbController.value + i * 0.33;
            return Positioned(
              left: 150 + sin(t * 2 * pi) * 80, top: 200 + cos(t * 2 * pi) * 120,
              child: Container(width: 150 + i * 80, height: 150 + i * 80, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF6366F1).withOpacity(0.06 + i * 0.03), Colors.transparent]))),
            );
          },
        )),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(height: 28.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)), borderRadius: BorderRadius.circular(20), color: const Color(0xFFF59E0B).withOpacity(0.06)),
                  child: const Text('👑 Первые 50 — Premium навсегда!', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w500)),
                ),
                SizedBox(height: 28.h),
                Text('Создай презентацию', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                SizedBox(height: 3.h),
                Text('с помощью ИИ за 1 минуту', style: TextStyle(fontSize: 11.sp, color: Colors.white60, letterSpacing: 0.2)),
                SizedBox(height: 24.h),
                // Поле ввода
                Container(
                  width: 280.w, height: 38.h,
                  decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.12))),
                  child: TextField(
                    controller: _topicController,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'О чём презентация?',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    ),
                    onSubmitted: (_) => _generate(),
                  ),
                ),
                SizedBox(height: 10.h),
                // Кнопка Создать
                GestureDetector(
                  onTap: _generate,
                  child: Container(
                    width: 160.w, height: 34.h,
                    decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('✨ Создать', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: _examples.map((e) => GestureDetector(
                  onTap: () { _topicController.text = e; },
                  child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(14)), child: Text(e, style: TextStyle(fontSize: 10, color: Colors.white60))),
                )).toList()),
                SizedBox(height: 18.h),
                _counter(up),
                SizedBox(height: 12.h),
                TextButton.icon(
                  onPressed: _surprise,
                  icon: const Text('🎲', style: TextStyle(fontSize: 12)),
                  label: const Text('Удиви меня', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 10)),
                  style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h)),
                ),
                SizedBox(height: 24.h),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _navItem('🏫', 'Учителям', _showTeacher),
                  _navItem('💼', 'Бизнесу', _showCorporate),
                  _navItem('👥', 'Команда', _showWorkspace),
                  _navItem('🎁', 'Друзья', _showReferral),
                  _navItem('👤', 'Профиль', _showProfile),
                ]),
                SizedBox(height: 20.h),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _counter(UserProvider up) {
    if (up.isPremium) return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(10)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star, color: Colors.amber, size: 13), SizedBox(width: 5),
        Text('Premium', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        SizedBox(width: 6),
        Text('∞', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ]),
    );
    final left = up.freeGenerationsLeft;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Осталось:', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        SizedBox(width: 6.w),
        Text('$left из 5', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
        SizedBox(width: 8.w),
        SizedBox(width: 44.w, height: 3.h, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: left / 5.0, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981))))),
      ]),
    );
  }

  Widget _navItem(String icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      SizedBox(height: 2.h),
      Text(label, style: const TextStyle(fontSize: 7, color: Colors.white38)),
    ]),
  );
}