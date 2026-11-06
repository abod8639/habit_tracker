import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/setting/domain/repositories/setting_repository.dart';

class SaveCustomModelUseCase {
  final SettingRepository repository;

  SaveCustomModelUseCase(this.repository);

  Future<Either<Failure, void>> call(String? model) {
    return repository.saveCustomModel(model);
  }
}
