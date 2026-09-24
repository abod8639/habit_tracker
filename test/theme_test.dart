import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_utils.dart';

void main() {
  group('ThemeUtils & Contrast Tests', () {
    test('buildThemeData computes Brightness.dark when background is dark', () {
      final darkColors = themeColors['github_dark_green']!;
      final theme = ThemeUtils.buildThemeData(
        forceDark: false,
        colors: darkColors,
        isDarkTheme: true,
      );

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor.computeLuminance(), lessThan(0.5));
    });

    test('buildThemeData computes Brightness.light when background is light', () {
      final lightColors = themeColors.values.firstWhere(
        (c) => !ThemeUtils.isDarkTheme(c),
      );
      final theme = ThemeUtils.buildThemeData(
        forceDark: false,
        colors: lightColors,
        isDarkTheme: false,
      );

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor.computeLuminance(), greaterThan(0.5));
    });

    test('custom background dynamically drives brightness and contrast', () {
      final colors = themeColors['github_dark_green']!;

      // Override with pure white custom background
      final whiteBgTheme = ThemeUtils.buildThemeData(
        forceDark: false,
        colors: colors,
        isDarkTheme: true,
        customBackground: Colors.white,
      );
      expect(whiteBgTheme.brightness, Brightness.light);
      expect(whiteBgTheme.colorScheme.brightness, Brightness.light);

      // Override with pure black custom background
      final blackBgTheme = ThemeUtils.buildThemeData(
        forceDark: false,
        colors: colors,
        isDarkTheme: false,
        customBackground: Colors.black,
      );
      expect(blackBgTheme.brightness, Brightness.dark);
      expect(blackBgTheme.colorScheme.brightness, Brightness.dark);
    });
  });
}
