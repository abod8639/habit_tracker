import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

/// Extension on [BuildContext] for ergonomic and clean theme access.
extension ThemeContextExtension on BuildContext {
  /// Quick access to the nearest [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Quick access to current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to custom unified [AppThemeColors].
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ??
      AppThemeColors.fallback(Theme.of(this).brightness == Brightness.dark);

  /// Whether the active theme is in dark mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Extension on [ThemeData] for direct access to custom [AppThemeColors].
extension ThemeDataColorsExtension on ThemeData {
  /// Quick access to custom unified [AppThemeColors] directly from [ThemeData].
  AppThemeColors get appColors =>
      extension<AppThemeColors>() ??
      AppThemeColors.fallback(brightness == Brightness.dark);

  /// Whether this [ThemeData] represents a dark theme.
  bool get isDark => brightness == Brightness.dark;
}
