import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/error/failures.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final String currentTheme;
  final bool useCustomBackground;
  final Color? customBackgroundColor;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Failure? activeFailure;
  final bool isSyncing;

  const ThemeState({
    required this.themeMode,
    required this.currentTheme,
    required this.useCustomBackground,
    this.customBackgroundColor,
    required this.lightTheme,
    required this.darkTheme,
    this.activeFailure,
    this.isSyncing = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    String? currentTheme,
    bool? useCustomBackground,
    Color? customBackgroundColor,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    Failure? activeFailure,
    bool clearFailure = false,
    bool? isSyncing,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      currentTheme: currentTheme ?? this.currentTheme,
      useCustomBackground: useCustomBackground ?? this.useCustomBackground,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      activeFailure: clearFailure
          ? null
          : (activeFailure ?? this.activeFailure),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    currentTheme,
    useCustomBackground,
    customBackgroundColor,
    lightTheme,
    darkTheme,
    activeFailure,
    isSyncing,
  ];
}
