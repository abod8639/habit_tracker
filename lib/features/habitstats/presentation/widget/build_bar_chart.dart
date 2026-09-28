import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'my_bar_touch_data.dart';
import 'stats_neumorphic_utils.dart';

class TodayBarChartCard extends StatelessWidget {
  const TodayBarChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitStatsController controller = Get.find<HabitStatsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final List<Map<String, dynamic>> chartData = controller.todaySummary;
      final int streak = controller.stats.value?.streak ?? 1;

      if (chartData.isEmpty) {
        return SoftCard(
          child: NeumorphicEmptyState(
            icon: Icons.bar_chart_rounded,
            message: S.current.barChartIsEmpty,
            height: 240,
          ),
        );
      }

      final double effectiveStreak = streak > 0 ? streak.toDouble() : 1.0;
      final double maxY = effectiveStreak * 1.25;
      final double interval = (maxY / 5).ceilToDouble().clamp(
        1.0,
        double.infinity,
      );
      final double rodWidth = (180.0 / chartData.length).clamp(10.0, 18.0);

      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 210,
              child: BarChart(
                BarChartData(
                  barTouchData: myBarTouchData(context),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 5,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 1,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: false,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.12 : 0.22,
                      ),
                      strokeWidth: 0.8,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: chartData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final bool isCompleted = entry.value['completed'] ?? false;
                    final double barHeight = isCompleted
                        ? effectiveStreak
                        : maxY * 0.12;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: barHeight,
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.secondary,
                                    colorScheme.primary,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    colorScheme.error.withValues(
                                      alpha: 0.65,
                                    ),
                                    colorScheme.error.withValues(
                                      alpha: 0.25,
                                    ),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                          width: rodWidth,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                            bottom: Radius.circular(4),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.32)
                                : const Color(
                                    0xFFA3B1C6,
                                  ).withValues(alpha: 0.20),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      );
    });
  }
}
