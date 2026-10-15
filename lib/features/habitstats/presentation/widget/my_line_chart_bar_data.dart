import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartBarData myLineChartBarData({
  required List<FlSpot> spots,
  required Color? color,
  required Color color1,
  required Color color2,
  String? label,
}) {
  return LineChartBarData(
    show: true,
    curveSmoothness: 0.32,
    spots: spots,
    isCurved: true,
    barWidth: 3.2,
    color: color,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: true,
      getDotPainter: (spot, percent, barData, index) {
        return FlDotCirclePainter(
          radius: 3.5,
          color: color ?? Colors.blue,
          strokeWidth: 1.5,
          strokeColor: Colors.white,
        );
      },
    ),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        colors: [
          color1,
          color2,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}
