import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'premium_screen.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Профиль', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(children: [
          // Аватар
          Center(
            child: Column(children: [
              Container(
                width: 72.w, height: 72.w,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [green, Color(0xFF17A34A)]), shape: BoxShape.circle),
                child: const Center(child: Text('U', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w800))),
              ),
              SizedBox(height: 10.h),
              const Text('Пользователь', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              if (up.isPremium)
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(10)),
                  child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
          SizedBox(height: 24.h),

          // Статистика
          Row(children: [
            _stat('${up.totalGenerationsMade}', 'Презентаций', green),
            SizedBox(width: 8.w),
            _stat(up.isPremium ? '∞' : '${up.freeGenerationsLeft}', 'Осталось', green),
            SizedBox(width: 8.w),
            _stat('1', 'День', green),
          ]),
          SizedBox(height: 20.h),

          // Инфо
          Container(
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              ListTile(leading: const Icon(Icons.email_outlined, color: Colors.white54, size: 20), title: const Text('Email', style: TextStyle(color: Colors.white, fontSize: 13)), subtitle: Text(up.userEmail ?? 'Не указан', style: const TextStyle(color: Color(0xFFB3B3B3)))),
              ListTile(leading: const Icon(Icons.manage_accounts_outlined, color: green, size: 20), title: const Text('Управление подпиской', style: TextStyle(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.chevron_right, color: Colors.white38), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
            ]),
          ),

          if (!up.isPremium) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: green, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Перейти на Premium', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) => Expanded(
    child: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: const Color(0xFFB3B3B3))),
      ]),
    ),
  );
}