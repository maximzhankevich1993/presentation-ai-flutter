import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'editor_screen.dart';
import 'premium_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String topic;
  final int slideCount;

  const LoadingScreen({
    super.key,
    required this.topic,
    required this.slideCount,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _status = 'Создаю презентацию...';
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  final List<String> _statusMessages = [
    'Анализирую тему...',
    'Генерирую структуру...',
    'Создаю слайды...',
    'Подбираю оформление...',
    'Почти готово...',
  ];

  @override
  void initState() {
    super.initState();
    _startGeneration();
    _startProgressAnimation();
  }

  void _startProgressAnimation() {
    int step = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && step < _statusMessages.length) {
        setState(() {
          _status = _statusMessages[step];
          _progress = (step + 1) / _statusMessages.length;
        });
        step++;
        return true;
      }
      return false;
    });
  }

  Future<void> _startGeneration() async {
    try {
      final presentation = await ApiService.generate(
        topic: widget.topic,
        slideCount: widget.slideCount,
      );
      
      if (!mounted) return;
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUser();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: presentation),
        ),
      );
    } on LimitReachedException catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 24),
            SizedBox(width: 8),
            Text('Лимит генераций исчерпан', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'У вас закончились бесплатные генерации на этот месяц.\n\nОформите подписку, чтобы продолжить создавать презентации без ограничений.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('На главную', style: TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showLimitDialog();
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1DB954)),
              SizedBox(height: 20),
              Text('Завершаем...', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 250,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  color: const Color(0xFF1DB954),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Это может занять до 30 секунд',
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}