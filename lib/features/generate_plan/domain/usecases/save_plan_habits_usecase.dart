import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/plan_repository.dart';

class SavePlanHabitsUseCase {
  final PlanRepository repository;

  SavePlanHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> habitNames) {
    return repository.savePlanHabits(habitNames);
  }
}
