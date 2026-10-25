import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_pie_chart.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/habitstats_providers.dart';
import 'build_stat_item.dart';

/// Summary overview card displaying overall total, completed habits, and success rate.
class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(habitStatsNotifierProvider).value ?? const HabitStatsState();
    final stats = state.stats;
    if (stats == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color totalColor = colorScheme.primary;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StatItem(
                title: S.current.total,
                value: stats.totalHabits.toString(),
                icon: Icons.format_list_bulleted_rounded,
                color: totalColor,
              ),
              const CompletionPieChartCard.compact(),
              StatItem(
                title: S.current.streak,
                value: stats.streak.toString(),
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
