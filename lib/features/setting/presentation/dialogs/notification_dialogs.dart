import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/notification_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialogs and UI interactions for notification settings.
class NotificationDialogs {
  NotificationDialogs._();

  /// Displays the time picker dialog to set daily reminder time.
  static Future<void> showReminderTimePicker(
    BuildContext context,
    NotificationController controller,
  ) async {
    if (!context.mounted) return;

    if (!controller.isNotificationEnabled.value) {
      await controller.toggleNotification(true);
    }

    if (!context.mounted) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.notificationTime.value ?? TimeOfDay.now(),
    );

    if (picked != null && context.mounted) {
      final formattedTime = picked.format(context);
      final s = S.of(context);
      await controller.setNotificationTime(picked);
      Get.snackbar(
        s.success,
        s.reminderSetFor(formattedTime),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Handles toggling notifications on or off.
  static Future<void> handleToggle(
    BuildContext context,
    NotificationController controller,
    bool value,
  ) async {
    await controller.toggleNotification(value);
    if (value && context.mounted) {
      await showReminderTimePicker(context, controller);
    } else {
      Get.snackbar(
        S.current.success,
        S.current.notificationsDisabled,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
