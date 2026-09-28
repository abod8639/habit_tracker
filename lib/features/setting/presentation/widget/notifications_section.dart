import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/components/neumorphic_switch.dart';
import 'package:habit_tracker/core/functions/handle_notification_toggle.dart';
import 'package:habit_tracker/core/functions/my_show_time_picker.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/notification_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class NotificationsSection extends StatelessWidget {
  final AnimationController animationController;

  const NotificationsSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;
    final primaryColor = theme.primaryColor;

    return Obx(() {
      final isEnabled = notificationController.isNotificationEnabled.value;
      final time = notificationController.notificationTime.value;

      final subtitleText = s.setDailyReminder;

      return AnimatedSettingTile(
        animationController: animationController,
        index: 8,
        icon: isEnabled
            ? Icons.notifications_active_rounded
            : Icons.notifications_rounded,
        title: s.dailyReminder,
        subtitle: subtitleText,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEnabled && time != null) ...[
              GestureDetector(
                onTap: () => myShowTimePicker(notificationController, context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      primaryColor.withValues(alpha: isDark ? 0.14 : 0.08),
                      baseSurface,
                    ),
                    borderRadius: AppRadius.badgeRadius,
                    border: Border.all(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.25 : 0.18,
                      ),
                      width: 0.9,
                    ),
                    boxShadow: AppShadows.badge(isDark: isDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm_rounded,
                        size: 13,
                        color: primaryColor,
                        shadows: AppShadows.buttonPressed(isDark: isDark),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time.format(context),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            NeumorphicSwitch(
              value: isEnabled,
              onChanged: (value) => handleNotificationToggle(
                notificationController,
                value,
                context,
              ),
            ),
          ],
        ),
        onTap: () => myShowTimePicker(notificationController, context),
      );
    });
  }
}
