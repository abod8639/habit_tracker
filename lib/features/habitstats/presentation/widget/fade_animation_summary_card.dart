import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_summary_card.dart';

class FadeAnimationSummaryCard extends StatelessWidget {
  final AnimationController _animationController;

  const FadeAnimationSummaryCard({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  @override
  Widget build(BuildContext context) {
    return PageEntranceTransition(
      animationController: _animationController,
      index: 0,
      child: const SummaryCard(),
    );
  }
}
