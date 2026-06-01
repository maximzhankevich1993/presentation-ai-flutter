import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../providers/user_provider.dart';
import 'editor_screen.dart';
import 'loading_screen.dart';
import '../models/presentation.dart';
import 'teacher_screen.dart';
import 'premium_screen.dart';

// ═══════════════════════════════════════════════════════════════
// CRYPTO PAYMENT URL
// ═══════════════════════════════════════════════════════════════
const String CRYPTO_PAYMENT_URL = 'https://pay.cryptocloud.plus/pos/L1dhlsPbHiuNO7Fv';

class WorkspaceScreen extends StatefulWidget {
  final String countryCode;
  const WorkspaceScreen({super.key, required this.countryCode});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadWorkspaceData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _workspaceNameController.dispose();
    super.dispose();
  }

  void _openCryptoPayment(double amount) {
    final url = amount > 0 ? '$CRYPTO_PAYMENT_URL?amount=$amount' : CRYPTO_PAYMENT_URL;
    html.window.open(url, '_blank');
    
    // Исправленный SnackBar (убрана ошибка с const)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('💸 After payment, subscription activates in 1-2 minutes. Promo code CRYPTO10 → second month free!'),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 5),
      ),
    );
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
            _workspaceName = data['name'] ?? 'My Team';
            _members = List<Map<String, dynamic>>.from(data['members'] ?? []);
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
        SnackBar(
          content: const Text('Enter workspace name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _workspaceId = DateTime.now().toString();
      _workspaceName = _workspaceNameController.text.trim();
      _hasWorkspace = true;
      _members = [
        {'id': '1', 'name': 'Me', 'email': 'me@example.com', 'role': 'Owner', 'avatar': 'M', 'status': 'online'},
      ];
      _presentations = [];
      _usedGenerations = 0;
    });
    _saveWorkspaceData();
  }

  void _generatePresentation() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter presentation topic'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.isPremium;
    
    if (!isPremium && _usedGenerations >= _maxGenerations) {
      _showLimitDialog();
      return;
    }
    
    setState(() {
      _usedGenerations++;
      _presentations.insert(0, {
        'id': DateTime.now().toString(),
        'title': topic,
        'updated': 'Just now',
        'author': 'Me',
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
        title: const Text('Limit reached', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(
          'You have used all $_maxGenerations free generations for this workspace.\n\nSubscribe to continue creating unlimited presentations.',
          style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _inviteMember() {
    if (_inviteEmail.trim().isEmpty) return;
    
    if (_members.length >= _maxMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Free workspace limited to $_maxMembers members'),
          backgroundColor: Colors.orange,
        ),
      );
      _showUpgradeForMoreMembers();
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
      const SnackBar(content: Text('Invitation sent'), backgroundColor: Color(0xFF1DB954)),
    );
  }
  
  void _showUpgradeForMoreMembers() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Upgrade for more members', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text(
          'Free workspace is limited to 5 members.\n\nUpgrade to Team or Business plan for unlimited members.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Upgrade', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _removeMember(String id) {
    setState(() {
      _members.removeWhere((m) => m['id'] == id);
    });
    _saveWorkspaceData();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;
    final isPremium = userProvider.isPremium;
    final remaining = isPremium ? 999 : _maxGenerations - _usedGenerations;
    
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
        title: Text(_workspaceName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.group_rounded, color: Colors.white, size: 32)),
                      const SizedBox(height: 16),
                      Text(_workspaceName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Members: ${_members.length}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Crypto note for workspace upgrade
                if (!isPremium && _members.length >= 3)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF627EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF627EEA).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('💡 Upgrade for unlimited members', style: TextStyle(color: Color(0xFF627EEA), fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Pay with USDT — no fees, no banks', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        const SizedBox(height: 4),
                        const Text('🎁 Promo code CRYPTO10 → second month free', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF627EEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('💳 Upgrade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Text('CREATE PRESENTATION', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'What is your presentation about?',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Slides:', style: TextStyle(color: Color(0xFF9A9A9A))),
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
                
                if (!isPremium && remaining <= 3)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.1) : const Color(0xFF1DB954).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: remaining <= 0 ? const Color(0xFFFF3B30).withOpacity(0.3) : const Color(0xFF1DB954).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(remaining <= 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded, color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(remaining <= 0 ? 'Free generations used up.' : '$remaining of $_maxGenerations free generations left', style: TextStyle(color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954), fontSize: 13))),
                        if (remaining <= 0)
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Subscribe', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isPremium || _usedGenerations < _maxGenerations) ? _generatePresentation : _showLimitDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isPremium || _usedGenerations < _maxGenerations) ? const Color(0xFF1DB954) : const Color(0xFF4A4A4A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text((isPremium || _usedGenerations < _maxGenerations) ? 'Create Presentation' : 'Limit reached', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF2A2A2A)),
                const SizedBox(height: 24),
                
                const Text('TEAM MEMBERS', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => _inviteEmail = v,
                        decoration: InputDecoration(
                          hintText: 'Email to invite',
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Invite'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._members.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: m['role'] == 'Owner' ? const Color(0xFFFFD700) : const Color(0xFF2A2A2A),
                        child: Text(m['avatar'], style: TextStyle(color: m['role'] == 'Owner' ? Colors.black : Colors.white, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            Text(m['email'], style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                          ],
                        ),
                      ),
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
                )),
                
                const SizedBox(height: 12),
                if (!isPremium && _members.length >= 3)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFF1DB954), size: 18),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Free workspace limited to 5 members. Upgrade for unlimited members.', style: TextStyle(color: Color(0xFF1DB954), fontSize: 13))),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(20)),
                            child: const Text('Upgrade', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
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
        title: const Text('Workspace', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 32)),
                      const SizedBox(height: 16),
                      const Text('Create a Team', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Work on presentations together', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text('CREATE WORKSPACE', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(
                  controller: _workspaceNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Workspace name',
                    hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
                    prefixIcon: const Icon(Icons.group_rounded, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createWorkspace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create Free Workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF1DB954), size: 16),
                      SizedBox(width: 8),
                      Expanded(child: Text('Free workspace includes: 5 members, 5 presentations/month, 10 slides per presentation', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}