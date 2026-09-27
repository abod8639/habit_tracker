import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_trend_chart.dart';

class FadeAnimationTrendChart extends StatelessWidget {
  final AnimationController _animationController;

  const FadeAnimationTrendChart({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 0.9),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
          ),
        ),
        child: const TrendChartCard(),
      ),
    );
  }
}
