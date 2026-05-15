import 'package:flutter/material.dart';
import 'lesson_constructor_screen.dart';

class TeacherScreen extends StatefulWidget {
  final String countryCode;
  const TeacherScreen({super.key, required this.countryCode});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String _selectedTariff = 'teacher';
  bool _isLoading = false;

  void _openConstructor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonConstructorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Учителям', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openConstructor,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Конструктор уроков', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTariffCard(
                        title: 'Учитель',
                        price: '0',
                        period: 'бесплатно',
                        description: 'Для преподавателей',
                        features: const ['10 генераций в месяц', '15 слайдов', 'Конструктор уроков'],
                        isPopular: true,
                        onTap: () => setState(() => _selectedTariff = 'teacher'),
                      ),
                      const SizedBox(height: 14),
                      _buildTariffCard(
                        title: 'Школа',
                        price: '1499',
                        period: 'месяц',
                        description: 'Для школ и классов',
                        features: const ['До 30 учителей', '∞ генераций', 'Конструктор уроков PRO'],
                        isPopular: false,
                        onTap: () => setState(() => _selectedTariff = 'school'),
                      ),
                      const SizedBox(height: 14),
                      _buildTariffCard(
                        title: 'Университет',
                        price: '4999',
                        period: 'месяц',
                        description: 'Для вузов и колледжей',
                        features: const ['Неограниченно преподавателей', '∞ генераций', 'Конструктор уроков PRO'],
                        isPopular: false,
                        onTap: () => setState(() => _selectedTariff = 'university'),
                      ),
                      const SizedBox(height: 32),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _openConstructor,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Открыть конструктор уроков', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTariffCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedTariff == title.toLowerCase();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1DB95420) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A), width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: isPopular ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
                    child: Icon(title == 'Учитель' ? Icons.person_outline_rounded : Icons.school_rounded, color: isPopular ? Colors.white : const Color(0xFF1DB954), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(description, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isPopular) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(12)), child: const Text('Популярный', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (price == '0')
                    const Text('Бесплатно', style: TextStyle(color: Color(0xFF1DB954), fontSize: 28, fontWeight: FontWeight.w800))
                  else ...[
                    Text('$price ₽', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 32, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Text('/$period', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                  ],
                  const Spacer(),
                  if (isSelected) Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 16),
              const Text('Включено:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12, runSpacing: 10,
                children: features.map((feature) => Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                  const SizedBox(width: 6),
                  Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ])).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}