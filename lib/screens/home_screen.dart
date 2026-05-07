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
  final List<String> _examples = ['ИИ', 'Бизнес', 'Экология', 'Космос', 'IT'];

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

  void _showTextInput() {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Загрузите текст', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: ctrl,
            maxLines: 6,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Введите текст диплома, статьи...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true, fillColor: const Color(0xFF282828),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена', style: TextStyle(color: Color(0xFFB3B3B3)))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingScreen(topic: text.substring(0, 50))));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
              child: const Text('Создать', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoUpload() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Загрузите логотип', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('Выберите файл логотипа (PNG, JPG)\n\nБренд-кит будет создан автоматически.', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена', style: TextStyle(color: Color(0xFFB3B3B3)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Бренд-кит создан!'), backgroundColor: Color(0xFF1DB954)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Загрузить', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final left = up.freeGenerationsLeft;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Презентатор ИИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showVip, icon: const Icon(Icons.diamond, color: Color(0xFFFFD60A), size: 20)),
          IconButton(onPressed: _showLogin, icon: const Icon(Icons.person_outline, color: Color(0xFFB3B3B3), size: 20)),
          IconButton(onPressed: _showSettings, icon: const Icon(Icons.settings_outlined, color: Color(0xFFB3B3B3), size: 20)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: 20.h),
              // VIP
              GestureDetector(
                onTap: _showVip,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(color: const Color(0xFFFFD60A), borderRadius: BorderRadius.circular(20)),
                  child: const Text('👑 Первые 50 — Premium навсегда!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ),
              SizedBox(height: 28.h),
              Text('Создай презентацию', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              SizedBox(height: 4.h),
              Text('с помощью ИИ за 1 минуту', style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB3B3B3))),
              SizedBox(height: 24.h),
              // Поле ввода
              Container(
                width: 280.w, height: 44.h,
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
                child: TextField(
                  controller: _topicController,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'О чём презентация?',
                    hintStyle: TextStyle(color: const Color(0xFFB3B3B3).withOpacity(0.5), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                  onSubmitted: (_) => _generate(),
                ),
              ),
              SizedBox(height: 10.h),
              // Кнопка Создать
              GestureDetector(
                onTap: _generate,
                child: Container(
                  width: 280.w, height: 44.h,
                  decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('✨ Создать', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14))),
                ),
              ),
              SizedBox(height: 14.h),
              // Примеры
              Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: _examples.map((e) => GestureDetector(
                onTap: () { _topicController.text = e; },
                child: Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)), child: Text(e, style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3)))),
              )).toList()),
              SizedBox(height: 10.h),
              // Дополнительные кнопки
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _extraBtn('📄', 'Из текста', _showTextInput),
                SizedBox(width: 12.w),
                _extraBtn('🏷', 'Из логотипа', _showLogoUpload),
              ]),
              SizedBox(height: 18.h),
              // Счётчик
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Осталось: ', style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
                  Text('$left из 5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1DB954))),
                  SizedBox(width: 8.w),
                  SizedBox(width: 40.w, height: 3.h, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: left / 5.0, backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954))))),
                ]),
              ),
              SizedBox(height: 20.h),
              // Навигация
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _nav('🏫', 'Учителям', _showTeacher),
                SizedBox(width: 20.w),
                _nav('💼', 'Бизнесу', _showCorporate),
                SizedBox(width: 20.w),
                _nav('👥', 'Команда', _showWorkspace),
                SizedBox(width: 20.w),
                _nav('🎁', 'Друзья', _showReferral),
                SizedBox(width: 20.w),
                _nav('👤', 'Профиль', _showProfile),
              ]),
              SizedBox(height: 20.h),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _extraBtn(String icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
      ]),
    ),
  );

  Widget _nav(String icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      SizedBox(height: 3.h),
      Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFFB3B3B3))),
    ]),
  );
}