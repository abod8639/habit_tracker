import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_empty_state.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Clean Architecture Component: Reusable empty state for habit list,
/// reusing [NeumorphicEmptyState] from core components.
class NoHabitsYet extends StatelessWidget {
  const NoHabitsYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeumorphicEmptyState(
        icon: Icons.sentiment_satisfied_alt_rounded,
        message: '${S.current.noHabitsYet}\n${S.current.addFirstHabitSubtitle}',
        height: 240,
      ),
    );
  }
}

