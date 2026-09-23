import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/notification_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

Future<void> myShowTimePicker(
  NotificationController controller,
  BuildContext context,
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
