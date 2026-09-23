import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'line_chart_box.dart';
import 'warp_habit_names.dart';

final List<Color> lineColors = [
  Colors.purple,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.teal,
  Colors.pink,
  Colors.greenAccent,
  Colors.yellowAccent,
  Colors.purpleAccent,
];

Widget buildTrendChart() {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final List<FlSpot> trendSpots = controller.overallTrend;
    final bool hasOverallData =
        trendSpots.isNotEmpty &&
        !(trendSpots.length <= 1 && trendSpots[0] == const FlSpot(0, 0));
    final bool hasIndividualData = controller.individualTrends.isNotEmpty;

    // Determine if we should show the empty state based on the current view mode
    final bool isEmpty = controller.showAllHabits.value
        ? !hasOverallData
        : !hasIndividualData;

    if (isEmpty && !controller.isLoading.value) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: Center(
              child: Text(
                S.current.trendChartIsEmpty,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.togglePeriod(),
                    child: Text(
                      controller.isWeeklyView.value
                          ? S.current.weekly
                          : S.current.monthly,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.toggleShowAllHabits(),
                    icon: Icon(
                      controller.showAllHabits.value
                          ? Icons.stacked_line_chart
                          : Icons.view_list,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const LineChartBox(),
            const SizedBox(height: 16),
            const WarpHabitNames(),
          ],
        ),
      ),
    );
  });
}
