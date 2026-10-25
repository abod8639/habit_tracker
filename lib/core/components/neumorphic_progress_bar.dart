import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

/// A tactile Neumorphic progress indicator featuring a debossed recessed well
/// track and an extruded glowing gradient progress fill.
class NeumorphicProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? accentColor;
  final Color? trackColor;

  const NeumorphicProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.accentColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final effectiveAccent = accentColor ?? theme.colorScheme.primary;

    final Color wellColor =
        trackColor ?? ThemeUtils.debossedSurfaceColor(baseColor, isDark);

    final clampedValue = value.clamp(0.0, 1.0);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: wellColor,
        borderRadius: AppRadius.pillRadius,
        boxShadow: AppShadows.wellDual(isDark: isDark),
        border: Border.all(
          color: ThemeUtils.subtleBorderColor(isDark),
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * clampedValue;
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: AppRadius.pillRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeUtils.accentGradientStart(effectiveAccent, isDark),
                    effectiveAccent,
                  ],
                ),
                boxShadow: [
                  ...AppShadows.bloom(
                    color: effectiveAccent,
                    isDark: isDark,
                    blur: 0,
                    spread: 0.1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
