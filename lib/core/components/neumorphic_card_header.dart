import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable tactile Neumorphic header for cards, sections, and dialogs.
/// Displays an embossed circular icon, clean title, and optional trailing widget.
class NeumorphicCardHeader extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget? trailing;
  final Color? iconColor;
  final TextStyle? titleStyle;

  const NeumorphicCardHeader({
    super.key,
    this.icon,
    this.title,
    this.trailing,
    this.iconColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    final baseColor = theme.cardColor;
    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) 
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [surfaceGradientStart, surfaceGradientEnd],
                  ),
                  border: Border.all(
                    color: isDark
                        ? const Color.fromARGB(255, 20, 20, 20).withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.90),
                    width: 1.0,
                  ),
                  boxShadow: AppShadows.dotIndicator(isDark: isDark),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: effectiveIconColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title??"",
                style: titleStyle ??
                    theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
