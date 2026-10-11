class HabitDateUtils {
  HabitDateUtils._();

  /// Determines if daily habits should be reset based on the [lastResetDate].
  /// Returns `true` if [lastResetDate] is null or before the start of today.
  static bool shouldResetHabits(DateTime? lastResetDate) {
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
}
