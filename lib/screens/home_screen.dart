import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';

import 'loading_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'features_screen.dart';
import 'workspace_screen.dart';
import 'teacher_screen.dart';
import 'corporate_screen.dart';
import 'referral_screen.dart';
import 'vip_screen.dart';
import 'login_screen.dart';

import '../services/surprise_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  bool _isLoading = false;

  final List<String> _examples = const [
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
    if (topic.isEmpty || _isLoading) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.canGenerate) {
      _showPremiumDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoadingScreen(topic: topic),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPremiumDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  void _showScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _surpriseMe(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.canUseSurpriseMe) {
      _showPremiumDialog();
      return;
    }

    await userProvider.useSurpriseMe();

    final style = SurpriseService.generateRandomStyle();

    if (!mounted) return;

    SurpriseService.showSurpriseAnimation(context, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Применён стиль: ${style.themeName} 🎉'),
          backgroundColor: style.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Презентатор ИИ'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => _showScreen(const LoginScreen()), icon: const Icon(Icons.login)),
          IconButton(onPressed: () => _showScreen(const VipScreen()), icon: const Icon(Icons.diamond)),
          IconButton(onPressed: () => _showScreen(const FeaturesScreen()), icon: const Icon(Icons.stars)),
          IconButton(onPressed: _showWorkspaceScreen, icon: const Icon(Icons.workspace_outlined)),
          IconButton(onPressed: () => _showScreen(const TeacherScreen(countryCode: 'RU')), icon: const Icon(Icons.school)),
          IconButton(onPressed: () => _showScreen(const CorporateScreen(countryCode: 'RU')), icon: const Icon(Icons.business)),
          IconButton(onPressed: () => _showScreen(const ReferralScreen()), icon: const Icon(Icons.card_giftcard)),
          if (!userProvider.isPremium)
            IconButton(
              onPressed: _showPremiumDialog,
              icon: Icon(Icons.star, color: Colors.amber[700]),
            ),
          IconButton(onPressed: () => _showScreen(const HistoryScreen()), icon: const Icon(Icons.history)),
          IconButton(onPressed: () => _showScreen(const ProfileScreen()), icon: const Icon(Icons.person_outline)),
          IconButton(onPressed: () => _showScreen(const SettingsScreen()), icon: const Icon(Icons.settings_outlined)),
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
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'с помощью Искусственного Интеллекта',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 24.h),

              _buildGenerationCounter(userProvider),

              SizedBox(height: 32.h),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInputField(),
                    SizedBox(height: 20.h),
                    _buildExamples(),
                    SizedBox(height: 16.h),
                    _buildSurpriseButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _topicController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                hintText: 'Введи тему презентации...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
              onSubmitted: (_) => _generatePresentation(),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _generatePresentation,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _examples.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(_examples[index]),
            onPressed: _isLoading
                ? null
                : () {
                    _topicController.text = _examples[index].substring(2);
                  },
          );
        },
      ),
    );
  }

  Widget _buildSurpriseButton() {
    return TextButton.icon(
      onPressed: () => _surpriseMe(context),
      icon: const Text('🎲'),
      label: Text(
        'Удиви меня',
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Widget _buildGenerationCounter(UserProvider userProvider) {
    if (userProvider.isPremium) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 12),
            Text(
              'Premium активен',
              style: TextStyle(color: Colors.white),
            ),
            Spacer(),
            Text('∞', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    final left = userProvider.freeGenerationsLeft / 5;

    return Column(
      children: [
        LinearProgressIndicator(value: left),
        SizedBox(height: 8.h),
        Text('Осталось генераций: ${userProvider.freeGenerationsLeft}'),
      ],
    );
  }
}