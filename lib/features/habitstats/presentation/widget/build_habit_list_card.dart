import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/habitstats_providers.dart';
import 'build_habit_list.dart';
import 'stats_neumorphic_utils.dart';

/// Interactive habit list card breaking down today's completed and incomplete habits.
class HabitListCard extends ConsumerWidget {
  const HabitListCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitStatsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final List<HabitEntity> chartData = state.todaySummary;
    final completedHabits = chartData
        .where((habit) => habit.isCompleted)
        .toList();
    final incompleteHabits = chartData
        .where((habit) => !habit.isCompleted)
        .toList();

    if (chartData.isEmpty) {
      return SoftCard(
        child: NeumorphicEmptyState(
          icon: Icons.checklist_rounded,
          message: S.current.isEmpty,
          height: 220,
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (completedHabits.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  _StatusIndicatorCircle(
                    icon: Icons.check_circle_rounded,
                    iconColor: colorScheme.primary,
                    isDark: isDark,
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${S.current.completedLabel} (${completedHabits.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            HabitSubList(habits: completedHabits, isCompleted: true),
            const SizedBox(height: 16),
          ],

          if (incompleteHabits.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  _StatusIndicatorCircle(
                    icon: Icons.pending_actions_rounded,
                    iconColor: colorScheme.error,
                    isDark: isDark,
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${S.current.incomplete} (${incompleteHabits.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            HabitSubList(habits: incompleteHabits, isCompleted: false),
          ],
        ],
      ),
    );
  }
}

class _StatusIndicatorCircle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final BuildContext context;

  const _StatusIndicatorCircle({
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: StatsNeumorphicTheme.surfaceGradient(context),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.90),
          width: 1.0,
        ),
        boxShadow: AppShadows.dotIndicator(isDark: isDark),
      ),
      child: Icon(
        icon,
        size: 19,
        color: iconColor,
      ),
    );
  }
}

/// Backward-compatible builder function delegating to [HabitListCard].
Widget buildHabitListCard(BuildContext context) => const HabitListCard();
