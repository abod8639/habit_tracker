import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class SaveCustomApiKeyUseCase {
  final SettingRepository repository;

  SaveCustomApiKeyUseCase(this.repository);

  Future<Either<Failure, void>> call(String key) async {
    return await repository.saveCustomApiKey(key);
  }
}
