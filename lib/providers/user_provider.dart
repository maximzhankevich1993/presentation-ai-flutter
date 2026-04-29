import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isPremium = false;
  int _freeGenerationsLeft = 5;
  int _totalGenerationsMade = 0;
  int _surpriseMeUsesLeft = 3;
  String? _userEmail;
  String? _userName;
  bool _newsletterSubscription = false;
  DateTime? _premiumExpiryDate;

  bool get isPremium => _isPremium;
  int get freeGenerationsLeft => _freeGenerationsLeft;
  int get totalGenerationsMade => _totalGenerationsMade;
  int get surpriseMeUsesLeft => _surpriseMeUsesLeft;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get newsletterSubscription => _newsletterSubscription;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;

  bool get canGenerate {
    if (_isPremium) return true;
    return _freeGenerationsLeft > 0;
  }

  int get maxSlidesPerPresentation => _isPremium ? 50 : 10;
  int get maxImagesPerPresentation => _isPremium ? 50 : 10;

  bool get canUseSurpriseMe {
    if (_isPremium) return true;
    return _surpriseMeUsesLeft > 0;
  }

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;
    _freeGenerationsLeft = prefs.getInt('freeGenerationsLeft') ?? 5;
    _totalGenerationsMade = prefs.getInt('totalGenerationsMade') ?? 0;
    _surpriseMeUsesLeft = prefs.getInt('surpriseMeUsesLeft') ?? 3;
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _newsletterSubscription = prefs.getBool('newsletterSubscription') ?? false;
    final expiryString = prefs.getString('premiumExpiryDate');
    if (expiryString != null) _premiumExpiryDate = DateTime.tryParse(expiryString);
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', _isPremium);
    await prefs.setInt('freeGenerationsLeft', _freeGenerationsLeft);
    await prefs.setInt('totalGenerationsMade', _totalGenerationsMade);
    await prefs.setInt('surpriseMeUsesLeft', _surpriseMeUsesLeft);
    if (_userEmail != null) await prefs.setString('userEmail', _userEmail!);
    if (_userName != null) await prefs.setString('userName', _userName!);
    await prefs.setBool('newsletterSubscription', _newsletterSubscription);
    if (_premiumExpiryDate != null) await prefs.setString('premiumExpiryDate', _premiumExpiryDate!.toIso8601String());
    notifyListeners();
  }

  Future<bool> useGeneration() async {
    if (!canGenerate) return false;
    if (!_isPremium) _freeGenerationsLeft--;
    _totalGenerationsMade++;
    await _saveData();
    return true;
  }

  Future<bool> useSurpriseMe() async {
    if (!canUseSurpriseMe) return false;
    if (!_isPremium) _surpriseMeUsesLeft--;
    await _saveData();
    return true;
  }

  Future<void> activatePremium({DateTime? expiryDate}) async {
    _isPremium = true;
    _premiumExpiryDate = expiryDate;
    await _saveData();
  }

  void setUserEmail(String email) { _userEmail = email; _saveData(); }
  void setUserName(String name) { _userName = name; _saveData(); }
  void setNewsletterSubscription(bool value) { _newsletterSubscription = value; _saveData(); }
  Future<void> addFreeGenerations(int count) async { _freeGenerationsLeft += count; await _saveData(); }
  Future<void> init() async => await _init();
}