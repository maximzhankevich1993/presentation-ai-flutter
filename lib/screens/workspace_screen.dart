import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/generation_counter.dart';
import 'editor_screen.dart';
import '../models/presentation.dart';

class WorkspaceScreen extends StatefulWidget {
  final String countryCode;
  const WorkspaceScreen({super.key, required this.countryCode});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTariff = 'team';
  bool _isLoading = false;
  bool _loadingRates = true;
  bool _showUpgrade = false;
  
  // Валюты
  String _currency = 'USD';
  String _currencySymbol = '\$';
  double _rate = 1.0;
  
  // Цены в USD
  final double _teamPriceUSD = 49.99;
  final double _businessPriceUSD = 99.99;
  final double _enterprisePriceUSD = 199.99;
  
  // Бесплатные лимиты
  final int _freeMemberLimit = 5;
  final int _freeGenerationLimit = 5;
  
  // Демо-данные для команды
  List<Map<String, dynamic>> _members = [
    {'id': '1', 'name': 'Алексей Иванов', 'email': 'alex@company.com', 'role': 'Owner', 'avatar': 'А', 'status': 'online', 'generations': 3},
    {'id': '2', 'name': 'Мария Петрова', 'email': 'maria@company.com', 'role': 'Admin', 'avatar': 'М', 'status': 'online', 'generations': 2},
  ];
  
  final List<Map<String, dynamic>> _sharedPresentations = [
    {'id': '1', 'title': 'План продаж 2024', 'updated': '2 часа назад', 'author': 'Алексей', 'slides': 8},
    {'id': '2', 'title': 'Отчёт по маркетингу', 'updated': 'Вчера', 'author': 'Мария', 'slides': 12},
  ];
  
  String _inviteEmail = '';
  int _totalGenerations = 5; // Использовано 5 из 5 бесплатных

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _detectCurrency();
    _checkLimits();
  }
  
  void _checkLimits() {
    setState(() {
      _showUpgrade = _members.length >= _freeMemberLimit || _totalGenerations >= _freeGenerationLimit;
    });
  }
  
  Future<void> _detectCurrency() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final countryCode = (data['country_code'] as String? ?? 'US').toUpperCase();
        
        const euroCountries = {
          'IT', 'FR', 'DE', 'ES', 'NL', 'BE', 'AT', 'PT', 'FI',
          'IE', 'GR', 'SK', 'SI', 'EE', 'LV', 'LT', 'LU', 'MT', 'CY',
        };
        
        if (countryCode == 'BY') {
          setState(() { _currency = 'BYN'; _currencySymbol = 'Br'; _rate = 3.25; });
        }
        else if (countryCode == 'RU') {
          setState(() { _currency = 'RUB'; _currencySymbol = '₽'; _rate = 95.0; });
        }
        else if (countryCode == 'KZ') {
          setState(() { _currency = 'KZT'; _currencySymbol = '₸'; _rate = 460.0; });
        }
        else if (countryCode == 'UA') {
          setState(() { _currency = 'UAH'; _currencySymbol = '₴'; _rate = 41.0; });
        }
        else if (countryCode == 'GB') {
          setState(() { _currency = 'GBP'; _currencySymbol = '£'; _rate = 0.79; });
        }
        else if (euroCountries.contains(countryCode)) {
          setState(() { _currency = 'EUR'; _currencySymbol = '€'; _rate = 0.92; });
        }
        else {
          setState(() { _currency = 'USD'; _currencySymbol = '\$'; _rate = 1.0; });
        }
      }
    } catch (e) {
      setState(() { _currency = 'USD'; _currencySymbol = '\$'; _rate = 1.0; });
    }
    if (mounted) setState(() => _loadingRates = false);
  }

  String _formatPrice(double usd) {
    final value = usd * _rate;
    if (_currency == 'USD' || _currency == 'EUR' || _currency == 'GBP') {
      return '$_currencySymbol${value.toStringAsFixed(2)}';
    }
    return '${value.ceil()} $_currencySymbol';
  }
  
  void _addPresentation() {
    final newPresentation = Presentation(
      id: DateTime.now().toString(),
      title: 'Новая презентация',
      slides: [Slide(title: 'Слайд 1', content: ['Введите текст'])],
      createdAt: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(presentation: newPresentation)),
    );
  }
  
  void _openPresentation(Map<String, dynamic> presentation) {
    // TODO: загрузить презентацию по ID
  }
  
  void _inviteMember() {
    if (_inviteEmail.trim().isEmpty) return;
    
    if (!_showUpgrade && _members.length >= _freeMemberLimit) {
      _showUpgradeDialog();
      return;
    }
    
    setState(() {
      _members.add({
        'id': DateTime.now().toString(),
        'name': _inviteEmail.split('@')[0],
        'email': _inviteEmail,
        'role': 'Viewer',
        'avatar': _inviteEmail[0].toUpperCase(),
        'status': 'invited',
        'generations': 0,
      });
      _inviteEmail = '';
    });
    
    _checkLimits();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Приглашение отправлено'), backgroundColor: Color(0xFF1DB954)),
    );
  }
  
  void _removeMember(String id) {
    setState(() {
      _members.removeWhere((m) => m['id'] == id);
    });
    _checkLimits();
  }
  
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Лимит превышен', style: TextStyle(color: Colors.white)),
        content: Text(
          _members.length >= _freeMemberLimit 
            ? 'Бесплатно можно пригласить до $_freeMemberLimit участников.\n\nПриобретите тариф Team или выше для добавления новых участников.'
            : 'Использованы все $_freeGenerationLimit бесплатных генераций.\n\nПриобретите тариф Team или выше для безлимитных генераций.',
          style: const TextStyle(color: Color(0xFF9A9A9A)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _tabController.index = 3; }); // Переход на вкладку тарифов
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
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
        title: const Text(
          'Рабочее пространство',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1DB954),
          labelColor: const Color(0xFF1DB954),
          unselectedLabelColor: const Color(0xFF9A9A9A),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Обзор'),
            Tab(icon: Icon(Icons.people_rounded), text: 'Участники'),
            Tab(icon: Icon(Icons.folder_shared_rounded), text: 'Общие'),
            Tab(icon: Icon(Icons.stars_rounded), text: 'Тарифы'),
          ],
        ),
      ),
      body: _loadingRates
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildMembersTab(),
                _buildSharedTab(),
                _buildTariffsTab(),
              ],
            ),
    );
  }
  
  Widget _buildOverviewTab() {
    final remainingMembers = _freeMemberLimit - _members.length;
    final remainingGenerations = _freeGenerationLimit - _totalGenerations;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Статистика
          Row(
            children: [
              _buildStatCard('Участники', '${_members.length}/$_freeMemberLimit', Icons.people_rounded, remainingMembers > 0 ? Colors.green : Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Генерации', '${_totalGenerations} / $_freeGenerationLimit', Icons.auto_awesome_rounded, remainingGenerations > 0 ? Colors.green : Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard('Презентации', _sharedPresentations.length.toString(), Icons.slideshow_rounded, Colors.blue),
          
          if (_showUpgrade) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(child: Text('Расширьте возможности команды', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          const Text('АКТИВНОСТЬ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._members.where((m) => m['status'] == 'online').map((m) => ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFF1DB954), child: Text(m['avatar'], style: const TextStyle(color: Colors.white, fontSize: 14))),
            title: Text(m['name'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(m['status'] == 'online' ? 'В сети' : 'Был(а) недавно', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
            trailing: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          )),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            Text(title, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembersTab() {
    return Column(
      children: [
        // Приглашение
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border(bottom: BorderSide(color: const Color(0xFF2A2A2A))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => _inviteEmail = v,
                  decoration: InputDecoration(
                    hintText: 'Email для приглашения',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _inviteMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Пригласить', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: _members.length,
            itemBuilder: (_, i) {
              final m = _members[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2A2A2A),
                  child: Text(m['avatar'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                title: Text(m['name'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(m['email'], style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: m['role'] == 'Owner' ? const Color(0xFFFFD700).withOpacity(0.2) : const Color(0xFF1DB954).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m['role'], style: TextStyle(color: m['role'] == 'Owner' ? const Color(0xFFFFD700) : const Color(0xFF1DB954), fontSize: 11)),
                    ),
                    if (m['role'] != 'Owner')
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF9A9A9A), size: 18),
                        onPressed: () => _removeMember(m['id']),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSharedTab() {
    return Column(
      children: [
        // Кнопка новой презентации
        Padding(
          padding: const EdgeInsets.all(16),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _addPresentation,
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
                    Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Создать презентацию', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: _sharedPresentations.length,
            itemBuilder: (_, i) {
              final p = _sharedPresentations[i];
              return ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.slideshow_rounded, color: Color(0xFF1DB954), size: 24),
                ),
                title: Text(p['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('${p['author']} • ${p['updated']} • ${p['slides']} слайдов', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF9A9A9A), size: 16),
                onTap: () => _openPresentation(p),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTariffsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Информация о бесплатном плане
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
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.favorite_rounded, color: Color(0xFF1DB954), size: 24),
                ),
                const SizedBox(height: 12),
                const Text('Бесплатный', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('$_freeMemberLimit участников, $_freeGenerationLimit генераций', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                const SizedBox(height: 16),
                if (_showUpgrade)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Лимит превышен. Выберите платный тариф.', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('ПЛАТНЫЕ ТАРИФЫ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          
          _buildTariffCard(
            title: 'Team',
            price: _teamPriceUSD,
            period: 'месяц',
            description: 'Для небольших команд',
            features: const ['До 10 участников', 'Безлимит генераций', 'Общие презентации', 'Бренд-кит', 'Приоритетная поддержка'],
            isPopular: true,
            onTap: () => _selectTariff('team'),
          ),
          const SizedBox(height: 14),
          
          _buildTariffCard(
            title: 'Business',
            price: _businessPriceUSD,
            period: 'месяц',
            description: 'Для среднего бизнеса',
            features: const ['До 30 участников', 'Безлимит генераций', 'API доступ', 'Интеграции', 'VIP поддержка 24/7'],
            isPopular: false,
            onTap: () => _selectTariff('business'),
          ),
          const SizedBox(height: 14),
          
          _buildTariffCard(
            title: 'Enterprise',
            price: _enterprisePriceUSD,
            period: 'месяц',
            description: 'Для крупных компаний',
            features: const ['Неограниченно участников', 'Безлимит генераций', 'Выделенный сервер', 'SLA 99.9%', 'Персональный менеджер'],
            isPopular: false,
            onTap: () => _selectTariff('enterprise'),
          ),
          
          const SizedBox(height: 24),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _contactSales(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 20),
                    SizedBox(width: 10),
                    Text('Связаться с отделом продаж', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTariffCard({
    required String title,
    required double price,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedTariff == title.toLowerCase();
    final priceLabel = _formatPrice(price);
    
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
                    child: Icon(title == 'Team' ? Icons.group_rounded : (title == 'Business' ? Icons.business_center_rounded : Icons.apartment_rounded), color: isPopular ? Colors.white : const Color(0xFF1DB954), size: 22),
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
                  Text(priceLabel, style: const TextStyle(color: Color(0xFF1DB954), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  if (period.isNotEmpty && price > 0) ...[
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
                children: features.map((feature) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                    const SizedBox(width: 6),
                    Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                )).toList(),
              ),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]) : null,
                      color: isSelected ? null : const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF2A2A2A)),
                    ),
                    child: Center(
                      child: Text(
                        isSelected ? 'Выбран' : 'Выбрать тариф',
                        style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1DB954), fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTariff(String tariff) {
    setState(() => _selectedTariff = tariff);
    _showPaymentDialog(tariff);
  }
  
  void _showPaymentDialog(String tariff) {
    double price = tariff == 'team' ? _teamPriceUSD : (tariff == 'business' ? _businessPriceUSD : _enterprisePriceUSD);
    String period = '/мес';
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Тариф $tariff', style: const TextStyle(color: Colors.white)),
        content: Text('Стоимость: ${_formatPrice(price)} $period\n\nОплата временно недоступна.', style: const TextStyle(color: Color(0xFF9A9A9A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть', style: TextStyle(color: Color(0xFF1DB954)))),
        ],
      ),
    );
  }

  void _contactSales() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.email_rounded, color: Color(0xFF1DB954), size: 26)),
              const SizedBox(height: 16),
              const Text('Отдел продаж', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Напишите нам на почту для подбора тарифа', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))), child: const Row(children: [Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 18), SizedBox(width: 10), Text('team@presentator.ai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))])),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF252525), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Закрыть', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}