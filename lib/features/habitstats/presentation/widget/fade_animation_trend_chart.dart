import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_trend_chart.dart';

class FadeAnimationTrendChart extends StatelessWidget {
  final AnimationController _animationController;

  const FadeAnimationTrendChart({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  @override
  Widget build(BuildContext context) {
    return PageEntranceTransition(
      animationController: _animationController,
      index: 5,
      child: const TrendChartCard(),
    );
  }
}
