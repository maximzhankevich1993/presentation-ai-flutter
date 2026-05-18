Future<void> _generateLesson() async {
  final topic = _topicController.text.trim();
  final subject = _subjectController.text.trim();
  final grade = _gradeController.text.trim();
  
  if (topic.isEmpty || subject.isEmpty || grade.isEmpty) {
    _showError('Заполните все поля');
    return;
  }
  
  setState(() => _isGenerating = true);
  
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isLoggedIn;
    final isPremium = userProvider.isPremium;
    
    // Проверка лимита для гостей
    final canGenerate = await GenerationCounter.canGenerate(isLoggedIn, isPremium);
    if (!canGenerate) {
      _showLimitDialog();
      setState(() => _isGenerating = false);
      return;
    }
    
    // Получаем токен (если есть)
    String? token = userProvider.token;
    
    // Если пользователь не авторизован — генерируем без токена
    // API должно поддерживать гостевые запросы
    final lessonPlan = await LessonPlanService.generate(
      topic: topic,
      subject: subject,
      standard: _selectedStandard,
      grade: grade,
      durationMinutes: _durationMinutes,
      token: token, // Может быть null для гостей
    );
    
    // Увеличиваем счётчик для гостей
    if (!isLoggedIn) {
      await GenerationCounter.increment();
      final remaining = await GenerationCounter.getRemainingForGuest();
      _showGuestInfo(remaining);
    }
    
    final presentation = _convertToPresentation(lessonPlan);
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(presentation: presentation),
      ),
    );
  } catch (e) {
    _showError('Ошибка создания плана урока: $e');
    setState(() => _isGenerating = false);
  }
}

void _showLimitDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Лимит генераций исчерпан', style: TextStyle(color: Colors.white)),
      content: const Text(
        'Вы использовали все 5 бесплатных генераций.\n\n'
        'Зарегистрируйтесь или войдите в аккаунт, чтобы продолжить создавать планы уроков без ограничений.',
        style: TextStyle(color