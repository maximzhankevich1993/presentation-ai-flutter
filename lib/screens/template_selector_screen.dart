import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../models/design_template.dart';
import '../data/design_templates.dart';
import '../providers/user_provider.dart';
import 'editor_screen.dart';
import 'teacher_screen.dart';

class TemplateSelectorScreen extends StatefulWidget {
  const TemplateSelectorScreen({super.key});

  @override
  State<TemplateSelectorScreen> createState() => _TemplateSelectorScreenState();
}

class _TemplateSelectorScreenState extends State<TemplateSelectorScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _showOnlyFree = false;

  final List<String> _categories = [
    'all', 'business', 'technology', 'creative', 'education', 'events', 'nature', 'medical'
  ];

  final Map<String, String> _categoryNames = {
    'all': 'Все',
    'business': 'Бизнес',
    'technology': 'Технологии',
    'creative': 'Креатив',
    'education': 'Образование',
    'events': 'Мероприятия',
    'nature': 'Природа',
    'medical': 'Медицина',
  };

  List<DesignTemplate> get _filteredTemplates {
    return allDesignTemplates.where((template) {
      final matchesSearch = _searchQuery.isEmpty ||
          template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'all' || template.category == _selectedCategory;
      
      final matchesPrice = !_showOnlyFree || !template.isPremium;
      
      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPremiumUser = userProvider.isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Шаблоны',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Text('Бесплатные', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                const SizedBox(width: 4),
                                Switch(
                  value: _showOnlyFree,
                  onChanged: (value) => setState(() => _showOnlyFree = value),
                  activeColor: const Color(0xFF1DB954),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Поиск...',
                  hintStyle: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1DB954), size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          // Категории
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final category = _categories[i];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1DB954) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFF2A2A2A),
                        ),
                      ),
                      child: Text(
                        _categoryNames[category]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Список шаблонов
          Expanded(
            child: _filteredTemplates.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF4A4A4A)),
                        SizedBox(height: 8),
                        Text(
                          'Ничего не найдено',
                          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: ScrollController(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (_, i) {
                      final template = _filteredTemplates[i];
                      return _TemplateCard(
                        template: template,
                        isPremiumUser: isPremiumUser,
                        onTap: () => _applyTemplate(template),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(DesignTemplate template) {
    // Проверка Premium
    if (template.isPremium) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (!userProvider.isPremium) {
        _showPremiumDialog();
        return;
      }
    }
    
    // Создаём презентацию с 5 слайдами на основе шаблона
    final slides = <Slide>[
      Slide(title: template.name, content: [
        'Презентация в стиле "${template.name}"',
        'Создано в Презентатор ИИ',
        'Профессиональный дизайн',
      ]),
      Slide(title: 'О компании', content: [
        'Напишите здесь о своей компании',
        'Ключевые преимущества',
        'Достижения и планы',
      ]),
      Slide(title: 'Наши услуги', content: [
        'Услуга 1 с подробным описанием',
        'Услуга 2 с преимуществами',
        'Услуга 3 с примерами работ',
      ]),
      Slide(title: 'Почему мы?', content: [
        'Профессионализм и опыт',
        'Индивидуальный подход',
        'Гарантия качества',
      ]),
      Slide(title: 'Контакты', content: [
        'Телефон: +7 (XXX) XXX-XX-XX',
        'Email: info@company.ru',
        'Сайт: www.company.ru',
      ]),
    ];
    
    final presentation = Presentation(
      id: DateTime.now().toString(),
      title: template.name,
      slides: slides,
      createdAt: DateTime.now(),
    );
    
    // Переход в редактор
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(presentation: presentation),
      ),
    );
  }
  
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Premium шаблон', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Этот шаблон доступен только по подписке Premium.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
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
            child: const Text('Купить Premium'),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final DesignTemplate template;
  final bool isPremiumUser;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isPremiumUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = template.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Превью (верхняя часть)
            Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: cs.gradient.isNotEmpty ? cs.gradient : [cs.background, cs.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(template.icon, color: cs.primary, size: 36),
              ),
            ),
            // Информация
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: TextStyle(
                            color: cs.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (template.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(color: Color(0xFFFFD700), fontSize: 8, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.description,
                    style: TextStyle(
                      color: cs.textSecondary,
                      fontSize: 9,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.slideshow_rounded, color: cs.accent, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        '${template.slideCount} слайдов',
                        style: TextStyle(color: cs.accent, fontSize: 8),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getCategoryName(template.category),
                          style: TextStyle(color: cs.accent, fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCategoryName(String category) {
    switch (category) {
      case 'business': return 'Бизнес';
      case 'technology': return 'Технологии';
      case 'creative': return 'Креатив';
      case 'education': return 'Образование';
      case 'events': return 'Мероприятия';
      case 'nature': return 'Природа';
      case 'medical': return 'Медицина';
      default: return category;
    }
  }
}