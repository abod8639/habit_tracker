import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_charts_section.dart';

class FadeAnimationChartsSection extends StatelessWidget {
  final AnimationController _animationController;

  const FadeAnimationChartsSection({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  @override
  Widget build(BuildContext context) {
    return PageEntranceTransition(
      animationController: _animationController,
      index: 4,
      child: const ChartsSection(),
    );
  }
}
