import 'package:flutter/material.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';

abstract class SettingLocalDataSource {
  Future<String> getLanguage();
  Future<void> saveLanguage(String languageCode);

  bool isNotificationEnabled();
  Future<void> setNotificationEnabled(bool enabled);

  TimeOfDay? getNotificationTime();
  Future<void> setNotificationTime(TimeOfDay time);

  DateTime? getLastSyncTime();

  String? getCustomGeminiApiKey();
  Future<void> saveCustomGeminiApiKey(String? key);
  Future<void> clearCustomGeminiApiKey();

  Future<void> clearAllData();
}

class SettingLocalDataSourceImpl implements SettingLocalDataSource {
  final LangStorage _langStorage;
  final SettingsStorage _settingsStorage;
  final ThemeStorageService _themeStorage;

  SettingLocalDataSourceImpl({
    required LangStorage langStorage,
    required SettingsStorage settingsStorage,
    required ThemeStorageService themeStorage,
  })  : _langStorage = langStorage,
        _settingsStorage = settingsStorage,
        _themeStorage = themeStorage;

  @override
  Future<String> getLanguage() async {
    return _langStorage.getCurrentLanguage();
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _langStorage.saveLanguage(languageCode);
  }

  @override
  bool isNotificationEnabled() {
    return _settingsStorage.isNotificationEnabled;
  }

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    await _settingsStorage.setNotificationEnabled(enabled);
  }

  @override
  TimeOfDay? getNotificationTime() {
    return _settingsStorage.notificationTime;
  }

  @override
  Future<void> setNotificationTime(TimeOfDay time) async {
    await _settingsStorage.setNotificationTime(time);
  }

  @override
  DateTime? getLastSyncTime() {
    return null;
  }

  @override
  String? getCustomGeminiApiKey() {
    return _settingsStorage.customGeminiApiKey;
  }

  @override
  Future<void> saveCustomGeminiApiKey(String? key) async {
    await _settingsStorage.setCustomGeminiApiKey(key);
  }

  @override
  Future<void> clearCustomGeminiApiKey() async {
    await _settingsStorage.clearCustomGeminiApiKey();
  }

  @override
  Future<void> clearAllData() async {
    await _langStorage.clear();
    await _settingsStorage.clearAll();
    await _themeStorage.clear();
  }
}
