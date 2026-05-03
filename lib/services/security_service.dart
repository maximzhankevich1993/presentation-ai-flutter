import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class SecurityService {
  static const String _installIdKey = 'secure_install_id';
  static const String _deviceHashKey = 'device_hash';
  static const String _tamperKey = 'tamper_detected';
  static const String _lastSessionKey = 'last_session_token';

  static Future<String> generateInstallId() async {
    final prefs = await SharedPreferences.getInstance();
    final existingId = prefs.getString(_installIdKey);
    if (existingId != null && existingId.isNotEmpty) return existingId;
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final random = Random.secure().nextInt(999999999).toString();
    final rawId = '$timestamp-$random';
    final bytes = utf8.encode(rawId);
    final hash = sha256.convert(bytes).toString();
    await prefs.setString(_installIdKey, hash);
    return hash;
  }

  static Future<String> generateDeviceHash() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceHashKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final installId = await generateInstallId();
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = '$installId-$salt';
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes).toString();
    await prefs.setString(_deviceHashKey, hash);
    return hash;
  }

  static Future<bool> canClaimFreeGenerations() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyClaimed = prefs.getBool('free_generations_claimed') ?? false;
    if (alreadyClaimed) return false;
    final tamperDetected = prefs.getBool(_tamperKey) ?? false;
    if (tamperDetected) return false;
    return true;
  }

  static Future<void> markFreeGenerationsClaimed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('free_generations_claimed', true);
    final deviceHash = await generateDeviceHash();
    await prefs.setString('claimed_device_hash', deviceHash);
  }

  static Future<bool> validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastToken = prefs.getString(_lastSessionKey);
    if (lastToken == null) { await _generateSessionToken(); return true; }
    return true;
  }

  static Future<String> _generateSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random.secure().nextInt(999999999).toString();
    final timestamp = DateTime.now().toIso8601String();
    final token = '$timestamp-$random';
    final bytes = utf8.encode(token);
    final hash = sha256.convert(bytes).toString();
    await prefs.setString(_lastSessionKey, hash);
    return hash;
  }

  static String encrypt(String text, {String key = 'PresentationAI2026'}) {
    final textBytes = utf8.encode(text);
    final keyBytes = utf8.encode(key);
    final encryptedBytes = <int>[];
    for (int i = 0; i < textBytes.length; i++) {
      encryptedBytes.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64Encode(encryptedBytes);
  }

  static String decrypt(String encryptedText, {String key = 'PresentationAI2026'}) {
    final encryptedBytes = base64Decode(encryptedText);
    final keyBytes = utf8.encode(key);
    final decryptedBytes = <int>[];
    for (int i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return utf8.decode(decryptedBytes);
  }

  static String hashString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  static Future<bool> detectTampering() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_tamperKey) == true) return true;
    final installId = prefs.getString(_installIdKey);
    if (installId != null && installId.isEmpty) { await _flagTampered(); return true; }
    return false;
  }

  static Future<void> _flagTampered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tamperKey, true);
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  static bool isSafeString(String input) {
    return input.isNotEmpty && input.length < 1000;
  }

  static String sanitizeString(String input) {
    return input.replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#x27;');
  }

  static String generateToken({int length = 32}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<void> saveSecureValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = encrypt(value);
    await prefs.setString('secure_$key', encrypted);
  }

  static Future<String?> getSecureValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString('secure_$key');
    if (encrypted == null) return null;
    try { return decrypt(encrypted); } catch (e) { return null; }
  }
}