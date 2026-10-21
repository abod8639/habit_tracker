import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeEntity extends Equatable {
  static const String defaultTheme = 'github_dark_green';

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

  factory ThemeEntity.empty() {
    return const ThemeEntity(
      themeName: defaultTheme,
      themeMode: ThemeMode.dark,
      useCustomBackground: false,
      customBackgroundColor: null,
    );
  }

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

  @override
  List<Object?> get props => [
    themeName,
    themeMode,
    useCustomBackground,
    customBackgroundColor,
  ];
}
