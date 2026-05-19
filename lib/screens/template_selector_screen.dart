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
    'all', 'business', 'technology', 'creative', 'education', 'events', 'nature', 'medical', 'health'
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
    'health': 'Здоровье',
  };

  List<DesignTemplate> get _filteredTemplates {
    return allDesignTemplates.where((template) {
      // Поиск
      final matchesSearch = _searchQuery.isEmpty ||
          template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Категория
      final matchesCategory = _selectedCategory == 'all' || template.category == _selectedCategory;
      
      // Бесплатные/все
      final matchesPrice = !_showOnlyFree || !template.isPremium;
      
      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<UserProvider>(context).isPremium;
    final isVip = Provider.of<UserProvider>(context).isVip;
    
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
          'Дизайнерские шаблоны',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          // Переключатель "Только бесплатные"
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Text('Бесплатные', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
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
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Поиск шаблонов...',
                  hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1DB954)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          // Категории
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final category = _categories[i];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1DB954) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFF2A2A2A),
                        ),
                      ),
                      child: Text(
                        _categoryNames[category]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                          fontSize: 13,
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: const Color(0xFF4A4A4A)),
                        const SizedBox(height: 12),
                        const Text(
                          'Ничего не найдено',
                          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (_, i) {
                      final template = _filteredTemplates[i];
                      return _TemplateCard(
                        template: template,
                        isPremiumUser: isPremium || isVip,
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
      final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
      final isVip = Provider.of<UserProvider>(context, listen: false).isVip;
      
      if (!isPremium && !isVip) {
        _showPremiumDialog();
        return;
      }
    }
    
    // Создаём презентацию с цветами шаблона
    final presentation = Presentation(
      id: DateTime.now().toString(),
      title: template.name,
      slides: _createDefaultSlides(template),
      createdAt: DateTime.now(),
    );
    
    // TODO: Сохранить выбранный шаблон в настройках презентации
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(presentation: presentation),
      ),
    );
  }
  
  List<Slide> _createDefaultSlides(DesignTemplate template) {
    return [
      Slide(title: template.name, content: [
        'Создано в Презентатор ИИ',
        'Профессиональный дизайн',
        'Легко редактируется',
      ]),
      Slide(title: 'Ключевые преимущества', content: [
        'Современный дизайн',
        'Готовые макеты',
        'Простота редактирования',
      ]),
      Slide(title: 'Ваш заголовок', content: [
        'Добавьте свой текст',
        'Измените содержимое',
        'Настройте под себя',
      ]),
      Slide(title: 'Спасибо за внимание!', content: [
        'Ваше имя',
        'Контактная информация',
      ]),
    ];
  }
  
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Premium шаблон', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Этот шаблон доступен только по подписке Premium.\n\nОформите подписку, чтобы получить доступ ко всем 30 дизайнерским шаблонам.',
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
          gradient: LinearGradient(
            colors: [cs.background, cs.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Превью
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: cs.gradient.isNotEmpty ? cs.gradient : [cs.background, cs.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(template.icon, color: cs.primary, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (template.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: TextStyle(
                      color: cs.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.slideshow_rounded, color: cs.accent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${template.slideCount} слайдов',
                        style: TextStyle(color: cs.accent, fontSize: 10),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          template.category,
                          style: TextStyle(color: cs.accent, fontSize: 9),
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
}