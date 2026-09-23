import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;
  SignInWithEmailUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(
    String email,
    String password,
  ) async {
    return await repository.signInWithEmail(email, password);
  }
}
