import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Команда', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_add, color: green, size: 20)),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text('Участники', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _member('Анна М.', 'anna@email.com', 'Владелец', green),
              _member('Дмитрий К.', 'dima@email.com', 'Редактор', const Color(0xFF007AFF)),
              _member('Елена С.', 'elena@email.com', 'Зритель', const Color(0xFFFFD60A)),
            ]),
          ),
          SizedBox(height: 20.h),
          Text('Общие презентации', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _pres('Стратегия 2026', 'Максим Ж. • 15 слайдов'),
              _pres('Отчёт Q1', 'Анна М. • 10 слайдов'),
              _pres('Питч-дек', 'Дмитрий К. • 12 слайдов'),
            ]),
          ),
          if (!up.isPremium) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: green.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.star, color: Color(0xFFFFD60A), size: 20),
                SizedBox(width: 10.w),
                Expanded(child: Text('Команда доступна в Premium', style: TextStyle(fontSize: 13, color: Colors.white))),
                const Icon(Icons.chevron_right, color: green),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _member(String name, String email, String role, Color color) => ListTile(
    leading: CircleAvatar(backgroundColor: color, radius: 18.r, child: Text(name[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
    title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
    subtitle: Text(email, style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 11)),
    trailing: Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(role, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _pres(String title, String subtitle) => ListTile(
    leading: Container(
      width: 36.w, height: 36.w,
      decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.insert_drive_file, color: Color(0xFF1DB954), size: 18),
    ),
    title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
    subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 11)),
    trailing: const Icon(Icons.chevron_right, color: Colors.white38),
  );
}