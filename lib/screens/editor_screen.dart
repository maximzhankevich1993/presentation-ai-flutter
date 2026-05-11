import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import '../services/image_service.dart';
import 'home_screen.dart';

class _T {
  static const bgBase = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard = Color(0xFF1E1E1E);
  static const bgHover = Color(0xFF252525);
  static const border = Color(0xFF2A2A2A);
  static const txtPrimary = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted = Color(0xFF4A4A4A);
  static const accent = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim = Color(0xFF1DB95420);
  static const danger = Color(0xFFFF3B30);
  static const gold = Color(0xFFFFD700);
}

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with TickerProviderStateMixin {
  late Presentation _p;
  late List<TextEditingController> _tc;
  late List<List<TextEditingController>> _cc;
  late List<String?> _ci, _cb;
  late List<double> _fs;
  late List<String> _fn;
  int _as = 0, _sbi = 0, _iu = 0;
  String _gf = 'Inter';
  bool _nc = false, _ppo = true, _ii = false;
  String _apt = 'design';
  Color _gfc = Colors.black;
  late List<Color?> _sfc;
  late List<String> _tr;
  final Map<int, String?> _ai = {};
  final _sc = ScrollController();

  final List<Map<String, dynamic>> _fb = [
    {'type': 'solid', 'color': Colors.white, 'label': 'Белый'},
    {'type': 'solid', 'color': const Color(0xFF0F0F0F), 'label': 'Чёрный'},
    {'type': 'solid', 'color': const Color(0xFFFFF8E7), 'label': 'Кремовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF1a1a2e), const Color(0xFF16213e)], 'label': 'Midnight'},
    {'type': 'gradient', 'colors': [const Color(0xFF667eea), const Color(0xFF764ba2)], 'label': 'Фиолет'},
    {'type': 'gradient', 'colors': [const Color(0xFF4facfe), const Color(0xFF00f2fe)], 'label': 'Голубой'},
    {'type': 'gradient', 'colors': [const Color(0xFFf093fb), const Color(0xFFf5576c)], 'label': 'Розовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF434343), const Color(0xFF000000)], 'label': 'Уголь'},
  ];

  final List<Map<String, dynamic>> _pb = [
    {'type': 'gradient', 'colors': [const Color(0xFF1DB954), const Color(0xFF191414)], 'label': 'Spotify'},
    {'type': 'gradient', 'colors': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], 'label': 'Неон'},
    {'type': 'gradient', 'colors': [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)], 'label': 'Cosmos'},
    {'type': 'gradient', 'colors': [const Color(0xFF11998e), const Color(0xFF38ef7d)], 'label': 'Mint'},
    {'type': 'gradient', 'colors': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], 'label': 'Закат'},
    {'type': 'gradient', 'colors': [const Color(0xFFFFE000), const Color(0xFF799F0C)], 'label': 'Лимон'},
    {'type': 'gradient', 'colors': [const Color(0xFF00b4db), const Color(0xFF0083B0)], 'label': 'Океан'},
    {'type': 'solid', 'color': const Color(0xFF1A1A2E), 'label': 'Navy'},
  ];

  static const List<Map<String, dynamic>> _atr = [
    {'id': 'none', 'label': 'Нет', 'icon': Icons.block_rounded, 'premium': false},
    {'id': 'fade', 'label': 'Затухание', 'icon': Icons.blur_on_rounded, 'premium': false},
    {'id': 'slide', 'label': 'Слайд', 'icon': Icons.swap_horiz_rounded, 'premium': true},
    {'id': 'zoom', 'label': 'Зум', 'icon': Icons.zoom_in_rounded, 'premium': true},
    {'id': 'flip', 'label': 'Флип', 'icon': Icons.flip_rounded, 'premium': true},
    {'id': 'cube', 'label': 'Куб', 'icon': Icons.view_in_ar_rounded, 'premium': true},
  ];

  String? get _logo => Provider.of<LogoProvider>(context, listen: true).logoUrl;

  @override
  void initState() {
    super.initState();
    _p = widget.presentation;
    _ci = List.filled(_p.slides.length, null);
    _cb = List.filled(_p.slides.length, null);
    _fs = List.filled(_p.slides.length, 9.0);
    _fn = List.filled(_p.slides.length, 'Inter');
    _sfc = List.filled(_p.slides.length, null);
    _tr = List.filled(_p.slides.length, 'none');
    _tc = _p.slides.map((s) => TextEditingController(text: s.title)).toList();
    _cc = _p.slides.map((s) => s.content.map((c) => TextEditingController(text: c)).toList()).toList();
    _loadImages();
    _countUp();
  }

  void _countUp() => _iu = _ci.where((i) => i != null).length;

  Future<void> _loadImages() async {
    for (int i = 0; i < _p.slides.length; i++) {
      _ai[i] = await ImageService.searchImage(_tc[i].text.isNotEmpty ? _tc[i].text : _p.title);
      if (mounted) setState(() {});
    }
  }

  void _save() {
    for (int i = 0; i < _p.slides.length; i++) {
      _p.slides[i].title = _tc[i].text;
      _p.slides[i].content = _cc[i].map((c) => c.text).toList();
    }
  }

  void _addSlide() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_p.slides.length >= up.maxSlidesPerPresentation) {
      _toast('Максимум ${up.maxSlidesPerPresentation} слайдов');
      return;
    }
    setState(() {
      final x = _as + 1;
      _p.slides.insert(x, Slide(title: 'Новый слайд', content: ['Введите текст']));
      _tc.insert(x, TextEditingController(text: 'Новый слайд'));
      _cc.insert(x, [TextEditingController(text: 'Введите текст')]);
      _ci.insert(x, null);
      _cb.insert(x, null);
      _fs.insert(x, 9.0);
      _fn.insert(x, _gf);
      _sfc.insert(x, null);
      _tr.insert(x, 'none');
      _as = x;
    });
  }

  void _delSlide(int i) {
    if (_p.slides.length <= 1) return;
    setState(() {
      _tc[i].dispose();
      for (var c in _cc[i]) c.dispose();
      _p.slides.removeAt(i);
      _tc.removeAt(i);
      _cc.removeAt(i);
      _ci.removeAt(i);
      _cb.removeAt(i);
      _fs.removeAt(i);
      _fn.removeAt(i);
      _ai.remove(i);
      _sfc.removeAt(i);
      _tr.removeAt(i);
      if (_as >= _p.slides.length) _as = _p.slides.length - 1;
    });
    _countUp();
  }

  void _dupSlide(int i) {
    setState(() {
      final x = i + 1;
      _p.slides.insert(x, Slide(title: _p.slides[i].title, content: List.from(_p.slides[i].content)));
      _tc.insert(x, TextEditingController(text: _tc[i].text));
      _cc.insert(x, _cc[i].map((c) => TextEditingController(text: c.text)).toList());
      _ci.insert(x, _ci[i]);
      _cb.insert(x, _cb[i]);
      _fs.insert(x, _fs[i]);
      _fn.insert(x, _fn[i]);
      _sfc.insert(x, _sfc[i]);
      _tr.insert(x, _tr[i]);
      _as = x;
    });
    _countUp();
  }

  void _moveSlide(int f, int t) {
    if (t < 0 || t >= _p.slides.length) return;
    setState(() {
      void sw<T>(List<T> l) { final x = l[f]; l[f] = l[t]; l[t] = x; }
      sw(_p.slides); sw(_tc); sw(_cc); sw(_ci); sw(_cb); sw(_fs); sw(_fn); sw(_sfc); sw(_tr);
      _as = t;
    });
  }

  void _addItem(int i) => setState(() => _cc[i].add(TextEditingController(text: 'Новый пункт')));

  void _remItem(int s, int i) {
    if (_cc[s].length <= 1) return;
    setState(() { _cc[s][i].dispose(); _cc[s].removeAt(i); });
  }

  Future<void> _improveSlide(int i) async {
    setState(() => _ii = true);
    try {
      final t = await AiImproveService.improveText(_tc[i].text);
      final cs = <String>[];
      for (final c in _cc[i]) cs.add(await AiImproveService.improveText(c.text));
      if (!mounted) return;
      setState(() {
        _tc[i].text = t;
        for (int j = 0; j < cs.length && j < _cc[i].length; j++) _cc[i][j].text = cs[j];
      });
      _toast('Текст улучшен', success: true);
    } catch (e) {
      _toast('Ошибка: $e', error: true);
    } finally {
      if (mounted) setState(() => _ii = false);
    }
  }

  Future<void> _uploadImage(int i) async {
    if (!Provider.of<UserProvider>(context, listen: false).isPremium) {
      _toast('Замена картинок — Premium', warning: true);
      return;
    }
    final inp = html.FileUploadInputElement()..accept = 'image/*';
    inp.click();
    inp.onChange.listen((e) {
      final f = inp.files?.first;
      if (f == null) return;
      final r = html.FileReader();
      r.readAsDataUrl(f);
      r.onLoad.listen((_) => setState(() => _ci[i] = r.result as String));
    });
  }

  Future<void> _uploadBg(int i) async {
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    final u = _cb.where((b) => b != null).length;
    if (!p && u >= 10 && _cb[i] == null) {
      _toast('10 фонов бесплатно', warning: true);
      return;
    }
    final inp = html.FileUploadInputElement()..accept = 'image/*';
    inp.click();
    inp.onChange.listen((e) {
      final f = inp.files?.first;
      if (f == null) return;
      final r = html.FileReader();
      r.readAsDataUrl(f);
      r.onLoad.listen((_) => setState(() => _cb[i] = r.result as String));
    });
  }

  Decoration _deco(int i) {
    if (_cb[i] != null) return BoxDecoration(image: DecorationImage(image: NetworkImage(_cb[i]!), fit: BoxFit.cover), borderRadius: BorderRadius.circular(12));
    final bg = _fb[_sbi.clamp(0, _fb.length - 1)];
    if (bg['type'] == 'gradient') return BoxDecoration(gradient: LinearGradient(colors: bg['colors'] as List<Color>, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12));
    return BoxDecoration(color: bg['color'] as Color, borderRadius: BorderRadius.circular(12));
  }

  bool _dark(int i) {
    if (_cb[i] != null) return true;
    final bg = _fb[_sbi.clamp(0, _fb.length - 1)];
    if (bg['type'] == 'solid') return (bg['color'] as Color).computeLuminance() < 0.5;
    return true;
  }

  void _toast(String m, {bool success = false, bool error = false, bool warning = false}) {
    Color c = _T.bgCard;
    if (success) c = _T.accent.withOpacity(0.9);
    if (error) c = _T.danger.withOpacity(0.9);
    if (warning) c = _T.gold.withOpacity(0.9);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2),
    ));
  }

  void _export() {
    _save();
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExportSheet(isPremium: p, presentation: _p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _dark(_as);
    if (_sfc[_as] == null) _gfc = d ? Colors.white : Colors.black;
    return Scaffold(
      backgroundColor: _T.bgBase,
      body: Column(children: [
        _TopBar(title: _p.title, slideCount: _p.slides.length, uploadsUsed: _iu, onBack: () { _save(); Navigator.pop(context); }, onExport: _export),
        const Divider(color: _T.border, height: 1),
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 200), width: _nc ? 48 : 200, child: _SlideNavigator(slides: _p.slides, titleControllers: _tc, activeIndex: _as, collapsed: _nc, customBgs: _cb, backgrounds: _fb, selectedBgIndex: _sbi, onSelect: (i) => setState(() => _as = i), onAdd: _addSlide, onDelete: _delSlide, onDuplicate: _dupSlide, onMoveUp: (i) => _moveSlide(i, i - 1), onMoveDown: (i) => _moveSlide(i, i + 1), onToggleCollapse: () => setState(() => _nc = !_nc))),
          const VerticalDivider(color: _T.border, width: 1),
          Expanded(child: _Canvas(index: _as, titleCtrl: _tc[_as], contentCtrl: _cc[_as], decoration: _deco(_as), isDark: d, image: _ci[_as] ?? _ai[_as], font: _fn[_as] != 'Inter' ? _fn[_as] : _gf, fontSize: _fs[_as], fontColor: _sfc[_as] ?? _gfc, slideCount: _p.slides.length, logoUrl: _logo, onAddItem: () => _addItem(_as), onRemoveItem: (i) => _remItem(_as, i), onRemoveImage: () => setState(() { _ci[_as] = null; _countUp(); }), hasCustomImage: _ci[_as] != null)),
          const VerticalDivider(color: _T.border, width: 1),
          AnimatedContainer(duration: const Duration(milliseconds: 200), width: _ppo ? 260 : 0, child: _ppo ? _PropertiesPanel(index: _as, isPremium: Provider.of<UserProvider>(context, listen: false).isPremium, activeTab: _apt, globalFont: _gf, selectedBgIndex: _sbi, freeBgs: _fb, premiumBgs: _pb, customBg: _cb[_as], fontSize: _fs[_as], fontColor: _sfc[_as] ?? _gfc, transition: _tr[_as], allTransitions: _atr, isImproving: _ii, onTabChange: (t) => setState(() => _apt = t), onBgSelect: (i) => setState(() { _sbi = i; _cb = List.filled(_p.slides.length, null); }), onBgUpload: () => _uploadBg(_as), onImageUpload: () => _uploadImage(_as), onFontChange: (f) => setState(() { _gf = f; for (int i = 0; i < _fn.length; i++) _fn[i] = f; }), onFontSizeChange: (v) => setState(() => _fs[_as] = v), onFontColorChange: (c) => setState(() { _sfc[_as] = c; _gfc = c; }), onTransitionChange: (t) => setState(() => _tr[_as] = t), uploadsUsed: _iu) : const SizedBox.shrink()),
        ])),
      ]),
    );
  }

  @override
  void dispose() {
    _save();
    for (var c in _tc) c.dispose();
    for (var l in _cc) for (var c in l) c.dispose();
    _sc.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String title;
  final int slideCount, uploadsUsed;
  final VoidCallback onBack, onExport;
  const _TopBar({required this.title, required this.slideCount, required this.uploadsUsed, required this.onBack, required this.onExport});

  @override
  Widget build(BuildContext c) => Container(
    height: 52, color: _T.bgSurface,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      _IconBtn(Icons.arrow_back_ios_rounded, onBack, tooltip: 'Назад', size: 17),
      const SizedBox(width: 8),
      Container(width: 26, height: 26, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14)),
      const SizedBox(width: 10),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
        Text('$slideCount слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 10)),
      ])),
      if (uploadsUsed > 0) Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: uploadsUsed >= 10 ? _T.gold.withOpacity(0.12) : _T.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: uploadsUsed >= 10 ? _T.gold.withOpacity(0.3) : _T.accent.withOpacity(0.3))), child: Text('🖼 $uploadsUsed/10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: uploadsUsed >= 10 ? _T.gold : _T.accentLight))),
      MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onExport, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.ios_share_rounded, color: Colors.white, size: 14), SizedBox(width: 6), Text('Экспорт', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))])))),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════
// SLIDE NAVIGATOR
// ═══════════════════════════════════════════════════════════════
class _SlideNavigator extends StatelessWidget {
  final List<Slide> slides;
  final List<TextEditingController> titleControllers;
  final int activeIndex;
  final bool collapsed;
  final List<String?> customBgs;
  final List<Map<String, dynamic>> backgrounds;
  final int selectedBgIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete, onDuplicate, onMoveUp, onMoveDown;
  final VoidCallback onToggleCollapse;
  const _SlideNavigator({required this.slides, required this.titleControllers, required this.activeIndex, required this.collapsed, required this.customBgs, required this.backgrounds, required this.selectedBgIndex, required this.onSelect, required this.onAdd, required this.onDelete, required this.onDuplicate, required this.onMoveUp, required this.onMoveDown, required this.onToggleCollapse});

  Color _c(int i) {
    if (customBgs[i] != null) return Colors.grey.shade800;
    final bg = backgrounds[selectedBgIndex.clamp(0, backgrounds.length - 1)];
    if (bg['type'] == 'solid') return bg['color'] as Color;
    return (bg['colors'] as List<Color>).first;
  }

  @override
  Widget build(BuildContext c) => Container(color: _T.bgSurface, child: Column(children: [
    Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
      if (!collapsed) ...[const Text('СЛАЙДЫ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)), const Spacer()],
      _IconBtn(collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, onToggleCollapse, size: 16),
    ])),
    const Divider(color: _T.border, height: 1),
    Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6), itemCount: slides.length, itemBuilder: (_, i) => _SlideThumbnail(index: i, title: titleControllers[i].text, isActive: i == activeIndex, collapsed: collapsed, bgColor: _c(i), onTap: () => onSelect(i), onDelete: slides.length > 1 ? () => onDelete(i) : null, onDuplicate: () => onDuplicate(i), onMoveUp: i > 0 ? () => onMoveUp(i) : null, onMoveDown: i < slides.length - 1 ? () => onMoveDown(i) : null))),
    const Divider(color: _T.border, height: 1),
    GestureDetector(onTap: onAdd, child: Container(height: 44, alignment: Alignment.center, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 20, height: 20, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(5), border: Border.all(color: _T.accent.withOpacity(0.4))), child: const Icon(Icons.add_rounded, color: _T.accent, size: 14)), if (!collapsed) ...[const SizedBox(width: 8), const Text('Слайд', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w600))]]))),
  ]));
}

class _SlideThumbnail extends StatefulWidget {
  final int index; final String title; final bool isActive, collapsed; final Color bgColor; final VoidCallback onTap, onDuplicate; final VoidCallback? onDelete, onMoveUp, onMoveDown;
  const _SlideThumbnail({required this.index, required this.title, required this.isActive, required this.collapsed, required this.bgColor, required this.onTap, this.onDelete, required this.onDuplicate, this.onMoveUp, this.onMoveDown});
  @override State<_SlideThumbnail> createState() => _SlideThumbnailState();
}
class _SlideThumbnailState extends State<_SlideThumbnail> {
  bool _h = false;
  @override Widget build(BuildContext c) => MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false), child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 120), margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: widget.isActive ? _T.accent.withOpacity(0.12) : _h ? _T.bgHover : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: widget.isActive ? _T.accent.withOpacity(0.5) : Colors.transparent, width: 1.5)), child: widget.collapsed ? _cv() : _ev())));
  Widget _cv() => Column(children: [Container(width: 30, height: 20, decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(3)), child: Center(child: Text('${widget.index + 1}', style: TextStyle(fontSize: 8, color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, fontWeight: FontWeight.w700))))]);
  Widget _ev() => Row(children: [Container(width: 52, height: 34, decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(4)), child: Center(child: Text('${widget.index + 1}', style: TextStyle(fontSize: 10, color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white38, fontWeight: FontWeight.w700)))), const SizedBox(width: 8), Expanded(child: Text(widget.title.isEmpty ? 'Слайд ${widget.index + 1}' : widget.title, style: TextStyle(color: widget.isActive ? _T.txtPrimary : _T.txtSecondary, fontSize: 11, fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400), maxLines: 2, overflow: TextOverflow.ellipsis)), if (_h) PopupMenuButton<String>(padding: EdgeInsets.zero, iconSize: 14, color: _T.bgCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _T.border)), icon: const Icon(Icons.more_vert_rounded, color: _T.txtSecondary, size: 14), onSelected: (v) { if (v == 'dup') widget.onDuplicate(); if (v == 'del') widget.onDelete?.call(); if (v == 'up') widget.onMoveUp?.call(); if (v == 'down') widget.onMoveDown?.call(); }, itemBuilder: (_) => [if (widget.onMoveUp != null) const PopupMenuItem(value: 'up', height: 36, child: _MenuItem(Icons.arrow_upward_rounded, 'Вверх')), if (widget.onMoveDown != null) const PopupMenuItem(value: 'down', height: 36, child: _MenuItem(Icons.arrow_downward_rounded, 'Вниз')), const PopupMenuItem(value: 'dup', height: 36, child: _MenuItem(Icons.copy_rounded, 'Дублировать')), if (widget.onDelete != null) const PopupMenuItem(value: 'del', height: 36, child: _MenuItem(Icons.delete_outline_rounded, 'Удалить', danger: true))])]);
}
class _MenuItem extends StatelessWidget { final IconData i; final String l; final bool d; const _MenuItem(this.i, this.l, {this.d = false}); @override Widget build(BuildContext c) => Row(children: [Icon(i, size: 14, color: d ? _T.danger : _T.txtSecondary), const SizedBox(width: 8), Text(l, style: TextStyle(color: d ? _T.danger : _T.txtPrimary, fontSize: 12))]); }

// ═══════════════════════════════════════════════════════════════
// CANVAS
// ═══════════════════════════════════════════════════════════════
class _Canvas extends StatelessWidget {
  final int index; final TextEditingController titleCtrl; final List<TextEditingController> contentCtrl; final Decoration decoration;
  final bool isDark; final String? image; final String font; final double fontSize; final Color fontColor; final int slideCount; final String? logoUrl;
  final VoidCallback onAddItem, onRemoveImage; final ValueChanged<int> onRemoveItem; final bool hasCustomImage;
  const _Canvas({super.key, required this.index, required this.titleCtrl, required this.contentCtrl, required this.decoration, required this.isDark, required this.image, required this.font, required this.fontSize, required this.fontColor, required this.slideCount, this.logoUrl, required this.onAddItem, required this.onRemoveItem, required this.onRemoveImage, required this.hasCustomImage});

  @override Widget build(BuildContext c) => Container(color: _T.bgBase, child: Center(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24), child: Column(children: [
    Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${index + 1} / $slideCount', style: const TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w500))),
    LayoutBuilder(builder: (ctx, _) { final w = (MediaQuery.of(c).size.width - 460).clamp(360.0, 900.0); final h = w * 9 / 16; return Container(width: w, height: h, decoration: decoration, clipBehavior: Clip.antiAlias, child: Stack(children: [
      Positioned(top: 12, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(5)), child: Text('${index + 1}', style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700)))),
      Padding(padding: const EdgeInsets.fromLTRB(28, 36, 28, 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EditableText(controller: titleCtrl, focusNode: FocusNode(), style: TextStyle(fontSize: fontSize * 2.2, fontWeight: FontWeight.w800, fontFamily: font, color: fontColor, height: 1.15, letterSpacing: -0.5), cursorColor: _T.accent, backgroundCursorColor: _T.accent, maxLines: 2),
          const SizedBox(height: 12),
          ...contentCtrl.take(5).mapIndexed((i, ctrl) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: EdgeInsets.only(top: fontSize * 0.38, right: 7), child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: _T.accent, shape: BoxShape.circle))), Expanded(child: EditableText(controller: ctrl, focusNode: FocusNode(), style: TextStyle(fontSize: fontSize * 1.4, fontFamily: font, color: fontColor.withOpacity(0.8), height: 1.4), cursorColor: _T.accent, backgroundCursorColor: _T.accent, maxLines: 3))]))),
        ])),
        if (image != null) ...[const SizedBox(width: 20), Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(image!, width: w * 0.28, height: h * 0.55, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())), if (hasCustomImage) Positioned(top: 4, right: 4, child: GestureDetector(onTap: onRemoveImage, child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close_rounded, color: Colors.white, size: 12))))])],
      ])),
      if (logoUrl != null) Positioned(bottom: 10, right: 14, child: Opacity(opacity: 0.7, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(logoUrl!, width: 50, height: 20, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox())))),
    ])); }),
    const SizedBox(height: 16),
    LayoutBuilder(builder: (ctx, _) { final w = (MediaQuery.of(c).size.width - 460).clamp(360.0, 900.0); return Container(width: w, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('СОДЕРЖИМОЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)), const SizedBox(height: 10),
      _EditorField(controller: titleCtrl, hint: 'Заголовок слайда...', isTitle: true), const SizedBox(height: 8),
      ...contentCtrl.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [const Padding(padding: EdgeInsets.only(right: 8, top: 2), child: Icon(Icons.drag_indicator_rounded, color: _T.txtMuted, size: 14)), Expanded(child: _EditorField(controller: e.value, hint: 'Пункт ${e.key + 1}...')), const SizedBox(width: 4), GestureDetector(onTap: () => onRemoveItem(e.key), child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 14))]))),
      const SizedBox(height: 4), GestureDetector(onTap: onAddItem, child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.add_rounded, color: _T.accent, size: 14), SizedBox(width: 4), Text('Добавить пункт', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w500))])),
    ])); }),
  ]))));
}

class _EditorField extends StatelessWidget { final TextEditingController c; final String h; final bool t; const _EditorField({required this.c, required this.h, this.t = false}); @override Widget build(BuildContext _) => TextField(controller: c, style: TextStyle(color: _T.txtPrimary, fontSize: t ? 15 : 13, fontWeight: t ? FontWeight.w700 : FontWeight.w400), maxLines: null, decoration: InputDecoration(hintText: h, hintStyle: const TextStyle(color: _T.txtMuted, fontSize: 13), filled: true, fillColor: _T.bgCard, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.accent, width: 1.5)), isDense: true)); }

// ═══════════════════════════════════════════════════════════════
// PROPERTIES PANEL
// ═══════════════════════════════════════════════════════════════
class _PropertiesPanel extends StatelessWidget {
  final int index; final bool isPremium; final String activeTab, globalFont; final int selectedBgIndex; final List<Map<String, dynamic>> freeBgs, premiumBgs, allTransitions; final String? customBg; final double fontSize; final Color fontColor; final String transition; final bool isImproving; final ValueChanged<String> onTabChange, onFontChange, onTransitionChange; final ValueChanged<int> onBgSelect; final VoidCallback onBgUpload, onImageUpload; final ValueChanged<double> onFontSizeChange; final ValueChanged<Color> onFontColorChange; final int uploadsUsed;
  const _PropertiesPanel({required this.index, required this.isPremium, required this.activeTab, required this.globalFont, required this.selectedBgIndex, required this.freeBgs, required this.premiumBgs, required this.customBg, required this.fontSize, required this.fontColor, required this.transition, required this.allTransitions, required this.isImproving, required this.onTabChange, required this.onBgSelect, required this.onBgUpload, required this.onImageUpload, required this.onFontChange, required this.onFontSizeChange, required this.onFontColorChange, required this.onTransitionChange, required this.uploadsUsed});
  @override Widget build(BuildContext c) => Container(color: _T.bgSurface, child: Column(children: [
    Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 6), child: Row(children: [_Tab('design', 'Дизайн', Icons.palette_rounded, activeTab, onTabChange), _Tab('image', 'Медиа', Icons.image_rounded, activeTab, onTabChange), _Tab('ai', 'ИИ', Icons.auto_awesome_rounded, activeTab, onTabChange)])),
    const Divider(color: _T.border, height: 1),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: switch (activeTab) { 'image' => _ImageTab(onUpload: onImageUpload, isPremium: isPremium), 'ai' => _AiTab(isImproving: isImproving, onImprove: () {}), _ => _DesignTab(globalFont: globalFont, selectedBgIndex: selectedBgIndex, freeBgs: freeBgs, premiumBgs: premiumBgs, customBg: customBg, fontSize: fontSize, fontColor: fontColor, transition: transition, allTransitions: allTransitions, isPremium: isPremium, onBgSelect: onBgSelect, onBgUpload: onBgUpload, onFontChange: onFontChange, onFontSizeChange: onFontSizeChange, onFontColorChange: onFontColorChange, onTransitionChange: onTransitionChange) })),
  ]));
}

class _Tab extends StatelessWidget { final String id, label, active; final IconData icon; final ValueChanged<String> onTap; const _Tab(this.id, this.label, this.icon, this.active, this.onTap); @override Widget build(BuildContext c) { final a = id == active; return Expanded(child: GestureDetector(onTap: () => onTap(id), child: AnimatedContainer(duration: const Duration(milliseconds: 120), margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6), padding: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: a ? _T.accentDim : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: a ? _T.accent.withOpacity(0.3) : Colors.transparent)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 12, color: a ? _T.accentLight : _T.txtMuted), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: a ? _T.accentLight : _T.txtMuted))])))); } }

class _DesignTab extends StatelessWidget {
  final String gf; final int si; final List<Map<String, dynamic>> fb, pb, at; final String? cb; final double fs; final Color fc; final String tr; final bool ip; final ValueChanged<int> ob; final VoidCallback ou; final ValueChanged<String> of, ot; final ValueChanged<double> os; final ValueChanged<Color> oc;
  const _DesignTab({required this.gf, required this.si, required this.fb, required this.pb, required this.cb, required this.fs, required this.fc, required this.tr, required this.at, required this.ip, required this.ob, required this.ou, required this.of, required this.os, required this.oc, required this.ot});
  static const _fc = [Colors.white, Color(0xFFF2F2F2), Color(0xFF1A1A2E), Colors.black, Color(0xFF1DB954), Color(0xFF4facfe), Color(0xFFf5576c), Color(0xFFFFD700), Color(0xFFf093fb), Color(0xFFFF6B35)];
  @override Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _SectionLabel('ШРИФТ'), const SizedBox(height: 8),
    ...(['Inter', 'Georgia', 'Courier'].map((f) => MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => of(f), child: AnimatedContainer(duration: const Duration(milliseconds: 120), margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: gf == f ? _T.accentDim : _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: gf == f ? _T.accent.withOpacity(0.4) : _T.border)), child: Row(children: [Expanded(child: Text(f, style: TextStyle(fontFamily: f, color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600))), if (gf == f) const Icon(Icons.check_circle_rounded, color: _T.accent, size: 16)])))))),
    const SizedBox(height: 18), _SectionLabel('РАЗМЕР ТЕКСТА'), const SizedBox(height: 10),
    Row(children: [Expanded(child: SliderTheme(data: SliderThemeData(activeTrackColor: _T.accent, inactiveTrackColor: _T.border, thumbColor: _T.accent, overlayColor: _T.accentDim, trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)), child: Slider(value: fs, min: 6, max: 18, divisions: 12, onChanged: os))), Container(width: 36, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(6), border: Border.all(color: _T.border)), child: Text('${fs.toInt()}', style: const TextStyle(color: _T.txtPrimary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center))]),
    const SizedBox(height: 18), _SectionLabel('ЦВЕТ ТЕКСТА'), const SizedBox(height: 10),
    Wrap(spacing: 7, runSpacing: 7, children: _fc.map((x) { final s = fc.value == x.value; return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => oc(x), child: AnimatedContainer(duration: const Duration(milliseconds: 120), width: 28, height: 28, decoration: BoxDecoration(color: x, shape: BoxShape.circle, border: Border.all(color: s ? _T.accent : Colors.white12, width: s ? 2.5 : 1), boxShadow: s ? [BoxShadow(color: _T.accent.withOpacity(0.4), blurRadius: 6)] : null), child: s ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null))); }).toList()),
    const SizedBox(height: 18), _SectionLabel('ФОН'), const SizedBox(height: 8),
    GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.4, children: fb.asMap().entries.map((e) { final i = e.key; final bg = e.value; final s = i == si && cb == null; return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => ob(i), child: AnimatedContainer(duration: const Duration(milliseconds: 120), decoration: BoxDecoration(gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null, color: bg['type'] == 'solid' ? bg['color'] as Color : null, borderRadius: BorderRadius.circular(6), border: Border.all(color: s ? _T.accent : Colors.transparent, width: 2), boxShadow: s ? [BoxShadow(color: _T.accent.withOpacity(0.35), blurRadius: 6)] : null), child: s ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 12)) : null))); }).toList()),
    const SizedBox(height: 8),
    MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: ou, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: _T.border)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload_rounded, color: _T.txtSecondary, size: 13), SizedBox(width: 6), Text('Загрузить фон', style: TextStyle(color: _T.txtSecondary, fontSize: 12, fontWeight: FontWeight.w500))])))),
    const SizedBox(height: 12),
    Row(children: [_SectionLabel('PREMIUM ФОНЫ'), const Spacer(), if (!ip) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _T.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(4)), child: const Text('PRO', style: TextStyle(color: _T.gold, fontSize: 9, fontWeight: FontWeight.w800)))]), const SizedBox(height: 8),
    GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.4, children: pb.asMap().entries.map((e) { final i = e.key; final bg = e.value; return MouseRegion(cursor: ip ? SystemMouseCursors.click : SystemMouseCursors.forbidden, child: GestureDetector(onTap: ip ? () => ob(fb.length + i) : null, child: Stack(children: [Container(decoration: BoxDecoration(gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null, color: bg['type'] == 'solid' ? bg['color'] as Color : null, borderRadius: BorderRadius.circular(6))), if (!ip) Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white54, size: 13)))])),); }).toList()),
    const SizedBox(height: 18),
    Row(children: [_SectionLabel('ПЕРЕХОД'), const Spacer(), if (!ip) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _T.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(4)), child: const Text('2 бесплатно', style: TextStyle(color: _T.gold, fontSize: 9, fontWeight: FontWeight.w700)))]), const SizedBox(height: 8),
    GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 2.0, children: at.map((t) { final pr = t['premium'] as bool; final locked = pr && !ip; final s = tr == t['id']; return MouseRegion(cursor: locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click, child: GestureDetector(onTap: locked ? null : () => ot(t['id'] as String), child: AnimatedContainer(duration: const Duration(milliseconds: 120), decoration: BoxDecoration(color: s ? _T.accentDim : _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: s ? _T.accent.withOpacity(0.5) : _T.border)), child: Stack(alignment: Alignment.center, children: [Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(t['icon'] as IconData, size: 16, color: locked ? _T.txtMuted : s ? _T.accent : _T.txtSecondary), const SizedBox(height: 3), Text(t['label'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: locked ? _T.txtMuted : s ? _T.accent : _T.txtSecondary))]), if (locked) Positioned(top: 4, right: 4, child: Icon(Icons.lock_rounded, size: 9, color: _T.gold.withOpacity(0.7)))])))); }).toList()),
  ]);
}

class _ImageTab extends StatelessWidget { final VoidCallback u; final bool p; const _ImageTab({required this.u, required this.p}); @override Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_SectionLabel('ИЗОБРАЖЕНИЕ'), const SizedBox(height: 8), if (!p) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: _T.gold.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: _T.gold.withOpacity(0.2))), child: Row(children: const [Icon(Icons.star_rounded, color: _T.gold, size: 14), SizedBox(width: 8), Expanded(child: Text('Замена — Premium.', style: TextStyle(color: _T.gold, fontSize: 11, fontWeight: FontWeight.w500)))])), MouseRegion(cursor: p ? SystemMouseCursors.click : SystemMouseCursors.forbidden, child: GestureDetector(onTap: p ? u : null, child: AnimatedContainer(duration: const Duration(milliseconds: 120), width: double.infinity, height: 90, decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: p ? _T.border : _T.border.withOpacity(0.4))), child: Opacity(opacity: p ? 1.0 : 0.4, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_rounded, color: _T.accent, size: 17)), const SizedBox(height: 8), const Text('Нажмите для загрузки', style: TextStyle(color: _T.txtSecondary, fontSize: 11)), const Text('PNG, JPG до 10 МБ', style: TextStyle(color: _T.txtMuted, fontSize: 10))]))))), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _T.border)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, color: _T.txtMuted, size: 13), SizedBox(width: 8), Expanded(child: Text('Unsplash подбирает изображение.', style: TextStyle(color: _T.txtMuted, fontSize: 11, height: 1.5)))]))]); }

class _AiTab extends StatelessWidget {
  final bool i; final VoidCallback o;
  const _AiTab({required this.i, required this.o});
  @override Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _SectionLabel('ИИ ПОМОЩНИК'), const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [_T.accent.withOpacity(0.08), _T.accentLight.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.accent.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 30, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15)), const SizedBox(width: 10), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Улучшить текст', style: TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w700)), Text('Текущий слайд', style: TextStyle(color: _T.txtMuted, fontSize: 10))])]),
      const SizedBox(height: 10), const Text('ИИ перепишет заголовок и пункты.', style: TextStyle(color: _T.txtSecondary, fontSize: 11, height: 1.5)), const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: GestureDetector(onTap: i ? null : o, child: AnimatedContainer(duration: const Duration(milliseconds: 120), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(gradient: i ? null : const LinearGradient(colors: [Color(0xFF169C46), _T.accent, _T.accentLight], begin: Alignment.centerLeft, end: Alignment.centerRight), color: i ? _T.bgHover : null, borderRadius: BorderRadius.circular(9)), child: Center(child: i ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: _T.accent, strokeWidth: 2)) : const Text('Улучшить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))))),
    ])),
  ]);
}

// ═══════════════════════════════════════════════════════════════
// EXPORT SHEET
// ═══════════════════════════════════════════════════════════════
class _ExportSheet extends StatelessWidget {
  final bool isPremium;
  final Presentation presentation;
  const _ExportSheet({required this.isPremium, required this.presentation});

  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
    decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.border)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.only(top: 12, bottom: 16), child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)))),
      const Text('Экспорт', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
      const SizedBox(height: 4),
      const Text('Скачайте вашу презентацию', style: TextStyle(color: _T.txtSecondary, fontSize: 12)),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
        _ExportOption(icon: Icons.slideshow_rounded, color: _T.accent, title: 'PPTX', subtitle: isPremium ? 'Без знака' : 'С водяным знаком', badge: isPremium ? 'PRO' : null, onTap: () { Navigator.pop(c); ExportService.exportToPPTX(context: c, presentation: presentation, isPremium: isPremium); }),
        const SizedBox(height: 8),
        _ExportOption(icon: Icons.picture_as_pdf_rounded, color: isPremium ? _T.danger : _T.txtMuted, title: 'PDF', subtitle: isPremium ? 'Высокое качество' : 'Только Premium', locked: !isPremium, onTap: isPremium ? () { Navigator.pop(c); ExportService.exportToPDF(context: c, presentation: presentation, isPremium: true); } : null),
      ])),
      const SizedBox(height: 20),
    ]),
  );
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final String? badge;
  final bool locked;
  final VoidCallback? onTap;
  const _ExportOption({required this.icon, required this.color, required this.title, required this.subtitle, this.badge, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
          ])),
          if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(5)), child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
          if (locked) const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 16),
          if (!locked && badge == null) const Icon(Icons.arrow_forward_ios_rounded, color: _T.txtMuted, size: 12),
        ]),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget { final String t; const _SectionLabel(this.t); @override Widget build(BuildContext c) => Text(t, style: const TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)); }

class _IconBtn extends StatefulWidget { final IconData i; final VoidCallback? o; final double s; final String? t; final bool d, a, dis; const _IconBtn(this.i, this.o, {this.s = 18, this.t, this.d = false, this.a = false, this.dis = false}); @override State<_IconBtn> createState() => _IconBtnState(); }
class _IconBtnState extends State<_IconBtn> { bool _h = false; @override Widget build(BuildContext c) { final cl = widget.dis ? _T.txtMuted : widget.d ? _T.danger : widget.a ? _T.accent : _h ? _T.txtPrimary : _T.txtSecondary; return MouseRegion(cursor: widget.dis ? SystemMouseCursors.forbidden : SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false), child: Tooltip(message: widget.t ?? '', child: GestureDetector(onTap: widget.dis ? null : widget.o, child: AnimatedContainer(duration: const Duration(milliseconds: 120), padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: _h && !widget.dis ? _T.bgHover : Colors.transparent, borderRadius: BorderRadius.circular(7)), child: Icon(widget.i, size: widget.s, color: cl))))); } }

extension _IterableMapIndexed<T> on Iterable<T> { Iterable<R> mapIndexed<R>(R Function(int, T) f) { var i = 0; return map((e) => f(i++, e)); } }