import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    final up = Provider.of<UserProvider>(context);
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Настройки', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text('Оформление', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _tile(Icons.brightness_4, 'Системная', tp.themeModeType == ThemeModeType.system, () => tp.setThemeMode(ThemeModeType.system)),
              _tile(Icons.light_mode, 'Светлая', tp.themeModeType == ThemeModeType.light, () => tp.setThemeMode(ThemeModeType.light)),
              _tile(Icons.dark_mode, 'Тёмная', tp.themeModeType == ThemeModeType.dark, () => tp.setThemeMode(ThemeModeType.dark)),
            ]),
          ),
          if (!up.isPremium) ...[
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: green.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: green.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.star, color: Color(0xFFFFD60A), size: 20),
                  SizedBox(width: 10.w),
                  Expanded(child: Text('Разблокируйте все настройки', style: TextStyle(fontSize: 13, color: Colors.white))),
                  const Icon(Icons.chevron_right, color: green),
                ]),
              ),
            ),
          ],
          SizedBox(height: 20.h),
          Text('Информация', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              ListTile(leading: const Icon(Icons.info_outline, color: Colors.white54), title: const Text('Версия', style: TextStyle(color: Colors.white, fontSize: 14)), subtitle: const Text('1.0.0', style: TextStyle(color: Color(0xFFB3B3B3)))),
              ListTile(leading: const Icon(Icons.mail_outline, color: Colors.white54), title: const Text('Поддержка', style: TextStyle(color: Colors.white, fontSize: 14)), subtitle: const Text('support@prezentator-ai.com', style: TextStyle(color: Color(0xFFB3B3B3)))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, bool selected, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: selected ? const Color(0xFF1DB954) : Colors.white54, size: 20),
    title: Text(title, style: TextStyle(color: selected ? Colors.white : const Color(0xFFB3B3B3), fontSize: 14)),
    trailing: selected ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
    onTap: onTap,
  );
}