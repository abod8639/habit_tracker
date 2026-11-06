import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/setting/domain/repositories/setting_repository.dart';

class GetCustomModelUseCase {
  final SettingRepository repository;

  GetCustomModelUseCase(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.getCustomModel();
  }
}
