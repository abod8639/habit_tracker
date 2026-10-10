import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/utils/click_throttler.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/myalart_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

void addHabit(BuildContext context) {
  final c = Get.find<HabitController>();
  c.habitTextController.clear();
  showDialog(
    context: context,
    builder: (context) {
      return MyalartDialog(
        hintText: S.current.addNewHabit,
        controller: c.habitTextController,
        onSave: () async {
          final String habitName = c.habitTextController.text.trim();
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
            await c.addHabit(habitName);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }.throttle(),
      );
    },
  );
}
