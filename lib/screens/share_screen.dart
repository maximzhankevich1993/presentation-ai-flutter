import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShareScreen extends StatefulWidget {
  final String presentationId;
  final String presentationTitle;

  const ShareScreen({super.key, required this.presentationId, required this.presentationTitle});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String _level = 'view';
  final String _link = 'https://prezentator-ai.com/share/abc123';

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Поделиться', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.presentationTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 20.h),
          Text('Уровень доступа', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          _option('view', 'Просмотр', 'Могут только смотреть', Icons.visibility_outlined),
          _option('comment', 'Комментирование', 'Могут оставлять комментарии', Icons.comment_outlined),
          _option('edit', 'Редактирование', 'Могут изменять презентацию', Icons.edit_outlined),
          SizedBox(height: 20.h),
          Text('Ссылка', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(child: Text(_link, style: TextStyle(fontSize: 12, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.copy, color: Color(0xFF1DB954))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _option(String value, String title, String subtitle, IconData icon) {
    final selected = _level == value;
    return GestureDetector(
      onTap: () => setState(() => _level = value),
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1DB954).withOpacity(0.1) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0xFF1DB954).withOpacity(0.4) : Colors.white.withOpacity(0.06)),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? const Color(0xFF1DB954) : Colors.white54, size: 20),
          SizedBox(width: 10.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: const Color(0xFFB3B3B3))),
          ])),
          if (selected) const Icon(Icons.check_circle, color: Color(0xFF1DB954), size: 20),
        ]),
      ),
    );
  }
}