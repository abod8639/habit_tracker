import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class DeleteMultipleHabitsUseCase {
  final HabitRepository repository;

  DeleteMultipleHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> ids) {
    return repository.deleteMultipleHabits(ids);
  }
}
