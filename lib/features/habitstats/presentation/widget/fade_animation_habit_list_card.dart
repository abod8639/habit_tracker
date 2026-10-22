import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/build_habit_list_card.dart';

class FadeAnimationHabitListCard extends StatelessWidget {
  final AnimationController _animationController;

  const FadeAnimationHabitListCard({
    super.key,
    required AnimationController animationController,
  }) : _animationController = animationController;

  @override
  Widget build(BuildContext context) {
    return PageEntranceTransition(
      animationController: _animationController,
      index: 3,
      child: const HabitListCard(),
    );
  }
}
