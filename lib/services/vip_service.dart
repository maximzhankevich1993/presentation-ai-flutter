import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class VipService {
  static const String _vipKey = 'vip_status';
  static const String _vipSlotKey = 'vip_slot';
  static const String _vipDeviceKey = 'vip_device_hash';
  static const String _vipEmailKey = 'vip_email';
  static const String _vipDevicesKey = 'vip_devices';

  static const int _totalVipSlots = 50;

  /// Проверяет, является ли пользователь VIP
  static Future<bool> isVip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vipKey) ?? false;
  }

  /// Активирует VIP-статус
  static Future<Map<String, dynamic>> activateVip({
    required String email,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedEmail = email.trim().toLowerCase();

    // Уже VIP
    if (prefs.getBool(_vipKey) == true) {
      return {
        'success': false,
        'message': 'У вас уже есть VIP-доступ!',
      };
    }

    final currentSlot = prefs.getInt(_vipSlotKey) ?? 0;

    // Проверка лимита
    if (currentSlot >= _totalVipSlots) {
      return {
        'success': false,
        'message':
            'Все $_totalVipSlots VIP-мест уже заняты! Но вы можете оформить Premium.',
      };
    }

    final deviceHash = SecurityService.hashString(deviceId);

    final existingDevices =
        prefs.getStringList(_vipDevicesKey) ?? <String>[];

    // Проверка повторного использования
    if (existingDevices.contains(deviceHash)) {
      return {
        'success': false,
        'message': 'Это устройство уже зарегистрировано в VIP.',
      };
    }

    final newSlot = currentSlot + 1;

    // Сохраняем
    await prefs.setBool(_vipKey, true);
    await prefs.setInt(_vipSlotKey, newSlot);
    await prefs.setString(_vipDeviceKey, deviceHash);
    await prefs.setString(_vipEmailKey, normalizedEmail);

    // Обновляем список устройств (без дубликатов)
    final updatedDevices = {...existingDevices, deviceHash}.toList();
    await prefs.setStringList(_vipDevicesKey, updatedDevices);

    return {
      'success': true,
      'slot': newSlot,
      'remaining': (_totalVipSlots - newSlot).clamp(0, _totalVipSlots),
      'message':
          '🎉 Поздравляем! Вы VIP-пользователь #$newSlot! Пожизненный Premium активирован!',
    };
  }

  /// Остаток слотов
  static Future<int> getRemainingSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_vipSlotKey) ?? 0;
    return (_totalVipSlots - current).clamp(0, _totalVipSlots);
  }

  /// Номер слота
  static Future<int> getVipSlot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_vipSlotKey) ?? 0;
  }

  /// Проверка валидности VIP
  static Future<bool> validateVipStatus(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();

    final isVip = prefs.getBool(_vipKey) ?? false;
    if (!isVip) return false;

    final savedDevice = prefs.getString(_vipDeviceKey);
    if (savedDevice == null) return false;

    final currentDeviceHash = SecurityService.hashString(deviceId);

    return savedDevice == currentDeviceHash;
  }

  /// Сброс VIP (админ)
  static Future<void> resetVip() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_vipKey);
    await prefs.remove(_vipSlotKey);
    await prefs.remove(_vipDeviceKey);
    await prefs.remove(_vipEmailKey);
    await prefs.remove(_vipDevicesKey);
  }
}