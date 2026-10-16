import 'package:flutter/material.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';

class ThemeStorageService {
  static const String themeBox = "Theme_db";
  static const String themeNameKey = "current_theme";
  static const String themeModeKey = "theme_mode";
  static const String useCustomBgKey = "use_custom_bg";
  static const String customBgColorKey = "custom_bg_color";

  final KeyValueStorage _storage;

  ThemeStorageService(this._storage);

  String getThemeName(String defaultTheme) {
    return _storage.getString(themeNameKey, defaultValue: defaultTheme)!;
  }

  bool getUseCustomBackground() {
    return _storage.getBool(useCustomBgKey, defaultValue: false);
  }

  Color? getCustomBackgroundColor() {
    final int? colorValue = _storage.getInt(customBgColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  ThemeMode getThemeMode() {
    final String? modeStr = _storage.getString(themeModeKey);
    if (modeStr == 'ThemeMode.dark') return ThemeMode.dark;
    if (modeStr == 'ThemeMode.light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> saveThemeSettings({
    required String themeName,
    required ThemeMode mode,
    required bool useCustomBg,
    Color? customBgColor,
  }) async {
    await _storage.setString(themeNameKey, themeName);
    await _storage.setString(themeModeKey, mode.toString());
    await _storage.setBool(useCustomBgKey, useCustomBg);
    if (customBgColor != null) {
      await _storage.setInt(customBgColorKey, customBgColor.toARGB32());
    } else {
      await _storage.remove(customBgColorKey);
    }
  }

  Future<void> clear() async {
    await _storage.remove(themeNameKey);
    await _storage.remove(themeModeKey);
    await _storage.remove(useCustomBgKey);
    await _storage.remove(customBgColorKey);
  }
}
