import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final _topicController = TextEditingController();
  bool _isLoading = false;
  
  final List<String> _examples = [
    '🤖 Искусственный интеллект',
    '📈 Бизнес-план',
    '🌍 Экология',
    '🚀 Космос',
    '📱 IT-тренды',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generatePresentation() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.canGenerate) { _showPremiumDialog(); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingScreen(topic: topic)));
  }

  void _showPremiumDialog() => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
  void _showSettingsScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  void _showProfileScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  void _showHistoryScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
  void _showFeaturesScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeaturesScreen()));
  void _showWorkspaceScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkspaceScreen()));
  void _showTeacherScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherScreen(countryCode: 'RU')));
  void _showCorporateScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => CorporateScreen(countryCode: 'RU')));
  void _showReferralScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
  void _showVipScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const VipScreen()));
  void _showLoginScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  void _surpriseMe(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.canUseSurpriseMe) { _showPremiumDialog(); return; }
    await userProvider.useSurpriseMe();
    final style = SurpriseService.generateRandomStyle();
    if (mounted) {
      SurpriseService.showSurpriseAnimation(context, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Применён стиль: ${style.themeName} 🎉'), backgroundColor: style.primaryColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]).createShader(bounds),
          child: const Text('Презентатор ИИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showVipScreen, icon: const Icon(Icons.diamond, color: Color(0xFFF59E0B)), tooltip: 'VIP'),
          IconButton(onPressed: _showLoginScreen, icon: const Icon(Icons.person_outline, color: Color(0xFF6366F1)), tooltip: 'Войти'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              
              // VIP бейдж
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                ),
                child: const Text('👑 Первые 50 — Premium навсегда!', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              
              SizedBox(height: 32.h),
              
              // Заголовок
              Text('Создай презентацию', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              SizedBox(height: 8.h),
              Text('за 1 минуту', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
              SizedBox(height: 8.h),
              Text('с помощью Искусственного Интеллекта', style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white70 : Colors.grey[600])),
              
              SizedBox(height: 40.h),
              
              // Поле ввода
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: TextField(
                  controller: _topicController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'О чём презентация?',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
                  ),
                  onSubmitted: (_) => _generatePresentation(),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Кнопка Создать
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generatePresentation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✨', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('Создать', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Примеры
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _examples.map((e) => ActionChip(
                  label: Text(e, style: const TextStyle(fontSize: 12)),
                  onPressed: () { _topicController.text = e.substring(2); },
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                )).toList(),
              ),
              
              SizedBox(height: 16.h),
              
              // Счётчик
              _buildCounter(userProvider, isDark),
              
              SizedBox(height: 24.h),
              
              // Удиви меня
              TextButton.icon(
                onPressed: () => _surpriseMe(context),
                icon: const Text('🎲', style: TextStyle(fontSize: 18)),
                label: const Text('Удиви меня', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(UserProvider userProvider, bool isDark) {
    if (userProvider.isPremium) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Text('Premium активен', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Spacer(),
          Text('∞', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
      );
    }
    final left = userProvider.freeGenerationsLeft;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Осталось генераций', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
        Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('$left из 5', style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}