import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/neumorphic_card_header.dart';
import 'package:habit_tracker/core/components/neumorphic_empty_state.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/components/neumorphic_pill_toggle.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/habitstats_providers.dart';
import 'line_chart_box.dart';
import 'warp_habit_names.dart';

final List<Color> lineColors = [
  const Color(0xFF6366F1), // Indigo
  const Color(0xFF10B981), // Emerald
  const Color(0xFFF59E0B), // Amber
  const Color(0xFFEC4899), // Pink
  const Color(0xFF06B6D4), // Cyan
  const Color(0xFF8B5CF6), // Purple
  const Color(0xFFF97316), // Orange
  const Color(0xFF14B8A6), // Teal
  const Color(0xFF3B82F6), // Blue
  const Color(0xFFE11D48), // Rose
];

/// Interactive trend chart card displaying overall and per-habit completion trends.
class TrendChartCard extends ConsumerWidget {
  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state =
        ref.watch(habitStatsNotifierProvider).value ?? const HabitStatsState();
    final notifier = ref.read(habitStatsNotifierProvider.notifier);

    final List<FlSpot> trendSpots = state.overallTrend;
    final bool hasOverallData =
        trendSpots.isNotEmpty &&
        !(trendSpots.length <= 1 && trendSpots[0] == const FlSpot(0, 0));
    final bool hasIndividualData = state.individualTrends.isNotEmpty;

    final bool isEmpty = state.showAllHabits
        ? !hasOverallData
        : !hasIndividualData;

    final colorScheme = Theme.of(context).colorScheme;

    if (isEmpty && state.isLoading) {
      return SoftCard(
        child: SizedBox(
          height: 240,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (isEmpty && !state.isLoading) {
      return SoftCard(
        child: NeumorphicEmptyState(
          icon: Icons.trending_up_rounded,
          message: S.current.trendChartIsEmpty,
          height: 240,
        ),
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeumorphicCardHeader(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeumorphicPillToggle(
                  options: [S.current.weekly, S.current.monthly],
                  selectedIndex: state.isWeeklyView ? 0 : 1,
                  onSelect: (index) {
                    if ((index == 0 && !state.isWeeklyView) ||
                        (index == 1 && state.isWeeklyView)) {
                      notifier.togglePeriod();
                    }
                  },
                ),
                const SizedBox(width: 8),
                NeumorphicIconButton(
                  customShadows: AppShadows.softCard(isDark: isDark),
                  size: 36,
                  icon: state.showAllHabits
                      ? Icons.stacked_line_chart_rounded
                      : Icons.view_list_rounded,
                  accentColor: colorScheme.primary,
                  tooltip: state.showAllHabits
                      ? 'Show individual habits'
                      : 'Show overall trend',
                  onPressed: () => notifier.toggleShowAllHabits(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const LineChartBox(),
          if (state.showAllHabits) ...[
            const SizedBox(height: 16),
            const WarpHabitNames(),
          ],
        ],
      ),
    );
  }
}

/// Backward-compatible builder function delegating to [TrendChartCard].
Widget buildTrendChart() => const TrendChartCard();
