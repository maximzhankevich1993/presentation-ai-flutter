import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/referral_service.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _referralCode = '';
  int _referralCount = 0;
  int _freeMonths = 0;
  ReferralTier _currentTier = ReferralService.tiers.first;
  List<Map<String, String>> _referralList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final code = await ReferralService.generateReferralCode();
    final count = await ReferralService.getReferralCount();
    final months = await ReferralService.getFreeMonthsRemaining();
    final list = await ReferralService.getReferralList();
    final tier = ReferralService.getCurrentTier(count);
    setState(() {
      _referralCode = code;
      _referralCount = count;
      _freeMonths = months;
      _currentTier = tier;
      _referralList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(title: const Text('Приведи друга'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10b981), Color(0xFF34d399)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(children: [
              Text('🎁', style: TextStyle(fontSize: 60.sp)),
              SizedBox(height: 12.h),
              Text('Приведи друга — получи 2 месяца Premium!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text('Друг тоже получит 1 месяц бесплатно', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
            ]),
          ),

          SizedBox(height: 24.h),

          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Text(_currentTier.emoji, style: TextStyle(fontSize: 40.sp)),
              SizedBox(width: 16.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Уровень: ${_currentTier.name}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text('Приглашено: $_referralCount друзей', style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text('Бесплатных месяцев: $_freeMonths', style: TextStyle(color: const Color(0xFF10b981), fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),

          SizedBox(height: 24.h),

          Text('Ваш реферальный код', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF10b981))),
            child: Row(children: [
              Expanded(child: Text(_referralCode, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, letterSpacing: 3))),
              IconButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Код скопирован!'))); }, icon: const Icon(Icons.copy, color: Color(0xFF10b981))),
            ]),
          ),

          SizedBox(height: 24.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = ReferralService.getShareText(_referralCode, 'Пользователь');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 5)));
              },
              icon: const Icon(Icons.share),
              label: const Text('Поделиться кодом'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10b981), padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),

          SizedBox(height: 32.h),

          Text('Уровни программы', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          ...ReferralService.tiers.map((tier) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _currentTier.name == tier.name ? const Color(0xFF10b981).withOpacity(0.1) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _currentTier.name == tier.name ? const Color(0xFF10b981) : Colors.grey.withOpacity(0.1), width: _currentTier.name == tier.name ? 2 : 1),
            ),
            child: Row(children: [
              Text(tier.emoji, style: TextStyle(fontSize: 28.sp)),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tier.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                Text('${tier.requiredReferrals}+ друзей: ${tier.reward}', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
              ])),
              if (_currentTier.name == tier.name) const Icon(Icons.check_circle, color: Color(0xFF10b981)),
            ]),
          )),

          SizedBox(height: 24.h),

          if (_referralList.isNotEmpty) ...[
            Text('Приглашённые друзья', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ..._referralList.map((friend) => ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF10b981).withOpacity(0.2), child: Text(friend['name']?[0] ?? '?', style: const TextStyle(color: Color(0xFF10b981)))),
              title: Text(friend['name'] ?? 'Друг'),
              subtitle: Text(friend['date'] ?? ''),
            )),
          ],
        ]),
      ),
    );
  }
}