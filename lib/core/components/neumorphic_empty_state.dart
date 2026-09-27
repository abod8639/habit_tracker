import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable Neumorphic empty state presentation widget.
/// Displays an embossed circular well with an icon and contextual message.
class NeumorphicEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final double height;
  final Widget? action;

  const NeumorphicEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.height = 220.0,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = theme.cardColor;
    final wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.30) ?? baseColor);

    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: wellBase,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.70),
                  width: 1.0,
                ),
                boxShadow: AppShadows.wellDual(isDark: isDark),
              ),
              child: Icon(
                icon,
                size: 36,
                color: colorScheme.outline.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
