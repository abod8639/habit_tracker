import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_summary_card.dart';

class FadeAnimationSummaryCard extends StatelessWidget {
  final AnimationController _animationController;

  const FadeAnimationSummaryCard({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        ),
        child: const SummaryCard(),
      ),
    );
  }
}
