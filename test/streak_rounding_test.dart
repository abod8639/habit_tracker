import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Streak Rounding Bug Prevention Tests', () {
    test('1 completed habit out of 21 produces positive strength and preserves streak', () {
      const int totalHabits = 21;
      const int completedCount = 1;

      final completionRate = completedCount / totalHabits;
      // Legacy buggy behavior:
      expect(completionRate.toStringAsFixed(1), '0.0');

      // Fixed behavior:
      final rateStr = completionRate.toString();
      expect(rateStr, isNot('0.0'));

      final parsed = double.tryParse(rateStr) ?? 0.0;
      expect(parsed, greaterThan(0.0));

      int strength = (parsed * 10).toInt();
      if (strength == 0 && parsed > 0) {
        strength = 1;
      }

      expect(strength, 1);
    });

    test('Consecutive days with minimal completion keep streak alive', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final dayBeforeYesterday = DateTime(today.year, today.month, today.day - 2);

      // 1 habit out of 25 completed each day:
      final double rateYesterday = 1 / 25;
      final double rateDayBefore = 1 / 30;

      int calcStrength(double rate) {
        int s = (rate * 10).toInt();
        if (s == 0 && rate > 0) s = 1;
        return s;
      }

      final heatmap = <DateTime, int>{
        yesterday: calcStrength(rateYesterday),
        dayBeforeYesterday: calcStrength(rateDayBefore),
      };

      expect(heatmap[yesterday], 1);
      expect(heatmap[dayBeforeYesterday], 1);

      // Simulate streak calculation starting from today with 1 habit completed
      int streak = 0;
      const bool isTodayCompleted = true;
      if (isTodayCompleted) {
        streak++;
      }

      int daysBack = 1;
      while (true) {
        final checkDay = DateTime(today.year, today.month, today.day - daysBack);
        final strength = heatmap[checkDay] ?? 0;
        if (strength > 0) {
          streak++;
          daysBack++;
        } else {
          break;
        }
      }

      // Streak should be 3 (today, yesterday, day before yesterday)
      expect(streak, 3);
    });
  });
}
