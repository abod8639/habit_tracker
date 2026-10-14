import 'package:flutter/material.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';
import '../models/theme_model.dart';

abstract class ThemeLocalDataSource {
  Future<ThemeModel> getThemeSettings();
  ThemeModel getCachedThemeSettings();
  Future<void> saveThemeSettings(ThemeModel settings);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final ThemeStorageService? storageService;

  ThemeLocalDataSourceImpl(this.storageService);

  @override
  ThemeModel getCachedThemeSettings() {
    if (storageService == null) {
      return const ThemeModel(
        themeName: 'github_dark_green',
        themeMode: ThemeMode.dark,
        useCustomBackground: false,
      );
    }
    final themeName = storageService!.getThemeName('github_dark_green');
    final themeMode = storageService!.getThemeMode();
    final useCustomBg = storageService!.getUseCustomBackground();
    final customBgColor = storageService!.getCustomBackgroundColor();

    return ThemeModel(
      themeName: themeName,
      themeMode: themeMode,
      useCustomBackground: useCustomBg,
      customBackgroundColor: customBgColor,
    );
  }

  @override
  Future<ThemeModel> getThemeSettings() async {
    return getCachedThemeSettings();
  }

  @override
  Future<void> saveThemeSettings(ThemeModel settings) async {
    if (storageService == null) return;
    await storageService!.saveThemeSettings(
      themeName: settings.themeName,
      mode: settings.themeMode,
      useCustomBg: settings.useCustomBackground,
      customBgColor: settings.customBackgroundColor,
    );
  }
}
