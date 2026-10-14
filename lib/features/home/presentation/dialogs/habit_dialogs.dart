import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/utils/click_throttler.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/myalart_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialog handlers for adding and editing habits.
class HabitDialogs {
  HabitDialogs._();

  /// Shows the dialog to create a new habit.
  static void showAdd(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MyalartDialog(
          hintText: S.current.addNewHabit,
          controller: textController,
          onSave: () async {
            final String habitName = textController.text.trim();
            if (habitName.isEmpty) {
              _showSnackBar(context, S.current.theFieldCantBeEmpty);
            } else if (habitName.length > 100) {
              final isAr = Localizations.localeOf(context).languageCode == 'ar';
              _showSnackBar(
                context,
                isAr
                    ? 'لا يمكن أن يتجاوز اسم العادة 100 حرف'
                    : 'Habit name cannot exceed 100 characters',
              );
            } else {
              try {
                final container = ProviderScope.containerOf(context);
                await container.read(habitNotifierProvider.notifier).addHabit(habitName);
              } catch (_) {}

              if (Get.isRegistered<HabitController>()) {
                await Get.find<HabitController>().addHabit(habitName);
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
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
    final textController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MyalartDialog(
          hintText: S.current.editThisHabit,
          controller: textController,
          onSave: () async {
            final String habitName = textController.text.trim();
            if (habitName.isNotEmpty) {
              try {
                final container = ProviderScope.containerOf(context);
                await container.read(habitNotifierProvider.notifier).editHabit(id, habitName);
              } catch (_) {}

              if (Get.isRegistered<HabitController>()) {
                await Get.find<HabitController>().editHabit(id, habitName);
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            } else {
              _showSnackBar(context, S.current.theFieldCantBeEmpty);
            }
          },
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
