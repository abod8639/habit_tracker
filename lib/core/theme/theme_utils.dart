import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_radius.dart';

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
    final backgroundColor =
        customBackground ??
        (forceDark && !isDarkTheme
            ? adjustBrightness(colors['background']!, 0.2)
            : colors['background']!);

    final surfaceColor = forceDark && !isDarkTheme
        ? adjustBrightness(colors['surface']!, 0.2)
        : colors['surface']!;

    final brightness = _shouldUseDarkText(backgroundColor)
        ? Brightness.light
        : Brightness.dark;

    final onSurfaceColor = getContrastColor(surfaceColor);
    final onBackgroundColor = getContrastColor(backgroundColor);

    return ThemeData(
      brightness: brightness,
      primaryColor: colors['primary'],
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
      ),
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors['secondary'],
        foregroundColor: colors['onSecondary'],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors['onPrimary'],
          backgroundColor: colors['primary'],
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
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
          borderRadius: AppRadius.smRadius,
          borderSide: BorderSide(color: colors['primary']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smRadius,
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

  // ── Unified Neumorphic Lighting & Surface Utilities ────────────────────────

  /// Calculates top-left light highlight tone for convex Neumorphic surfaces.
  static Color surfaceGradientStart(Color baseColor, bool isDark) {
    return isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.40) ?? baseColor);
  }

  /// Calculates bottom-right depth shadow tone for convex Neumorphic surfaces.
  static Color surfaceGradientEnd(Color baseColor, bool isDark) {
    return isDark
        ? (Color.lerp(baseColor, Colors.black, 0.16) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.09) ?? baseColor);
  }

  /// Returns a pre-configured [LinearGradient] for tactile Neumorphic cards and buttons.
  static LinearGradient softGradient({
    required Color baseColor,
    required bool isDark,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        surfaceGradientStart(baseColor, isDark),
        surfaceGradientEnd(baseColor, isDark),
      ],
    );
  }

  /// Unified crisp hairline border color for tactile Neumorphic edges.
  static Color subtleBorderColor(bool isDark, {bool isPressed = false}) {
    return isDark
        ? Colors.white.withValues(alpha: isPressed ? 0.03 : 0.06)
        : Colors.white.withValues(alpha: isPressed ? 0.35 : 0.82);
  }

  /// Recessed/debossed inner surface color for well containers and inputs.
  static Color debossedSurfaceColor(Color baseColor, bool isDark) {
    return isDark
        ? (Color.lerp(baseColor, Colors.black, 0.28) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.35) ?? baseColor);
  }
}
