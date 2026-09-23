import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

class SyncHabitsUseCase {
  final SettingRepository repository;

  SyncHabitsUseCase(this.repository);

  Future<Either<Failure, List<HabitModel>>> call(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  }) async {
    return await repository.syncHabits(
      localHabits,
      localTombstones: localTombstones,
      localStartDay: localStartDay,
    );
  }
}
