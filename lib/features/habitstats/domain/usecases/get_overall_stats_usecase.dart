import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../repositories/habit_stats_repository.dart';

class GetOverallStatsUseCase {
  final HabitStatsRepository repository;

  GetOverallStatsUseCase(this.repository);

  Future<Either<Failure, HabitStatsEntity>> call() async {
    return await repository.getOverallStats();
  }
}
