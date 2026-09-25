import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_bar_chart.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_pie_chart.dart';

Widget buildChartsSection(BuildContext context) {
  final isDesktop = ResponsiveUtils.isDesktop(context);

  if (isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildBarChart()),
        const SizedBox(width: 16),
        Expanded(child: buildPieChart()),
      ],
    );
  }

  return Column(
    children: [
      buildBarChart(),
      const SizedBox(height: 16),
      buildPieChart(),
    ],
  );
}
