import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
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
  final Box _langBox;
  final Box _settingsBox;

  SettingLocalDataSourceImpl({
    required Box langBox,
    required Box settingsBox,
  }) : _langBox = langBox,
       _settingsBox = settingsBox;

  @override
  Future<String> getLanguage() async {
    return _langBox.get(LangStorage.languageKey, defaultValue: LangStorage.defaultLanguage);
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _langBox.put(LangStorage.languageKey, languageCode);
  }

  @override
  bool isNotificationEnabled() {
    return _settingsBox.get('is_notification_enabled', defaultValue: false);
  }

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    await _settingsBox.put('is_notification_enabled', enabled);
  }

  @override
  TimeOfDay? getNotificationTime() {
    final String? timeStr = _settingsBox.get('notification_time');
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Future<void> setNotificationTime(TimeOfDay time) async {
    await _settingsBox.put('notification_time', '${time.hour}:${time.minute}');
  }

  @override
  DateTime? getLastSyncTime() {
    return null; 
  }

  @override
  String? getCustomGeminiApiKey() {
    return _settingsBox.get('custom_gemini_api_key');
  }

  @override
  Future<void> saveCustomGeminiApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _settingsBox.delete('custom_gemini_api_key');
    } else {
      await _settingsBox.put('custom_gemini_api_key', key.trim());
    }
  }

  @override
  Future<void> clearCustomGeminiApiKey() async {
    await _settingsBox.delete('custom_gemini_api_key');
  }

  @override
  Future<void> clearAllData() async {
    // Clear all related boxes
    await _langBox.clear();
    await _settingsBox.clear();
    
    // Clear other global boxes
    if (Hive.isBoxOpen(HabitStorage.boxName)) {
      await Hive.box(HabitStorage.boxName).clear();
    }
    
    if (Hive.isBoxOpen(ThemeStorageService.themeBox)) {
      await Hive.box(ThemeStorageService.themeBox).clear();
    }
  }
}
