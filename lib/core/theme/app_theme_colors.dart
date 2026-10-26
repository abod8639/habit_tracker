import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_utils.dart';

/// Custom theme extension providing unified application colors not natively
/// covered by standard [ColorScheme].
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color debossedSurface;
  final Color subtleBorder;
  final Color disabledSurface;
  final Color drawerScanIcon;
  final Color drawerStatsIcon;
  final Color drawerAiIcon;
  final Color drawerSettingsIcon;

  const AppThemeColors({
    required this.debossedSurface,
    required this.subtleBorder,
    required this.disabledSurface,
    required this.drawerScanIcon,
    required this.drawerStatsIcon,
    required this.drawerAiIcon,
    required this.drawerSettingsIcon,
  });

  /// Factory creating an [AppThemeColors] instance tailored for light or dark modes.
  factory AppThemeColors.fromTheme({
    required bool isDark,
    required Color surfaceColor,
  }) {
    return AppThemeColors(
      debossedSurface: ThemeUtils.debossedSurfaceColor(surfaceColor, isDark),
      subtleBorder: ThemeUtils.subtleBorderColor(isDark),
      disabledSurface: AppColors.disabledSurface(isDark),
      drawerScanIcon: AppColors.drawerScan,
      drawerStatsIcon: AppColors.drawerStats,
      drawerAiIcon: AppColors.drawerAiCoach,
      drawerSettingsIcon: AppColors.drawerSettings,
    );
  }

  /// Default fallback instance when no extension is found in current theme context.
  factory AppThemeColors.fallback(bool isDark) {
    final surfaceColor = isDark
        ? const Color(0xFF1E2228)
        : const Color(0xFFE8EEF5);
    return AppThemeColors.fromTheme(isDark: isDark, surfaceColor: surfaceColor);
  }

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? debossedSurface,
    Color? subtleBorder,
    Color? disabledSurface,
    Color? drawerScanIcon,
    Color? drawerStatsIcon,
    Color? drawerAiIcon,
    Color? drawerSettingsIcon,
  }) {
    return AppThemeColors(
      debossedSurface: debossedSurface ?? this.debossedSurface,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      disabledSurface: disabledSurface ?? this.disabledSurface,
      drawerScanIcon: drawerScanIcon ?? this.drawerScanIcon,
      drawerStatsIcon: drawerStatsIcon ?? this.drawerStatsIcon,
      drawerAiIcon: drawerAiIcon ?? this.drawerAiIcon,
      drawerSettingsIcon: drawerSettingsIcon ?? this.drawerSettingsIcon,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      debossedSurface: Color.lerp(debossedSurface, other.debossedSurface, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      disabledSurface: Color.lerp(disabledSurface, other.disabledSurface, t)!,
      drawerScanIcon: Color.lerp(drawerScanIcon, other.drawerScanIcon, t)!,
      drawerStatsIcon: Color.lerp(drawerStatsIcon, other.drawerStatsIcon, t)!,
      drawerAiIcon: Color.lerp(drawerAiIcon, other.drawerAiIcon, t)!,
      drawerSettingsIcon: Color.lerp(
        drawerSettingsIcon,
        other.drawerSettingsIcon,
        t,
      )!,
    );
  }
}
