import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/vip_service.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _activateVip() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите корректный email')));
      return;
    }

    setState(() => _isLoading = true);

    final result = await VipService.activateVip(
      email: email,
      deviceId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    setState(() {
      _isLoading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(title: const Text('VIP-доступ'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(children: [
          // Золотая карточка
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(children: [
              Text('👑', style: TextStyle(fontSize: 60.sp)),
              SizedBox(height: 12.h),
              Text('Первые 50 — навсегда!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text('Зарегистрируйтесь среди первых 50 пользователей и получите ПОЖИЗНЕННЫЙ Premium', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
            ]),
          ),

          SizedBox(height: 24.h),

          // Счётчик
          FutureBuilder<int>(
            future: VipService.getRemainingSlots(),
            builder: (context, snapshot) {
              final remaining = snapshot.data ?? 50;
              final taken = 50 - remaining;
              final progress = taken / 50;

              return Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3))),
                child: Column(children: [
                  Text('Осталось VIP-мест', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  Text('$remaining из 50', style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                  SizedBox(height: 16.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)), minHeight: 10),
                  ),
                  SizedBox(height: 8.h),
                  Text('Занято: $taken мест', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                ]),
              );
            },
          ),

          SizedBox(height: 24.h),

          // Форма активации
          if (_result == null || _result!['success'] != true) ...[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Введите ваш email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _activateVip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Активировать VIP 🎉', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],

          // Результат
          if (_result != null) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: _result!['success'] == true ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _result!['success'] == true ? Colors.green : Colors.orange, width: 2),
              ),
              child: Column(children: [
                Icon(_result!['success'] == true ? Icons.check_circle : Icons.info, color: _result!['success'] == true ? Colors.green : Colors.orange, size: 48.sp),
                SizedBox(height: 12.h),
                Text(_result!['message'], textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                if (_result!['slot'] != null) ...[
                  SizedBox(height: 8.h),
                  Text('Вы — VIP #${_result!['slot']}! 🏆', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                ],
              ]),
            ),
          ],

          SizedBox(height: 32.h),

          // Что получает VIP
          Text('Что получает VIP', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _buildVipFeature('♾️', 'Пожизненный Premium', 'Все 30+ фишек навсегда'),
          _buildVipFeature('🎨', 'Безлимитные презентации', 'Без ограничений по слайдам'),
          _buildVipFeature('🖼', 'Все фоны и шрифты', 'Премиум-библиотека дизайна'),
          _buildVipFeature('📤', 'Экспорт без знака', 'PPTX и PDF без водяного знака'),
          _buildVipFeature('👑', 'Статус VIP', 'Особая отметка в профиле'),
        ]),
      ),
    );
  }

  Widget _buildVipFeature(String emoji, String title, String desc) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(children: [
        Text(emoji, style: TextStyle(fontSize: 28.sp)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
          Text(desc, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
        ])),
      ]),
    );
  }
}