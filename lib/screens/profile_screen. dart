import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import 'premium_screen.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildProfileHeader(context, userProvider),
            SizedBox(height: 32.h),
            _buildStatsGrid(userProvider),
            SizedBox(height: 32.h),
            _buildAccountInfo(context, userProvider),
            SizedBox(height: 32.h),
            if (!userProvider.isPremium)
              _buildPremiumBanner(context)
            else
              _buildPremiumActive(context),
            SizedBox(height: 32.h),
            _buildEmailSection(context),
            SizedBox(height: 32.h),
            _buildLogoutButton(context, userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, UserProvider userProvider) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: userProvider.isPremium
                    ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                    : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          /// ✅ FIX: нормальный FutureBuilder
          FutureBuilder<String?>(
            future: AuthService.getName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 24, child: CircularProgressIndicator());
              }
              return Text(
                snapshot.data ?? 'Пользователь',
                style: TextStyle(
                    fontSize: 24.sp, fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProvider userProvider) {
    return Row(
      children: [
        _buildStatCard(
            icon: Icons.insert_drive_file,
            value: '${userProvider.totalGenerationsMade}',
            label: 'Презентаций',
            color: const Color(0xFF4F46E5)),
        SizedBox(width: 12.w),
        _buildStatCard(
            icon: Icons.star,
            value: userProvider.isPremium
                ? '∞'
                : '${userProvider.freeGenerationsLeft}',
            label: 'Осталось',
            color: const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildStatCard(
      {required IconData icon,
      required String value,
      required String label,
      required Color color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(value),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumActive(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(height: 12.h),
          Text(
            'Premium активен!',
            style:
                TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isSubscribedToNewsletter(),
      builder: (context, snapshot) {
        final isSubscribed = snapshot.data ?? false;

        return SwitchListTile(
          title: const Text('Новости'),
          value: isSubscribed,
          onChanged: (value) async {
            await AuthService.updateNewsletter(value);

            /// ✅ FIX: обновляем UI
            (context as Element).markNeedsBuild();
          },
        );
      },
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, UserProvider userProvider) {
    return OutlinedButton(
      onPressed: () => _showLogoutDialog(context, userProvider),
      child: const Text('Выйти'),
    );
  }

  void _showLogoutDialog(
      BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              await AuthService.logout();

              /// ✅ FIX: очищаем Provider
              userProvider.clear();

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  String _getInitials() => 'U';
}