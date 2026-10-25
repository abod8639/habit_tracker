import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../providers/habitstats_providers.dart';
import 'build_trend_chart.dart';
import 'package:habit_tracker/core/components/neu_surface.dart';

Color resolveHabitColor(String habitName, int index, List<HabitEntity> habits) {
  final habit = habits
      .where((h) => h.name == habitName || h.id == habitName)
      .firstOrNull;
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
    final state =
        ref.watch(habitStatsNotifierProvider).value ?? const HabitStatsState();
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
    // Selected chip rises and glows; the rest stay engraved in the surface.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDimmed ? 0.45 : 1.0,
      child: NeuSurface(
        onTap: onTap,
        depth: isSelected ? NeuDepth.raised : NeuDepth.inset,
        accentColor: color,
        highlighted: isSelected,
        borderRadius: AppRadius.pillRadius,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? AppShadows.activeDot(color: color)
                    : null,
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
    );
  }
}
