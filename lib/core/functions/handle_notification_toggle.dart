import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/notification_controller.dart';
import 'package:habit_tracker/core/functions/my_show_time_picker.dart';
import 'package:habit_tracker/generated/l10n.dart';

Future<void> handleNotificationToggle(
  NotificationController controller,
  bool value,
  BuildContext context,
) async {
  await controller.toggleNotification(value);
  if (value && context.mounted) {
    await myShowTimePicker(controller, context);
  } else {
    Get.snackbar(
      S.current.success,
      S.current.notificationsDisabled,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
