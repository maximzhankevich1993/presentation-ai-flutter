import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'premium_screen.dart';

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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
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
        title: const Text('Настройки',
          style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Аккаунт ──────────────────────────────────────────
          _SectionLabel('АККАУНТ'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _T.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border),
            ),
            child: Column(children: [
              _Tile(
                icon: Icons.person_outline_rounded,
                title: up.userName ?? 'Гость',
                subtitle: up.userEmail ?? 'Не авторизован',
                trailing: const Icon(Icons.edit_rounded, color: _T.txtMuted, size: 16),
                onTap: () {},
              ),
              if (!isPremium)
                Column(children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: _T.border, height: 1),
                  ),
                  _Tile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Premium',
                    subtitle: 'Разблокируйте все функции',
                    titleColor: _T.gold,
                    iconColor: _T.gold,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text('UPGRADE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                  ),
                ]),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Оформление ───────────────────────────────────────
          _SectionLabel('ОФОРМЛЕНИЕ'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _T.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border),
            ),
            child: Column(children: [
              _ThemeTile(
                icon: Icons.dark_mode_rounded,
                title: 'Тёмная',
                selected: true, // Always dark for this design
                onTap: () {},
              ),
              if (!isPremium)
                Column(children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: _T.border, height: 1),
                  ),
                  _Tile(
                    icon: Icons.palette_rounded,
                    title: 'Своя тема',
                    subtitle: 'Premium',
                    trailing: const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 14),
                    onTap: null,
                    enabled: isPremium,
                  ),
                ]),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Данные ──────────────────────────────────────────
          _SectionLabel('ДАННЫЕ'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _T.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border),
            ),
            child: Column(children: [
              _Tile(
                icon: Icons.cloud_sync_rounded,
                title: 'Синхронизация',
                subtitle: 'Автоматически',
                trailing: const Icon(Icons.check_circle_rounded, color: _T.accent, size: 18),
                onTap: () {},
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: _T.border, height: 1),
              ),
              _Tile(
                icon: Icons.delete_outline_rounded,
                title: 'Очистить кэш',
                subtitle: '24.5 MB',
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── О приложении ─────────────────────────────────────
          _SectionLabel('О ПРИЛОЖЕНИИ'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _T.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border),
            ),
            child: Column(children: [
              _Tile(
                icon: Icons.info_outline_rounded,
                title: 'Версия',
                subtitle: '1.0.0 (build 42)',
                onTap: () {},
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: _T.border, height: 1),
              ),
              _Tile(
                icon: Icons.mail_outline_rounded,
                title: 'Поддержка',
                subtitle: 'support@prezentator-ai.com',
                onTap: () {},
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: _T.border, height: 1),
              ),
              _Tile(
                icon: Icons.star_rate_rounded,
                title: 'Оценить приложение',
                subtitle: 'Помогите нам стать лучше',
                trailing: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.star_rounded, color: _T.gold, size: 16),
                  Icon(Icons.star_rounded, color: _T.gold, size: 16),
                  Icon(Icons.star_rounded, color: _T.gold, size: 16),
                  Icon(Icons.star_rounded, color: _T.gold, size: 16),
                  Icon(Icons.star_rounded, color: _T.gold, size: 16),
                ]),
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Опасная зона ─────────────────────────────────────
          _SectionLabel('ОПАСНАЯ ЗОНА'),
          const SizedBox(height: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _T.danger.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _T.danger.withOpacity(0.2)),
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.logout_rounded, color: _T.danger, size: 18),
                  SizedBox(width: 8),
                  Text('Выйти из аккаунта',
                    style: TextStyle(color: _T.danger, fontWeight: FontWeight.w600, fontSize: 14)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
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
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _T.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _T.border),
                      ),
                      child: const Center(child: Text('Отмена', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600)))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      // TODO: actual logout
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _T.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('Выйти', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
                  ),
                ),
              ),
            ]),
          ]),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
    child: Text(text,
      style: const TextStyle(
        color: _T.txtMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// TILE
// ═══════════════════════════════════════════════════════════════
class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: (onTap != null && enabled) ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? _T.txtSecondary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor ?? _T.txtSecondary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                    style: TextStyle(
                      color: titleColor ?? _T.txtPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
                ]),
              ),
              if (trailing != null) trailing!,
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// THEME TILE
// ═══════════════════════════════════════════════════════════════
class _ThemeTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<_ThemeTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hovered ? _T.bgHover : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: widget.selected ? _T.accentDim : _T.txtSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon,
                  color: widget.selected ? _T.accentLight : _T.txtSecondary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(widget.title,
                style: TextStyle(
                  color: widget.selected ? _T.txtPrimary : _T.txtSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.selected)
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _T.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}