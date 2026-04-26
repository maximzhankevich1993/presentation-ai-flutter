import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
          tabs: const [
            Tab(text: 'Фон'),
            Tab(text: 'Шрифты'),
            Tab(text: 'Приложение'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBackgroundTab(),
          _buildFontsTab(),
          _buildAppTab(),
        ],
      ),
    );
  }

  Widget _buildBackgroundTab() {
    final userProvider = Provider.of<UserProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Цвета фона', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        _buildColorGrid(userProvider),
        SizedBox(height: 32.h),
        Text('Градиенты', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        _buildGradientGrid(userProvider),
        SizedBox(height: 32.h),
        Text('Текстуры', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        _buildTextureGrid(userProvider),
      ]),
    );
  }

  Widget _buildColorGrid(UserProvider userProvider) {
    final colors = [
      {'name': 'Белый', 'value': 0xFFFFFFFF, 'free': true},
      {'name': 'Светло-серый', 'value': 0xFFF5F5F5, 'free': true},
      {'name': 'Тёмно-серый', 'value': 0xFF2A2A2A, 'free': true},
      {'name': 'Тёмно-синий', 'value': 0xFF1A1A2E, 'free': false},
      {'name': 'Кремовый', 'value': 0xFFFFF8E7, 'free': false},
      {'name': 'Мятный', 'value': 0xFFE8F5E9, 'free': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, crossAxisSpacing: 12.w, mainAxisSpacing: 12.h),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        final isAvailable = (color['free'] as bool) || userProvider.isPremium;
        
        return GestureDetector(
          onTap: isAvailable ? () => _selectBackground(color['value'] as int) : () => _showPremiumNudge(),
          child: Container(
            decoration: BoxDecoration(color: Color(color['value'] as int), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
            child: !isAvailable ? Center(child: Icon(Icons.lock, size: 18, color: Colors.amber[700])) : null,
          ),
        );
      },
    );
  }

  Widget _buildGradientGrid(UserProvider userProvider) {
    final gradients = [
      {'name': 'Простой', 'colors': [0xFF4F46E5, 0xFF7C3AED], 'free': true},
      {'name': 'Северное сияние', 'colors': [0xFF1BFFFF, 0xFF2E3192], 'free': false},
      {'name': 'Персиковый', 'colors': [0xFFFFD6A5, 0xFFFF9B82], 'free': false},
      {'name': 'Мохито', 'colors': [0xFF11998E, 0xFF38EF7D], 'free': false},
    ];

    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5, crossAxisSpacing: 12.w, mainAxisSpacing: 12.h),
      itemCount: gradients.length,
      itemBuilder: (context, index) {
        final g = gradients[index];
        final isAvailable = (g['free'] as bool) || userProvider.isPremium;
        final gColors = (g['colors'] as List).map((c) => Color(c as int)).toList();
        
        return GestureDetector(
          onTap: isAvailable ? () => _selectGradient(g['name'] as String) : () => _showPremiumNudge(),
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: gColors), borderRadius: BorderRadius.circular(12)),
            child: Stack(children: [
              if (!isAvailable) Positioned(top: 8, right: 8, child: Icon(Icons.lock, size: 16, color: Colors.white.withOpacity(0.8))),
              Positioned(bottom: 8, left: 8, child: Text(g['name'] as String, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600))),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildTextureGrid(UserProvider userProvider) {
    final textures = [
      {'name': 'Крафт', 'icon': '🧻', 'free': true},
      {'name': 'Мрамор', 'icon': '🪨', 'free': false},
      {'name': 'Акварель', 'icon': '🎨', 'free': false},
    ];

    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 1, crossAxisSpacing: 8.w, mainAxisSpacing: 8.h),
      itemCount: textures.length,
      itemBuilder: (context, index) {
        final t = textures[index];
        final isAvailable = (t['free'] as bool) || userProvider.isPremium;
        
        return GestureDetector(
          onTap: isAvailable ? () => _selectTexture(t['name'] as String) : () => _showPremiumNudge(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
            child: Stack(children: [
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t['icon'] as String, style: TextStyle(fontSize: 28.sp)), SizedBox(height: 4.h), Text(t['name'] as String, style: TextStyle(fontSize: 10.sp))])),
              if (!isAvailable) Positioned(top: 4, right: 4, child: Icon(Icons.lock, size: 12, color: Colors.amber[700])),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildFontsTab() {
    final userProvider = Provider.of<UserProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Шрифтовые пары', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Text('Выбери сочетание шрифтов', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        SizedBox(height: 24.h),
        _buildFontOption(name: 'Modern Tech', fontFamily: 'Poppins', isFree: true, isPremium: userProvider.isPremium),
        _buildFontOption(name: 'Clean Swiss', fontFamily: 'Inter', isFree: true, isPremium: userProvider.isPremium),
        _buildFontOption(name: 'Classic Elegance', fontFamily: 'Georgia', isFree: false, isPremium: userProvider.isPremium),
        _buildFontOption(name: 'Playful Hand', fontFamily: 'Caveat', isFree: false, isPremium: userProvider.isPremium),
      ]),
    );
  }

  Widget _buildFontOption({required String name, required String fontFamily, required bool isFree, required bool isPremium}) {
    final isAvailable = isFree || isPremium;
    
    return GestureDetector(
      onTap: isAvailable ? () => _selectFont(name) : () => _showPremiumNudge(),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h), padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontFamily: fontFamily, fontSize: 18.sp, fontWeight: FontWeight.bold)), SizedBox(height: 4.h), Text('Пример текста', style: TextStyle(fontFamily: fontFamily, fontSize: 14.sp, color: Colors.grey[600]))])),
          if (!isAvailable) Icon(Icons.lock, color: Colors.amber[700]) else const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildAppTab() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Тема оформления', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        ListTile(leading: const Icon(Icons.brightness_4), title: const Text('Системная'), trailing: themeProvider.themeModeType == ThemeModeType.system ? const Icon(Icons.check, color: Color(0xFF4F46E5)) : null, onTap: () => themeProvider.setThemeMode(ThemeModeType.system)),
        ListTile(leading: const Icon(Icons.light_mode), title: const Text('Светлая'), trailing: themeProvider.themeModeType == ThemeModeType.light ? const Icon(Icons.check, color: Color(0xFF4F46E5)) : null, onTap: () => themeProvider.setThemeMode(ThemeModeType.light)),
        ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Тёмная'), trailing: themeProvider.themeModeType == ThemeModeType.dark ? const Icon(Icons.check, color: Color(0xFF4F46E5)) : null, onTap: () => themeProvider.setThemeMode(ThemeModeType.dark)),
        SizedBox(height: 32.h),
        if (!userProvider.isPremium)
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFF59E0B).withOpacity(0.1), const Color(0xFFD97706).withOpacity(0.05)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3))),
            child: Row(children: [
              Container(width: 48.w, height: 48.w, decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.crown, color: Color(0xFFF59E0B))),
              SizedBox(width: 16.w),
              Expanded(child: Text('Разблокируй все настройки с Premium', style: TextStyle(fontSize: 14.sp))),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)), child: const Text('Premium')),
            ]),
          ),
        SizedBox(height: 32.h),
        Text('Информация', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        ListTile(leading: const Icon(Icons.info_outline), title: const Text('Версия приложения'), subtitle: const Text('1.0.0')),
        ListTile(leading: const Icon(Icons.mail_outline), title: const Text('Связаться с нами'), subtitle: const Text('support@presentation-ai.com')),
      ]),
    );
  }

  void _selectBackground(int colorValue) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Фон выбран'), duration: Duration(seconds: 1)));
  void _selectGradient(String name) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Градиент "$name" выбран'), duration: const Duration(seconds: 1)));
  void _selectTexture(String name) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Текстура "$name" выбрана'), duration: const Duration(seconds: 1)));
  void _selectFont(String name) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Шрифт "$name" выбран'), duration: const Duration(seconds: 1)));

  void _showPremiumNudge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.crown, color: Colors.amber[700]), SizedBox(width: 8.w), const Text('Premium')]),
        content: const Text('Эта возможность доступна в Premium версии.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже')),
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)), child: const Text('Оформить Premium')),
        ],
      ),
    );
  }
}