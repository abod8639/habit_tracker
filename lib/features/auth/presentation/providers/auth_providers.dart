import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:habit_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:habit_tracker/features/auth/domain/entities/auth_entity.dart';
import 'package:habit_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/get_skip_login_status_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/set_skip_login_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habitstats/presentation/providers/habitstats_providers.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/features/theme/presentation/providers/theme_providers.dart';

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

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  ref,
) {
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

final getSkipLoginStatusUseCaseProvider = Provider<GetSkipLoginStatusUseCase>((
  ref,
) {
  return GetSkipLoginStatusUseCase(ref.watch(authRepositoryProvider));
});

// Immutable State
class AuthState {
  final AuthEntity? currentUser;
  final bool hasSkippedLogin;
  final Failure? failure;
  final bool isActionLoading;

  const AuthState({
    this.currentUser,
    this.hasSkippedLogin = false,
    this.failure,
    this.isActionLoading = false,
  });

  bool get isLoggedIn => currentUser != null;
  AuthEntity? get user => currentUser;
  bool get isLoading => isActionLoading;
  String? get errorMessage => failure?.toMessage();

  AuthState copyWith({
    AuthEntity? currentUser,
    bool? hasSkippedLogin,
    Failure? failure,
    bool clearFailure = false,
    bool? isActionLoading,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      hasSkippedLogin: hasSkippedLogin ?? this.hasSkippedLogin,
      failure: clearFailure ? null : (failure ?? this.failure),
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}

/// Convenience extensions for consuming [AsyncValue<AuthState>] without boilerplate
extension AsyncValueAuthStateX on AsyncValue<AuthState> {
  AuthEntity? get user => value?.currentUser;
  bool get isLoggedIn => value?.isLoggedIn ?? false;
  bool get hasSkippedLogin => value?.hasSkippedLogin ?? false;
  bool get isInitialized => hasValue;
  bool get isLoadingAction => isLoading || (value?.isActionLoading ?? false);
}

// Clean Architecture AsyncNotifier managing Authentication
class AuthNotifier extends AsyncNotifier<AuthState> {
  StreamSubscription<AuthEntity?>? _authSubscription;
  bool _isDisposed = false;

  @override
  FutureOr<AuthState> build() async {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _authSubscription?.cancel();
    });

    final getAuthState = ref.watch(getAuthStateUseCaseProvider);
    final getSkipStatus = ref.watch(getSkipLoginStatusUseCaseProvider);

    _authSubscription?.cancel();
    _authSubscription = getAuthState().listen((user) {
      if (_isDisposed) return;
      final current = state.value ?? const AuthState();
      if (current.isActionLoading) {
        return;
      }
      final previousUser = current.currentUser;
      state = AsyncValue.data(
        current.copyWith(
          currentUser: user,
          clearUser: user == null,
        ),
      );
      if (user != null && previousUser?.uid != user.uid) {
        unawaited(_syncUserDataAfterAuth());
      }
    });

    final skipResult = await getSkipStatus();
    final bool hasSkipped = skipResult.fold(
      (failure) {
        debugPrint('[AuthNotifier] Failed to load skip login status: ${failure.toMessage()}');
        return false;
      },
      (status) => status,
    );

    return AuthState(hasSkippedLogin: hasSkipped);
  }

  Future<void> _syncUserDataAfterAuth() async {
    if (_isDisposed) return;
    final fcm = ref.read(fcmServiceProvider);
    fcm?.syncTokenToFirestore();

    try {
      if (_isDisposed) return;
      final syncNotifier = ref.read(syncNotifierProvider.notifier);
      final themeNotifier = ref.read(themeNotifierProvider.notifier);
      await Future.wait([
        syncNotifier.syncHabits(),
        themeNotifier.syncWithCloud(),
      ]);
    } catch (e) {
      debugPrint('[AuthNotifier] Auto sync after authentication failed: $e');
    } finally {
      if (!_isDisposed) {
        try {
          await ref.read(habitStatsNotifierProvider.notifier).refreshStats();
        } catch (e) {
          debugPrint('[AuthNotifier] Failed to refresh habit stats after authentication: $e');
        }
      }
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final current = state.value ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isActionLoading: true, clearFailure: true),
    );

    final useCase = ref.read(signInWithEmailUseCaseProvider);
    final result = await useCase(email, password);

    return await result.fold(
      (failure) async {
        if (_isDisposed) return false;
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            failure: failure,
          ),
        );
        return false;
      },
      (user) async {
        if (_isDisposed) return false;
        await _syncUserDataAfterAuth();
        if (_isDisposed) return true;
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            currentUser: user,
            clearFailure: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = state.value ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isActionLoading: true, clearFailure: true),
    );

    final useCase = ref.read(signUpWithEmailUseCaseProvider);
    final result = await useCase(email, password, displayName);

    return await result.fold(
      (failure) async {
        if (_isDisposed) return false;
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            failure: failure,
          ),
        );
        return false;
      },
      (user) async {
        if (_isDisposed) return false;
        await _syncUserDataAfterAuth();
        if (_isDisposed) return true;
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            currentUser: user,
            clearFailure: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    final current = state.value ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isActionLoading: true, clearFailure: true),
    );

    final useCase = ref.read(signInWithGoogleUseCaseProvider);
    final result = await useCase();

    return await result.fold(
      (failure) async {
        if (_isDisposed) return false;
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            failure: failure,
          ),
        );
        return false;
      },
      (user) async {
        if (_isDisposed) return false;
        if (user != null) {
          await _syncUserDataAfterAuth();
        }
        if (_isDisposed) return user != null;
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            currentUser: user,
            clearFailure: true,
          ),
        );
        return user != null;
      },
    );
  }

  Future<void> signOut() async {
    final current = state.value ?? const AuthState();
    state = AsyncValue.data(current.copyWith(isActionLoading: true));
    try {
      final currentUid = current.currentUser?.uid ?? 'offline_user';
      final habitRepo = ref.read(habitRepositoryProvider);
      await habitRepo.backupToVault(userId: currentUid);

      final setSkip = ref.read(setSkipLoginUseCaseProvider);
      await setSkip(false);

      final fcm = ref.read(fcmServiceProvider);
      try {
        await fcm?.clearTokenFromFirestore();
      } catch (_) {}

      final localData = ref.read(habitLocalDataSourceProvider);
      await localData.clearAllData();

      if (!_isDisposed) {
        await ref.read(habitNotifierProvider.notifier).refreshData();
      }
      if (!_isDisposed) {
        await ref.read(habitStatsNotifierProvider.notifier).refreshStats();
      }

      final signOutUseCase = ref.read(signOutUseCaseProvider);
      final result = await signOutUseCase();

      if (!_isDisposed) {
        result.fold(
          (failure) {
            state = AsyncValue.data(
              (state.value ?? current).copyWith(
                isActionLoading: false,
                failure: failure,
              ),
            );
          },
          (_) {
            state = AsyncValue.data(
              (state.value ?? current).copyWith(
                isActionLoading: false,
                clearUser: true,
                hasSkippedLogin: false,
                clearFailure: true,
              ),
            );
          },
        );
      }
    } catch (e, stack) {
      if (!_isDisposed) {
        final failure = NetworkErrorHandler.handle(e, stack);
        state = AsyncValue.data(
          (state.value ?? current).copyWith(
            isActionLoading: false,
            failure: failure,
          ),
        );
      }
    }
  }

  Future<bool> resetPassword({required String email}) async {
    final current = state.value ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isActionLoading: true, clearFailure: true),
    );

    final useCase = ref.read(resetPasswordUseCaseProvider);
    final result = await useCase(email);

    return result.fold(
      (failure) {
        if (!_isDisposed) {
          state = AsyncValue.data(
            (state.value ?? current).copyWith(
              isActionLoading: false,
              failure: failure,
            ),
          );
        }
        return false;
      },
      (_) {
        if (!_isDisposed) {
          state = AsyncValue.data(
            (state.value ?? current).copyWith(
              isActionLoading: false,
              clearFailure: true,
            ),
          );
        }
        return true;
      },
    );
  }

  Future<void> setSkipLogin(bool skipped) async {
    final useCase = ref.read(setSkipLoginUseCaseProvider);
    final result = await useCase(skipped);
    if (!_isDisposed) {
      result.fold(
        (failure) => debugPrint(
          '[AuthNotifier] Failed to persist skip login status: ${failure.toMessage()}',
        ),
        (_) {
          final current = state.value ?? const AuthState();
          state = AsyncValue.data(current.copyWith(hasSkippedLogin: skipped));
        },
      );
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
