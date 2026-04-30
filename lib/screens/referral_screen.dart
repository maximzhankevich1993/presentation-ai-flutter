import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final code = await ReferralService.generateReferralCode();
      final count = await ReferralService.getReferralCount();
      final months = await ReferralService.getFreeMonthsRemaining();
      final list = await ReferralService.getReferralList();
      final tier = ReferralService.getCurrentTier(count);

      if (!mounted) return;

      setState(() {
        _referralCode = code;
        _referralCount = count;
        _freeMonths = months;
        _currentTier = tier;
        _referralList = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar:
          AppBar(title: const Text('Приведи друга'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10b981), Color(0xFF34d399)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text('🎁', style: TextStyle(fontSize: 60.sp)),
                  SizedBox(height: 12.h),
                  Text(
                    'Приведи друга — получи 2 месяца Premium!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// УРОВЕНЬ
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(_currentTier.emoji,
                      style: TextStyle(fontSize: 40.sp)),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Уровень: ${_currentTier.name}'),
                        Text('Приглашено: $_referralCount'),
                        Text('Месяцы: $_freeMonths'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// КОД
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF10b981)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(_referralCode)),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: _referralCode));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Скопировано')),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            ElevatedButton(
              onPressed: () {
                final text = ReferralService.getShareText(
                    _referralCode, 'Пользователь');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(text)),
                );
              },
              child: const Text('Поделиться'),
            ),

            SizedBox(height: 24.h),

            /// СПИСОК ДРУЗЕЙ
            if (_referralList.isNotEmpty)
              ..._referralList.map(
                (friend) => ListTile(
                  title: Text(friend['name'] ?? 'Друг'),
                  subtitle: Text(friend['date'] ?? ''),
                ),
              ),
          ],
        ),
      ),
    );
  }
}