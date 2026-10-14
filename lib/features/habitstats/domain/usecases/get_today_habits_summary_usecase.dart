import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../repositories/habit_stats_repository.dart';

class GetTodayHabitsSummaryUseCase {
  final HabitStatsRepository repository;

  GetTodayHabitsSummaryUseCase(this.repository);

  Future<Either<Failure, List<HabitEntity>>> call() async {
    return await repository.getTodayHabitsSummary();
  }
}
