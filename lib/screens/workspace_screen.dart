import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
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
  bool _isLoading = true;
  String _inviteEmail = '';
  
  // Демо-данные
  final List<Map<String, dynamic>> _members = [
    {'id': '1', 'name': 'Алексей Иванов', 'email': 'alex@company.com', 'role': 'Owner', 'avatar': 'А', 'status': 'online'},
    {'id': '2', 'name': 'Мария Петрова', 'email': 'maria@company.com', 'role': 'Admin', 'avatar': 'М', 'status': 'online'},
    {'id': '3', 'name': 'Дмитрий Сидоров', 'email': 'dmitry@company.com', 'role': 'Editor', 'avatar': 'Д', 'status': 'away'},
  ];
  
  final List<Map<String, dynamic>> _presentations = [
    {'id': '1', 'title': 'План продаж 2024', 'updated': '2 часа назад', 'author': 'Алексей', 'slides': 8},
    {'id': '2', 'title': 'Отчёт по маркетингу', 'updated': 'Вчера', 'author': 'Мария', 'slides': 12},
    {'id': '3', 'title': 'Стратегия развития', 'updated': '3 дня назад', 'author': 'Дмитрий', 'slides': 15},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Имитация загрузки
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
  
  void _inviteMember() {
    if (_inviteEmail.trim().isEmpty) return;
    
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Приглашение отправлено'), backgroundColor: Color(0xFF1DB954)),
    );
  }
  
  void _removeMember(String id) {
    setState(() {
      _members.removeWhere((m) => m['id'] == id);
    });
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
            Tab(icon: Icon(Icons.people_rounded), text: 'Участники'),
            Tab(icon: Icon(Icons.folder_shared_rounded), text: 'Презентации'),
            Tab(icon: Icon(Icons.info_outline_rounded), text: 'О пространстве'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(),
                _buildPresentationsTab(),
                _buildInfoTab(),
              ],
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
                      child: Text(
                        m['role'], 
                        style: TextStyle(
                          color: m['role'] == 'Owner' ? const Color(0xFFFFD700) : const Color(0xFF1DB954), 
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
  
  Widget _buildPresentationsTab() {
    return Column(
      children: [
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
                    Text('Создать презентацию', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _presentations.length,
            itemBuilder: (_, i) {
              final p = _presentations[i];
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
                onTap: () {
                  // TODO: открыть презентацию
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.group_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Командная работа',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Создавайте презентации вместе с коллегами',
            style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.people_rounded, 'Участников', '${_members.length}'),
                const Divider(color: Color(0xFF2A2A2A), height: 1),
                _buildInfoRow(Icons.slideshow_rounded, 'Презентаций', '${_presentations.length}'),
                const Divider(color: Color(0xFF2A2A2A), height: 1),
                _buildInfoRow(Icons.storage_rounded, 'Хранилище', '15 МБ / 100 МБ'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: Color(0xFFFFD700), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Больше возможностей', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700)),
                      Text('До 50 участников, безлимит презентаций', style: TextStyle(color: Color(0xFFFFD700).withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Premium', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1DB954), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}