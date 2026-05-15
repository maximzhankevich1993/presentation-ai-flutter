import 'package:flutter/material.dart';

class CanvasBlock {
  final String id;
  String type; // title | text | bullet
  String content;

  CanvasBlock({
    required this.id,
    required this.type,
    required this.content,
  });
}

class CanvasEditorScreen extends StatefulWidget {
  final String title;
  final String initialContent;

  const CanvasEditorScreen({
    super.key,
    required this.title,
    this.initialContent = '',
  });

  @override
  State<CanvasEditorScreen> createState() => _CanvasEditorScreenState();
}

class _CanvasEditorScreenState extends State<CanvasEditorScreen> {
  late List<CanvasBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = _parseInitialContent();
  }

  List<CanvasBlock> _parseInitialContent() {
    if (widget.initialContent.isEmpty) {
      return [
        CanvasBlock(id: '1', type: 'title', content: '📊 Новый документ'),
        CanvasBlock(id: '2', type: 'text', content: 'Начни редактировать этот отчёт...'),
      ];
    }
    
    final lines = widget.initialContent.split('\n');
    final blocks = <CanvasBlock>[];
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      if (line.contains('•')) {
        blocks.add(CanvasBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString() + blocks.length.toString(),
          type: 'bullet',
          content: line.trim(),
        ));
      } else if (line.contains('📊') || line.contains('📈') || line.contains('🎯') || line.contains('💰') || line.contains('🚀')) {
        blocks.add(CanvasBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString() + blocks.length.toString(),
          type: 'title',
          content: line.trim(),
        ));
      } else {
        blocks.add(CanvasBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString() + blocks.length.toString(),
          type: 'text',
          content: line.trim(),
        ));
      }
    }
    
    if (blocks.isEmpty) {
      return [
        CanvasBlock(id: '1', type: 'title', content: widget.title),
        CanvasBlock(id: '2', type: 'text', content: 'Начните редактировать...'),
      ];
    }
    
    return blocks;
  }

  void _addBlock(String type) {
    setState(() {
      _blocks.add(
        CanvasBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          content: type == 'title'
              ? 'Новый заголовок'
              : type == 'bullet'
                  ? '• Новый пункт'
                  : 'Новый текстовый блок',
        ),
      );
    });
  }

  void _deleteBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
    });
  }

  void _editBlock(CanvasBlock block) {
    final controller = TextEditingController(text: block.content);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Редактирование блока',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLines: 10,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Введите текст...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                block.content = controller.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportDocument() {
    final content = _blocks.map((b) => b.content).join('\n\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Документ "$content" готов к экспорту'),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
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
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF1DB954)),
            onPressed: _exportDocument,
          ),
          PopupMenuButton<String>(
            color: const Color(0xFF1E1E1E),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onSelected: _addBlock,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'title', child: Row(children: [Icon(Icons.title, size: 18), SizedBox(width: 8), Text('Заголовок', style: TextStyle(color: Colors.white))])),
              PopupMenuItem(value: 'text', child: Row(children: [Icon(Icons.text_fields, size: 18), SizedBox(width: 8), Text('Текст', style: TextStyle(color: Colors.white))])),
              PopupMenuItem(value: 'bullet', child: Row(children: [Icon(Icons.list, size: 18), SizedBox(width: 8), Text('Список', style: TextStyle(color: Colors.white))])),
            ],
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blocks.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _blocks.removeAt(oldIndex);
            _blocks.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final block = _blocks[index];
          final isTitle = block.type == 'title';

          return Container(
            key: ValueKey(block.id),
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _editBlock(block),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator, color: Colors.white24, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        block.content,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTitle ? 20 : 14,
                          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteBlock(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1DB954),
        onPressed: () => _addBlock('text'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}