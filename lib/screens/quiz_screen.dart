import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/generation_counter.dart';
import 'teacher_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _questionCountController = TextEditingController(text: '5');
  
  bool _isLoading = false;
  bool _showQuiz = false;
  bool _showAnswers = false;
  String _countryCode = 'RU';
  String _currency = 'RUB';
  String _currencySymbol = '₽';
  double _rate = 95.0;
  
  List<Map<String, dynamic>> _questions = [];
  Map<int, String?> _userAnswers = {};
  int _score = 0;
  int _usedGenerations = 0;
  final int _maxGenerations = 5;
  
  String _currentTestTopic = '';
  int _currentQuestionIndex = 0;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _detectCountry();
    _loadGenerationCount();
  }

  Future<void> _detectCountry() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['country_code'] ?? 'RU';
        
        setState(() {
          _countryCode = countryCode;
          if (countryCode == 'BY') {
            _currency = 'BYN'; _currencySymbol = 'Br'; _rate = 3.25;
          } else if (countryCode == 'RU') {
            _currency = 'RUB'; _currencySymbol = '₽'; _rate = 95.0;
          } else if (countryCode == 'KZ') {
            _currency = 'KZT'; _currencySymbol = '₸'; _rate = 460.0;
          } else {
            _currency = 'USD'; _currencySymbol = '\$'; _rate = 1.0;
          }
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

  Future<void> _generateQuiz() async {
    final topic = _topicController.text.trim();
    final questionCount = int.tryParse(_questionCountController.text.trim()) ?? 5;
    
    if (topic.isEmpty) {
      _showError('Введите тему теста');
      return;
    }
    
    if (questionCount < 3 || questionCount > 10) {
      _showError('Количество вопросов от 3 до 10');
      return;
    }
    
    // Проверка лимита
    if (_usedGenerations >= _maxGenerations) {
      _showLimitDialog();
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final prompt = _buildPrompt(topic, questionCount);
      
      // TODO: Заменить на реальный API запрос к YandexGPT
      await Future.delayed(const Duration(seconds: 2));
      
      // Демо-данные для теста
      final demoQuestions = _generateDemoQuestions(topic, questionCount);
      
      setState(() {
        _questions = demoQuestions;
        _currentTestTopic = topic;
        _showQuiz = true;
        _showAnswers = false;
        _quizFinished = false;
        _currentQuestionIndex = 0;
        _userAnswers.clear();
        _score = 0;
        _usedGenerations++;
      });
      
      _saveGenerationCount();
      
    } catch (e) {
      _showError('Ошибка генерации теста: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  String _buildPrompt(String topic, int questionCount) {
    return '''
Ты — эксперт по педагогике. Создай тест по теме "${topic}" для учащихся.

Параметры:
- Количество вопросов: $questionCount
- Страна: ${_getCountryName()}
- Язык: русский

Для каждого вопроса:
- Вопрос
- 4 варианта ответа
- Номер правильного ответа (0-3)
- Краткое пояснение

Верни ТОЛЬКО JSON в формате:
{
  "questions": [
    {
      "question": "текст вопроса",
      "options": ["вариант 1", "вариант 2", "вариант 3", "вариант 4"],
      "correct": 0,
      "explanation": "пояснение"
    }
  ]
}
''';
  }
  
  String _getCountryName() {
    switch (_countryCode) {
      case 'RU': return 'Россия';
      case 'BY': return 'Беларусь';
      case 'KZ': return 'Казахстан';
      default: return 'международный';
    }
  }
  
  List<Map<String, dynamic>> _generateDemoQuestions(String topic, int count) {
    List<Map<String, dynamic>> questions = [];
    for (int i = 0; i < count; i++) {
      questions.add({
        'question': 'Вопрос ${i + 1} по теме "$topic"?',
        'options': ['Вариант А', 'Вариант Б', 'Вариант В', 'Вариант Г'],
        'correct': i % 4,
        'explanation': 'Это пояснение к вопросу ${i + 1}. Правильный ответ — вариант ${String.fromCharCode(65 + (i % 4))}.',
      });
    }
    return questions;
  }
  
  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Лимит исчерпан', style: TextStyle(color: Colors.white)),
        content: Text(
          'Вы использовали все $_maxGenerations бесплатных генераций тестов.\n\nПриобретите тариф "Учитель" для безлимитного доступа.',
          style: const TextStyle(color: Color(0xFF9A9A9A)),
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
    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question['correct'];
    
    setState(() {
      _userAnswers[_currentQuestionIndex] = question['options'][selectedIndex];
      if (isCorrect) _score++;
    });
    
    _showSnackBar(
      isCorrect ? 'Правильно! 🎉' : 'Неправильно! Правильный ответ: ${question['options'][question['correct']]}',
      isCorrect,
    );
    
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
  
  void _exportToWord() {
    // Генерация HTML для Word
    String html = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>${_currentTestTopic} - Тест</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #1DB954; }
        .question { margin-bottom: 30px; }
        .question-text { font-weight: bold; margin-bottom: 10px; }
        .options { margin-left: 20px; margin-bottom: 10px; }
        .correct { color: green; }
        .explanation { color: #666; margin-top: 10px; font-style: italic; }
        hr { margin: 20px 0; }
      </style>
    </head>
    <body>
      <h1>Тест: ${_currentTestTopic}</h1>
      <p>Количество вопросов: ${_questions.length}</p>
      <hr>
    ''';
    
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final correctLetter = String.fromCharCode(65 + (q['correct'] as int));
      html += '''
      <div class="question">
        <div class="question-text">${i + 1}. ${q['question']}</div>
        <div class="options">
    ''';
      for (int j = 0; j < (q['options'] as List).length; j++) {
        final letter = String.fromCharCode(65 + j);
        final isCorrect = j == q['correct'];
        html += '<div>${letter}. ${q['options'][j]} ${isCorrect ? '✓' : ''}</div>';
      }
      html += '''
        </div>
        <div class="explanation">📝 ${q['explanation']}</div>
      </div>
      <hr>
    ''';
    }
    
    html += '</body></html>';
    
    final blob = html.Blob([html], 'application/msword');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '${_currentTestTopic}_тест.doc')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    _showSnackBar('Тест сохранён в Word', true);
  }
  
  void _exportToPdf() {
    // Для PDF используем print или html2canvas
    html.window.print();
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _showQuiz
              ? (!_quizFinished ? _buildQuizScreen() : _buildResultScreen())
              : _buildStartScreen(remaining),
    );
  }
  
  Widget _buildStartScreen(int remaining) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
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
                  child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Генератор тестов', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Создайте тест по любой теме для ваших учеников', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
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
                
                const Text('КОЛИЧЕСТВО ВОПРОСОВ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionCountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '5',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
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
                ),
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: _generateQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Center(
                    child: Text('Сгенерировать тест', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestionIndex];
    
    return Column(
      children: [
        Container(
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
                  Text('Вопрос ${_currentQuestionIndex + 1} из ${_questions.length}', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                  Text('Счёт: $_score', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
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
          child: Text(question['question'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 24),
        
        const Text('ВЫБЕРИТЕ ОТВЕТ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...List.generate((question['options'] as List).length, (index) {
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
                title: Text(question['options'][index], style: const TextStyle(color: Colors.white)),
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length) * 100;
    
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
              child: Text('${percentage.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
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
                    const Text('Правильных ответов:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14)),
                    Text('$_score / ${_questions.length}', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _score / _questions.length,
                  backgroundColor: const Color(0xFF2A2A2A),
                  color: const Color(0xFF1DB954),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Правильные ответы
          if (_showAnswers) ...[
            const Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._questions.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              final correctLetter = String.fromCharCode(65 + (q['correct'] as int));
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
                    Text('${i + 1}. ${q['question']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('✓ $correctLetter. ${q['options'][q['correct']]}', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('📝 ${q['explanation']}', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
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
                  child: Text(_showAnswers ? 'Скрыть ответы' : 'Показать ответы', style: const TextStyle(color: Color(0xFF1DB954))),
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