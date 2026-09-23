import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/functions/habit_utils.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('HabitTracker Domain & Utility Tests', () {
    test('HabitEntity copyWith updates properties accurately', () {
      final habit = HabitEntity(
        id: 'habit_1',
        name: 'Morning Meditation',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = habit.copyWith(
        name: 'Evening Meditation',
        isCompleted: true,
      );

      expect(updated.id, 'habit_1');
      expect(updated.name, 'Evening Meditation');
      expect(updated.isCompleted, true);
      expect(updated.createdAt, DateTime(2026, 1, 1));
    });

    test('HabitModel toEntity and fromEntity maintain all properties', () {
      final model = HabitModel(
        id: 'h_100',
        name: 'Drink 2L Water',
        isCompleted: true,
        createdAt: DateTime(2026, 5, 10),
        completedAt: DateTime(2026, 5, 10, 14, 30),
        colorValue: 0xFF4CAF50,
        index: 2,
      );

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.isCompleted, model.isCompleted);
      expect(entity.colorValue, model.colorValue);
      expect(entity.index, model.index);

      final reconstructedModel = HabitModel.fromEntity(entity);
      expect(reconstructedModel.id, model.id);
      expect(reconstructedModel.name, model.name);
      expect(reconstructedModel.isCompleted, model.isCompleted);
    });

    test('shouldResetHabits detects new day correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      // Null last reset date should trigger reset
      expect(shouldResetHabits(null), true);

      // Past day should trigger reset
      expect(shouldResetHabits(yesterday), true);

      // Same day should not trigger reset
      expect(shouldResetHabits(today), false);
    });

    test(
      'GeminiService throws ApiKeyMissingException when API key is not configured',
      () {
        dotenv.clean();
        final service = GeminiService();
        expect(
          () => service.startChat(),
          throwsA(isA<ApiKeyMissingException>()),
        );
      },
    );

    test(
      'GeminiService initializes ChatSession when API key is provided via dotenv',
      () {
        dotenv.loadFromString(
          envString: 'GEMINI_API_KEY=AIzaSyC7a6RZ9mr10Do1G_Zk_R7HjVc_RVRLNhM',
        );
        addTearDown(dotenv.clean);
        final service = GeminiService();
        final session = service.startChat();
        expect(session, isNotNull);
      },
    );
  });
}
