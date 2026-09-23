import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> signInWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, AuthEntity>> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  );
  Future<Either<Failure, AuthEntity?>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Stream<AuthEntity?> get authStateChanges;

  // Local Auth Settings
  Future<Either<Failure, void>> setSkipLogin(bool skipped);
  Future<Either<Failure, bool>> getSkipLoginStatus();
}
