import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_text_taile.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Simplified Home Screen Widget view designed to be rendered into an image
/// and displayed on the Android/iOS Home Screen via `home_widget`.
///
/// Features:
/// 1. Simplified tactile Neumorphic container.
/// 2. HeatMap progress calendar reflecting real live completion data.
/// 3. Shows only uncompleted habits using `MyTextTaile`.
/// 4. Completed habits disappear immediately.
class HomeAppWidgetView extends StatelessWidget {
  final List<HabitEntity> habits;
  final Map<DateTime, int> heatmapDatasets;
  final bool isDark;
  final Color primaryColor;

  const HomeAppWidgetView({
    super.key,
    required this.habits,
    required this.heatmapDatasets,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.maybeOf(context) ?? S.current;

    // Only display uncompleted habits
    final uncompletedHabits = habits.where((h) => !h.isCompleted).toList();

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final startDate = normalizedToday.subtract(const Duration(days: 55));

    final activeColorSet = {
      1: primaryColor.withValues(alpha: 0.2),
      3: primaryColor.withValues(alpha: 0.4),
      5: primaryColor.withValues(alpha: 0.6),
      7: primaryColor.withValues(alpha: 0.8),
      10: primaryColor,
    };

    final cardBgColor = isDark
        ? const Color(0xFF1B1D22)
        : const Color(0xFFF4F6FA);

    return Container(
      width: 380,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 15,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.today,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E2024),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: uncompletedHabits.isEmpty
                        ? Colors.green.withValues(alpha: 0.16)
                        : primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    uncompletedHabits.isEmpty
                        ? '✓ ${s.completedLabel}'
                        : '${uncompletedHabits.length} ${s.pending}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: uncompletedHabits.isEmpty
                          ? (isDark ? Colors.greenAccent : Colors.green.shade800)
                          : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // HeatMap from theme_card.dart showing real current progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFFF3F5F9),
              borderRadius: AppRadius.wellRadius,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
              boxShadow: AppShadows.insetWell(isDark: isDark),
            ),
            child: Center(
              child: HeatMap(
                startDate: startDate,
                endDate: normalizedToday,
                datasets: heatmapDatasets,
                colorMode: ColorMode.color,
                defaultColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                textColor: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.45),
                showColorTip: false,
                showText: false,
                scrollable: false,
                size: 14,
                colorsets: activeColorSet,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Uncompleted Habits using MyTextTaile
          if (uncompletedHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isDark
                          ? Colors.greenAccent
                          : Colors.green.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.allHabitsCompletedToday,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF4A4E57),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (final habit in uncompletedHabits.take(3))
              MyTextTaile(
                key: ValueKey(habit.id),
                habitName: habit.name,
                habitCompleted: false,
                colorValue: habit.colorValue,
                enableSlidable: false,
                onChanged: (_) {},
                onDelete: (_) {},
                onEdit: (_) {},
                onTap: () {},
              ),
            if (uncompletedHabits.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 2),
                child: Center(
                  child: Text(
                    s.moreHabitsCount(uncompletedHabits.length - 3),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
