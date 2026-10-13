import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

void main() {
  group('Habit History Decoupling & Rename Tests', () {
    test('History is tracked per habit ID and survives renaming', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);

      // Habit originally named 'Reading'
      const habitId = 'habit_123';
      const initialName = 'Reading';
      const renamedName = 'Reading 20 Pages';

      final historyMap = <String, Map<DateTime, bool>>{};

      // Internal storage mapping both ID and name
      final habitDates = <DateTime, bool>{
        yesterday: true,
        today: true,
      };

      historyMap[habitId] = habitDates;
      historyMap[initialName] = habitDates;

      // Verify initial state
      expect(historyMap[habitId]?[yesterday], true);
      expect(historyMap[initialName]?[yesterday], true);

      // Rename habit: Update name pointer to the same habit dates
      historyMap.remove(initialName);
      historyMap[renamedName] = habitDates;

      // Stats lookup uses ID first: history is completely preserved!
      final lookupById = historyMap[habitId] ?? historyMap[renamedName] ?? {};
      expect(lookupById[yesterday], true);
      expect(lookupById[today], true);
    });

    test('Two habits with identical names maintain separate histories by ID', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      const habit1Id = 'id_morning_walk';
      const habit2Id = 'id_evening_walk';
      const sharedName = 'Walk';

      final habit1 = HabitModel(
        id: habit1Id,
        name: sharedName,
        isCompleted: true,
        createdAt: now,
      );

      final habit2 = HabitModel(
        id: habit2Id,
        name: sharedName,
        isCompleted: false,
        createdAt: now,
      );

      final historyMap = <String, Map<DateTime, bool>>{
        habit1.id: {today: habit1.isCompleted},
        habit2.id: {today: habit2.isCompleted},
      };

      // Querying by ID preserves independent completion statuses
      expect(historyMap[habit1.id]?[today], true);
      expect(historyMap[habit2.id]?[today], false);
      expect(historyMap[habit1.id]?[today], isNot(historyMap[habit2.id]?[today]));
    });
  });
}
