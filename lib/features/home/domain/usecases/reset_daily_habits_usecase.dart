import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/functions/habit_utils.dart';
import '../repositories/habit_repository.dart';

class ResetDailyHabitsUseCase {
  final HabitRepository repository;

  ResetDailyHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    final dateResult = await repository.getLastResetDate();
    
    return dateResult.fold(
      (failure) => Left(failure),
      (lastResetDate) async {
        if (shouldResetHabits(lastResetDate)) {
          // 1. Get current habits to save to history
          final habitsResult = await repository.getHabits();
          
          return await habitsResult.fold(
            (failure) => Left(failure),
            (habits) async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final lastDay = lastResetDate != null
                  ? DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day)
                  : today.subtract(const Duration(days: 1));

              final daysDiff = today.difference(lastDay).inDays;

              // 2. Save last active day's habit completion status
              for (var habit in habits) {
                await repository.saveHabitCompletionToHistory(
                  habit.id,
                  habit.isCompleted,
                  lastDay,
                  habitName: habit.name,
                );
              }

              // 2.1 If intermediate days were missed, record them as false
              for (int d = 1; d < daysDiff; d++) {
                final missedDate = lastDay.add(Duration(days: d));
                for (var habit in habits) {
                  await repository.saveHabitCompletionToHistory(
                    habit.id,
                    false,
                    missedDate,
                    habitName: habit.name,
                  );
                }
              }

              // 3. Reset completion status
              final resetResult = await repository.resetHabitsCompletion();
              if (resetResult.isLeft()) return resetResult;

              // 4. Increment day count by actual days elapsed
              final incrementResult = await repository.incrementDayCount(daysDiff > 0 ? daysDiff : 1);
              if (incrementResult.isLeft()) return incrementResult;

              // 5. Update last reset date
              return await repository.saveLastResetDate(DateTime.now());
            },
          );
        }
        return const Right(null);
      },
    );
  }
}
