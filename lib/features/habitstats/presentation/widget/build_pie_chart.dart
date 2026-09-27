import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/neumorphic_card_header.dart';
import 'package:habit_tracker/core/components/neumorphic_empty_state.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'stats_neumorphic_utils.dart';

/// Completion rate pie chart card displaying a breakdown of completed vs incomplete habits.
class CompletionPieChartCard extends StatelessWidget {
  const CompletionPieChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitStatsController controller = Get.find<HabitStatsController>();

    return Obx(() {
      final stats = controller.stats.value;
      if (stats == null || stats.totalHabits <= 0) {
        return SoftCard(
          child: NeumorphicEmptyState(
            icon: Icons.donut_large_rounded,
            message: S.current.pieChartIsEmpty,
            height: 240,
          ),
        );
      }

      final int completedHabits = stats.completedHabits;
      final int totalHabits = stats.totalHabits;
      final int incompleteHabits = totalHabits - completedHabits;
      final double completionRate = stats.completionRate;

      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;
      final isDark = theme.brightness == Brightness.dark;

      const Color completedColor = Color(0xFF10B981); // Emerald
      final Color incompleteColor = colorScheme.error.withValues(alpha: 0.85);

      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NeumorphicCardHeader(
            //   icon: Icons.donut_large_rounded,
            //   title: S.current.completionRate,
            //   iconColor: completedColor,
            //   trailing: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //     decoration: StatsNeumorphicTheme.badgeDecoration(
            //       context,
            //       color: completedColor,
            //       borderRadius: AppRadius.lg,
            //     ),
            //     child: Text(
            //       '${completionRate.toStringAsFixed(1)}%',
            //       style: TextStyle(
            //         fontSize: 12,
            //         fontWeight: FontWeight.bold,
            //         color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 62,
                      sectionsSpace: 3,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: completedHabits.toDouble(),
                          showTitle: false,
                          radius: 20,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF34D399),
                              Color(0xFF059669),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        if (incompleteHabits > 0)
                          PieChartSectionData(
                            value: incompleteHabits.toDouble(),
                            showTitle: false,
                            radius: 17,
                            color: incompleteColor,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${completionRate.toStringAsFixed(0)}%',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        S.current.success,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: StatsNeumorphicTheme.wellDecoration(
                      context,
                      borderRadius: AppRadius.md,
                      accentColor: completedColor,
                      accentAlpha: isDark ? 0.08 : 0.04,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: completedColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: completedColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.current.completed,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$completedHabits',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: completedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: StatsNeumorphicTheme.wellDecoration(
                      context,
                      borderRadius: AppRadius.md,
                      accentColor: incompleteColor,
                      accentAlpha: isDark ? 0.08 : 0.04,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: incompleteColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: incompleteColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.current.incomplete,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$incompleteHabits',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: incompleteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Backward-compatible builder function delegating to [CompletionPieChartCard].
Widget buildPieChart() => const CompletionPieChartCard();
