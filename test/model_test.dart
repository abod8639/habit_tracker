import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

void main() {
  group('HabitModel Serialization', () {
    test('should serialize to map correctly', () {
      final habit = HabitModel(
        id: '1',
        name: 'Test Habit',
        isCompleted: true,
        createdAt: DateTime(2023, 1, 1),
      );

      final map = habit.toMap();

      expect(map['name'], 'Test Habit');
      expect(map['isCompleted'], true);
      expect(map['createdAt'], isNotNull);
      expect(map['id'], '1');
    });

    test('should deserialize from map correctly', () {
      final map = {
        'id': '123',
        'name': 'Test Habit',
        'isCompleted': true,
        'created_at': DateTime(2023, 1, 1).toIso8601String(),
      };

      final habit = HabitModel.fromMap(map);

      expect(habit.id, '123');
      expect(habit.name, 'Test Habit');
      expect(habit.isCompleted, true);
      expect(habit.createdAt, DateTime(2023, 1, 1));
    });

    test('should maintain ID across serialization', () {
      final habit = HabitModel(
        id: '456',
        name: 'Test Habit',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      final originalId = habit.id;

      final map = habit.toMap();
      final newHabit = HabitModel.fromMap(map);

      expect(newHabit.id, originalId);
    });
  });
}
