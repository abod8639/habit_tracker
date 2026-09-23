import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/monthly_summary.dart';

class SliverMonthlySummary extends StatelessWidget {
  const SliverMonthlySummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return SliverToBoxAdapter(
      child: Center(
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(() {
              final datasets = controller.heatmapDateSet;
              final startDay = controller.getStartDay();
              return MonthlySummary(
                key: ValueKey('${startDay}_${datasets.isEmpty}'),
                datasets: Map<DateTime, int>.from(datasets),
              );
            }),
          ),
        ),
      ),
    );
  }
}
