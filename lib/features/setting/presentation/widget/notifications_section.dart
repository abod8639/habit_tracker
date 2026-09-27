import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/handle_notification_toggle.dart';
import 'package:habit_tracker/core/functions/my_show_time_picker.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/notification_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class NotificationsSection extends StatelessWidget {
  final AnimationController animationController;

  const NotificationsSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    final s = S.of(context);

    return AnimatedSettingTile(
      animationController: animationController,
      index: 8,
      icon: Icons.notifications_rounded,
      title: s.dailyReminder,
      subtitle: s.setDailyReminder,
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
  }
}

Widget buildNotificationsSection(AnimationController animationController) {
  return NotificationsSection(animationController: animationController);
}
