import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'editor_screen.dart';

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
  String _status = 'Подготовка...';
  int _currentSlide = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generatePresentation();
  }

  Future<void> _generatePresentation() async {
    try {
      setState(() {
        _status = 'Генерация слайда 1 из ${widget.slideCount}';
        _currentSlide = 1;
      });

      final response = await ApiService.generate(
        topic: widget.topic,
        slideCount: widget.slideCount,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _currentSlide = current;
              _status = 'Генерация слайда $current из $total';
            });
          }
        },
      );

      if (!mounted) return;

      // Переход в редактор
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: response),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Анимированный логотип
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 32),

              // Тема
              Text(
                'Создаём презентацию',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${widget.topic}"',
                style: const TextStyle(
                  color: Color(0xFF9A9A9A),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Статус
              if (!_hasError) ...[
                Text(
                  _status,
                  style: const TextStyle(
                    color: Color(0xFF1DB954),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Прогресс-бар
                LinearProgressIndicator(
                  value: _currentSlide / widget.slideCount,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                ),
                const SizedBox(height: 12),

                // Процент
                Text(
                  '${((_currentSlide / widget.slideCount) * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 12,
                  ),
                ),
              ],

              // Ошибка
              if (_hasError) ...[
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF3B30),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка генерации',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: const Text(
                        'Попробовать снова',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}