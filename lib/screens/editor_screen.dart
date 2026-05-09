import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import 'share_screen.dart';

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Presentation _presentation;
  late List<TextEditingController> _titleControllers;
  late List<List<TextEditingController>> _contentControllers;

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _initControllers();
  }

  void _initControllers() {
    _titleControllers = _presentation.slides
        .map((s) => TextEditingController(text: s.title))
        .toList();
    _contentControllers = _presentation.slides
        .map((s) => s.content.map((c) => TextEditingController(text: c)).toList())
        .toList();
  }

  void _saveAll() {
    for (int i = 0; i < _presentation.slides.length; i++) {
      _presentation.slides[i].title = _titleControllers[i].text;
      _presentation.slides[i].content =
          _contentControllers[i].map((c) => c.text).toList();
    }
  }

  void _addSlide() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= up.maxSlidesPerPresentation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Максимум ${up.maxSlidesPerPresentation} слайдов')),
      );
      return;
    }
    setState(() {
      _presentation.slides.add(Slide(title: 'Новый слайд', content: ['Введите текст']));
      _titleControllers.add(TextEditingController(text: 'Новый слайд'));
      _contentControllers.add([TextEditingController(text: 'Введите текст')]);
    });
  }

  void _deleteSlide(int index) {
    if (_presentation.slides.length <= 1) return;
    setState(() {
      _presentation.slides.removeAt(index);
      _titleControllers[index].dispose();
      for (var c in _contentControllers[index]) { c.dispose(); }
      _titleControllers.removeAt(index);
      _contentControllers.removeAt(index);
    });
  }

  void _duplicateSlide(int index) {
    setState(() {
      final slide = _presentation.slides[index];
      _presentation.slides.insert(
        index + 1,
        Slide(title: '${slide.title} (копия)', content: List.from(slide.content)),
      );
      _titleControllers.insert(index + 1, TextEditingController(text: '${slide.title} (копия)'));
      _contentControllers.insert(index + 1, slide.content.map((c) => TextEditingController(text: c)).toList());
    });
  }

  void _addContentItem(int slideIndex) {
    setState(() {
      _contentControllers[slideIndex].add(TextEditingController(text: 'Новый пункт'));
    });
  }

  void _removeContentItem(int slideIndex, int itemIndex) {
    if (_contentControllers[slideIndex].length <= 1) return;
    setState(() {
      _contentControllers[slideIndex][itemIndex].dispose();
      _contentControllers[slideIndex].removeAt(itemIndex);
    });
  }

  Future<void> _improveSlide(int index) async {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))));
    try {
      final improvedTitle = await AiImproveService.improveText(_titleControllers[index].text);
      final improvedContent = <String>[];
      for (final c in _contentControllers[index]) {
        improvedContent.add(await AiImproveService.improveText(c.text));
      }
      Navigator.pop(context);
      setState(() {
        _titleControllers[index].text = improvedTitle;
        for (int i = 0; i < improvedContent.length && i < _contentControllers[index].length; i++) {
          _contentControllers[index][i].text = improvedContent[i];
        }
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  void _export() {
    _saveAll();
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 16.h),
            Text('Экспорт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFF1DB954)),
              title: const Text('PPTX', style: TextStyle(color: Colors.white)),
              subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком', style: TextStyle(color: Colors.grey)),
              onTap: () { Navigator.pop(ctx); ExportService.exportToPPTX(presentation: _presentation, isPremium: isPremium); },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey),
              title: const Text('PDF', style: TextStyle(color: Colors.white)),
              subtitle: Text(isPremium ? 'Доступно' : 'Premium', style: TextStyle(color: Colors.grey)),
              onTap: isPremium ? () { Navigator.pop(ctx); ExportService.exportToPDF(presentation: _presentation, isPremium: true); } : null,
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveAll();
    for (var c in _titleControllers) { c.dispose(); }
    for (var list in _contentControllers) {
      for (var c in list) { c.dispose(); }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(_presentation.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: _addSlide, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1DB954), size: 22), tooltip: 'Добавить слайд'),
          IconButton(onPressed: _export, icon: const Icon(Icons.download, color: Colors.white70, size: 20), tooltip: 'Экспорт'),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12.w),
        itemCount: _presentation.slides.length,
        itemBuilder: (context, index) => _buildSlideCard(index),
      ),
    );
  }

  Widget _buildSlideCard(int index) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Шапка карточки
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(8)),
              child: Text('Слайд ${index + 1}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const Spacer(),
            IconButton(onPressed: () => _duplicateSlide(index), icon: const Icon(Icons.copy, size: 18, color: Colors.white54), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            IconButton(onPressed: () => _improveSlide(index), icon: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF1DB954)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            IconButton(onPressed: () => _deleteSlide(index), icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF3B30)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
          SizedBox(height: 10.h),
          // Заголовок
          TextField(
            controller: _titleControllers[index],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Заголовок слайда',
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: 8.h),
          // Пункты
          ..._contentControllers[index].asMap().entries.map((entry) {
            final i = entry.key;
            final ctrl = entry.value;
            return Row(children: [
              Container(width: 6.w, height: 6.w, margin: EdgeInsets.only(right: 8.w), decoration: const BoxDecoration(color: Color(0xFF1DB954), shape: BoxShape.circle)),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                  decoration: InputDecoration(
                    hintText: 'Пункт ${i + 1}',
                    hintStyle: TextStyle(color: Colors.white12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(onPressed: () => _removeContentItem(index, i), icon: const Icon(Icons.close, size: 14, color: Color(0xFFFF3B30)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]);
          }),
          SizedBox(height: 6.h),
          TextButton.icon(
            onPressed: () => _addContentItem(index),
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF1DB954)),
            label: const Text('Добавить пункт', style: TextStyle(color: Color(0xFF1DB954), fontSize: 11)),
          ),
        ]),
      ),
    );
  }
}