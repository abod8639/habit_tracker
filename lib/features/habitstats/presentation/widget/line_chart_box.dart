import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habitstats_providers.dart';
import 'my_line_chart_bar_data.dart';
import 'build_trend_chart.dart';

class LineChartBox extends ConsumerWidget {
  const LineChartBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitStatsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Map<String, List<FlSpot>> progression = state.individualTrends;

    final now = DateTime.now();
    final List<String> trendLabels = List.generate(
      state.daysPeriod,
      (index) {
        final date = now.subtract(
          Duration(days: state.daysPeriod - 1 - index),
        );
        return '${date.day}/${date.month}';
      },
    );

    return SizedBox(
      height: 240,
      child: LineChart(
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.50)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 28,
                interval: (state.daysPeriod / 7).ceilToDouble(),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == 0 ||
                      value == 0.25 ||
                      value == 0.5 ||
                      value == 0.75 ||
                      value == 1.0) {
                    return Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : const Color(0xFF64748B),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 34,
                interval: 0.25,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.20 : 0.35,
                ),
                width: 1,
              ),
              left: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.20 : 0.35,
                ),
                width: 1,
              ),
              top: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          minX: 0,
          maxX: (state.daysPeriod - 1).toDouble(),
          minY: -0.05,
          maxY: 1.10,

          lineBarsData: _buildLineBarsData(
            context: context,
            state: state,
            progression: progression,
            trendLabels: trendLabels,
          ),
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData({
    required BuildContext context,
    required HabitStatsState state,
    required Map<String, List<FlSpot>> progression,
    required List<String> trendLabels,
  }) {
    final List<LineChartBarData> lineBars = [];

    if (state.showAllHabits) {
      lineBars.add(
        myLineChartBarData(
          color: Theme.of(context).colorScheme.secondary,
          color1: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          color2: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.1),
          spots: state.overallTrend,
          label: 'Overall',
        ),
      );
    } else {
      for (int i = 0; i < state.habitNames.length; i++) {
        final habitName = state.habitNames[i];

        if (progression.containsKey(habitName)) {
          final spots = progression[habitName];
          if (spots != null && spots.isNotEmpty) {
            lineBars.add(
              myLineChartBarData(
                color: _getHabitColor(i, context),
                spots: spots,
                color1: _getHabitColor(i, context).withValues(alpha: 0.05),
                color2: _getHabitColor(i, context).withValues(alpha: 0.07),
                label: _getHabitLabel(habitName, state.isWeeklyView),
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
