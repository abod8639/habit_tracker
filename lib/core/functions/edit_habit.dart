import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/myalart_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

void editHabit(String id, String currentName, BuildContext context) {
  HabitController c = Get.find<HabitController>();

  c.habitTextController.text = currentName;

  showDialog(
    context: context,
    builder: (context) {
      return MyalartDialog(
        hintText: S.current.editThisHabit,
        controller: c.habitTextController,
        onSave: () async {
          final String habitName = c.habitTextController.text.trim();
          if (habitName.isNotEmpty) {
            await c.editHabit(id, habitName);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          } else {
            Get.snackbar(
              S.current.error,
              S.current.theFieldCantBeEmpty,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withValues(alpha: 0.7),
              colorText: Colors.white,
            );
          }
        },
      );
    },
  );
}
