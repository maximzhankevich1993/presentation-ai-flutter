import 'package:flutter/material.dart';

class GenerationRecord {
  final String topic;
  final int slideCount;
  final DateTime createdAt;

  GenerationRecord({
    required this.topic,
    required this.slideCount,
    required this.createdAt,
  });
}

class UserHistoryProvider extends ChangeNotifier {
  final List<GenerationRecord> _records = [];

  List<GenerationRecord> get records => List.unmodifiable(_records);

  void add(
    String topic, {
    int slideCount = 5,
  }) {
    _records.insert(
      0,
      GenerationRecord(
        topic: topic,
        slideCount: slideCount,
        createdAt: DateTime.now(),
      ),
    );

    if (_records.length > 20) {
      _records.removeLast();
    }

    notifyListeners();
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }
}