import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

/// A tactile Neumorphic / Soft UI toggle switch.
/// Features a recessed debossed well track, extruded sliding thumb,
/// smooth physical depth shadows, and adaptive lighting gradients.
class NeumorphicSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? activeSecondaryColor;
  final double width;
  final double height;

  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.activeSecondaryColor,
    this.width = 54.0,
    this.height = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final primary = activeColor ?? colorScheme.primary;
    final secondary = activeSecondaryColor ?? colorScheme.secondary;

    // Recessed well surface for the track
    final Color wellBase = ThemeUtils.debossedSurfaceColor(baseColor, isDark);

    final Color trackColor = value
        ? Color.alphaBlend(
            primary.withValues(alpha: isDark ? 0.35 : 0.22),
            wellBase,
          )
        : wellBase;

    // Convex surface for inactive thumb
    final Color surfaceStart = ThemeUtils.surfaceGradientStart(
      baseColor,
      isDark,
    );
    final Color surfaceEnd = ThemeUtils.surfaceGradientEnd(baseColor, isDark);

    final double thumbSize = height - 6.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          width: width,
          height: height,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(
              color: value
                  ? primary.withValues(alpha: isDark ? 0.40 : 0.28)
                  : ThemeUtils.subtleBorderColor(isDark),
              width: 1.0,
            ),
            boxShadow: AppShadows.wellDual(isDark: isDark),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOutCubic,
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: value
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, secondary],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [surfaceStart, surfaceEnd],
                      ),
                border: Border.all(
                  color: value
                      ? colorScheme.onPrimary.withValues(
                          alpha: isDark ? 0.35 : 0.85,
                        )
                      : ThemeUtils.subtleBorderColor(isDark),
                  width: 1.0,
                ),
                boxShadow: value
                    ? AppShadows.buttonPressed(isDark: isDark)
                    : AppShadows.buttonResting(isDark: isDark),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: value
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('on'),
                          size: 13,
                          color: colorScheme.onPrimary,
                          shadows: AppShadows.buttonPressed(isDark: isDark),
                        )
                      : Container(
                          key: const ValueKey('off'),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.onSurface.withValues(
                              alpha: isDark ? 0.30 : 0.25,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
