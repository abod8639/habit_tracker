import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_card_header.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

export 'package:habit_tracker/core/components/neumorphic_card_header.dart';
export 'package:habit_tracker/core/components/neumorphic_empty_state.dart';
export 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
export 'package:habit_tracker/core/components/neumorphic_pill_toggle.dart';

/// Backward-compatible alias for [NeumorphicCardHeader].
typedef StatsCardHeader = NeumorphicCardHeader;

/// Backward-compatible alias for [NeumorphicIconButton].
typedef NeumorphicCircularButton = NeumorphicIconButton;

/// Centralized Neumorphism & Soft UI styling utilities for Habit Stats feature.
/// Delegates shadow calculations and curvature scales directly to centralized
/// [AppShadows] and [AppRadius] design tokens.
abstract final class StatsNeumorphicTheme {
  /// Base surface gradient with top-left light source reflection.
  static LinearGradient surfaceGradient(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [surfaceGradientStart, surfaceGradientEnd],
    );
  }

  /// Ambient raised card decoration with unified [AppShadows.softCard].
  static BoxDecoration cardDecoration(
    BuildContext context, {
    double borderRadius = AppRadius.card,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.80);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: surfaceGradient(context),
      border: Border.all(
        color: borderColor,
        width: 1.2,
      ),
      boxShadow: AppShadows.softCard(isDark: isDark),
    );
  }

  /// Debossed / recessed well decoration with unified [AppShadows.wellDual].
  static BoxDecoration wellDecoration(
    BuildContext context, {
    double borderRadius = AppRadius.well,
    Color? accentColor,
    double accentAlpha = 0.08,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.30) ?? baseColor);

    final surfaceColor = accentColor != null
        ? (Color.lerp(wellBase, accentColor, accentAlpha) ?? wellBase)
        : wellBase;

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.70);

    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: 1.0,
      ),
      boxShadow: AppShadows.wellDual(isDark: isDark),
    );
  }

  /// Circular or pill soft badge decoration with unified [AppShadows.badge].
  static BoxDecoration badgeDecoration(
    BuildContext context, {
    Color? color,
    double borderRadius = AppRadius.badge,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final badgeColor = color ?? theme.colorScheme.primary;

    final badgeBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.28) ?? baseColor);

    final surfaceColor =
        Color.lerp(
          badgeBase,
          badgeColor,
          isDark ? 0.14 : 0.09,
        ) ??
        badgeBase;

    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: badgeColor.withValues(alpha: isDark ? 0.35 : 0.25),
        width: 1.0,
      ),
      boxShadow: AppShadows.badge(isDark: isDark),
    );
  }
}
