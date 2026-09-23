import 'package:flutter/material.dart';

class ThemeEntity {
  final String themeName;
  final ThemeMode themeMode;
  final bool useCustomBackground;
  final Color? customBackgroundColor;

  const ThemeEntity({
    required this.themeName,
    required this.themeMode,
    required this.useCustomBackground,
    this.customBackgroundColor,
  });

  ThemeEntity copyWith({
    String? themeName,
    ThemeMode? themeMode,
    bool? useCustomBackground,
    Color? customBackgroundColor,
  }) {
    return ThemeEntity(
      themeName: themeName ?? this.themeName,
      themeMode: themeMode ?? this.themeMode,
      useCustomBackground: useCustomBackground ?? this.useCustomBackground,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
    );
  }
}
