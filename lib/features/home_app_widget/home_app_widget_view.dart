import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'domain/entities/home_app_widget_data_entity.dart';

export 'presentation/widgets/home_app_widget_card.dart';
export 'presentation/widgets/home_app_widget_error_card.dart';

/// Simplified Home Screen Widget view designed to be rendered into an image
/// and displayed on the Android/iOS Home Screen via `home_widget` or in-app preview.
///
/// Features:
/// 1. Simplified tactile Neumorphic container sized strictly to prevent RenderFlex overflow.
/// 2. HeatMap progress calendar reflecting real live completion data.
/// 3. Shows compact uncompleted habit pills tailored for static widget snapshots.
/// 4. Completed habits disappear immediately.
class HomeAppWidgetView extends StatelessWidget {
  final List<HabitEntity> habits;
  final Map<DateTime, int> heatmapDatasets;
  final bool isDark;
  final Color primaryColor;
  final bool asSliver;
  final EdgeInsetsGeometry? sliverPadding;

  const HomeAppWidgetView({
    super.key,
    required this.habits,
    required this.heatmapDatasets,
    required this.isDark,
    required this.primaryColor,
  }) : asSliver = false,
       sliverPadding = null;

  const HomeAppWidgetView.sliver({
    super.key,
    required this.habits,
    required this.heatmapDatasets,
    required this.isDark,
    required this.primaryColor,
    this.sliverPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
  }) : asSliver = true;

  factory HomeAppWidgetView.fromEntity({
    Key? key,
    required HomeAppWidgetDataEntity entity,
    required bool isDark,
    required Color primaryColor,
    bool asSliver = false,
    EdgeInsetsGeometry? sliverPadding,
  }) {
    if (asSliver) {
      return HomeAppWidgetView.sliver(
        key: key,
        habits: entity.uncompletedHabits,
        heatmapDatasets: entity.heatmapDatasets,
        isDark: isDark,
        primaryColor: primaryColor,
        sliverPadding: sliverPadding,
      );
    }
    return HomeAppWidgetView(
      key: key,
      habits: entity.uncompletedHabits,
      heatmapDatasets: entity.heatmapDatasets,
      isDark: isDark,
      primaryColor: primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.maybeOf(context);

    // Only display uncompleted habits defensively
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

    final content = Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 14,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s?.today ?? 'Today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E2024),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: uncompletedHabits.isEmpty
                        ? Colors.green.withValues(alpha: 0.16)
                        : primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    uncompletedHabits.isEmpty
                        ? '✓ ${s?.completedLabel ?? 'Done'}'
                        : '${uncompletedHabits.length} ${s?.pending ?? 'Pending'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: uncompletedHabits.isEmpty
                          ? (isDark
                                ? Colors.greenAccent
                                : Colors.green.shade800)
                          : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // HeatMap from theme_card.dart showing real current progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                size: 13,
                colorsets: activeColorSet,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Uncompleted Habits using compact snapshot-friendly tiles
          if (uncompletedHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isDark
                          ? Colors.greenAccent
                          : Colors.green.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s?.allHabitsCompletedToday ??
                          'All habits completed today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF4A4E57),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (final habit in uncompletedHabits.take(2))
              _buildCompactHabitRow(
                context: context,
                habit: habit,
                isDark: isDark,
              ),
            if (uncompletedHabits.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 1),
                child: Center(
                  child: Text(
                    s?.moreHabitsCount(uncompletedHabits.length - 2) ??
                        '+${uncompletedHabits.length - 2} more',
                    style: TextStyle(
                      fontSize: 10.5,
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

    if (asSliver) {
      return SliverToBoxAdapter(
        child: Padding(
          padding:
              sliverPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(child: content),
        ),
      );
    }

    return content;
  }

  Widget _buildCompactHabitRow({
    required BuildContext context,
    required HabitEntity habit,
    required bool isDark,
  }) {
    final habitColor = habit.colorValue != null
        ? Color(habit.colorValue!)
        : primaryColor;

    final displayName = habit.name.trim().isEmpty ? 'Habit' : habit.name;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: habitColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: habitColor.withValues(alpha: 0.4),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.90)
                    : const Color(0xFF202328),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A Sliver wrapper for [HomeAppWidgetView] designed to be placed directly
/// inside a [CustomScrollView].
class SliverHomeAppWidgetView extends StatelessWidget {
  final List<HabitEntity> habits;
  final Map<DateTime, int> heatmapDatasets;
  final bool isDark;
  final Color primaryColor;
  final EdgeInsetsGeometry padding;

  const SliverHomeAppWidgetView({
    super.key,
    required this.habits,
    required this.heatmapDatasets,
    required this.isDark,
    required this.primaryColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return HomeAppWidgetView.sliver(
      habits: habits,
      heatmapDatasets: heatmapDatasets,
      isDark: isDark,
      primaryColor: primaryColor,
      sliverPadding: padding,
    );
  }
}
