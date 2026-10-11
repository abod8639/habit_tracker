import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/utils/click_throttler.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/myalart_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialog handlers for adding and editing habits.
class HabitDialogs {
  HabitDialogs._();

  /// Shows the dialog to create a new habit.
  static void showAdd(BuildContext context) {
    final controller = Get.find<HabitController>();
    controller.habitTextController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return MyalartDialog(
          hintText: S.current.addNewHabit,
          controller: controller.habitTextController,
          onSave: () async {
            final String habitName = controller.habitTextController.text.trim();
            if (habitName.isEmpty) {
              Get.snackbar(
                S.current.error,
                S.current.theFieldCantBeEmpty,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.7),
                colorText: Colors.white,
              );
            } else if (habitName.length > 100) {
              Get.snackbar(
                S.current.error,
                Get.locale?.languageCode == 'ar'
                    ? 'لا يمكن أن يتجاوز اسم العادة 100 حرف'
                    : 'Habit name cannot exceed 100 characters',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.7),
                colorText: Colors.white,
              );
            } else {
              await controller.addHabit(habitName);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          }.throttle(),
        );
      },
    );
  }

  /// Shows the dialog to edit an existing habit by [id].
  static void showEdit(
    BuildContext context, {
    required String id,
    required String currentName,
  }) {
    final controller = Get.find<HabitController>();
    controller.habitTextController.text = currentName;

    showDialog(
      context: context,
      builder: (context) {
        return MyalartDialog(
          hintText: S.current.editThisHabit,
          controller: controller.habitTextController,
          onSave: () async {
            final String habitName = controller.habitTextController.text.trim();
            if (habitName.isNotEmpty) {
              await controller.editHabit(id, habitName);
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
}
