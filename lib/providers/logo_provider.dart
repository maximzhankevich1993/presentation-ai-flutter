import 'package:flutter/material.dart';

class LogoProvider extends ChangeNotifier {
  String? _logoUrl;
  String? get logoUrl => _logoUrl;

  void setLogo(String url) {
    _logoUrl = url;
    notifyListeners();
  }

  void clear() {
    _logoUrl = null;
    notifyListeners();
  }
}