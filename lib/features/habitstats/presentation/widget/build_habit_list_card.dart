import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'build_habit_list.dart';
import 'stats_neumorphic_utils.dart';

class HabitListCard extends StatelessWidget {
  const HabitListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitStatsController controller = Get.find<HabitStatsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final List<Map<String, dynamic>> chartData = controller.todaySummary;
      final completedHabits = chartData
          .where((habit) => habit['completed'] == true)
          .toList();
      final incompleteHabits = chartData
          .where((habit) => habit['completed'] == false)
          .toList();

      if (chartData.isEmpty) {
        return SoftCard(
          child: SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: StatsNeumorphicTheme.wellDecoration(
                      context,
                      borderRadius: 36,
                    ),
                    child: Icon(
                      Icons.checklist_rounded,
                      size: 38,
                      color: colorScheme.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    S.current.isEmpty,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsCardHeader(
              icon: Icons.task_alt_rounded,
              title: S.current.success,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: StatsNeumorphicTheme.badgeDecoration(
                  context,
                  borderRadius: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_rtl_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${completedHabits.length}/${chartData.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (completedHabits.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                     Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: StatsNeumorphicTheme.surfaceGradient(context),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.9),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.9),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 19,
                  color: colorScheme.primary,
                ),
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
                     Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: StatsNeumorphicTheme.surfaceGradient(context),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.red.withValues(alpha: 0.9),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.red.withValues(alpha: 0.9),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pending_actions_rounded,
                  size: 19,
                  color: colorScheme.error,
                ),
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
    });
  }
}

Widget buildHabitListCard(BuildContext context) {
  return const HabitListCard();
}
