import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_bar_chart.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_pie_chart.dart';

/// Charts section containing the daily completion bar chart and overall pie chart.
/// Responsive: displays side-by-side on desktop/tablet, stacked vertically on phone.
class ChartsSection extends StatelessWidget {
  const ChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    if (isDesktop) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: TodayBarChartCard()),
          SizedBox(width: 16),
          Expanded(child: CompletionPieChartCard()),
        ],
      );
    }

    return const Column(
      children: [
        TodayBarChartCard(),
        // SizedBox(height: 16),
        // CompletionPieChartCard(),
      ],
    );
  }
}

/// Backward-compatible builder function delegating to [ChartsSection].
Widget buildChartsSection(BuildContext context) => const ChartsSection();
