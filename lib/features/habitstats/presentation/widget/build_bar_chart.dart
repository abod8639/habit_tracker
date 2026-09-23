import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'my_bar_touch_data.dart';

Widget buildBarChart() {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final List<Map<String, dynamic>> chartData = controller.todaySummary;
    final int streak = controller.stats.value?.streak ?? 1;

    if (chartData.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: Colors.grey.withValues(alpha: .4),
              ),
              const SizedBox(height: 16),
              Text(
                S.current.barChartIsEmpty,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final int completedCount = chartData
            .where((e) => e['completed'] == true)
            .length;
        final double maxY = streak > 0 ? streak.toDouble() * 1.25 : 5.0;
        final double interval = (maxY / 5).ceilToDouble().clamp(
          1.0,
          double.infinity,
        );

        return Card(
          elevation: 2,
     
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.current.today,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _LegendDot(
                            color: colorScheme.primary,
                            label: S.current.completed,
                          ),
                          const SizedBox(width: 12),
                          _LegendDot(
                            color: colorScheme.error.withValues(alpha: .5),
                            label: S.of(context).incomplete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
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
                                space: 6,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
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
                            alpha: .25,
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
                                          alpha: .65,
                                        ),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        colorScheme.error.withValues(
                                          alpha: .45,
                                        ),
                                        colorScheme.error.withValues(
                                          alpha: .15,
                                        ),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: streak.toDouble(),
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: .25),
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
                      label: S.current.completed,
                      value: '$completedCount / ${chartData.length}',
                      color: colorScheme.primaryContainer,
                      textColor: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: S.current.completionRate,
                      value: chartData.isEmpty
                          ? '0%'
                          : '${(completedCount / chartData.length * 100).round()}%',
                      color: colorScheme.secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: S.current.streak,
                      value: '$streak',
                      color: colorScheme.tertiaryContainer,
                      textColor: colorScheme.onTertiaryContainer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  });
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
