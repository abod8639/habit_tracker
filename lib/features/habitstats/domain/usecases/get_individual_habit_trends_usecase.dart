import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/trend_point_entity.dart';
import '../repositories/habit_stats_repository.dart';

class GetIndividualHabitTrendsUseCase {
  final HabitStatsRepository repository;

  GetIndividualHabitTrendsUseCase(this.repository);

  Future<Either<Failure, Map<String, List<TrendPointEntity>>>> call(
    int days,
  ) async {
    return await repository.getIndividualHabitTrends(days);
  }
}
