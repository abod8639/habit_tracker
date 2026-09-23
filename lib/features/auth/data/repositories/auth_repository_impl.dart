import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/generated/l10n.dart';
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
  ) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);
      return Right(userModel);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmail(
        email,
        password,
        displayName,
      );
      return Right(userModel);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Right(userModel);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> setSkipLogin(bool skipped) async {
    try {
      await localDataSource.setSkipLogin(skipped);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> getSkipLoginStatus() async {
    try {
      final status = await localDataSource.getSkipLoginStatus();
      return Right(status);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Failure _mapExceptionToFailure(Object e) {
    if (e is AuthException) {
      return ServerFailure(_handleAuthErrorCode(e.message));
    } else if (e is ServerException) {
      return ServerFailure(e.message);
    }
    return ServerFailure(S.current.authErrorDefault);
  }

  String _handleAuthErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return S.current.authErrorUserNotFound;
      case 'wrong-password':
        return S.current.authErrorWrongPassword;
      case 'email-already-in-use':
        return S.current.authErrorEmailInUse;
      case 'invalid-email':
        return S.current.authErrorInvalidEmail;
      case 'weak-password':
        return S.current.authErrorWeakPassword;
      case 'too-many-requests':
        return S.current.authErrorTooManyRequests;
      case 'network-request-failed':
        return S.current.authErrorNetworkFailed;
      default:
        return S.current.authErrorDefault;
    }
  }
}
