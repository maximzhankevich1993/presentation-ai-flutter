import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:presentator_ai/l10n/app_strings.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _autoRenew = true;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          AppStrings.current.subscription,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF17A34A)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.black, size: 24),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.current.premiumActive,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        '${AppStrings.current.validUntil}: 26.05.2026',
                        style: const TextStyle(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Text(
                    AppStrings.current.autoRenew,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  Switch(
                    value: _autoRenew,
                    onChanged: (v) => setState(() => _autoRenew = v),
                    activeColor: green,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppStrings.current.actions,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3)),
            ),
            SizedBox(height: 8.h),
            _action(Icons.swap_horiz, AppStrings.current.changePlan, () {}),
            _action(Icons.pause_circle_outline, AppStrings.current.pause, () {}),
            _action(Icons.receipt_long, AppStrings.current.paymentHistory, () {}),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B30),
                  side: const BorderSide(color: Color(0xFFFF3B30)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  AppStrings.current.cancelSubscription,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(IconData icon, String title, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: const Color(0xFF1DB954), size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      );
}