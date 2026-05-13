import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  bool _quizStarted = false;
  bool _quizFinished = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Сколько слайдов можно создать в бесплатной версии?',
      'options': ['5 слайдов', '10 слайдов', '15 слайдов', '20 слайдов'],
      'correct': 1,
    },
    {
      'question': 'Какая функция доступна только в Premium?',
      'options': ['ИИ-генерация', 'Загрузка логотипа', 'Выбор темы', 'Слайдер количества'],
      'correct': 1,
    },
    {
      'question': 'Какой ИИ используется для генерации презентаций?',
      'options': ['ChatGPT', 'YandexGPT', 'Google Bard', 'Claude AI'],
      'correct': 1,
    },
    {
      'question': 'Сколько бесплатных фонов доступно?',
      'options': ['4', '6', '8', '10'],
      'correct': 2,
    },
    {
      'question': 'Какой максимальный слайд-лимит в бесплатной версии?',
      'options': ['5 слайдов', '10 слайдов', '15 слайдов', '20 слайдов'],
      'correct': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Тесты',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFF1DB954),
                  strokeWidth: 2.5,
                ),
              ),
            )
          : !_quizStarted
              ? _buildStartScreen()
              : !_quizFinished
                  ? _buildQuizScreen()
                  : _buildResultScreen(),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Проверь свои знания',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Тест из 5 вопросов о возможностях\nПрезентатор ИИ',
              style: TextStyle(
                color: Color(0xFF9A9A9A),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(
                    icon: Icons.question_answer_rounded,
                    label: '5 вопросов',
                  ),
                  _buildInfoChip(
                    icon: Icons.timer_rounded,
                    label: '~2 минуты',
                  ),
                  _buildInfoChip(
                    icon: Icons.bolt_rounded,
                    label: 'Проверка знаний',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _quizStarted = true;
                    _currentQuestionIndex = 0;
                    _score = 0;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Начать тест',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestionIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Вопрос ${_currentQuestionIndex + 1} из ${_questions.length}',
                      style: const TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Счёт: $_score',
                      style: const TextStyle(
                        color: Color(0xFF1DB954),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1DB954).withOpacity(0.1),
                  const Color(0xFF1ED760).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.2)),
            ),
            child: Text(
              question['question'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          const Text(
            'ВЫБЕРИТЕ ОТВЕТ',
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(question['options'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildOptionCard(
                text: question['options'][index],
                onTap: () => _answerQuestion(index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String text,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.circle_outlined,
                  color: Color(0xFF9A9A9A),
                  size: 12,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length) * 100;
    String message;
    String advice;
    
    if (percentage >= 80) {
      message = 'Отлично! 🎉';
      advice = 'Ты отлично знаешь возможности Презентатор ИИ!';
    } else if (percentage >= 60) {
      message = 'Хорошо! 👍';
      advice = 'Неплохой результат, но есть куда расти!';
    } else {
      message = 'Попробуй ещё! 💪';
      advice = 'Познакомься с платформой поближе и попробуй снова.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: const TextStyle(
              color: Color(0xFF9A9A9A),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Правильных ответов:',
                      style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                    ),
                    Text(
                      '$_score / ${_questions.length}',
                      style: const TextStyle(
                        color: Color(0xFF1DB954),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _score / _questions.length,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _quizStarted = false;
                        _quizFinished = false;
                        _currentQuestionIndex = 0;
                        _score = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: const Center(
                        child: Text(
                          'Пройти снова',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'На главную',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _answerQuestion(int selectedIndex) {
    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question['correct'];
    
    if (isCorrect) {
      setState(() {
        _score++;
      });
      _showSnackBar('Правильно! 🎉', true);
    } else {
      final correctAnswer = question['options'][question['correct']];
      _showSnackBar('Неправильно! Правильный ответ: $correctAnswer', false);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          if (_currentQuestionIndex + 1 < _questions.length) {
            _currentQuestionIndex++;
          } else {
            _quizFinished = true;
          }
        });
      }
    });
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF1DB954) : const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1DB954), size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9A9A9A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}