import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';
import '../utils/habit_date_utils.dart';

class ResetDailyHabitsUseCase {
  final HabitRepository repository;

  ResetDailyHabitsUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    final dateResult = await repository.getLastResetDate();

    return dateResult.fold(
      (failure) async => Left(failure),
      (lastResetDate) async {
        if (HabitDateUtils.shouldResetHabits(lastResetDate)) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // If this is the initial launch, just mark today as the reset benchmark
          if (lastResetDate == null) {
            final saveResult = await repository.saveLastResetDate(now);
            return saveResult.fold(
              (failure) => Left(failure),
              (_) => const Right(false),
            );
          }

          // 1. Get current habits to save to history
          final habitsResult = await repository.getHabits();

          return await habitsResult.fold(
            (failure) async => Left(failure),
            (habits) async {
              final lastDay = DateTime(
                lastResetDate.year,
                lastResetDate.month,
                lastResetDate.day,
              );

              final daysDiff = today.difference(lastDay).inDays;

              if (habits.isNotEmpty) {
                // 2. Save last active day's habit completion status
                await Future.wait(
                  habits.map(
                    (habit) => repository.saveHabitCompletionToHistory(
                      habit.id,
                      habit.isCompleted,
                      lastDay,
                      habitName: habit.name,
                    ),
                  ),
                );
              }

              // 4. Reset completion status for today
              final resetResult = await repository.resetHabitsCompletion();
              if (resetResult.isLeft()) {
                return Left(
                  resetResult.fold(
                    (failure) => failure,
                    (_) => throw StateError('Unreachable'),
                  ),
                );
              }

              // 5. Increment day count by actual days elapsed
              final incrementResult = await repository.incrementDayCount(
                daysDiff > 0 ? daysDiff : 1,
              );
              if (incrementResult.isLeft()) {
                return Left(
                  incrementResult.fold(
                    (failure) => failure,
                    (_) => throw StateError('Unreachable'),
                  ),
                );
              }

              // 6. Update last reset date
              final saveDateResult = await repository.saveLastResetDate(now);
              return saveDateResult.fold(
                (failure) => Left(failure),
                (_) => const Right(true),
              );
            },
          );
        }
        return const Right(false);
      },
    );
  }
}
