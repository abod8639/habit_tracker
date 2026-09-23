import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

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

    final bool hasStreak = streak > 0;
    final Color badgeColor =
        hasStreak ? colorScheme.secondary : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: hasStreak ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: hasStreak ? 0.3 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: badgeColor,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            S.of(context).streakDay(streak),
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildStreakBadge(int streak) {
  return StreakBadge(streak: streak);
}

