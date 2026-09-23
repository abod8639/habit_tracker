import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository repository;
  SignUpWithEmailUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(
    String email,
    String password,
    String? displayName,
  ) async {
    return await repository.signUpWithEmail(email, password, displayName);
  }
}
