import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habitstats_controller.dart';
import 'build_trend_chart.dart';

class WarpHabitNames extends StatelessWidget {
  const WarpHabitNames({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitStatsController>();

    return Obx(() {
      final List<String> habitNames = controller.habitNames;

      return Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          for (int i = 0; i < habitNames.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: lineColors[i % lineColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  habitNames[i],
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }
}
