import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import '../services/quiz_service.dart';
import '../providers/user_provider.dart';
import '../models/presentation.dart';
import '../services/api_service.dart';
import 'premium_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentTab = 0;
  List<Presentation> _userPresentations = [];
  Presentation? _selectedPresentation;
  bool _loadingPresentations = false;
  String? _uploadedFileName;
  String? _uploadedFileContent;
  
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _textbookController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController(text: '9');
  final TextEditingController _questionCountController = TextEditingController(text: '5');
  
  bool _isLoading = false;
  bool _showQuiz = false;
  bool _showAnswers = false;
  
  Quiz? _currentQuiz;
  Map<int, int?> _userAnswers = {};
  int _score = 0;
  int _currentQuestionIndex = 0;
  bool _quizFinished = false;
  String _countryCode = 'RU';

  @override
  void initState() {
    super.initState();
    _loadUserPresentations();
    _detectCountry();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _textbookController.dispose();
    _gradeController.dispose();
    _questionCountController.dispose();
    super.dispose();
  }

  Future<void> _detectCountry() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _countryCode = data['country_code'] ?? 'RU');
      }
    } catch (e) {}
  }

  Future<void> _loadUserPresentations() async {
    setState(() => _loadingPresentations = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final presentationsJson = prefs.getString('user_presentations');
      if (presentationsJson != null) {
        final List<dynamic> list = json.decode(presentationsJson);
        setState(() => _userPresentations = list.map((p) => Presentation.fromJson(p)).toList());
      }
    } catch (e) {}
    setState(() => _loadingPresentations = false);
  }

  void _uploadFile() {
    final input = html.FileUploadInputElement()..accept = '.pptx,.pdf,.docx,.txt';
    input.click();
    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoad.listen((_) {
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFileContent = reader.result as String;
        });
      });
    });
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
          'У вас закончились бесплатные генерации.\n\nОформите подписку, чтобы продолжить создавать тесты без ограничений.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Premium доступ', style: TextStyle(color: Color(0xFFFFD700))),
        content: const Text('Экспорт в PDF доступен только по подписке Premium.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)), child: const Text('Выбрать тариф')),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFFF3B30), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.fromLTRB(16, 0, 16, 24), duration: const Duration(seconds: 5)),
    );
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? const Color(0xFF1DB954) : const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _generateQuizFromFile() async {
    if (_uploadedFileContent == null) { _showError('Загрузите файл'); return; }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.freeGenerationsLeft <= 0) { _showLimitDialog(); return; }
    setState(() => _isLoading = true);
    try {
      final quiz = await ApiService.generateQuizFromPresentation(
        title: _uploadedFileName ?? 'презентация', slides: [_uploadedFileContent!], questionCount: 5,
      );
      await userProvider.loadUser();
      if (!mounted) return;
      final adapted = _adaptQuizResponse(quiz);
      setState(() {
        _currentQuiz = Quiz.fromJson(adapted);
        _showQuiz = true; _quizFinished = false; _currentQuestionIndex = 0; _userAnswers.clear(); _score = 0;
      });
    } on LimitReachedException catch (_) {
      if (mounted) { _showLimitDialog(); await userProvider.loadUser(); }
    } catch (e) { _showError('Ошибка: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _generateQuizFromSelectedPresentation() async {
    if (_selectedPresentation == null) { _showError('Выберите презентацию'); return; }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.freeGenerationsLeft <= 0) { _showLimitDialog(); return; }
    setState(() => _isLoading = true);
    try {
      final slideContents = _selectedPresentation!.slides.map((s) => s.title + ' ' + s.content.join(' ')).toList();
      final quiz = await ApiService.generateQuizFromPresentation(
        title: _selectedPresentation!.title, slides: slideContents, questionCount: 5,
      );
      await userProvider.loadUser();
      if (!mounted) return;
      final adapted = _adaptQuizResponse(quiz);
      setState(() {
        _currentQuiz = Quiz.fromJson(adapted);
        _showQuiz = true; _quizFinished = false; _currentQuestionIndex = 0; _userAnswers.clear(); _score = 0;
      });
    } on LimitReachedException catch (_) {
      if (mounted) { _showLimitDialog(); await userProvider.loadUser(); }
    } catch (e) { _showError('Ошибка: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _generateQuizFromTopic() async {
    final topic = _topicController.text.trim();
    final questionCount = int.tryParse(_questionCountController.text.trim()) ?? 5;
    
    if (topic.isEmpty) { _showError('Введите тему'); return; }
    if (questionCount < 3 || questionCount > 10) { _showError('Вопросов от 3 до 10'); return; }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.freeGenerationsLeft <= 0) { _showLimitDialog(); return; }
    
    setState(() => _isLoading = true);
    try {
      final quiz = await ApiService.generateQuiz(
        topic: topic,
        questionCount: questionCount,
      );
      await userProvider.loadUser();
      if (!mounted) return;
      
      // Диагностика: показываем первые 200 символов ответа
      final responseStr = quiz.toString();
      _showError('Ответ API: ${responseStr.length > 200 ? responseStr.substring(0, 200) + '...' : responseStr}');
      
      final adapted = _adaptQuizResponse(quiz);
      setState(() {
        _currentQuiz = Quiz.fromJson(adapted);
        _showQuiz = true;
        _quizFinished = false;
        _currentQuestionIndex = 0;
        _userAnswers.clear();
        _score = 0;
      });
    } on LimitReachedException catch (_) {
      if (mounted) { _showLimitDialog(); await userProvider.loadUser(); }
    } catch (e) {
      _showError('Ошибка: $e');
      print('Ошибка генерации теста: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _adaptQuizResponse(Map<String, dynamic> response) {
    if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
      return response['data'] as Map<String, dynamic>;
    }
    if (response.containsKey('quiz') && response['quiz'] is Map<String, dynamic>) {
      return response['quiz'] as Map<String, dynamic>;
    }
    if (response.containsKey('questions') && response.containsKey('title')) {
      return response;
    }
    if (response.containsKey('questions')) {
      return {
        'title': 'Тест по теме ${_topicController.text.trim()}',
        'questions': response['questions'],
      };
    }
    throw Exception('Неизвестный формат ответа: ключи ${response.keys}');
  }
  
  void _answerQuestion(int selectedIndex) {
    final question = _currentQuiz!.questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question.correctIndex;
    setState(() { _userAnswers[_currentQuestionIndex] = selectedIndex; if (isCorrect) _score++; });
    _showSnackBar(isCorrect ? 'Правильно! 🎉' : 'Неправильно! Правильный ответ: ${question.options[question.correctIndex]}', isCorrect);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          if (_currentQuestionIndex + 1 < _currentQuiz!.questions.length) { _currentQuestionIndex++; }
          else { _quizFinished = true; }
        });
      }
    });
  }
  
  void _exportToWord() {
    if (_currentQuiz == null) return;
    final content = QuizService.exportToWord(_currentQuiz!, includeAnswers: true);
    final htmlContent = '''<!DOCTYPE html><html><head><meta charset="UTF-8"><title>${_currentQuiz!.title}</title>
    <style>body{font-family:Arial;margin:40px;} h1{color:#1DB954;} .question{margin-bottom:30px;}</style>
    </head><body><pre style="white-space:pre-wrap;">$content</pre></body></html>''';
    final blob = html.Blob([htmlContent], 'application/msword');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)..setAttribute('download', '${_currentQuiz!.title}.doc')..click();
    html.Url.revokeObjectUrl(url);
    _showSnackBar('Тест сохранён в Word', true);
  }
  
  void _exportToPdf() {
    if (_currentQuiz == null) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isPremium) { _showPremiumDialog(); return; }
    final content = QuizService.exportToWord(_currentQuiz!, includeAnswers: true);
    final fullHtml = '''<!DOCTYPE html><html><head><meta charset="UTF-8"><title>${_currentQuiz!.title}</title>
    <style>body{font-family:Arial;margin:40px;} h1{color:#1DB954;}</style>
    </head><body><pre style="white-space:pre-wrap;">$content</pre>
    <script>window.onload=function(){window.print();};</script></body></html>''';
    final blob = html.Blob([fullHtml], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final remaining = userProvider.freeGenerationsLeft;
    final isPremium = userProvider.isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Генератор тестов', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _showQuiz
              ? (!_quizFinished ? _buildQuizScreen() : _buildResultScreen())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20), physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: double.infinity, padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(24)),
                          child: Column(children: [
                            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 32)),
                            const SizedBox(height: 16),
                            const Text('Генератор тестов', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Создайте тест по презентации или теме', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
                          child: Row(children: [_buildTabButton('Из презентации', 0), const SizedBox(width: 8), _buildTabButton('По теме', 1)]),
                        ),
                        const SizedBox(height: 24),
                        _currentTab == 0 ? _buildPresentationTab(remaining, isPremium) : _buildTopicTab(remaining, isPremium),
                      ]),
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildTabButton(String title, int index) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF1DB954) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF9A9A9A), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontSize: 14))),
        ),
      ),
    );
  }
  
  Widget _buildPresentationTab(int remaining, bool isPremium) {
    final canGenerate = remaining > 0 || isPremium;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ЗАГРУЗИТЬ ФАЙЛ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _uploadFile, icon: const Icon(Icons.upload_file_rounded, color: Colors.white), label: const Text('Выбрать файл'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF252525), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          if (_uploadedFileName != null) ...[
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF1DB954), size: 20), const SizedBox(width: 12),
                Expanded(child: Text(_uploadedFileName!, style: const TextStyle(color: Colors.white))),
                IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF9A9A9A), size: 18), onPressed: () => setState(() { _uploadedFileName = null; _uploadedFileContent = null; })),
              ])),
            const SizedBox(height: 16),
            if (!isPremium && remaining <= 3)
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.1) : const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.3) : const Color(0xFF1DB954).withOpacity(0.3))),
                child: Row(children: [
                  Icon(remaining <= 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded, color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), size: 18), const SizedBox(width: 10),
                  Expanded(child: Text(remaining <= 0 ? 'Бесплатные генерации закончились.' : 'Осталось $remaining из 5 бесплатных генераций', style: TextStyle(color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), fontSize: 13))),
                  if (remaining <= 0) GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(20)), child: const Text('Купить', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))),
                ])),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: canGenerate ? _generateQuizFromFile : null,
              style: ElevatedButton.styleFrom(backgroundColor: canGenerate ? const Color(0xFF1DB954) : const Color(0xFF4A4A4A), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(canGenerate ? 'Сгенерировать тест из файла' : 'Лимит исчерпан', style: const TextStyle(color: Colors.white)))),
          ],
        ])),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ИЛИ ВЫБЕРИТЕ ИЗ СОХРАНЁННЫХ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
          _loadingPresentations ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))) :
          DropdownButtonFormField<Presentation>(value: _selectedPresentation, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A)))),
            items: _userPresentations.map((p) => DropdownMenuItem(value: p, child: Text(p.title, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: (value) => setState(() => _selectedPresentation = value), hint: const Text('Выберите презентацию', style: TextStyle(color: Color(0xFF9A9A9A)))),
          const SizedBox(height: 20),
          if (!isPremium && remaining <= 3) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.1) : const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.3) : const Color(0xFF1DB954).withOpacity(0.3))), child: Row(children: [Icon(remaining <= 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded, color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), size: 18), const SizedBox(width: 10), Expanded(child: Text(remaining <= 0 ? 'Бесплатные генерации закончились.' : 'Осталось $remaining из 5 бесплатных генераций', style: TextStyle(color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), fontSize: 13))), if (remaining <= 0) GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(20)), child: const Text('Купить', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))))])),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: canGenerate ? _generateQuizFromSelectedPresentation : null, style: ElevatedButton.styleFrom(backgroundColor: canGenerate ? const Color(0xFF1DB954) : const Color(0xFF4A4A4A), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(canGenerate ? 'Сгенерировать тест из презентации' : 'Лимит исчерпан', style: const TextStyle(color: Colors.white)))),
        ])),
    ]);
  }
  
  Widget _buildTopicTab(int remaining, bool isPremium) {
    final canGenerate = remaining > 0 || isPremium;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ТЕМА ТЕСТА', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          TextField(controller: _topicController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Например: Вторая мировая война', hintStyle: const TextStyle(color: Color(0xFF4A4A4A)), prefixIcon: const Icon(Icons.topic_rounded, color: Color(0xFF1DB954)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))))),
          const SizedBox(height: 16),
          const Text('УЧЕБНИК (ОПЦИОНАЛЬНО)', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          TextField(controller: _textbookController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Название учебника', hintStyle: const TextStyle(color: Color(0xFF4A4A4A)), prefixIcon: const Icon(Icons.menu_book_rounded, color: Color(0xFF1DB954)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))))),
          const SizedBox(height: 16),
          const Text('КЛАСС', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          TextField(controller: _gradeController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: '9', hintStyle: const TextStyle(color: Color(0xFF4A4A4A)), prefixIcon: const Icon(Icons.school_rounded, color: Color(0xFF1DB954)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))))),
          const SizedBox(height: 16),
          const Text('КОЛИЧЕСТВО ВОПРОСОВ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          TextField(controller: _questionCountController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: '5 (3-10)', hintStyle: const TextStyle(color: Color(0xFF4A4A4A)), prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF1DB954)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))))),
          const SizedBox(height: 20),
          if (!isPremium && remaining <= 3) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.1) : const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.3) : const Color(0xFF1DB954).withOpacity(0.3))), child: Row(children: [Icon(remaining <= 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded, color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), size: 18), const SizedBox(width: 10), Expanded(child: Text(remaining <= 0 ? 'Бесплатные генерации закончились.' : 'Осталось $remaining из 5 бесплатных генераций', style: TextStyle(color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), fontSize: 13))), if (remaining <= 0) GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(20)), child: const Text('Купить', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))))])),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: canGenerate ? _generateQuizFromTopic : null, style: ElevatedButton.styleFrom(backgroundColor: canGenerate ? const Color(0xFF1DB954) : const Color(0xFF4A4A4A), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(canGenerate ? 'Сгенерировать тест' : 'Лимит исчерпан', style: const TextStyle(color: Colors.white)))),
        ])),
    ]);
  }
  
  Widget _buildQuizScreen() {
    final question = _currentQuiz!.questions[_currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Вопрос ${_currentQuestionIndex + 1} из ${_currentQuiz!.questions.length}', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
              Text('Счёт: $_score', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (_currentQuestionIndex + 1) / _currentQuiz!.questions.length, backgroundColor: const Color(0xFF2A2A2A), color: const Color(0xFF1DB954)),
          ])),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.2))),
          child: Text(question.question, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
        const SizedBox(height: 24),
        const Text('ВЫБЕРИТЕ ОТВЕТ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...List.generate(question.options.length, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: ListTile(
              onTap: () => _answerQuestion(index),
              leading: Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.circle_outlined, color: Color(0xFF9A9A9A), size: 14)),
              title: Text(question.options[index], style: const TextStyle(color: Colors.white)),
            )),
        )),
      ]),
    );
  }
  
  Widget _buildResultScreen() {
    final percentage = (_score / _currentQuiz!.questions.length) * 100;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(50)), child: Center(child: Text('${percentage.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))),
        const SizedBox(height: 24),
        Text(percentage >= 80 ? 'Отлично! 🎉' : (percentage >= 60 ? 'Хорошо! 👍' : 'Попробуй ещё! 💪'), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 32),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Правильных ответов:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14)), Text('$_score / ${_currentQuiz!.questions.length}', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 20, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _score / _currentQuiz!.questions.length, backgroundColor: const Color(0xFF2A2A2A), color: const Color(0xFF1DB954)),
        ])),
        const SizedBox(height: 24),
        if (_showAnswers) ...[
          const Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
          ..._currentQuiz!.questions.asMap().entries.map((entry) {
            final i = entry.key; final q = entry.value; final correctLetter = String.fromCharCode(65 + q.correctIndex);
            return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${i + 1}. ${q.question}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), const SizedBox(height: 8),
                Text('✓ $correctLetter. ${q.options[q.correctIndex]}', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13)), const SizedBox(height: 8),
                Text('📝 ${q.explanation}', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
              ]));
          }),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => setState(() => _showAnswers = !_showAnswers), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A2A2A)), padding: const EdgeInsets.symmetric(vertical: 14)), child: Text(_showAnswers ? 'Скрыть ответы' : 'Показать ответы', style: const TextStyle(color: Color(0xFF1DB954))))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton(onPressed: _exportToWord, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A2A2A)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('📄 Word', style: TextStyle(color: Colors.white)))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _exportToPdf, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A2A2A)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('📑 PDF', style: TextStyle(color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton(onPressed: () { setState(() { _showQuiz = false; _quizFinished = false; _currentQuestionIndex = 0; _score = 0; _userAnswers.clear(); _currentQuiz = null; }); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2A2A2A)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Новый тест', style: TextStyle(color: Colors.white)))),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('На главную', style: TextStyle(color: Colors.white)))),
      ]),
    );
  }
}