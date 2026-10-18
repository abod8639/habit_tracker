import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';

class MockHabitRepository implements HabitRepository {
  DateTime? lastResetDate;
  final List<HabitEntity> habits;
  int dayCount = 1;
  int saveCompletionCalls = 0;
  bool habitsResetCalled = false;

  MockHabitRepository({
    required this.lastResetDate,
    required this.habits,
  });

  @override
  Future<Either<Failure, DateTime?>> getLastResetDate() async {
    return Right(lastResetDate);
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async {
    return Right(habits);
  }

  @override
  Future<Either<Failure, void>> saveHabitCompletionToHistory(
    String habitIdOrName,
    bool isCompleted,
    DateTime date, {
    String? habitName,
  }) async {
    saveCompletionCalls++;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resetHabitsCompletion() async {
    habitsResetCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> incrementDayCount([int amount = 1]) async {
    dayCount += amount;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveLastResetDate(DateTime date) async {
    lastResetDate = date;
    return const Right(null);
  }

  @override
  void invalidateHeatmapCache() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ResetDailyHabitsUseCase Performance Tests', () {
    test('Returning after 60 days does not execute excessive writes', () async {
      final now = DateTime.now();
      final sixtyDaysAgo = DateTime(now.year, now.month, now.day - 60);

      final habits = List.generate(
        15,
        (i) => HabitEntity(
          id: 'habit_$i',
          name: 'Habit $i',
          isCompleted: i.isEven,
          createdAt: sixtyDaysAgo,
        ),
      );

      final repo = MockHabitRepository(
        lastResetDate: sixtyDaysAgo,
        habits: habits,
      );

      final useCase = ResetDailyHabitsUseCase(repo);
      final result = await useCase();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => false), true);
      // Crucial test: It should ONLY save completion for lastDay (15 calls),
      // and NOT perform 60 * 15 = 900 sequential disk writes.
      expect(repo.saveCompletionCalls, 15);
      expect(repo.habitsResetCalled, true);
      expect(repo.dayCount, 61);
      expect(repo.lastResetDate?.day, now.day);
    });

    test('Same day does not trigger reset and returns Right(false)', () async {
      final now = DateTime.now();
      final repo = MockHabitRepository(
        lastResetDate: now,
        habits: [
          HabitEntity(
            id: 'h1',
            name: 'Habit 1',
            isCompleted: true,
            createdAt: now,
          ),
        ],
      );

      final useCase = ResetDailyHabitsUseCase(repo);
      final result = await useCase();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => true), false);
      expect(repo.habitsResetCalled, false);
      expect(repo.saveCompletionCalls, 0);
    });

    test('Initial launch (null lastResetDate) marks benchmark and returns Right(false)', () async {
      final now = DateTime.now();
      final repo = MockHabitRepository(
        lastResetDate: null,
        habits: [
          HabitEntity(
            id: 'h1',
            name: 'Habit 1',
            isCompleted: true,
            createdAt: now,
          ),
        ],
      );

      final useCase = ResetDailyHabitsUseCase(repo);
      final result = await useCase();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => true), false);
      expect(repo.habitsResetCalled, false);
      expect(repo.lastResetDate?.day, now.day);
    });
  });
}
