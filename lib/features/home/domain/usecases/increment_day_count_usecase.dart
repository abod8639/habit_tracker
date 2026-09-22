import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/habit_repository.dart';

class IncrementDayCountUseCase {
  final HabitRepository repository;

  IncrementDayCountUseCase(this.repository);

  Future<Either<Failure, void>> call([int amount = 1]) async {
    return await repository.incrementDayCount(amount);
  }
}
