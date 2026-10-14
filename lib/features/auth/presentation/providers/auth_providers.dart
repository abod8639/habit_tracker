import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:habit_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:habit_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/get_skip_login_status_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/set_skip_login_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final settingsStorage = ref.watch(settingsStorageServiceProvider);
  return AuthLocalDataSourceImpl(settingsStorage);
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Use Cases
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return SignUpWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  return GetAuthStateUseCase(ref.watch(authRepositoryProvider));
});

final setSkipLoginUseCaseProvider = Provider<SetSkipLoginUseCase>((ref) {
  return SetSkipLoginUseCase(ref.watch(authRepositoryProvider));
});

final getSkipLoginStatusUseCaseProvider = Provider<GetSkipLoginStatusUseCase>((ref) {
  return GetSkipLoginStatusUseCase(ref.watch(authRepositoryProvider));
});
