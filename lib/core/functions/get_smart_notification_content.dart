import 'package:habit_tracker/generated/l10n.dart';

class SmartNotificationContent {
  final String title;
  final String body;

  const SmartNotificationContent({
    required this.title,
    required this.body,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartNotificationContent &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => title.hashCode ^ body.hashCode;

  @override
  String toString() => 'SmartNotificationContent(title: $title, body: $body)';
}

/// Generates localized smart notification content based on habit progress.
SmartNotificationContent getSmartNotificationContent({
  required int remainingCount,
  required int totalCount,
}) {
  final title = S.current.dailyReminderTitle;
  final String body;

  if (totalCount == 0) {
    body = S.current.dailyReminderNoTasks;
  } else if (remainingCount <= 0) {
    body = S.current.dailyReminderAllCompleted;
  } else {
    body = S.current.dailyReminderPendingTasks(remainingCount);
  }

  return SmartNotificationContent(
    title: title,
    body: body,
  );
}
