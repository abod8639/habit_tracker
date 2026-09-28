import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';

BarTouchData myBarTouchData(BuildContext context) {
  final controller = Get.find<HabitStatsController>();

  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tooltipMargin: 8,
      // tooltipRoundedRadius: 10,
      getTooltipColor: (group) =>
          Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E222D)
          : const Color(0xFFF0F3F8),
      tooltipBorder: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.90),
        width: 1.0,
      ),
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final List<Map<String, dynamic>> chartData = controller.todaySummary;
        if (groupIndex < 0 || groupIndex >= chartData.length) return null;

        final Map<String, dynamic> habit = chartData[groupIndex];
        final String name = habit['habit'] ?? 'Unnamed';
        final bool completed = habit['completed'] ?? false;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BarTooltipItem(
          name,
          TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          children: [
            TextSpan(
              text:
                  '\n${completed ? S.current.tooltipItemCompleted : S.current.tooltipItem}',
              style: TextStyle(
                color: completed
                    ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669))
                    : (isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFDC2626)),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    ),
  );
}
