import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/neumorphic_card_header.dart';
import 'package:habit_tracker/core/components/neumorphic_empty_state.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/components/neumorphic_pill_toggle.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'line_chart_box.dart';
import 'warp_habit_names.dart';

final List<Color> lineColors = [
  const Color(0xFF6366F1), // Indigo
  const Color(0xFF10B981), // Emerald
  const Color(0xFFF59E0B), // Amber
  const Color(0xFFEC4899), // Pink
  const Color(0xFF06B6D4), // Cyan
  const Color(0xFF8B5CF6), // Purple
  const Color(0xFFF97316), // Orange
  const Color(0xFF14B8A6), // Teal
  const Color(0xFF3B82F6), // Blue
  const Color(0xFFE11D48), // Rose
];

/// Interactive trend chart card displaying overall and per-habit completion trends.
class TrendChartCard extends StatelessWidget {
  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitStatsController controller = Get.find<HabitStatsController>();

    return Obx(() {
      final List<FlSpot> trendSpots = controller.overallTrend;
      final bool hasOverallData =
          trendSpots.isNotEmpty &&
          !(trendSpots.length <= 1 && trendSpots[0] == const FlSpot(0, 0));
      final bool hasIndividualData = controller.individualTrends.isNotEmpty;

      final bool isEmpty = controller.showAllHabits.value
          ? !hasOverallData
          : !hasIndividualData;

      final colorScheme = Theme.of(context).colorScheme;

      if (isEmpty && !controller.isLoading.value) {
        return SoftCard(
          child: NeumorphicEmptyState(
            icon: Icons.trending_up_rounded,
            message: S.current.trendChartIsEmpty,
            height: 240,
          ),
        );
      }

      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeumorphicCardHeader(
              icon: Icons.trending_up_rounded,
              title: S.current.weekly,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeumorphicPillToggle(
                    options: [S.current.weekly, S.current.monthly],
                    selectedIndex: controller.isWeeklyView.value ? 0 : 1,
                    onSelect: (index) {
                      if ((index == 0 && !controller.isWeeklyView.value) ||
                          (index == 1 && controller.isWeeklyView.value)) {
                        controller.togglePeriod();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  NeumorphicIconButton(
                    size: 36,
                    icon: controller.showAllHabits.value
                        ? Icons.stacked_line_chart_rounded
                        : Icons.view_list_rounded,
                    accentColor: colorScheme.primary,
                    tooltip: controller.showAllHabits.value
                        ? 'Show individual habits'
                        : 'Show overall trend',
                    onPressed: () => controller.toggleShowAllHabits(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const LineChartBox(),
            if (!controller.showAllHabits.value) ...[
              const SizedBox(height: 16),
              const WarpHabitNames(),
            ],
          ],
        ),
      );
    });
  }
}

/// Backward-compatible builder function delegating to [TrendChartCard].
Widget buildTrendChart() => const TrendChartCard();
