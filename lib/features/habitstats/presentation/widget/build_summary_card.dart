import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'build_stat_item.dart';
import 'build_streak_badge.dart';
import 'stats_neumorphic_utils.dart';

Widget buildSummaryCard() {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final stats = controller.stats.value;
    if (stats == null) return const SizedBox.shrink();

    return Builder(
      builder: (context) {
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
              StatsCardHeader(
                icon: Icons.insights_rounded,
                title: S.current.summary,
                trailing: buildStreakBadge(stats.streak),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildStatItem(
                    S.current.total,
                    stats.totalHabits.toString(),
                    Icons.format_list_bulleted_rounded,
                    totalColor,
                  ),
                  buildStatItem(
                    S.current.completed,
                    stats.completedHabits.toString(),
                    Icons.check_circle_rounded,
                    completedColor,
                  ),
                  buildStatItem(
                    S.current.success,
                    '${stats.completionRate.toStringAsFixed(1)}%',
                    Icons.trending_up_rounded,
                    successColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  });
}
