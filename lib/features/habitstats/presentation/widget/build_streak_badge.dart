import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'stats_neumorphic_utils.dart';

/// Reusable streak indicator badge with flame icon and dynamic radiant styling.
class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final bool hasStreak = streak > 0;
    const Color streakColor = Color(0xFFFF9800); // Warm radiant amber flame
    final Color badgeColor = hasStreak
        ? streakColor
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: StatsNeumorphicTheme.badgeDecoration(
        context,
        color: hasStreak ? streakColor : colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.badge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: badgeColor,
            size: 18,
            shadows: hasStreak
                ? [
                    Shadow(
                      color: streakColor.withValues(
                        alpha: isDark ? 0.70 : 0.40,
                      ),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          const SizedBox(width: 5),
          Text(
            S.of(context).streakDay(streak),
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasStreak
                  ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100))
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward-compatible builder function delegating to [StreakBadge].
Widget buildStreakBadge(int streak) => StreakBadge(streak: streak);
