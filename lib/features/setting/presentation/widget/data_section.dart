import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/clear_all_habit_data.dart';
import 'package:habit_tracker/generated/l10n.dart';

class DataSection extends StatelessWidget {
  final AnimationController animationController;

  const DataSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        AnimatedSettingTile(
          animationController: animationController,
          index: 10,
          icon: Icons.delete_sweep_rounded,
          title: s.clearAllData,
          subtitle: s.deleteAllHabitsAndSettings,
          textColor: Colors.red,
          onTap: () => clearAppDataAndRestart(context),
        ),
      ],
    );
  }
}

Widget buildDataSection(AnimationController animationController) {
  return DataSection(animationController: animationController);
}
