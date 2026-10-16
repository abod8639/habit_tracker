import 'package:flutter/material.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';

class SettingsStorage {
  static const String boxName = 'settings_box';
  static const String _isNotificationEnabledKey = 'is_notification_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _hasSkippedLoginKey = 'has_skipped_login';
  static const String _customGeminiApiKeyKey = 'custom_gemini_api_key';
  static const String _customGeminiModelKey = 'custom_gemini_model';

  final KeyValueStorage _storage;

  SettingsStorage(this._storage);

  bool get isNotificationEnabled =>
      _storage.getBool(_isNotificationEnabledKey, defaultValue: false);

  Future<void> setNotificationEnabled(bool enabled) async {
    await _storage.setBool(_isNotificationEnabledKey, enabled);
  }

  TimeOfDay? get notificationTime {
    final String? timeStr = _storage.getString(_notificationTimeKey);
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _storage.setString(_notificationTimeKey, '${time.hour}:${time.minute}');
  }

  bool get hasSkippedLogin =>
      _storage.getBool(_hasSkippedLoginKey, defaultValue: false);

  Future<void> setSkippedLogin(bool skipped) async {
    await _storage.setBool(_hasSkippedLoginKey, skipped);
  }

  String? get customGeminiApiKey => _storage.getString(_customGeminiApiKeyKey);

  Future<void> setCustomGeminiApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _storage.remove(_customGeminiApiKeyKey);
      await _storage.remove(_customGeminiModelKey);
    } else {
      await _storage.setString(_customGeminiApiKeyKey, key.trim());
    }
  }

  Future<void> clearCustomGeminiApiKey() async {
    await _storage.remove(_customGeminiApiKeyKey);
    await _storage.remove(_customGeminiModelKey);
  }

  String? get customGeminiModel {
    final model = _storage.getString(_customGeminiModelKey);
    if (model == null) return null;
    final modelStr = model.trim();
    if (modelStr.contains('2.5') ||
        modelStr.contains('2.0') ||
        modelStr.contains('1.5')) {
      _storage.remove(_customGeminiModelKey);
      return null;
    }
    return modelStr;
  }

  Future<void> setCustomGeminiModel(String? model) async {
    if (model == null || model.trim().isEmpty) {
      await _storage.remove(_customGeminiModelKey);
    } else {
      await _storage.setString(_customGeminiModelKey, model.trim());
    }
  }

  Future<void> clearAll() async {
    await _storage.remove(_isNotificationEnabledKey);
    await _storage.remove(_notificationTimeKey);
    await _storage.remove(_hasSkippedLoginKey);
    await _storage.remove(_customGeminiApiKeyKey);
    await _storage.remove(_customGeminiModelKey);
  }
}
