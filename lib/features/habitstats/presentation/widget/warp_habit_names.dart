import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habitstats_controller.dart';
import 'build_trend_chart.dart';

class WarpHabitNames extends StatelessWidget {
  const WarpHabitNames({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitStatsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      final List<String> habitNames = controller.habitNames;
      if (habitNames.isEmpty) {
        return const SizedBox.shrink();
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (int i = 0; i < habitNames.length; i++)
            _HabitLegendChip(
              name: habitNames[i],
              color: lineColors[i % lineColors.length],
              surfaceColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              textColor: colorScheme.onSurface,
              textStyle: textTheme.labelMedium,
            ),
        ],
      );
    });
  }
}

class _HabitLegendChip extends StatelessWidget {
  final String name;
  final Color color;
  final Color surfaceColor;
  final Color textColor;
  final TextStyle? textStyle;

  const _HabitLegendChip({
    required this.name,
    required this.color,
    required this.surfaceColor,
    required this.textColor,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30), //surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: textStyle?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
