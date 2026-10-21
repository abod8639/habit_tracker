import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<AuthEntity?> get authStateChanges =>
      remoteDataSource.authStateChanges.map(
        (user) => user != null
            ? AuthEntity(
                uid: user.uid,
                email: user.email,
                displayName: user.displayName,
                photoUrl: user.photoURL,
              )
            : null,
      );

  @override
  Future<Either<Failure, AuthEntity>> signInWithEmail(
    String email,
    String password,
  ) {
    return NetworkErrorHandler.guard(() {
      return remoteDataSource.signInWithEmail(email, password);
    });
  }

  @override
  Future<Either<Failure, AuthEntity>> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) {
    return NetworkErrorHandler.guard(() {
      return remoteDataSource.signUpWithEmail(email, password, displayName);
    });
  }

  @override
  Future<Either<Failure, AuthEntity?>> signInWithGoogle() {
    return NetworkErrorHandler.guard(() {
      return remoteDataSource.signInWithGoogle();
    });
  }

  @override
  Future<Either<Failure, void>> signOut() {
    return NetworkErrorHandler.guard(() {
      return remoteDataSource.signOut();
    });
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) {
    return NetworkErrorHandler.guard(() {
      return remoteDataSource.resetPassword(email);
    });
  }

  @override
  Future<Either<Failure, void>> setSkipLogin(bool skipped) {
    return NetworkErrorHandler.guard(() {
      return localDataSource.setSkipLogin(skipped);
    });
  }

  @override
  Future<Either<Failure, bool>> getSkipLoginStatus() {
    return NetworkErrorHandler.guard(() {
      return localDataSource.getSkipLoginStatus();
    });
  }
}
