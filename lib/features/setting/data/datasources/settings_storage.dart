import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';

class SettingsStorage {
  static const String boxName = 'settings_box';
  static const String _isNotificationEnabledKey = 'is_notification_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _hasSkippedLoginKey = 'has_skipped_login';
  static const String _customGeminiApiKeyKey = 'custom_gemini_api_key';
  static const String _customGeminiModelKey = 'custom_gemini_model';

  final KeyValueStorage _storage;
  final FlutterSecureStorage _secureStorage;
  String? _cachedApiKey;

  SettingsStorage(
    this._storage, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
            ) {
    _initSecureStorage();
  }

  Future<void> _initSecureStorage() async {
    try {
      _cachedApiKey = await _secureStorage.read(key: _customGeminiApiKeyKey);
      // Migration: If not found in secure storage, check legacy storage and migrate
      if (_cachedApiKey == null) {
        final legacyKey = _storage.getString(_customGeminiApiKeyKey);
        if (legacyKey != null && legacyKey.trim().isNotEmpty) {
          _cachedApiKey = legacyKey.trim();
          await _secureStorage.write(
            key: _customGeminiApiKeyKey,
            value: _cachedApiKey,
          );
          await _storage.remove(_customGeminiApiKeyKey);
        }
      }
    } catch (_) {
      _cachedApiKey = _storage.getString(_customGeminiApiKeyKey);
    }
  }

  bool get isNotificationEnabled =>
      _storage.getBool(_isNotificationEnabledKey, defaultValue: false);

  Future<void> setNotificationEnabled(bool enabled) async {
    await _storage.setBool(_isNotificationEnabledKey, enabled);
  }

  TimeOfDay? get notificationTime {
    final String? timeStr = _storage.getString(_notificationTimeKey);
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _storage.setString(
      _notificationTimeKey,
      '${time.hour}:${time.minute}',
    );
  }

  bool get hasSkippedLogin =>
      _storage.getBool(_hasSkippedLoginKey, defaultValue: false);

  Future<void> setSkippedLogin(bool skipped) async {
    await _storage.setBool(_hasSkippedLoginKey, skipped);
  }

  String? get customGeminiApiKey =>
      _cachedApiKey ?? _storage.getString(_customGeminiApiKeyKey);

  Future<void> setCustomGeminiApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      _cachedApiKey = null;
      try {
        await _secureStorage.delete(key: _customGeminiApiKeyKey);
      } catch (_) {}
      await _storage.remove(_customGeminiApiKeyKey);
      await _storage.remove(_customGeminiModelKey);
    } else {
      final trimmed = key.trim();
      _cachedApiKey = trimmed;
      try {
        await _secureStorage.write(key: _customGeminiApiKeyKey, value: trimmed);
      } catch (_) {}
      // Remove from unencrypted storage to protect privacy
      await _storage.remove(_customGeminiApiKeyKey);
    }
  }

  Future<void> clearCustomGeminiApiKey() async {
    _cachedApiKey = null;
    try {
      await _secureStorage.delete(key: _customGeminiApiKeyKey);
    } catch (_) {}
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
    await clearCustomGeminiApiKey();
  }
}
