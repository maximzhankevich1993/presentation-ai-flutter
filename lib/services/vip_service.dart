import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

class VipService {
  static const String _vipKey = 'vip_status';
  static const String _vipSlotKey = 'vip_slot';
  static const String _vipDeviceKey = 'vip_device_hash';
  static const String _vipEmailKey = 'vip_email';
  static const String _totalVipSlots = '50';

  /// Проверяет, является ли пользователь VIP
  static Future<bool> isVip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vipKey) ?? false;
  }

  /// Активирует VIP-статус (если ещё есть места)
  static Future<Map<String, dynamic>> activateVip({
    required String email,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Проверяем, не активирован ли уже VIP на этом устройстве
    if (prefs.getBool(_vipKey) == true) {
      return {'success': false, 'message': 'У вас уже есть VIP-доступ!'};
    }

    // Проверяем, есть ли ещё места
    final currentSlot = prefs.getInt(_vipSlotKey) ?? 0;
    if (currentSlot >= 50) {
      return {'success': false, 'message': 'Все 50 VIP-мест уже заняты! Но вы можете оформить Premium.'};
    }

    // Проверяем, не пытается ли тот же человек зарегистрироваться повторно
    final deviceHash = SecurityService.hashString(deviceId);
    final existingDevices = prefs.getStringList('vip_devices') ?? [];
    if (existingDevices.contains(deviceHash)) {
      return {'success': false, 'message': 'Это устройство уже зарегистрировано в VIP.'};
    }

    // Активируем VIP
    final newSlot = currentSlot + 1;
    await prefs.setBool(_vipKey, true);
    await prefs.setInt(_vipSlotKey, newSlot);
    await prefs.setString(_vipDeviceKey, deviceHash);
    await prefs.setString(_vipEmailKey, email);

    // Добавляем устройство в список
    existingDevices.add(deviceHash);
    await prefs.setStringList('vip_devices', existingDevices);

    return {
      'success': true,
      'slot': newSlot,
      'remaining': 50 - newSlot,
      'message': '🎉 Поздравляем! Вы VIP-пользователь #$newSlot! Пожизненный Premium активирован!',
    };
  }

  /// Возвращает количество оставшихся VIP-мест
  static Future<int> getRemainingSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_vipSlotKey) ?? 0;
    return 50 - current;
  }

  /// Возвращает номер VIP-слота пользователя
  static Future<int> getVipSlot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_vipSlotKey) ?? 0;
  }

  /// Проверяет валидность VIP-статуса (защита от передачи)
  static Future<bool> validateVipStatus(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final isVip = prefs.getBool(_vipKey) ?? false;
    if (!isVip) return false;

    // Проверяем, что устройство совпадает
    final savedDevice = prefs.getString(_vipDeviceKey);
    final currentDeviceHash = SecurityService.hashString(deviceId);
    return savedDevice == currentDeviceHash;
  }

  /// Сбрасывает VIP-статус (только для админа)
  static Future<void> resetVip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vipKey);
    await prefs.remove(_vipSlotKey);
    await prefs.remove(_vipDeviceKey);
    await prefs.remove(_vipEmailKey);
  }
}