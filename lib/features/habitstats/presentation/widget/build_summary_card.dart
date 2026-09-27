import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'build_stat_item.dart';

/// Summary overview card displaying overall total, completed habits, and success rate.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitStatsController controller = Get.find<HabitStatsController>();

    return Obx(() {
      final stats = controller.stats.value;
      if (stats == null) return const SizedBox.shrink();

      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      final Color totalColor = colorScheme.primary;
      const Color completedColor = Color(0xFF10B981); // Emerald Green
      final Color successColor = stats.completionRate >= 50
          ? const Color(0xFF10B981)
          : const Color(0xFFF59E0B); // Amber

      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NeumorphicCardHeader(
            //   icon: Icons.insights_rounded,
            //   title: S.current.summary,
            //   trailing: StreakBadge(streak: stats.streak),
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StatItem(
                  title: S.current.total,
                  value: stats.totalHabits.toString(),
                  icon: Icons.format_list_bulleted_rounded,
                  color: totalColor,
                ),
                StatItem(
                  title: S.current.completed,
                  value: stats.completedHabits.toString(),
                  icon: Icons.check_circle_rounded,
                  color: completedColor,
                ),
                StatItem(
                  title: S.current.success,
                  value: '${stats.completionRate.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded,
                  color: successColor,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Backward-compatible builder function delegating to [SummaryCard].
Widget buildSummaryCard() => const SummaryCard();
