import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A tactile Neumorphic checkbox widget featuring a debossed recessed well
/// when unselected and a vibrant embossed blooming accent when selected.
class NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final double size;
  final BorderRadius? borderRadius;

  const NeumorphicCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.size = 22.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final effectiveColor = activeColor ?? colorScheme.primary;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(6.0);

    final Color wellColor = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.28) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.35) ?? baseColor);

    return MouseRegion(
      cursor: onChanged != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? effectiveColor : wellColor,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: value
                  ? effectiveColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFA3B1C6).withValues(alpha: 0.50)),
              width: 1.2,
            ),
            boxShadow: value
                ? AppShadows.bloom(
                    color: effectiveColor,
                    isDark: isDark,
                    blur: 6,
                    spread: 0.4,
                  )
                : AppShadows.insetWell(isDark: isDark),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: value
                ? Icon(
                    Icons.check_rounded,
                    key: const ValueKey('checked'),
                    size: size * 0.68,
                    color: Colors.white,
                  )
                : const SizedBox.shrink(key: ValueKey('unchecked')),
          ),
        ),
      ),
    );
  }
}
