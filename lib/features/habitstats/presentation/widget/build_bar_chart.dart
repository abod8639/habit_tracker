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
                      Icons.bar_chart_rounded,
                      size: 38,
                      color: colorScheme.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    S.current.barChartIsEmpty,
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
      }

      final int completedCount =
          chartData.where((e) => e['completed'] == true).length;
      final double maxY = streak > 0 ? streak.toDouble() * 1.25 : 5.0;
      final double interval =
          (maxY / 5).ceilToDouble().clamp(1.0, double.infinity);

      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsCardHeader(
              icon: Icons.bar_chart_rounded,
              title: S.current.today,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: StatsNeumorphicTheme.badgeDecoration(
                  context,
                  borderRadius: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendDot(
                      color: colorScheme.primary,
                      label: S.current.completed,
                    ),
                    const SizedBox(width: 10),
                    _LegendDot(
                      color: colorScheme.error.withValues(alpha: 0.8),
                      label: S.of(context).incomplete,
                    ),
                  ],
                ),
              ),
            ),
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
                        reservedSize: 26,
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
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 ||
                              value != value.roundToDouble()) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.outline,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
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
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.12 : 0.25,
                      ),
                      strokeWidth: 0.8,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: chartData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final bool isCompleted =
                        entry.value['completed'] ?? false;
                    final double barHeight = isCompleted
                        ? streak.toDouble()
                        : maxY * 0.10;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: barHeight,
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(
                                      alpha: 0.75,
                                    ),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    colorScheme.error.withValues(
                                      alpha: 0.6,
                                    ),
                                    colorScheme.error.withValues(
                                      alpha: 0.25,
                                    ),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: streak.toDouble(),
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.25)
                                : const Color(0xFFA3B1C6)
                                    .withValues(alpha: 0.18),
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
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                  icon: Icons.check_circle_outline_rounded,
                  label: S.current.completed,
                  value: '$completedCount / ${chartData.length}',
                  accentColor: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.pie_chart_outline_rounded,
                  label: S.current.completionRate,
                  value: chartData.isEmpty
                      ? '0%'
                      : '${(completedCount / chartData.length * 100).round()}%',
                  accentColor: const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  label: S.current.streak,
                  value: '$streak',
                  accentColor: const Color(0xFFFF9800),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

Widget buildBarChart() {
  return const TodayBarChartCard();
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 3,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color accentColor;

  const _StatChip({
    required this.label,
    required this.value,
    this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: StatsNeumorphicTheme.wellDecoration(
          context,
          borderRadius: 16,
          accentColor: accentColor,
          accentAlpha: isDark ? 0.07 : 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: isDark ? 0.16 : 0.12),
                    ),
                    child: Icon(
                      icon,
                      size: 13,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
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
