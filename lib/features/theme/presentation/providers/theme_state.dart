import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final String currentTheme;
  final bool useCustomBackground;
  final Color? customBackgroundColor;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.themeMode,
    required this.currentTheme,
    required this.useCustomBackground,
    this.customBackgroundColor,
    required this.lightTheme,
    required this.darkTheme,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? currentTheme,
    bool? useCustomBackground,
    Color? customBackgroundColor,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      currentTheme: currentTheme ?? this.currentTheme,
      useCustomBackground: useCustomBackground ?? this.useCustomBackground,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}
