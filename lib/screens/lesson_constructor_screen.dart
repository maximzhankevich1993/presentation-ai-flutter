Presentation _convertToPresentation(Map<String, dynamic> lessonData) {
    final List<Slide> slides = [];
    
    // Слайды урока (без титульного — он уже есть в ответе от AI)
    final slidesData = lessonData['slides'] as List? ?? [];
    for (final slideData in slidesData) {
      final content = slideData['content'] as List? ?? [];
      slides.add(Slide(
        title: slideData['title'] ?? 'Слайд',
        content: content.map((c) => c.toString()).toList(),
      ));
    }
    
    // Домашнее задание добавляем как дополнительный пункт к последнему слайду, а не отдельным слайдом
    if (lessonData['homework'] != null && lessonData['homework'].toString().isNotEmpty && slides.isNotEmpty) {
      final lastSlide = slides.last;
      final updatedContent = [...lastSlide.content, '📝 Домашнее задание: ${lessonData['homework']}'];
      slides[slides.length - 1] = Slide(
        title: lastSlide.title,
        content: updatedContent,
      );
    }
    
    // Материалы тоже добавляем к последнему слайду
    if (lessonData['materials'] != null && slides.isNotEmpty) {
      final materials = lessonData['materials'] as List? ?? [];
      if (materials.isNotEmpty) {
        final lastSlide = slides.last;
        final updatedContent = [...lastSlide.content, ...materials.map((m) => '📖 $m')];
        slides[slides.length - 1] = Slide(
          title: lastSlide.title,
          content: updatedContent,
        );
      }
    }
    
    return Presentation(
      id: DateTime.now().toString(),
      title: 'Урок: ${lessonData['topic'] ?? ''}',
      slides: slides,
      createdAt: DateTime.now(),
    );
  }