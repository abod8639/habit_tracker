// habit_utils.dart

bool shouldResetHabits(DateTime? lastResetDate) {
  if (lastResetDate == null) return true;
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime lastDay = DateTime(
    lastResetDate.year,
    lastResetDate.month,
    lastResetDate.day,
  );

  return today.isAfter(lastDay);
}
