import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/monthly_summary.dart';

class SliverMonthlySummary extends ConsumerWidget {
  const SliverMonthlySummary({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasets = ref.watch(
      habitNotifierProvider.select((s) => s.heatmapDateSet),
    );
    final habitNotifier = ref.watch(habitNotifierProvider.notifier);
    final startDay = habitNotifier.getStartDay();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: MonthlySummary(
          key: ValueKey(startDay),
          datasets: Map<DateTime, int>.from(datasets),
        ),
      ),
    );
  }
}
