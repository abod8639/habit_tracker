import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

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
    final Color wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.28) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.35) ?? baseColor);

    final Color trackColor = value
        ? Color.alphaBlend(
            primary.withValues(alpha: isDark ? 0.35 : 0.22),
            wellBase,
          )
        : wellBase;

    // Convex surface for inactive thumb
    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.08) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.70) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.20) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.12) ?? baseColor);

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
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.70)),
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
                      ? Colors.white.withValues(alpha: isDark ? 0.35 : 0.85)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.white.withValues(alpha: 0.95)),
                  width: 1.0,
                ),
                boxShadow: value
                    ? [
                        ...AppShadows.buttonResting(isDark: isDark),
                        BoxShadow(
                          color: primary.withValues(
                            alpha: isDark ? 0.45 : 0.30,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 1.5),
                        ),
                      ]
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
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.30)
                                : Colors.black.withValues(alpha: 0.25),
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
