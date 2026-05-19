import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../models/presentation.dart';
import 'teacher_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Вкладка "По презентации"
  List<Presentation> _userPresentations = [];
  Presentation? _selectedPresentation;
  bool _loadingPresentations = false;
  
  // Вкладка "По теме"
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _textbookController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController(text: '9');
  final TextEditingController _questionCountController = TextEditingController(text: '5');
  
  // Общее
  bool _isLoading = false;
  bool _showQuiz = false;
  bool _showAnswers = false;
  
  Quiz? _currentQuiz;
  Map<int, int?> _userAnswers = {};
  int _score = 0;
  int _usedGenerations = 0;
  final int _maxGenerations = 5;
  
  int _currentQuestionIndex = 0;
  bool _quizFinished = false;
  
  String _countryCode = 'RU';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGenerationCount();
    _loadUserPresentations();
    _detectCountry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    _textbookController.dispose();
    _gradeController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  Future<void> _detectCountry() async {
    try {
      final response = await http.get(Uri.parse('https://ipwho.is/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _countryCode = data['country_code'] ?? 'RU';
        });
      }
    } catch (e) {
      print('Error detecting country: $e');
    }
  }

  Future<void> _loadGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usedGenerations = prefs.getInt('quiz_generations') ?? 0;
    });
  }

  Future<void> _saveGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_generations', _usedGenerations);
  }

  Future<void> _loadUserPresentations() async {
    setState(() => _loadingPresentations = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      // TODO: Загрузить презентации пользователя из API
      // final presentations = await ApiService.getUserPresentations(token);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _userPresentations = [
          Presentation(id: '1', title: 'Вторая мировая война', slides: [], createdAt: DateTime.now()),
          Presentation(id: '2', title: 'Квадратные уравнения', slides: [], createdAt: DateTime.now()),
          Presentation(id: '3', title: 'Падежи русского языка', slides: [], createdAt: DateTime.now()),
        ];
        _loadingPresentations = false;
      });
    } catch (e) {
      setState(() => _loadingPresentations = false);
      _showError('Ошибка загрузки презентаций: $e');
    }
  }

  Future<void> _generateQuizFromPresentation() async {
    if (_selectedPresentation == null) {
      _showError('Выберите презентацию');
      return;
    }
    
    if (_usedGenerations >= _maxGenerations) {
      _showLimitDialog();
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      
      final slideContents = _selectedPresentation!.slides.map((s) => 
        s.title + ' ' + s.content.join(' ')
      ).toList();
      
      final quiz = await QuizService.generateFromPresentation(
        presentationTitle: _selectedPresentation!.title,
        slideContents: slideContents,
        token: token,
        questionCount: 5,
      );
      
      setState(() {
        _currentQuiz = quiz;
        _showQuiz = true;
        _showAnswers = false;
        _quizFinished = false;
        _currentQuestionIndex = 0;
        _userAnswers.clear();
        _score = 0;
        _usedGenerations++;
      });
      
      await _saveGenerationCount();
      
    } catch (e) {
      _showError('Ошибка генерации теста: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateQuizFromTopic() async {
    final topic = _topicController.text.trim();
    final textbook = _textbookController.text.trim();
    final grade = _gradeController.text.trim();
    final questionCount = int.tryParse(_questionCountController.text.trim()) ?? 5;
    
    if (topic.isEmpty) {
      _showError('Введите тему теста');
      return;
    }
    
    if (questionCount < 3 || questionCount > 10) {
      _showError('Количество вопросов от 3 до 10');
      return;
    }
    
    if (_usedGenerations >= _maxGenerations) {
      _showLimitDialog();
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      
      final quiz = await QuizService.generateFromTopic(
        topic: topic,
        textbook: textbook.isNotEmpty ? textbook : null,
        grade: grade,
        token: token,
        questionCount: questionCount,
        countryCode: _countryCode,
      );
      
      setState(() {
        _currentQuiz = quiz;
        _showQuiz = true;
        _showAnswers = false;
        _quizFinished = false;
        _currentQuestionIndex = 0;
        _userAnswers.clear();
        _score = 0;
        _usedGenerations++;
      });
      
      await _saveGenerationCount();
      
    } catch (e) {
      _showError('Ошибка генерации теста: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Лимит исчерпан', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы использовали все 5 бесплатных генераций тестов.\n\nПриобретите тариф "Учитель" для безлимитного доступа.',
          style: TextStyle(color: Color(0xFF9A9A9A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeacherScreen(countryCode: 'RU')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
    );
  }
  
  void _answerQuestion(int selectedIndex) {
    final question = _currentQuiz!.questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question.correctIndex;
    
    setState(() {
      _userAnswers[_currentQuestionIndex] = selectedIndex;
      if (isCorrect) _score++;
    });
    
    _showSnackBar(
      isCorrect ? 'Правильно! 🎉' : 'Неправильно! Правильный ответ: ${question.options[question.correctIndex]}',
      isCorrect,
    );
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          if (_currentQuestionIndex + 1 < _currentQuiz!.questions.length) {
            _currentQuestionIndex++;
          } else {
            _quizFinished = true;
          }
        });
      }
    });
  }
  
  void _exportToWord() {
    if (_currentQuiz == null) return;
    
    final content = QuizService.exportToWord(_currentQuiz!, includeAnswers: true);
    
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>${_currentQuiz!.title}</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.5; }
        h1 { color: #1DB954; }
        .question { margin-bottom: 30px; }
        .question-text { font-weight: bold; margin-bottom: 10px; }
        .options { margin-left: 20px; margin-bottom: 10px; }
        hr { margin: 20px 0; }
        .answer-key { margin-top: 30px; padding-top: 20px; border-top: 2px solid #1DB954; }
      </style>
    </head>
    <body>
      <pre style="white-space: pre-wrap; font-family: Arial, sans-serif;">$content</pre>
    </body>
    </html>
    ''';
    
    final blob = html.Blob([htmlContent], 'application/msword');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '${_currentQuiz!.title}.doc')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    _showSnackBar('Тест сохранён в Word', true);
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF1DB954) : const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxGenerations - _usedGenerations;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Генератор тестов', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1DB954),
          labelColor: const Color(0xFF1DB954),
          unselectedLabelColor: const Color(0xFF9A9A9A),
          tabs: const [
            Tab(icon: Icon(Icons.slideshow_rounded), text: 'Из презентации'),
            Tab(icon: Icon(Icons.topic_rounded), text: 'По теме'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _showQuiz
              ? (!_quizFinished ? _buildQuizScreen() : _buildResultScreen())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPresentationTab(remaining),
                    _buildTopicTab(remaining),
                  ],
                ),
    );
  }
  
  Widget _buildPresentationTab(int remaining) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Тест из презентации', 'Создайте тест по вашей презентации', Icons.slideshow_rounded),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _buildCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ВЫБЕРИТЕ ПРЕЗЕНТАЦИЮ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _loadingPresentations
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
                    : DropdownButtonFormField<Presentation>(
                        value: _selectedPresentation,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                        ),
                        items: _userPresentations.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.title, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedPresentation = value),
                        hint: const Text('Выберите презентацию', style: TextStyle(color: Color(0xFF9A9A9A))),
                      ),
                const SizedBox(height: 20),
                _buildRemainingInfo(remaining),
                const SizedBox(height: 20),
                _buildGenerateButton('Сгенерировать тест', _generateQuizFromPresentation),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopicTab(int remaining) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Тест по теме', 'Создайте тест по любой теме', Icons.topic_rounded),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _buildCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ТЕМА ТЕСТА', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _topicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Например: Вторая мировая война',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.topic_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text('УЧЕБНИК (ОПЦИОНАЛЬНО)', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _textbookController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Название учебника',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.menu_book_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text('КЛАСС', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _gradeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '9',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.school_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text('КОЛИЧЕСТВО ВОПРОСОВ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionCountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '5 (3-10)',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 20),
                _buildRemainingInfo(remaining),
                const SizedBox(height: 20),
                _buildGenerateButton('Сгенерировать тест', _generateQuizFromTopic),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
        ],
      ),
    );
  }
  
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF2A2A2A)),
    );
  }
  
  Widget _buildRemainingInfo(int remaining) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF1DB954), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Осталось $remaining из $_maxGenerations бесплатных генераций',
              style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGenerateButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1DB954),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
  
  Widget _buildQuizScreen() {
    final question = _currentQuiz!.questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Вопрос ${_currentQuestionIndex + 1} из ${_currentQuiz!.questions.length}', 
                        style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                    Text('Счёт: $_score', 
                        style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _currentQuiz!.questions.length,
                  backgroundColor: const Color(0xFF2A2A2A),
                  color: const Color(0xFF1DB954),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.2)),
            ),
            child: Text(question.question, 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          
          const Text('ВЫБЕРИТЕ ОТВЕТ', 
              style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: ListTile(
                  onTap: () => _answerQuestion(index),
                  leading: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.circle_outlined, color: Color(0xFF9A9A9A), size: 14),
                  ),
                  title: Text(question.options[index], 
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildResultScreen() {
    final percentage = (_score / _currentQuiz!.questions.length) * 100;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text('${percentage.toInt()}%', 
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            percentage >= 80 ? 'Отлично! 🎉' : (percentage >= 60 ? 'Хорошо! 👍' : 'Попробуй ещё! 💪'),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _buildCardDecoration(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Правильных ответов:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14)),
                    Text('$_score / ${_currentQuiz!.questions.length}', 
                        style: const TextStyle(color: Color(0xFF1DB954), fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _score / _currentQuiz!.questions.length,
                  backgroundColor: const Color(0xFF2A2A2A),
                  color: const Color(0xFF1DB954),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          if (_showAnswers) ...[
            const Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', 
                style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._currentQuiz!.questions.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              final correctLetter = String.fromCharCode(65 + q.correctIndex);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${q.question}', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('✓ $correctLetter. ${q.options[q.correctIndex]}', 
                        style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('📝 ${q.explanation}', 
                        style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
                  ],
                ),
              );
            }),
          ],
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showAnswers = !_showAnswers),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_showAnswers ? 'Скрыть ответы' : 'Показать ответы', 
                      style: const TextStyle(color: Color(0xFF1DB954))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _exportToWord,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('📄 Word', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showQuiz = false;
                      _quizFinished = false;
                      _currentQuestionIndex = 0;
                      _score = 0;
                      _userAnswers.clear();
                      _currentQuiz = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Новый тест', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('На главную', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}