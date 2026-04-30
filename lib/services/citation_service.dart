import 'dart:math';

class Citation {
  final String text;
  final String author;
  final String? source;
  final String? year;
  final String category;

  const Citation({
    required this.text,
    required this.author,
    this.source,
    this.year,
    required this.category,
  });
}

class CitationService {
  static final Random _random = Random();

  static final Map<String, List<Citation>> _citations = {
    'технологии': [
      Citation(text: 'Будущее уже здесь. Просто оно неравномерно распределено.', author: 'Уильям Гибсон', category: 'технологии'),
      Citation(text: 'Любая достаточно развитая технология неотличима от магии.', author: 'Артур Кларк', category: 'технологии'),
      Citation(text: 'Инновации — это то, что отличает лидера от последователя.', author: 'Стив Джобс', category: 'технологии'),
      Citation(text: 'Технологии — это всего лишь инструмент. Сердце и душа — это люди.', author: 'Тим Кук', category: 'технологии'),
    ],
    'бизнес': [
      Citation(text: 'Ваша работа заполнит большую часть жизни. Единственный способ быть по-настоящему довольным — делать то, что вы считаете великой работой.', author: 'Стив Джобс', category: 'бизнес'),
      Citation(text: 'Не бойтесь ошибаться. Бойтесь только отсутствия ошибок.', author: 'Питер Друкер', category: 'бизнес'),
      Citation(text: 'Лучший способ предсказать будущее — создать его.', author: 'Питер Друкер', category: 'бизнес'),
    ],
    'наука': [
      Citation(text: 'Наука — это способ задавать вопросы природе и получать на них ответы.', author: 'Ричард Фейнман', category: 'наука'),
      Citation(text: 'Самое непостижимое в этом мире — это то, что он постижим.', author: 'Альберт Эйнштейн', category: 'наука'),
      Citation(text: 'Наука — это организованное знание.', author: 'Герберт Спенсер', category: 'наука'),
    ],
    'экология': [
      Citation(text: 'Мы не наследуем землю у наших предков, мы берём её взаймы у наших детей.', author: 'Антуан де Сент-Экзюпери', category: 'экология'),
      Citation(text: 'Самая большая угроза нашей планете — вера в то, что кто-то другой спасёт её.', author: 'Роберт Свон', category: 'экология'),
    ],
    'образование': [
      Citation(text: 'Образование — это самое мощное оружие, которое вы можете использовать, чтобы изменить мир.', author: 'Нельсон Мандела', category: 'образование'),
      Citation(text: 'Скажи мне — и я забуду. Покажи мне — и я запомню. Вовлеки меня — и я пойму.', author: 'Конфуций', category: 'образование'),
    ],
    'лидерство': [
      Citation(text: 'Лидерство — это способность превращать видение в реальность.', author: 'Уоррен Беннис', category: 'лидерство'),
      Citation(text: 'Не иди туда, куда ведёт дорога. Иди туда, где дороги нет, и оставь за собой след.', author: 'Ральф Уолдо Эмерсон', category: 'лидерство'),
    ],
  };

  static List<Citation> getRelevantCitations(String topic, {int count = 3}) {
    final lowercaseTopic = topic.toLowerCase();
    final results = <Citation>[];

    for (final entry in _citations.entries) {
      if (lowercaseTopic.contains(entry.key) ||
          entry.key.contains(lowercaseTopic)) {
        results.addAll(entry.value);
      }
    }

    if (results.isEmpty) {
      results.addAll(_citations.values.expand((c) => c));
    }

    results.shuffle(_random);

    // убираем дубликаты (по тексту)
    final unique = <String, Citation>{};
    for (final c in results) {
      unique[c.text] = c;
    }

    return unique.values.take(count).toList();
  }

  static String formatCitationAPA(Citation citation) {
    final parts = <String>[];

    parts.add('"${citation.text}"');
    parts.add('— ${citation.author}');

    if (citation.source != null && citation.source!.isNotEmpty) {
      parts.add(citation.source!);
    }

    if (citation.year != null && citation.year!.isNotEmpty) {
      parts.add('(${citation.year})');
    }

    return parts.join(', ');
  }

  static String formatCitationGOST(Citation citation) {
    return '"${citation.text}" / ${citation.author}.';
  }

  static String formatReferences(List<Citation> citations) {
    final buffer = StringBuffer();
    buffer.writeln('📚 Источники:');

    for (int i = 0; i < citations.length; i++) {
      final c = citations[i];

      final source = c.source ?? '';
      final year = c.year ?? '';

      final extra = [source, year]
          .where((e) => e.isNotEmpty)
          .join(' ');

      buffer.writeln('${i + 1}. ${c.author}. $extra');
    }

    return buffer.toString();
  }

  static Map<String, dynamic> generateCitationSlide(
    String topic, {
    String style = 'APA',
  }) {
    final citations = getRelevantCitations(topic);

    return {
      'title': 'Мнения экспертов',
      'subtitle': 'Что говорят о "$topic"',
      'content': citations
          .map((c) =>
              style == 'APA'
                  ? formatCitationAPA(c)
                  : formatCitationGOST(c))
          .toList(),
      'image_keywords': 'quote inspiration motivation',
      'references':
          citations.map((c) => '${c.author}, ${c.source ?? ""}').toList(),
    };
  }
}