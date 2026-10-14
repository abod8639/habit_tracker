import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/trend_point_entity.dart';
import '../repositories/habit_stats_repository.dart';

class GetOverallTrendUseCase {
  final HabitStatsRepository repository;

  GetOverallTrendUseCase(this.repository);

  Future<Either<Failure, List<TrendPointEntity>>> call(int days) async {
    return await repository.getOverallTrendData(days);
  }
}
