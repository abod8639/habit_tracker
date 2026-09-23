import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';

Widget buildPieChart() {
  final HabitStatsController controller = Get.find<HabitStatsController>();

  return Obx(() {
    final stats = controller.stats.value;
    if (stats == null || stats.totalHabits <= 0) {
      return SizedBox(
        height: 330,
        child: Center(child: Text(S.current.pieChartIsEmpty)),
      );
    }

    final int completedHabits = stats.completedHabits;
    final int totalHabits = stats.totalHabits;

    return Builder(
      builder: (context) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 350,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: completedHabits.toDouble(),
                      title: S.current.completedLabel,
                      color: Theme.of(context).primaryColor,
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    PieChartSectionData(
                      value: (totalHabits - completedHabits).toDouble(),
                      title: S.current.incomplete,
                      color: Theme.of(context).colorScheme.error,
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}
