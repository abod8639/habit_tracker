import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habitstats_controller.dart';
import 'my_line_chart_bar_data.dart';
import 'build_trend_chart.dart';

class LineChartBox extends GetView<HabitStatsController> {
  const LineChartBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 240,
      child: Obx(() {
        final Map<String, List<FlSpot>> progression =
            controller.individualTrends;

        final now = DateTime.now();
        final List<String> trendLabels = List.generate(
          controller.daysPeriod.value,
          (index) {
            final date = now.subtract(
              Duration(days: controller.daysPeriod.value - 1 - index),
            );
            return '${date.day}/${date.month}';
          },
        );

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.12 : 0.22,
                  ),
                  strokeWidth: 0.8,
                  dashArray: [4, 4],
                );
              },
            ),

            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < trendLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          trendLabels[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 24,
                  interval: controller.isWeeklyView.value ? 1 : 5,
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.25,
                  getTitlesWidget: (value, meta) {
                    if (value < 0.0 || value > 1.0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Text(
                        '${(value * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: colorScheme.outline,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                  reservedSize: 34,
                ),
              ),

              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            borderData: FlBorderData(show: false),

            clipData: const FlClipData.all(),
            minX: 0.0,
            maxX: (trendLabels.length - 1).toDouble().clamp(1.0, double.infinity),
            minY: -0.05,
            maxY: 1.10,

            lineBarsData: _buildLineBarsData(
              context: context,
              controller: controller,
              progression: progression,
              trendLabels: trendLabels,
            ),
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }),
    );
  }

  List<LineChartBarData> _buildLineBarsData({
    required BuildContext context,
    required HabitStatsController controller,
    required Map<String, List<FlSpot>> progression,
    required List<String> trendLabels,
  }) {
    final List<LineChartBarData> lineBars = [];

    if (controller.showAllHabits.value) {
      lineBars.add(
        myLineChartBarData(
          color: Theme.of(context).colorScheme.primary,
          spots: controller.overallTrend,
          label: 'Overall',
        ),
      );
    } else {
      for (int i = 0; i < controller.habitNames.length; i++) {
        final habitName = controller.habitNames[i];

        if (progression.containsKey(habitName)) {
          final spots = progression[habitName];
          if (spots != null && spots.isNotEmpty) {
            lineBars.add(
              myLineChartBarData(
                spots: spots,
                color: _getHabitColor(i, context),
                label: _getHabitLabel(habitName, controller.isWeeklyView.value),
              ),
            );
          }
        }
      }
    }

    return lineBars;
  }

  Color _getHabitColor(int index, BuildContext context) {
    if (index < lineColors.length) {
      return lineColors[index];
    }
    return lineColors[index % lineColors.length];
  }

  String _getHabitLabel(String habitName, bool isWeekly) {
    final period = isWeekly ? '7d' : '30d';
    return '$habitName ($period)';
  }
}
