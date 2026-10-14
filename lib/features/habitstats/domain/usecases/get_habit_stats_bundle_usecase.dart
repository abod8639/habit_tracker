import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/habit_stats_bundle_entity.dart';
import '../repositories/habit_stats_repository.dart';

class GetHabitStatsBundleUseCase {
  final HabitStatsRepository repository;

  GetHabitStatsBundleUseCase(this.repository);

  Future<Either<Failure, HabitStatsBundleEntity>> call(int days) async {
    return await repository.getCompleteStatsBundle(days);
  }
}
