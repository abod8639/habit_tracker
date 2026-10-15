import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../providers/habitstats_providers.dart';
import 'build_trend_chart.dart';
import 'stats_neumorphic_utils.dart';

Color resolveHabitColor(String habitName, int index, List<HabitEntity> habits) {
  final habit = habits.where((h) => h.name == habitName || h.id == habitName).firstOrNull;
  if (habit?.colorValue != null && habit!.colorValue != 0) {
    return Color(habit.colorValue!);
  }
  return lineColors[index % lineColors.length];
}

/// Wrap layout displaying interactive legend chips for habits in trend charts.
class WarpHabitNames extends ConsumerWidget {
  const WarpHabitNames({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitStatsNotifierProvider);
    final notifier = ref.read(habitStatsNotifierProvider.notifier);
    final habitNames = state.habitNames;
    final habits = state.todaySummary;
    final selectedHabit = state.selectedHabitName;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (habitNames.isEmpty) {
      return const SizedBox.shrink();
    }

    final allLabel = isArabic ? 'الكل' : 'All';
    final isAllSelected = selectedHabit == null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "All" chip to view all habits together
        _HabitLegendChip(
          name: allLabel,
          color: colorScheme.primary,
          textColor: colorScheme.onSurface,
          textStyle: textTheme.labelMedium,
          isSelected: isAllSelected,
          onTap: () => notifier.selectHabit(null),
        ),
        for (int i = 0; i < habitNames.length; i++) ...[
          () {
            final name = habitNames[i];
            final color = resolveHabitColor(name, i, habits);
            final isSelected = selectedHabit == name;

            return _HabitLegendChip(
              name: name,
              color: color,
              textColor: colorScheme.onSurface,
              textStyle: textTheme.labelMedium,
              isSelected: isSelected,
              isDimmed: selectedHabit != null && !isSelected,
              onTap: () => notifier.selectHabit(name),
            );
          }(),
        ],
      ],
    );
  }
}

class _HabitLegendChip extends StatelessWidget {
  final String name;
  final Color color;
  final Color textColor;
  final TextStyle? textStyle;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _HabitLegendChip({
    required this.name,
    required this.color,
    required this.textColor,
    this.textStyle,
    this.isSelected = false,
    this.isDimmed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDimmed ? 0.38 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.well),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: StatsNeumorphicTheme.wellDecoration(
              context,
              borderRadius: AppRadius.well,
              accentColor: isSelected ? color : color.withValues(alpha: 0.3),
              accentAlpha: isSelected
                  ? (isDark ? 0.22 : 0.14)
                  : (isDark ? 0.06 : 0.03),
            ).copyWith(
              border: isSelected
                  ? Border.all(color: color.withValues(alpha: 0.8), width: 1.5)
                  : null,
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
                    boxShadow: isSelected ? AppShadows.activeDot(color: color) : null,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  name,
                  style: textStyle?.copyWith(
                    color: isSelected ? color : textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
