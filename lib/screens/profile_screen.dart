import 'package:flutter/material.dart';
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
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _buildProfileHeader(context, userProvider),
          const SizedBox(height: 32),
          _buildStatsGrid(userProvider),
          const SizedBox(height: 32),
          _buildAccountInfo(context, userProvider),
          const SizedBox(height: 32),
          if (!userProvider.isPremium) _buildPremiumBanner(context) else _buildPremiumActive(context),
          const SizedBox(height: 32),
          _buildEmailSection(context),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
        ]),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProvider userProvider) {
    return Center(
      child: Column(children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: userProvider.isPremium ? [const Color(0xFFF59E0B), const Color(0xFFD97706)] : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)]),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('U', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 16),
        FutureBuilder<String?>(future: AuthService.getName(), builder: (context, snapshot) => Text(snapshot.data ?? 'Пользователь', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        if (userProvider.isPremium)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.star, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildStatsGrid(UserProvider userProvider) {
    return Row(children: [
      _buildStatCard(icon: Icons.insert_drive_file, value: '${userProvider.totalGenerationsMade}', label: 'Презентаций', color: const Color(0xFF4F46E5)),
      const SizedBox(width: 12),
      _buildStatCard(icon: Icons.star, value: userProvider.isPremium ? '∞' : '${userProvider.freeGenerationsLeft}', label: 'Осталось', color: const Color(0xFF10B981)),
      const SizedBox(width: 12),
      _buildStatCard(icon: Icons.calendar_today, value: '1', label: 'Дней с нами', color: const Color(0xFFF59E0B)),
    ]);
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Информация об аккаунте', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        FutureBuilder<String?>(future: AuthService.getEmail(), builder: (context, snapshot) => ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Email'), subtitle: Text(snapshot.data ?? 'Не указан'))),
        ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('Статус'), subtitle: Text(userProvider.isPremium ? 'Premium активен' : 'Бесплатный тариф')),
        if (userProvider.isPremium)
          FutureBuilder<DateTime?>(future: PaymentService.getExpiryDate(), builder: (context, snapshot) => ListTile(leading: const Icon(Icons.event), title: const Text('Действует до'), subtitle: Text(snapshot.data != null ? '${snapshot.data!.day}.${snapshot.data!.month}.${snapshot.data!.year}' : 'Неизвестно'))),
        const SizedBox(height: 12),
        ListTile(leading: const Icon(Icons.manage_accounts_outlined, color: Color(0xFF4F46E5)), title: const Text('Управление подпиской'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
      ]),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(Icons.star, color: Colors.amber[700], size: 40),
        const SizedBox(height: 12),
        const Text('Разблокируй все возможности', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)), child: const Text('Перейти на Premium')),
      ]),
    );
  }

  Widget _buildPremiumActive(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: const Column(children: [
        Icon(Icons.check_circle, color: Colors.green, size: 40),
        SizedBox(height: 12),
        Text('Premium активен!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildEmailSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Рассылка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        FutureBuilder<bool>(future: AuthService.isSubscribedToNewsletter(), builder: (context, snapshot) => SwitchListTile(title: const Text('Новости и обновления'), value: snapshot.data ?? false, onChanged: (value) => AuthService.updateNewsletter(value), secondary: Icon((snapshot.data ?? false) ? Icons.notifications_active : Icons.notifications_off))),
      ]),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(onPressed: () async { await AuthService.logout(); if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы вышли из аккаунта'))); } }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Выйти')),
        ],
      ),
    );
  }
}