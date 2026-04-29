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

  SharedPreferences? _prefs;

  bool get isPremium {
    if (_premiumExpiryDate == null) return _isPremium;
    return _premiumExpiryDate!.isAfter(DateTime.now());
  }

  int get freeGenerationsLeft => _freeGenerationsLeft;
  int get totalGenerationsMade => _totalGenerationsMade;
  int get surpriseMeUsesLeft => _surpriseMeUsesLeft;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get newsletterSubscription => _newsletterSubscription;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;

  bool get canGenerate => isPremium || _freeGenerationsLeft > 0;

  int get maxSlidesPerPresentation => isPremium ? 50 : 10;
  int get maxImagesPerPresentation => isPremium ? 50 : 10;

  bool get canUseSurpriseMe => isPremium || _surpriseMeUsesLeft > 0;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    _isPremium = _prefs?.getBool('isPremium') ?? false;
    _freeGenerationsLeft = _prefs?.getInt('freeGenerationsLeft') ?? 5;
    _totalGenerationsMade = _prefs?.getInt('totalGenerationsMade') ?? 0;
    _surpriseMeUsesLeft = _prefs?.getInt('surpriseMeUsesLeft') ?? 3;
    _userEmail = _prefs?.getString('userEmail');
    _userName = _prefs?.getString('userName');
    _newsletterSubscription = _prefs?.getBool('newsletterSubscription') ?? false;

    final expiryString = _prefs?.getString('premiumExpiryDate');
    if (expiryString != null) {
      _premiumExpiryDate = DateTime.tryParse(expiryString);
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool('isPremium', _isPremium);
    await _prefs!.setInt('freeGenerationsLeft', _freeGenerationsLeft);
    await _prefs!.setInt('totalGenerationsMade', _totalGenerationsMade);
    await _prefs!.setInt('surpriseMeUsesLeft', _surpriseMeUsesLeft);

    if (_userEmail != null) {
      await _prefs!.setString('userEmail', _userEmail!);
    }

    if (_userName != null) {
      await _prefs!.setString('userName', _userName!);
    }

    await _prefs!.setBool('newsletterSubscription', _newsletterSubscription);

    if (_premiumExpiryDate != null) {
      await _prefs!.setString(
        'premiumExpiryDate',
        _premiumExpiryDate!.toIso8601String(),
      );
    }
  }

  Future<bool> useGeneration() async {
    if (!canGenerate) return false;

    if (!isPremium) {
      _freeGenerationsLeft =
          (_freeGenerationsLeft - 1).clamp(0, 999);
    }

    _totalGenerationsMade++;

    await _saveData();
    notifyListeners();
    return true;
  }

  Future<bool> useSurpriseMe() async {
    if (!canUseSurpriseMe) return false;

    if (!isPremium) {
      _surpriseMeUsesLeft =
          (_surpriseMeUsesLeft - 1).clamp(0, 999);
    }

    await _saveData();
    notifyListeners();
    return true;
  }

  Future<void> activatePremium({DateTime? expiryDate}) async {
    _isPremium = true;
    _premiumExpiryDate = expiryDate;

    await _saveData();
    notifyListeners();
  }

  Future<void> setUserEmail(String email) async {
    _userEmail = email;
    await _saveData();
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _saveData();
    notifyListeners();
  }

  Future<void> setNewsletterSubscription(bool value) async {
    _newsletterSubscription = value;
    await _saveData();
    notifyListeners();
  }

  Future<void> addFreeGenerations(int count) async {
    _freeGenerationsLeft += count;
    await _saveData();
    notifyListeners();
  }
}