import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/features/setting/presentation/dialogs/clear_data_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

class DataSection extends ConsumerWidget {
  final AnimationController animationController;

  const DataSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () => ClearDataDialog.show(context, ref),
        ),
      ],
    );
  }
}

Widget buildDataSection(AnimationController animationController) {
  return DataSection(animationController: animationController);
}
