import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/setting/domain/repositories/setting_repository.dart';

class ClearCustomModelUseCase {
  final SettingRepository repository;

  ClearCustomModelUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.saveCustomModel(null);
  }
}
