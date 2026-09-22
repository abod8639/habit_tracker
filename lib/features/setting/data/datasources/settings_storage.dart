import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorage {
  static const String boxName = 'settings_box';
  static const String _isNotificationEnabledKey = 'is_notification_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _hasSkippedLoginKey = 'has_skipped_login';
  static const String _customGeminiApiKeyKey = 'custom_gemini_api_key';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  bool get isNotificationEnabled =>
      _box.get(_isNotificationEnabledKey, defaultValue: false);

  Future<void> setNotificationEnabled(bool enabled) async {
    await _box.put(_isNotificationEnabledKey, enabled);
  }

  TimeOfDay? get notificationTime {
    final String? timeStr = _box.get(_notificationTimeKey);
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _box.put(_notificationTimeKey, '${time.hour}:${time.minute}');
  }

  bool get hasSkippedLogin =>
      _box.get(_hasSkippedLoginKey, defaultValue: false);

  Future<void> setSkippedLogin(bool skipped) async {
    await _box.put(_hasSkippedLoginKey, skipped);
  }

  String? get customGeminiApiKey => _box.get(_customGeminiApiKeyKey);

  Future<void> setCustomGeminiApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _box.delete(_customGeminiApiKeyKey);
    } else {
      await _box.put(_customGeminiApiKeyKey, key.trim());
    }
  }

  Future<void> clearCustomGeminiApiKey() async {
    await _box.delete(_customGeminiApiKeyKey);
  }
}
