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

class _HomeScreenState extends State<HomeScreen> {
  final _topicController = TextEditingController();
  final List<String> _examples = ['🤖 ИИ', '📈 Бизнес', '🌍 Экология', '🚀 Космос', '📱 IT'];

  @override
  void dispose() {
    _topicController.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Презентатор ИИ', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showVip, icon: Icon(Icons.diamond, color: Colors.amber[700], size: 20.sp)),
          IconButton(onPressed: _showLogin, icon: Icon(Icons.person_outline, color: isDark ? Colors.white70 : Colors.grey[600], size: 20.sp)),
          IconButton(onPressed: _showSettings, icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white54 : Colors.grey[500], size: 20.sp)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),

                // Заголовок
                Text('Создай презентацию', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                SizedBox(height: 4.h),
                Text('с помощью ИИ за 1 минуту', style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.white54 : Colors.grey[600])),

                SizedBox(height: 28.h),

                // Поле ввода
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
                    boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _topicController,
                    style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'О чём презентация?',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      suffixIcon: IconButton(
                        onPressed: _generate,
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(color: const Color(0xFF6366F1), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _generate(),
                  ),
                ),

                SizedBox(height: 14.h),

                // Примеры
                Wrap(spacing: 6.w, runSpacing: 6.h, alignment: WrapAlignment.center, children: _examples.map((e) => GestureDetector(
                  onTap: () { _topicController.text = e.substring(2); },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(e, style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white70 : Colors.grey[700])),
                  ),
                )).toList()),

                SizedBox(height: 20.h),

                // Счётчик
                _buildCounter(up, isDark),

                SizedBox(height: 14.h),

                // Удиви меня
                TextButton.icon(
                  onPressed: _surprise,
                  icon: const Text('🎲', style: TextStyle(fontSize: 14)),
                  label: Text('Удиви меня', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF7C3AED))),
                  style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)),
                ),

                SizedBox(height: 24.h),

                // Иконки разделов
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _iconBtn('🏫', _showTeacher),
                    _iconBtn('💼', _showCorporate),
                    _iconBtn('👥', _showWorkspace),
                    _iconBtn('🎁', _showReferral),
                    _iconBtn('👤', _showProfile),
                  ],
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(UserProvider up, bool isDark) {
    if (up.isPremium) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(12.r)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star, color: Colors.amber, size: 16),
          SizedBox(width: 6),
          Text('Premium', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Text('∞', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      );
    }
    final left = up.freeGenerationsLeft;
    final progress = left / 5.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[50], borderRadius: BorderRadius.circular(12.r)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Генераций: ', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        Text('$left из 5', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF10B981))),
        SizedBox(width: 10.w),
        SizedBox(
          width: 60.w, height: 4.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981))),
          ),
        ),
      ]),
    );
  }

  Widget _iconBtn(String icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12.r)),
      child: Text(icon, style: TextStyle(fontSize: 22.sp)),
    ),
  );
}