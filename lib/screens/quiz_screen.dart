import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _textbook = TextEditingController();
  final _topic = TextEditingController();
  String _grade = '9 класс';
  int _questionCount = 10;
  Quiz? _quiz;
  int _currentQuestion = 0;
  int? _selectedOption;
  int _score = 0;
  bool _finished = false;
  bool _isTeacher = true;

  final List<String> _grades = ['5 класс', '6 класс', '7 класс', '8 класс', '9 класс', '10 класс', '11 класс'];

  void _generate() {
    final textbook = _textbook.text.trim();
    final topic = _topic.text.trim();
    if (textbook.isEmpty || topic.isEmpty) return;

    setState(() {
      _quiz = QuizService.generateFromTextbook(
        textbook: textbook,
        topic: topic,
        grade: _grade,
        questionCount: _questionCount,
      );
      _currentQuestion = 0;
      _score = 0;
      _finished = false;
      _selectedOption = null;
    });
  }

  void _answer(int index) {
    if (_quiz == null) return;
    setState(() {
      _selectedOption = index;
      if (index == _quiz!.questions[_currentQuestion].correctIndex) _score++;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_currentQuestion < _quiz!.questions.length - 1) {
        setState(() { _currentQuestion++; _selectedOption = null; });
      } else {
        setState(() => _finished = true);
      }
    });
  }

  void _export() {
    if (_quiz == null) return;
    final text = QuizService.exportToWord(_quiz!, includeAnswers: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Тест готов! ${_quiz!.questions.length} вопросов'), backgroundColor: const Color(0xFF1DB954)),
    );
  }

  void _showAnswerKey() {
    if (_quiz == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ключ к тесту', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Text(_quiz!.answerKey, style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 13)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть', style: TextStyle(color: Color(0xFF1DB954)))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textbook.dispose();
    _topic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Генератор тестов', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: _quiz == null
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Создать тест', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 4.h),
                Text('Укажите учебник и тему', style: TextStyle(fontSize: 12, color: const Color(0xFFB3B3B3))),
                SizedBox(height: 16.h),
                TextField(
                  controller: _textbook,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(hintText: 'Название учебника', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), filled: true, fillColor: card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: EdgeInsets.all(14.w)),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _topic,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(hintText: 'Тема', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), filled: true, fillColor: card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: EdgeInsets.all(14.w)),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _grade,
                  dropdownColor: card,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(filled: true, fillColor: card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                  items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => _grade = v!),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generate,
                    style: ElevatedButton.styleFrom(backgroundColor: green, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Сгенерировать тест', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
              ])
            : _finished
                ? Column(children: [
                    Container(padding: EdgeInsets.all(20.w), decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)), child: Column(children: [
                      const Text('🎉', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 8.h),
                      Text('Результат: $_score из ${_quiz!.questions.length}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)),
                      SizedBox(height: 4.h),
                      Text('${(_score / _quiz!.questions.length * 100).round()}%', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7))),
                    ])),
                    SizedBox(height: 16.h),
                    Row(children: [
                      Expanded(child: ElevatedButton(onPressed: _export, style: ElevatedButton.styleFrom(backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('📥 Экспорт в Word', style: TextStyle(color: Colors.black)))),
                      SizedBox(width: 10.w),
                      Expanded(child: ElevatedButton(onPressed: _showAnswerKey, style: ElevatedButton.styleFrom(backgroundColor: card, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('🔑 Ответы', style: TextStyle(color: Colors.white)))),
                    ]),
                    SizedBox(height: 10.h),
                    TextButton(onPressed: () => setState(() => _quiz = null), child: const Text('Создать новый тест', style: TextStyle(color: green))),
                  ])
                : Column(children: [
                    LinearProgressIndicator(value: (_currentQuestion + 1) / _quiz!.questions.length, backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)), minHeight: 4),
                    SizedBox(height: 16.h),
                    Text('Вопрос ${_currentQuestion + 1} из ${_quiz!.questions.length}', style: TextStyle(fontSize: 12, color: const Color(0xFFB3B3B3))),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_quiz!.questions[_currentQuestion].question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        SizedBox(height: 12.h),
                        ..._quiz!.questions[_currentQuestion].options.asMap().entries.map((e) => GestureDetector(
                          onTap: _selectedOption == null ? () => _answer(e.key) : null,
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 6.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: _selectedOption == e.key
                                  ? (e.key == _quiz!.questions[_currentQuestion].correctIndex ? green : const Color(0xFFFF3B30))
                                  : const Color(0xFF282828),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${_letter(e.key)}) ${e.value}', style: TextStyle(fontSize: 14, color: _selectedOption == e.key ? Colors.black : Colors.white)),
                          ),
                        )),
                      ]),
                    ),
                  ]),
      ),
    );
  }

  String _letter(int index) => String.fromCharCode(65 + index);
}