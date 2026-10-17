import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habitstats_providers.dart';
import 'my_line_chart_bar_data.dart';
import 'warp_habit_names.dart';

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

    final lineBars = _buildLineBarsData(
      context: context,
      state: state,
      progression: progression,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: SizedBox(
        key: ValueKey(state.isWeeklyView),
        height: 240,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) =>
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                tooltipBorderRadius: BorderRadius.circular(8),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final barIndex = barSpot.barIndex;
                    if (barIndex < 0 || barIndex >= lineBars.length) return null;
                    final bar = lineBars[barIndex];
                    final isOverall = !state.showAllHabits;
                    if (isOverall) {
                      final percent = (barSpot.y * 100).toInt();
                      return LineTooltipItem(
                        '$percent%',
                        TextStyle(
                          color: bar.color ?? colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }
                    final habitName =
                        state.selectedHabitName ??
                        (barIndex < state.habitNames.length
                            ? state.habitNames[barIndex]
                            : 'Habit');
                    final isCompleted = barSpot.y >= 0.5;
                    final isArabic =
                        Localizations.localeOf(context).languageCode == 'ar';
                    final statusText = isCompleted
                        ? (isArabic ? 'مكتملة' : 'Completed')
                        : (isArabic ? 'غير مكتملة' : 'Incomplete');

                    return LineTooltipItem(
                      '$habitName\n$statusText',
                      TextStyle(
                        color: bar.color ?? colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
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
                    if (index >= 0 && index < state.daysPeriod) {
                      final date = now.subtract(
                        Duration(days: state.daysPeriod - 1 - index),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          '${date.day}/${date.month}',
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

            lineBarsData: lineBars,
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData({
    required BuildContext context,
    required HabitStatsState state,
    required Map<String, List<FlSpot>> progression,
  }) {
    final List<LineChartBarData> lineBars = [];
    final int expectedCount = state.daysPeriod;

    if (state.showAllHabits) {
      final habits = state.todaySummary;
      final habitNames = state.habitNames.isNotEmpty
          ? state.habitNames
          : (progression.isNotEmpty
                ? progression.keys.toList()
                : habits.map((h) => h.name).toList());

      final selectedName = state.selectedHabitName;
      final targetHabitNames = selectedName != null
          ? habitNames.where((name) => name == selectedName).toList()
          : habitNames;

      final activeList = targetHabitNames.isNotEmpty
          ? targetHabitNames
          : habitNames;
      final isSingleHabit = selectedName != null || activeList.length == 1;

      for (int i = 0; i < activeList.length; i++) {
        final habitName = activeList[i];
        final originalIndex = habitNames.indexOf(habitName);
        final effectiveIndex = originalIndex >= 0 ? originalIndex : i;

        List<FlSpot>? rawSpots = progression[habitName];

        if (rawSpots == null || rawSpots.isEmpty) {
          final matchingHabit = habits
              .where((h) => h.name == habitName || h.id == habitName)
              .firstOrNull;
          if (matchingHabit != null) {
            rawSpots =
                progression[matchingHabit.id] ??
                progression[matchingHabit.name];
          }
        }

        if (rawSpots == null || rawSpots.isEmpty) {
          final matchingHabit = habits
              .where((h) => h.name == habitName)
              .firstOrNull;
          final bool isCompletedToday = matchingHabit?.isCompleted ?? false;
          rawSpots = List.generate(
            expectedCount,
            (index) => FlSpot(
              index.toDouble(),
              (index == expectedCount - 1 && isCompletedToday) ? 1.0 : 0.0,
            ),
          );
        } else if (rawSpots.length != expectedCount) {
          if (rawSpots.length > expectedCount) {
            final sub = rawSpots.sublist(rawSpots.length - expectedCount);
            rawSpots = List.generate(
              expectedCount,
              (idx) => FlSpot(idx.toDouble(), sub[idx].y),
            );
          } else {
            final pad = expectedCount - rawSpots.length;
            rawSpots = [
              ...List.generate(pad, (idx) => FlSpot(idx.toDouble(), 0.0)),
              ...List.generate(
                rawSpots.length,
                (idx) => FlSpot((pad + idx).toDouble(), rawSpots![idx].y),
              ),
            ];
          }
        }

        final habitColor = resolveHabitColor(habitName, effectiveIndex, habits);

        lineBars.add(
          myLineChartBarData(
            color: habitColor,
            spots: rawSpots,
            color1: habitColor.withValues(alpha: isSingleHabit ? 0.35 : 0.12),
            color2: habitColor.withValues(alpha: 0.02),
            label: _getHabitLabel(habitName, state.isWeeklyView),
          ),
        );
      }
    } else {
      // Display overall aggregated trend line
      List<FlSpot> overallSpots = state.overallTrend;
      if (overallSpots.isEmpty) {
        final total = state.todaySummary.length;
        final completed = state.todaySummary.where((h) => h.isCompleted).length;
        final rate = total > 0 ? (completed / total) : 0.0;
        overallSpots = List.generate(
          expectedCount,
          (index) => FlSpot(
            index.toDouble(),
            index == expectedCount - 1 ? rate : 0.0,
          ),
        );
      } else if (overallSpots.length != expectedCount) {
        if (overallSpots.length > expectedCount) {
          final sub = overallSpots.sublist(overallSpots.length - expectedCount);
          overallSpots = List.generate(
            expectedCount,
            (idx) => FlSpot(idx.toDouble(), sub[idx].y),
          );
        } else {
          final pad = expectedCount - overallSpots.length;
          overallSpots = [
            ...List.generate(pad, (idx) => FlSpot(idx.toDouble(), 0.0)),
            ...List.generate(
              overallSpots.length,
              (idx) => FlSpot((pad + idx).toDouble(), overallSpots[idx].y),
            ),
          ];
        }
      }

      lineBars.add(
        myLineChartBarData(
          color: Theme.of(context).colorScheme.secondary,
          color1: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          color2: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.1),
          spots: overallSpots,
          label: 'Overall',
        ),
      );
    }

    return lineBars;
  }

  String _getHabitLabel(String habitName, bool isWeekly) {
    final period = isWeekly ? '7d' : '30d';
    return '$habitName ($period)';
  }
}
