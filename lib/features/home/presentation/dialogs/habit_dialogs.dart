import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/utils/click_throttler.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/myalart_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialog handlers for adding and editing habits.
class HabitDialogs {
  HabitDialogs._();

  /// Shows the dialog to create a new habit.
  static void showAdd(BuildContext context, {WidgetRef? ref}) {
    final textController = TextEditingController();

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MyalartDialog(
          title: isAr ? 'إضافة عادة' : 'Add Habit',
          hintText: S.current.addNewHabit,
          actionButtonText: isAr ? 'إضافة' : 'Add',
          isEditing: false,
          controller: textController,
          onSave: () async {
            final String habitName = textController.text.trim();
            if (habitName.isEmpty) {
              _showSnackBar(context, S.current.theFieldCantBeEmpty);
            } else if (habitName.characters.length > 100) {
              final isAr = Localizations.localeOf(context).languageCode == 'ar';
              _showSnackBar(
                context,
                isAr
                    ? 'لا يمكن أن يتجاوز اسم العادة 100 حرف'
                    : 'Habit name cannot exceed 100 characters',
              );
            } else {
              try {
                if (ref != null) {
                  await ref
                      .read(habitNotifierProvider.notifier)
                      .addHabit(habitName);
                } else {
                  final targetContext = dialogContext.mounted
                      ? dialogContext
                      : context;
                  if (targetContext.mounted) {
                    final container = ProviderScope.containerOf(targetContext);
                    await container
                        .read(habitNotifierProvider.notifier)
                        .addHabit(habitName);
                  }
                }
              } catch (e, st) {
                debugPrint('Failed to add habit: $e\n$st');
              }

              if (dialogContext.mounted &&
                  Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                Navigator.of(dialogContext, rootNavigator: true).pop();
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
    WidgetRef? ref,
  }) {
    final textController = TextEditingController(text: currentName);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MyalartDialog(
          title: S.current.editThisHabit,
          hintText: S.current.editThisHabit,
          actionButtonText: isAr ? 'تعديل' : 'Edit',
          isEditing: true,
          controller: textController,
          onSave: () async {
            final String habitName = textController.text.trim();
            if (habitName.isEmpty) {
              _showSnackBar(context, S.current.theFieldCantBeEmpty);
            } else if (habitName.characters.length > 100) {
              final isAr = Localizations.localeOf(context).languageCode == 'ar';
              _showSnackBar(
                context,
                isAr
                    ? 'لا يمكن أن يتجاوز اسم العادة 100 حرف'
                    : 'Habit name cannot exceed 100 characters',
              );
            } else {
              try {
                if (ref != null) {
                  await ref
                      .read(habitNotifierProvider.notifier)
                      .editHabit(id, habitName);
                } else {
                  final targetContext = dialogContext.mounted
                      ? dialogContext
                      : context;
                  if (targetContext.mounted) {
                    final container = ProviderScope.containerOf(targetContext);
                    await container
                        .read(habitNotifierProvider.notifier)
                        .editHabit(id, habitName);
                  }
                }
              } catch (e, st) {
                debugPrint('Failed to edit habit: $e\n$st');
              }

              if (dialogContext.mounted &&
                  Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              }
            }
          }.throttle(),
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    scaffoldMessenger?.hideCurrentSnackBar();
    scaffoldMessenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
