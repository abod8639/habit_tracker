import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/components/neumorphic_switch.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/setting/presentation/dialogs/notification_dialogs.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

class NotificationsSection extends ConsumerWidget {
  final AnimationController animationController;

  const NotificationsSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationNotifierProvider);
    final notificationNotifier =
        ref.watch(notificationNotifierProvider.notifier);
    final isEnabled = notificationState.isNotificationEnabled;
    final time = notificationState.notificationTime;
    final isBatteryIgnored =
        notificationState.isBatteryOptimizationIgnored;

    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;
    final primaryColor = theme.primaryColor;

    final subtitleText = s.setDailyReminder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSettingTile(
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
                  onTap: () => NotificationDialogs.showReminderTimePicker(
                    context,
                    ref,
                  ),
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
                onChanged: (value) => NotificationDialogs.handleToggle(
                  context,
                  ref,
                  value,
                ),
              ),
            ],
          ),
          onTap: () => NotificationDialogs.showReminderTimePicker(
            context,
            ref,
          ),
        ),
        if (isEnabled && !isBatteryIgnored) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  Colors.amber.withValues(alpha: isDark ? 0.12 : 0.08),
                  baseSurface,
                ),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: Colors.amber.withValues(
                    alpha: isDark ? 0.35 : 0.25,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.battery_alert_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.batteryOptimizationWarningTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.batteryOptimizationWarningSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        notificationNotifier.requestBatteryOptimization(),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      s.batteryOptimizationExemptAction,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
