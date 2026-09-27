import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';
import 'stats_neumorphic_utils.dart';

/// Reusable individual statistic metric widget displaying icon, numerical value, and label.
class StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatItem({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPhone = ResponsiveUtils.isPhone(context);

    final baseColor = theme.cardColor;

    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.06) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.55) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.10) ?? baseColor);

    final double iconContainerSize = isPhone ? 38.0 : 42.0;
    final double effectiveIconSize = isPhone ? 18.0 : 21.0;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(
          vertical: isPhone ? 14 : 16,
          horizontal: isPhone ? 6 : 10,
        ),
        decoration: StatsNeumorphicTheme.wellDecoration(
          context,
          borderRadius: AppRadius.well,
          accentColor: color,
          accentAlpha: isDark ? 0.07 : 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [surfaceStart, surfaceEnd],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.90),
                  width: 1.0,
                ),
                boxShadow: [
                  ...AppShadows.buttonResting(isDark: isDark),
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0.28 : 0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: effectiveIconSize,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: isPhone ? 18 : 22,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: isPhone ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Backward-compatible builder function delegating to [StatItem].
Widget buildStatItem(String title, String value, IconData icon, Color color) {
  return StatItem(
    title: title,
    value: value,
    icon: icon,
    color: color,
  );
}
