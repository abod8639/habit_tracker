import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';
import 'stats_neumorphic_utils.dart';

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

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(
          vertical: isPhone ? 14 : 18,
          horizontal: isPhone ? 8 : 12,
        ),
        decoration: StatsNeumorphicTheme.wellDecoration(
          context,
          borderRadius: 18,
          accentColor: color,
          accentAlpha: isDark ? 0.08 : 0.04,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.16 : 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0.25 : 0.18),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: isPhone ? 20 : 24,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isPhone ? 18 : 22,
                color: colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: isPhone ? 11 : 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
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

Widget buildStatItem(String title, String value, IconData icon, Color color) {
  return StatItem(
    title: title,
    value: value,
    icon: icon,
    color: color,
  );
}
