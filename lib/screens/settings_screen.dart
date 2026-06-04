import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  String _selectedLanguage = AppStrings.current.russian;
  String _selectedTheme = AppStrings.current.darkTheme;
  bool _isLoggingOut = false;

  late List<String> _languages;
  late List<String> _themes;

  @override
  void initState() {
    super.initState();
    _languages = [AppStrings.current.russian, AppStrings.current.english];
    _themes = [AppStrings.current.darkTheme, AppStrings.current.lightTheme, AppStrings.current.systemTheme];
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme') ?? AppStrings.current.darkTheme;
    setState(() {
      _selectedTheme = savedTheme;
    });
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme);
  }

  void _applyTheme(String theme) {
    setState(() {
      _selectedTheme = theme;
    });
    _saveTheme(theme);
    _showSuccess('${AppStrings.current.themeChangedTo} $theme. ${AppStrings.current.restartToApply}');
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: Text(
          AppStrings.current.settings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoggingOut
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSectionHeader(AppStrings.current.profile),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _SettingsItem(
                          icon: Icons.person_outline,
                          title: AppStrings.current.userName,
                          value: up.userName,
                          onTap: () => _editUserName(up),
                        ),
                        _SettingsItem(
                          icon: Icons.email_outlined,
                          title: AppStrings.current.email,
                          value: up.userEmail,
                          onTap: () => _editEmail(up),
                        ),
                        _SettingsItem(
                          icon: Icons.logout_rounded,
                          title: AppStrings.current.logout,
                          value: '',
                          isDanger: true,
                          onTap: () => _logout(),
                        ),
                      ]),
                      const SizedBox(height: 24),

                      _buildSectionHeader(AppStrings.current.application),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _SettingsSwitch(
                          icon: Icons.notifications_none,
                          title: AppStrings.current.notifications,
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                        ),
                        _SettingsSwitch(
                          icon: Icons.save_outlined,
                          title: AppStrings.current.autoSave,
                          value: _autoSaveEnabled,
                          onChanged: (v) => setState(() => _autoSaveEnabled = v),
                        ),
                        _SettingsItem(
                          icon: Icons.language_outlined,
                          title: AppStrings.current.language,
                          value: _selectedLanguage,
                          onTap: () => _showLanguagePicker(),
                        ),
                        _SettingsItem(
                          icon: Icons.dark_mode_outlined,
                          title: AppStrings.current.theme,
                          value: _selectedTheme,
                          onTap: () => _showThemePicker(),
                        ),
                      ]),
                      const SizedBox(height: 24),

                      _buildSectionHeader(AppStrings.current.about),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _SettingsItem(
                          icon: Icons.info_outline,
                          title: AppStrings.current.version,
                          value: '1.0.0',
                          onTap: null,
                        ),
                        _SettingsItem(
                          icon: Icons.description_outlined,
                          title: AppStrings.current.termsOfService,
                          value: '',
                          onTap: () => _showTerms(),
                        ),
                        _SettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: AppStrings.current.privacyPolicy,
                          value: '',
                          onTap: () => _showPrivacy(),
                        ),
                      ]),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4A4A4A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      width: double.infinity,
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
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.current.changeName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppStrings.current.enterName,
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
            child: Text(AppStrings.current.cancel, style: const TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: Text(AppStrings.current.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != up.userName) {
      up.setUserName(result);
      _showSuccess(AppStrings.current.nameUpdated);
    }
  }

  Future<void> _editEmail(UserProvider up) async {
    final controller = TextEditingController(text: up.userEmail);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.current.changeEmail,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: AppStrings.current.enterEmail,
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
            child: Text(AppStrings.current.cancel, style: const TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: Text(AppStrings.current.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != up.userEmail) {
      up.setUserEmail(result);
      _showSuccess(AppStrings.current.emailUpdated);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.current.logout,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppStrings.current.logoutConfirmation,
          style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.current.cancel, style: const TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
            child: Text(AppStrings.current.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoggingOut = true);
      
      try {
        final up = Provider.of<UserProvider>(context, listen: false);
        await up.logout();
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        setState(() => _isLoggingOut = false);
        _showError(AppStrings.current.logoutError);
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
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.current.selectLanguage,
            style: const TextStyle(
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
              _showSuccess(AppStrings.current.languageChanged);
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
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.current.selectTheme,
            style: const TextStyle(
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
              Navigator.pop(ctx);
              _applyTheme(theme);
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
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.current.termsOfService,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of service content will be displayed here...',
            style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.current.close, style: const TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.current.privacyPolicy,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy policy content will be displayed here...',
            style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.current.close, style: const TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDanger ? const Color(0xFFFF3B30).withOpacity(0.1) : const Color(0xFF1DB954).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: isDanger ? const Color(0xFFFF3B30) : const Color(0xFF1DB954)),
              ),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1DB954)),
          ),
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