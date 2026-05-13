import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  String _selectedLanguage = 'Русский';
  String _selectedTheme = 'Тёмная';

  final List<String> _languages = ['Русский', 'English', 'Қазақша'];
  final List<String> _themes = ['Тёмная', 'Светлая', 'Системная'];

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Настройки',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Профиль
            _buildSectionHeader('ПРОФИЛЬ'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.person_outline,
                title: 'Имя пользователя',
                value: up.userName,
                onTap: () => _editUserName(up),
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                title: 'Email',
                value: up.userEmail,
                onTap: () => _editEmail(up),
              ),
              _SettingsItem(
                icon: Icons.logout_rounded,
                title: 'Выйти',
                value: '',
                isDanger: true,
                onTap: () => _logout(),
              ),
            ]),
            const SizedBox(height: 24),

            // Настройки приложения
            _buildSectionHeader('ПРИЛОЖЕНИЕ'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _SettingsSwitch(
                icon: Icons.notifications_none,
                title: 'Уведомления',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              _SettingsSwitch(
                icon: Icons.save_outlined,
                title: 'Автосохранение',
                value: _autoSaveEnabled,
                onChanged: (v) => setState(() => _autoSaveEnabled = v),
              ),
              _SettingsItem(
                icon: Icons.language_outlined,
                title: 'Язык',
                value: _selectedLanguage,
                onTap: () => _showLanguagePicker(),
              ),
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Тема',
                value: _selectedTheme,
                onTap: () => _showThemePicker(),
              ),
            ]),
            const SizedBox(height: 24),

            // О приложении
            _buildSectionHeader('О ПРИЛОЖЕНИИ'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'Версия',
                value: '1.0.0',
                onTap: null,
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                title: 'Пользовательское соглашение',
                value: '',
                onTap: () => _showTerms(),
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Политика конфиденциальности',
                value: '',
                onTap: () => _showPrivacy(),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4A4A4A),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: items
            .expand((item) => [
                  item,
                  if (item != items.last)
                    const Divider(
                      height: 1,
                      color: Color(0xFF2A2A2A),
                      indent: 52,
                    ),
                ])
            .toList(),
      ),
    );
  }

  Future<void> _editUserName(UserProvider up) async {
    final controller = TextEditingController(text: up.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Изменить имя',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Введите имя',
            hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF9A9A9A)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != up.userName) {
      up.setUserName(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Имя обновлено'),
            backgroundColor: Color(0xFF1DB954),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editEmail(UserProvider up) async {
    final controller = TextEditingController(text: up.userEmail);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Изменить Email',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Введите email',
            hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF9A9A9A)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != up.userEmail) {
      up.setUserEmail(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email обновлён'),
            backgroundColor: Color(0xFF1DB954),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Выход',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF9A9A9A)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Выйти',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await ApiService.logout();
        final up = Provider.of<UserProvider>(context, listen: false);
        up.logout();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка выхода'),
              backgroundColor: Color(0xFFFF3B30),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Выберите язык',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._languages.map((lang) => ListTile(
            title: Text(lang, style: const TextStyle(color: Colors.white)),
            trailing: _selectedLanguage == lang
                ? const Icon(Icons.check_rounded, color: Color(0xFF1DB954))
                : null,
            onTap: () {
              setState(() => _selectedLanguage = lang);
              Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Выберите тему',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._themes.map((theme) => ListTile(
            title: Text(theme, style: const TextStyle(color: Colors.white)),
            trailing: _selectedTheme == theme
                ? const Icon(Icons.check_rounded, color: Color(0xFF1DB954))
                : null,
            onTap: () {
              setState(() => _selectedTheme = theme);
              Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Пользовательское соглашение',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Здесь будет текст пользовательского соглашения...',
            style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Политика конфиденциальности',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Здесь будет текст политики конфиденциальности...',
            style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ
// ──────────────────────────────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDanger;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.value,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: isDanger ? const Color(0xFFFF3B30) : const Color(0xFF1DB954)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDanger ? const Color(0xFFFF3B30) : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: TextStyle(
                    color: isDanger ? const Color(0xFFFF3B30) : const Color(0xFF9A9A9A),
                    fontSize: 13,
                  ),
                ),
              if (onTap != null && !isDanger)
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A4A4A), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1DB954)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1DB954),
            activeTrackColor: const Color(0xFF1DB954).withOpacity(0.3),
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }
}