import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _topicController = TextEditingController();
  bool _isLoading = false;
  
  final List<String> _examples = [
    '🤖 Искусственный интеллект',
    '📈 Бизнес-план для стартапа',
    '🌍 Глобальное потепление',
    '🚀 Будущее космонавтики',
    '📱 Тренды мобильной разработки',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generatePresentation() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.canGenerate) {
      _showPremiumDialog();
      return;
    }
    
    // Переходим на экран загрузки
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(topic: topic),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.crown, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('Premium'),
          ],
        ),
        content: const Text(
          'Бесплатные генерации закончились.\n\n'
          'Оформи Premium и получи:\n'
          '• Безлимитные презентации\n'
          '• До 50 слайдов\n'
          '• Все фоны и шрифты\n'
          '• Экспорт без водяного знака'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('299 ₽ / месяц'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Скоро'),
        content: const Text('Premium подписка будет доступна в ближайшее время!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Тема оформления',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.brightness_4),
                title: const Text('Системная'),
                trailing: themeProvider.themeModeType == ThemeModeType.system
                    ? const Icon(Icons.check, color: Color(0xFF4F46E5))
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeModeType.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Светлая'),
                trailing: themeProvider.themeModeType == ThemeModeType.light
                    ? const Icon(Icons.check, color: Color(0xFF4F46E5))
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeModeType.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Тёмная'),
                trailing: themeProvider.themeModeType == ThemeModeType.dark
                    ? const Icon(Icons.check, color: Color(0xFF4F46E5))
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeModeType.dark);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Презентатор ИИ'),
        centerTitle: true,
        actions: [
          if (!userProvider.isPremium)
            IconButton(
              onPressed: _showPremiumDialog,
              icon: Icon(Icons.crown, color: Colors.amber[700]),
            ),
          IconButton(
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Создай презентацию',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'с помощью Искусственного Интеллекта',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Счётчик генераций
              _buildGenerationCounter(userProvider),
              
              SizedBox(height: 32.h),
              
              // Поле ввода
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _topicController,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  hintText: 'Введи тему презентации...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 20.h,
                                  ),
                                ),
                                onSubmitted: (_) => _generatePresentation(),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoading ? null : _generatePresentation,
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 24.w,
                                            height: 24.w,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 24.w,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Примеры
                      SizedBox(
                        height: 40.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _examples.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            return ActionChip(
                              label: Text(_examples[index]),
                              onPressed: _isLoading ? null : () {
                                final text = _examples[index].substring(2);
                                _topicController.text = text;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationCounter(UserProvider userProvider) {
    if (userProvider.isPremium) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.crown, color: Colors.amber, size: 24),
            SizedBox(width: 12),
            Text(
              'Premium активен',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Spacer(),
            Text('∞', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final left = userProvider.freeGenerationsLeft;
    final progress = left / 5.0;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Осталось генераций', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$left из 5',
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}