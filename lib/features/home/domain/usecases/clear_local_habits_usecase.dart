import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class ClearLocalHabitsUseCase {
  final HabitRepository repository;

  ClearLocalHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call({String? earliestDateStr}) async {
    return await repository.clearLocalData(earliestDateStr: earliestDateStr);
  }
}
