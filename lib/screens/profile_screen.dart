import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';

// ═══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase    = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard    = Color(0xFF1E1E1E);
  static const bgHover   = Color(0xFF252525);
  static const border    = Color(0xFF2A2A2A);
  static const txtPrimary   = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted     = Color(0xFF4A4A4A);
  static const accent       = Color(0xFF1DB954);
  static const accentLight  = Color(0xFF1ED760);
  static const accentDim    = Color(0xFF1DB95420);
  static const danger       = Color(0xFFFF3B30);
  static const gold         = Color(0xFFFFD700);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    final up = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = up.userEmail != null && up.userEmail!.isNotEmpty;

    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _T.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _T.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: _T.danger, size: 24),
            ),
            const SizedBox(height: 16),
            const Text('Выйти?',
              style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 6),
            const Text('Вы уверены что хотите выйти из аккаунта?',
              style: TextStyle(color: _T.txtSecondary, fontSize: 13),
              textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _T.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _T.border),
                      ),
                      child: const Center(child: Text('Отмена', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _T.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('Выйти', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );

    if (confirmed == true) {
      final api = ApiService();
      await api.logout();

      if (!mounted) return;

      final up = Provider.of<UserProvider>(context, listen: false);
      await up.setUserEmail('');
      await up.setUserName('');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final isLoggedIn = up.userEmail != null && up.userEmail!.isNotEmpty;

    if (!isLoggedIn) {
      return const Scaffold(
        backgroundColor: _T.bgBase,
        body: Center(
          child: CircularProgressIndicator(color: _T.accent),
        ),
      );
    }

    final isPremium = up.isPremium;

    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: _T.txtSecondary, size: 17),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Профиль',
          style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: _T.txtSecondary, size: 18),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Avatar ─────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_T.accent, _T.accentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _T.accent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (up.userName ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                up.userName ?? 'Пользователь',
                style: const TextStyle(
                  color: _T.txtPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                up.userEmail ?? '',
                style: const TextStyle(color: _T.txtSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              if (isPremium) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_T.gold, Color(0xFFFFD60A)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('PREMIUM',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // ── Stats ──────────────────────────────────────────
              Row(children: [
                _StatCard(
                  value: '0',
                  label: 'Презентаций',
                  icon: Icons.slideshow_rounded,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  value: isPremium ? '∞' : '5',
                  label: 'Осталось',
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  value: isPremium ? 'PRO' : 'Free',
                  label: 'План',
                  icon: Icons.workspace_premium_rounded,
                ),
              ]),
              const SizedBox(height: 24),

              // ── Info ───────────────────────────────────────────
              _SectionLabel('ИНФОРМАЦИЯ'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _T.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _T.border),
                ),
                child: Column(children: [
                  _Tile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: up.userEmail ?? 'Не указан',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: _T.border, height: 1),
                  ),
                  _Tile(
                    icon: Icons.calendar_today_rounded,
                    title: 'Дата регистрации',
                    subtitle: 'Сегодня',
                  ),
                ]),
              ),

              if (!isPremium) ...[
                const SizedBox(height: 24),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_T.accent, _T.accentLight],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _T.accent.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Перейти на Premium',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Выйти ─────────────────────────────────────────
              _SectionLabel(''),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _T.danger.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _T.danger.withOpacity(0.2)),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.logout_rounded, color: _T.danger, size: 16),
                      SizedBox(width: 8),
                      Text('Выйти из профиля',
                        style: TextStyle(color: _T.danger, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(text,
        style: const TextStyle(
          color: _T.txtMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _T.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.border),
        ),
        child: Column(children: [
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _T.accentDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _T.accentLight, size: 16),
          ),
          Text(value,
            style: const TextStyle(
              color: _T.txtPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(color: _T.txtSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TILE
// ═══════════════════════════════════════════════════════════════
class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _T.txtSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _T.txtSecondary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
              style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
              style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
          ]),
        ),
      ]),
    );
  }
}