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
import '../services/surprise_service.dart';

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
    if (!userProvider.canGenerate) { _showPremiumDialog(); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingScreen(topic: topic)));
  }

  void _showPremiumDialog() => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
  void _showSettingsScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  void _showProfileScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  void _showHistoryScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
  void _showFeaturesScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeaturesScreen()));
  void _showWorkspaceScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkspaceScreen()));
  void _showTeacherScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherScreen(countryCode: 'RU')));
  void _showCorporateScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const CorporateScreen(countryCode: 'RU')));
  void _showReferralScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
  void _showVipScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => const VipScreen()));

  void _surpriseMe(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.canUseSurpriseMe) { _showPremiumDialog(); return; }
    await SurpriseService.useSurprise(context);
    final style = SurpriseService.generateRandomStyle();
    if (mounted) {
      SurpriseService.showSurpriseAnimation(context, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Применён стиль: ${style.themeName} 🎉'), backgroundColor: style.primaryColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Презентатор ИИ'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showVipScreen, icon: const Icon(Icons.diamond), tooltip: 'VIP-доступ'),
          IconButton(onPressed: _showFeaturesScreen, icon: const Icon(Icons.stars), tooltip: 'Все возможности'),
          IconButton(onPressed: _showWorkspaceScreen, icon: const Icon(Icons.workspaces_outline), tooltip: 'Команда'),
          IconButton(onPressed: _showTeacherScreen, icon: const Icon(Icons.school), tooltip: 'Учителям'),
          IconButton(onPressed: _showCorporateScreen, icon: const Icon(Icons.business), tooltip: 'Бизнесу'),
          IconButton(onPressed: _showReferralScreen, icon: const Icon(Icons.card_giftcard), tooltip: 'Приведи друга'),
          if (!userProvider.isPremium) IconButton(onPressed: _showPremiumDialog, icon: Icon(Icons.crown, color: Colors.amber[700])),
          IconButton(onPressed: _showHistoryScreen, icon: const Icon(Icons.history)),
          IconButton(onPressed: _showProfileScreen, icon: const Icon(Icons.person_outline)),
          IconButton(onPressed: _showSettingsScreen, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Создай презентацию', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('с помощью Искусственного Интеллекта', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
            SizedBox(height: 24.h),
            _buildGenerationCounter(userProvider),
            SizedBox(height: 32.h),
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))]),
                    child: Row(children: [
                      Expanded(child: TextField(controller: _topicController, enabled: !_isLoading, decoration: InputDecoration(hintText: 'Введи тему презентации...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h)), onSubmitted: (_) => _generatePresentation())),
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Material(color: Colors.transparent, child: InkWell(
                          onTap: _isLoading ? null : _generatePresentation, borderRadius: BorderRadius.circular(30),
                          child: Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]), shape: BoxShape.circle), child: _isLoading ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.auto_awesome, color: Colors.white, size: 24.w)),
                        )),
                      ),
                      SizedBox(width: 8.w),
                    ]),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(height: 40.h, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _examples.length, separatorBuilder: (_, __) => SizedBox(width: 8.w), itemBuilder: (context, index) => ActionChip(label: Text(_examples[index]), onPressed: _isLoading ? null : () { _topicController.text = _examples[index].substring(2); }))),
                  SizedBox(height: 16.h),
                  Center(child: TextButton.icon(onPressed: () => _surpriseMe(context), icon: const Text('🎲', style: TextStyle(fontSize: 20)), label: Text('Удиви меня', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF7C3AED))))),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildGenerationCounter(UserProvider userProvider) {
    if (userProvider.isPremium) {
      return Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.crown, color: Colors.amber, size: 24), SizedBox(width: 12), Text('Premium активен', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), Spacer(), Text('∞', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))]));
    }
    final left = userProvider.freeGenerationsLeft;
    final progress = left / 5.0;
    return Container(padding: EdgeInsets.all(20.w), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Осталось генераций', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])), Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('$left из 5', style: const TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.bold)))]),
      SizedBox(height: 12.h),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), minHeight: 8)),
    ]));
  }
}