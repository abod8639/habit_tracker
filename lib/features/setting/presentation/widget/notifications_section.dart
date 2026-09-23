import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/notification_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/handle_notification_toggle.dart';
import 'package:habit_tracker/core/functions/my_show_time_picker.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildNotificationsSection(AnimationController animationController) {
  final notificationController = Get.find<NotificationController>();
  return Builder(
    builder: (context) {
      return AnimatedSettingTile(
        animationController: animationController,
        index: 8,
        icon: Icons.notifications_rounded,
        title: S.of(context).dailyReminder,
        subtitle: S.of(context).setDailyReminder,
        trailing: Obx(
          () => Switch(
            value: notificationController.isNotificationEnabled.value,
            onChanged: (value) => handleNotificationToggle(
              notificationController,
              value,
              context,
            ),
          ),
        ),
        onTap: () => myShowTimePicker(notificationController, context),
      );
    },
  );
}
