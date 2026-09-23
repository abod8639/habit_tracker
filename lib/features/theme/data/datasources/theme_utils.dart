import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThemeUtils {
  static Color getContrastColor(Color backgroundColor) {
    return _shouldUseDarkText(backgroundColor)
        ? const Color(0xFF1F2328)
        : Colors.white;
  }

  static bool _shouldUseDarkText(Color backgroundColor) {
    // In modern Flutter, r, g, b are doubles in the range [0.0, 1.0].
    final brightness =
        backgroundColor.r * 0.299 +
        backgroundColor.g * 0.587 +
        backgroundColor.b * 0.114;
    return brightness > 0.5;
  }

  static Color adjustBrightness(Color color, double brightness) {
    assert(
      brightness >= 0 && brightness <= 1,
      'Brightness must be between 0 and 1',
    );
    return HSLColor.fromColor(color).withLightness(brightness).toColor();
  }

  static ThemeData buildThemeData({
    required bool forceDark,
    required Map<String, Color> colors,
    required bool isDarkTheme,
    Color? customBackground,
  }) {
    final brightness = forceDark ? Brightness.dark : Brightness.light;

    final backgroundColor =
        customBackground ??
        (forceDark && !isDarkTheme
            ? adjustBrightness(colors['background']!, 0.2)
            : colors['background']!);

    final surfaceColor = forceDark && !isDarkTheme
        ? adjustBrightness(colors['surface']!, 0.2)
        : colors['surface']!;

    final onSurfaceColor = getContrastColor(surfaceColor);
    final onBackgroundColor = getContrastColor(backgroundColor);

    return ThemeData(
      brightness: brightness,
      primaryColor: colors['primary'],
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dialogTheme: DialogThemeData(backgroundColor: surfaceColor),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors['primary']!,
        onPrimary: colors['onPrimary']!,
        secondary: colors['secondary']!,
        onSecondary: colors['onSecondary']!,
        error: colors['error']!,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceContainerLowest: surfaceColor,
        surfaceContainerHighest: surfaceColor.withValues(alpha: 0.7),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors['primary'],
        foregroundColor: colors['onPrimary'],
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shadowColor: colors['primary']!.withValues(alpha: 0.15),
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors['secondary'],
        foregroundColor: colors['onSecondary'],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors['onPrimary'],
          backgroundColor: colors['primary'],
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colors['primary']!;
          }
          return Colors.grey;
        }),
        checkColor: WidgetStateProperty.all(colors['onPrimary']),
      ),
      textTheme: _createTextTheme(brightness, onBackgroundColor),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors['primary']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors['primary']!, width: 2),
        ),
      ),
    );
  }

  static TextTheme _createTextTheme(Brightness brightness, Color textColor) {
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return baseTextTheme.apply(bodyColor: textColor, displayColor: textColor);
  }

  static bool isDarkTheme(Map<String, dynamic> themeColors) {
    if (themeColors.containsKey('isDark')) {
      return themeColors['isDark'] == true;
    }

    Color colorToAnalyze;

    if (themeColors.containsKey('background')) {
      colorToAnalyze = parseColor(themeColors['background']);
    } else if (themeColors.containsKey('surface')) {
      colorToAnalyze = parseColor(themeColors['surface']);
    } else if (themeColors.containsKey('primary')) {
      colorToAnalyze = parseColor(themeColors['primary']);
    } else {
      return false;
    }

    double r = colorToAnalyze.r;
    double g = colorToAnalyze.g;
    double b = colorToAnalyze.b;

    double hsp = math.sqrt(0.299 * (r * r) + 0.587 * (g * g) + 0.114 * (b * b));

    return hsp < 0.5; // Scale is 0.0 to 1.0 in modern Flutter
  }

  static Color parseColor(dynamic colorValue) {
    if (colorValue is Color) {
      return colorValue;
    } else if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String && colorValue.startsWith('#')) {
      String hex = colorValue.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.grey;
  }
}
