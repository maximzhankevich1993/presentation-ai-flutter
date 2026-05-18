import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'editor_screen.dart';
import 'loading_screen.dart';
import '../models/presentation.dart';

class WorkspaceScreen extends StatefulWidget {
  final String countryCode;
  const WorkspaceScreen({super.key, required this.countryCode});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasWorkspace = false;
  bool _isLoading = true;
  String _workspaceName = '';
  String _workspaceId = '';
  String _inviteEmail = '';
  int _topicMaxSlides = 5;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _workspaceNameController = TextEditingController();
  
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _presentations = [];
  int _usedGenerations = 0;
  final int _maxGenerations = 5;
  final int _maxMembers = 5;
  
  String _currency = 'USD';
  String _currencySymbol = '\$';
  double _rate = 1.0;
  bool _loadingRates = true;
  
  final double _teamPriceUSD = 49.99;
  final double _businessPriceUSD = 99.99;
  final double _enterprisePriceUSD = 199.99;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _detectCurrency();
    _loadWorkspaceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    _workspaceNameController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrency() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final countryCode = (data['country_code'] as String? ?? 'US').toUpperCase();
        
        if (countryCode == 'BY') {
          setState(() { _currency = 'BYN'; _currencySymbol = 'Br'; _rate = 3.25; });
        } else if (countryCode == 'RU') {
          setState(() { _currency = 'RUB'; _currencySymbol = '₽'; _rate = 95.0; });
        } else if (countryCode == 'KZ') {
          setState(() { _currency = 'KZT'; _currencySymbol = '₸'; _rate = 460.0; });
        } else {
          setState(() { _currency = 'USD'; _currencySymbol = '\$'; _rate = 1.0; });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingRates = false);
  }

  String _formatPrice(double usd) {
    if (usd == 0) return 'Бесплатно';
    final value = usd * _rate;
    if (_currency == 'USD' || _currency == 'EUR' || _currency == 'GBP') {
      return '$_currencySymbol${value.toStringAsFixed(2)}';
    }
    return '${value.ceil()} $_currencySymbol';
  }

  Future<void> _saveWorkspaceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'id': _workspaceId,
        'name': _workspaceName,
        'members': _members,
        'presentations': _presentations,
        'usedGenerations': _usedGenerations,
      };
      await prefs.setString('workspace_data', json.encode(data));
      await prefs.setBool('has_workspace', true);
    } catch (e) {
      print('Error saving workspace: $e');
    }
  }

  Future<void> _loadWorkspaceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasWorkspace = prefs.getBool('has_workspace') ?? false;
      
      if (hasWorkspace) {
        final savedData = prefs.getString('workspace_data');
        if (savedData != null) {
          final data = json.decode(savedData);
          setState(() {
            _workspaceId = data['id'] ?? DateTime.now().toString();
            _workspaceName = data['name'] ?? 'Моя команда';
            _members = List<Map<String, dynamic>>.from(data['members'] ?? [
              {'id': '1', 'name': 'Я', 'email': 'me@example.com', 'role': 'Owner', 'avatar': 'Я', 'status': 'online'},
            ]);
            _presentations = List<Map<String, dynamic>>.from(data['presentations'] ?? []);
            _usedGenerations = data['usedGenerations'] ?? 0;
            _hasWorkspace = true;
          });
        } else {
          _hasWorkspace = false;
        }
      } else {
        _hasWorkspace = false;
      }
    } catch (e) {
      print('Error loading workspace: $e');
      _hasWorkspace = false;
    }
    setState(() => _isLoading = false);
  }

  void _createWorkspace() {
    if (_workspaceNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название пространства'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() {
      _workspaceId = DateTime.now().toString();
      _workspaceName = _workspaceNameController.text.trim();
      _hasWorkspace = true;
      _members = [
        {'id': '1', 'name': 'Я', 'email': 'me@example.com', 'role': 'Owner', 'avatar': 'Я', 'status': 'online'},
      ];
      _presentations = [];
      _usedGenerations = 0;
    });
    _saveWorkspaceData();
  }

  void _editWorkspaceName() {
    final controller = TextEditingController(text: _workspaceName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Изменить название', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Название пространства',
            hintStyle: TextStyle(color: Color(0xFF4A4A4A)),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('Отмена', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              setState(() => _workspaceName = controller.text);
              Navigator.pop(_);
              _saveWorkspaceData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _generatePresentation() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите тему презентации'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_usedGenerations >= _maxGenerations) {
      _showLimitDialog();
      return;
    }
    
    setState(() {
      _usedGenerations++;
      _presentations.insert(0, {
        'id': DateTime.now().toString(),
        'title': topic,
        'updated': 'Только что',
        'author': 'Я',
        'slides': _topicMaxSlides,
      });
    });
    _saveWorkspaceData();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(topic: topic, slideCount: _topicMaxSlides),
      ),
    );
  }
  
  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Лимит генераций', style: TextStyle(color: Colors.white)),
        content: Text(
          'Вы использовали все $_maxGenerations бесплатных генераций.\n\nПриобретите тариф Team или выше для безлимитных генераций.',
          style: const TextStyle(color: Color(0xFF9A9A9A)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.index = 2;
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
    );
  }

  void _inviteMember() {
    if (_inviteEmail.trim().isEmpty) return;
    
    if (_members.length >= _maxMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Бесплатно до $_maxMembers участников. Приобретите тариф Team'), backgroundColor: Colors.orange),
      );
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
      });
      _inviteEmail = '';
    });
    _saveWorkspaceData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Приглашение отправлено'), backgroundColor: Color(0xFF1DB954)),
    );
  }
  
  void _removeMember(String id) {
    setState(() {
      _members.removeWhere((m) => m['id'] == id);
    });
    _saveWorkspaceData();
  }
  
  void _deletePresentation(String id) {
    setState(() {
      _presentations.removeWhere((p) => p['id'] == id);
    });
    _saveWorkspaceData();
  }
  
  void _openPresentation(Map<String, dynamic> presentation) {
    // Создаём презентацию для редактирования
    final pres = Presentation(
      id: presentation['id'],
      title: presentation['title'],
      slides: [Slide(title: 'Слайд 1', content: ['Загрузите сохранённую презентацию'])],
      createdAt: DateTime.now(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(presentation: pres)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))),
      );
    }
    
    if (!_hasWorkspace) {
      return _buildNoWorkspaceScreen();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _workspaceName,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF1DB954)),
            onPressed: _editWorkspaceName,
            tooltip: 'Изменить название',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1DB954),
          labelColor: const Color(0xFF1DB954),
          unselectedLabelColor: const Color(0xFF9A9A9A),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Обзор'),
            Tab(icon: Icon(Icons.people_rounded), text: 'Участники'),
            Tab(icon: Icon(Icons.stars_rounded), text: 'Тарифы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMembersTab(),
          _buildTariffsTab(),
        ],
      ),
    );
  }
  
  Widget _buildNoWorkspaceScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Рабочее пространство', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('Создайте команду', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Работайте над презентациями вместе', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('СОЗДАТЬ ПРОСТРАНСТВО', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _workspaceNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Название пространства',
                      hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                      prefixIcon: const Icon(Icons.group_rounded, color: Color(0xFF1DB954)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _createWorkspace,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Создать бесплатно', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('ТАРИФЫ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildTariffCard(
              title: 'Бесплатный',
              price: 0,
              period: '',
              description: 'Для старта',
              features: const ['5 участников', '5 генераций', 'Общие презентации'],
              isPopular: false,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildTariffCard(
              title: 'Team',
              price: _teamPriceUSD,
              period: '/мес',
              description: 'Для небольших команд',
              features: const ['До 15 участников', 'Безлимит генераций', 'Приоритетная поддержка', 'Бренд-кит'],
              isPopular: true,
              onTap: () => _showPaymentDialog('team'),
            ),
            const SizedBox(height: 12),
            _buildTariffCard(
              title: 'Business',
              price: _businessPriceUSD,
              period: '/мес',
              description: 'Для среднего бизнеса',
              features: const ['До 50 участников', 'Безлимит генераций', 'VIP поддержка 24/7', 'API доступ'],
              isPopular: false,
              onTap: () => _showPaymentDialog('business'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    final remainingGenerations = _maxGenerations - _usedGenerations;
    final remainingMembers = _maxMembers - _members.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Участники', '${_members.length}/$_maxMembers', Icons.people_rounded, remainingMembers > 0 ? Colors.green : Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Генерации', '$_usedGenerations/$_maxGenerations', Icons.auto_awesome_rounded, remainingGenerations > 0 ? Colors.green : Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard('Презентации', _presentations.length.toString(), Icons.slideshow_rounded, Colors.blue),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('СОЗДАТЬ ПРЕЗЕНТАЦИЮ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'О чём презентация?',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Слайдов:', style: TextStyle(color: Color(0xFF9A9A9A))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: _topicMaxSlides.toDouble(),
                        min: 3,
                        max: 10,
                        divisions: 7,
                        activeColor: const Color(0xFF1DB954),
                        inactiveColor: const Color(0xFF2A2A2A),
                        onChanged: (v) => setState(() => _topicMaxSlides = v.round()),
                      ),
                    ),
                    Text('$_topicMaxSlides', style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _generatePresentation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          if (_presentations.isNotEmpty) ...[
            const Text('ИСТОРИЯ ПРЕЗЕНТАЦИЙ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._presentations.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.slideshow_rounded, color: Color(0xFF1DB954), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text('${p['slides']} слайдов • ${p['updated']}', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9A9A9A), size: 20),
                        onPressed: () => _deletePresentation(p['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF1DB954), size: 16),
                        onPressed: () => _openPresentation(p),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
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
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1DB954))),
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
                  backgroundColor: m['role'] == 'Owner' ? const Color(0xFFFFD700) : const Color(0xFF2A2A2A),
                  child: Text(m['avatar'], style: TextStyle(color: m['role'] == 'Owner' ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                title: Text(m['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
  
  Widget _buildTariffsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                const Text('Текущий план: Бесплатный', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('$_maxMembers участников, $_maxGenerations генераций', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                if (_usedGenerations >= _maxGenerations || _members.length >= _maxMembers)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
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
            period: '/мес',
            description: 'Для небольших команд',
            features: const ['До 15 участников', 'Безлимит генераций', 'Приоритетная поддержка', 'Бренд-кит', 'API доступ'],
            isPopular: true,
            onTap: () => _showPaymentDialog('team'),
          ),
          const SizedBox(height: 14),
          _buildTariffCard(
            title: 'Business',
            price: _businessPriceUSD,
            period: '/мес',
            description: 'Для среднего бизнеса',
            features: const ['До 50 участников', 'Безлимит генераций', 'VIP поддержка 24/7', 'API + Webhook', 'Интеграции'],
            isPopular: false,
            onTap: () => _showPaymentDialog('business'),
          ),
          const SizedBox(height: 14),
          _buildTariffCard(
            title: 'Enterprise',
            price: _enterprisePriceUSD,
            period: '/мес',
            description: 'Для крупных компаний',
            features: const ['Неограниченно участников', 'Безлимит генераций', 'Выделенный сервер', 'SLA 99.9%', 'Персональный менеджер'],
            isPopular: false,
            onTap: () => _showPaymentDialog('enterprise'),
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
    final priceLabel = price == 0 ? 'Бесплатно' : _formatPrice(price);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPopular ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A), width: isPopular ? 1.5 : 1),
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
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Популярный', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(priceLabel, style: const TextStyle(color: Color(0xFF1DB954), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              if (period.isNotEmpty && price > 0) ...[
                const SizedBox(width: 4),
                Text(period, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
              ],
              const Spacer(),
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
                  gradient: price == 0 ? null : const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                  color: price == 0 ? const Color(0xFF2A2A2A) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    price == 0 ? 'Текущий план' : 'Выбрать',
                    style: TextStyle(color: price == 0 ? Colors.grey : Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPaymentDialog(String tariff) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Тариф $tariff', style: const TextStyle(color: Colors.white)),
        content: Text('Стоимость: ${_formatPrice(tariff == 'team' ? _teamPriceUSD : tariff == 'business' ? _businessPriceUSD : _enterprisePriceUSD)} ${_currency == 'RUB' ? '₽' : _currency == 'BYN' ? 'Br' : _currency == 'KZT' ? '₸' : '\$'}/мес\n\nОплата временно недоступна.', style: const TextStyle(color: Color(0xFF9A9A9A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть', style: TextStyle(color: Color(0xFF1DB954)))),
        ],
      ),
    );
  }
}