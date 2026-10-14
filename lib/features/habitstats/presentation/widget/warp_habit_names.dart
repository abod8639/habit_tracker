import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import '../providers/habitstats_providers.dart';
import 'build_trend_chart.dart';
import 'stats_neumorphic_utils.dart';

/// Wrap layout displaying legend chips for all active habits in trend charts.
class WarpHabitNames extends ConsumerWidget {
  const WarpHabitNames({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitNames = ref.watch(habitStatsNotifierProvider.select((s) => s.habitNames));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            textColor: colorScheme.onSurface,
            textStyle: textTheme.labelMedium,
          ),
      ],
    );
  }
}

class _HabitLegendChip extends StatelessWidget {
  final String name;
  final Color color;
  final Color textColor;
  final TextStyle? textStyle;

  const _HabitLegendChip({
    required this.name,
    required this.color,
    required this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: StatsNeumorphicTheme.wellDecoration(
        context,
        borderRadius: AppRadius.well,
        accentColor: color,
        accentAlpha: isDark ? 0.08 : 0.04,
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
              boxShadow: AppShadows.activeDot(color: color),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: textStyle?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
