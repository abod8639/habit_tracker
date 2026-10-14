import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialogs and UI interactions for notification settings.
class NotificationDialogs {
  NotificationDialogs._();

  /// Displays the time picker dialog to set daily reminder time.
  static Future<void> showReminderTimePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;

    final notifier = ref.read(notificationNotifierProvider.notifier);
    final state = ref.read(notificationNotifierProvider);

    if (!state.isNotificationEnabled) {
      await notifier.toggleNotification(true);
    }

    if (!context.mounted) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: state.notificationTime ?? TimeOfDay.now(),
    );

    if (picked != null && context.mounted) {
      final formattedTime = picked.format(context);
      final s = S.of(context);
      await notifier.setNotificationTime(picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.success}: ${s.reminderSetFor(formattedTime)}'),
          ),
        );
      }
    }
  }

  /// Handles toggling notifications on or off.
  static Future<void> handleToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final notifier = ref.read(notificationNotifierProvider.notifier);
    await notifier.toggleNotification(value);
    if (value && context.mounted) {
      await showReminderTimePicker(context, ref);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.current.success}: ${S.current.notificationsDisabled}',
          ),
        ),
      );
    }
  }
}
