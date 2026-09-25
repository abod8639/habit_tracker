import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'stats_neumorphic_utils.dart';

Widget buildPieChart() {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final stats = controller.stats.value;
    if (stats == null || stats.totalHabits <= 0) {
      return Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return SoftCard(
            child: SizedBox(
              height: 240,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: StatsNeumorphicTheme.wellDecoration(
                        context,
                        borderRadius: 36,
                      ),
                      child: Icon(
                        Icons.donut_large_rounded,
                        size: 38,
                        color: colorScheme.outline.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      S.current.pieChartIsEmpty,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    final int completedHabits = stats.completedHabits;
    final int totalHabits = stats.totalHabits;
    final int incompleteHabits = totalHabits - completedHabits;
    final double completionRate = stats.completionRate;

    return Builder(
      builder: (context) {
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
              StatsCardHeader(
                icon: Icons.donut_large_rounded,
                title: S.current.completionRate,
                iconColor: completedColor,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: StatsNeumorphicTheme.badgeDecoration(
                    context,
                    color: completedColor,
                    borderRadius: 16,
                  ),
                  child: Text(
                    '${completionRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                            color: completedColor,
                            radius: 22,
                          ),
                          PieChartSectionData(
                            value: incompleteHabits.toDouble(),
                            showTitle: false,
                            color: incompleteColor,
                            radius: 20,
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    ),
                    // Central Neumorphic recessed circular gauge indicator
                    Container(
                      width: 96,
                      height: 96,
                      decoration: StatsNeumorphicTheme.wellDecoration(
                        context,
                        borderRadius: 48,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${completionRate.round()}%',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            S.current.completedLabel,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Soft UI Legends
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
                        borderRadius: 14,
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
                              S.current.completedLabel,
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
                        borderRadius: 14,
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
      },
    );
  });
}
