import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartBarData myLineChartBarData({
  required List<FlSpot> spots,
  required Color color,
  String? label,
}) {
  return LineChartBarData(
    show: true,
    curveSmoothness: 0.32,
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 3.2,
    isStrokeCapRound: true,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}
