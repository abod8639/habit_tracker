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
              surfaceColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
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
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final chipBaseColor = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.3) ?? baseColor);

    final chipBg = Color.lerp(
          chipBaseColor,
          color,
          isDark ? 0.12 : 0.08,
        ) ??
        chipBaseColor;

    final lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.85);

    final darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: lightShadow,
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: darkShadow,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.6 : 0.45),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: textStyle?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
