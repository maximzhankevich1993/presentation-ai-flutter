import 'package:flutter/material.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  bool _isLoading = true;
  final int _totalSpots = 50;
  int _occupiedSpots = 0;
  int _availableSpots = 50;

  @override
  void initState() {
    super.initState();
    _loadVipStats();
  }

  Future<void> _loadVipStats() async {
    try {
      // TODO: Заменить на реальный API запрос, когда появится
      // final stats = await ApiService.getVipStats();
      // setState(() {
      //   _occupiedSpots = stats['occupiedSpots'];
      //   _availableSpots = _totalSpots - _occupiedSpots;
      //   _isLoading = false;
      // });
      
      // Для продакшена пока 0 занято, 50 свободно
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _occupiedSpots = 0;
          _availableSpots = _totalSpots - _occupiedSpots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: const Text(
          'VIP доступ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFF1DB954),
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFD60A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'VIP статус',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Свободно $_availableSpots мест из $_totalSpots',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Progress
                      Container(
                        width: double.infinity,
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
                                const Text(
                                  'Занято мест',
                                  style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                                ),
                                Text(
                                  '$_occupiedSpots / $_totalSpots',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _occupiedSpots / _totalSpots,
                                backgroundColor: const Color(0xFF2A2A2A),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _availableSpots > 0
                                  ? '🔥 Осталось всего $_availableSpots мест! Успей забрать VIP навсегда'
                                  : 'Все места заняты. Следите за новостями!',
                              style: TextStyle(
                                color: _availableSpots > 0 ? const Color(0xFFFFD700) : const Color(0xFF9A9A9A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Benefits
                      const Text(
                        'ПРЕИМУЩЕСТВА VIP',
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildBenefitCard(
                        icon: Icons.infinity_rounded,
                        title: '∞ генераций',
                        description: 'Неограниченное количество презентаций',
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitCard(
                        icon: Icons.slideshow_rounded,
                        title: 'До 50 слайдов',
                        description: 'Самые большие презентации без ограничений',
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitCard(
                        icon: Icons.palette_rounded,
                        title: 'Все премиум фоны',
                        description: '16+ эксклюзивных фонов и градиентов',
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitCard(
                        icon: Icons.picture_as_pdf_rounded,
                        title: 'Экспорт без знаков',
                        description: 'PDF и PPTX без водяных знаков',
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'AI улучшение текста',
                        description: 'Продвинутая нейросеть для контента',
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitCard(
                        icon: Icons.support_agent_rounded,
                        title: 'VIP поддержка 24/7',
                        description: 'Приоритетное решение любых вопросов',
                        color: const Color(0xFFFFD700),
                      ),
                      const SizedBox(height: 24),

                      // Price
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFFFD700).withOpacity(0.1), const Color(0xFFFFD60A).withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'VIP доступ навсегда',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '4 999',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: const Text(
                                    '₽',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Оплата только один раз',
                              style: TextStyle(
                                color: Color(0xFF9A9A9A),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 20),
                            MouseRegion(
                              cursor: _availableSpots > 0 ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
                              child: GestureDetector(
                                onTap: _availableSpots > 0 ? _purchaseVip : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: _availableSpots > 0
                                        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFD60A)])
                                        : null,
                                    color: _availableSpots > 0 ? null : const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _availableSpots > 0 ? 'Получить VIP' : 'Мест нет',
                                      style: TextStyle(
                                        color: _availableSpots > 0 ? Colors.white : const Color(0xFF9A9A9A),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFFFFD700), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'VIP статус выдаётся первым 50 пользователям навсегда. Сейчас свободно 50 мест!',
                                style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseVip() {
    // TODO: Интеграция с платёжной системой
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Оплата VIP доступа'),
        backgroundColor: Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: Duration(seconds: 2),
      ),
    );
  }
}