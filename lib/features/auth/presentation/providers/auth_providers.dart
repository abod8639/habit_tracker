import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Auth State
class AuthState {
  final AuthEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool hasSkippedLogin;
  final bool isInitialized;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.hasSkippedLogin = false,
    this.isInitialized = false,
  });

  bool get isLoggedIn => currentUser != null;
  AuthEntity? get user => currentUser;

  AuthState copyWith({
    AuthEntity? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? hasSkippedLogin,
    bool? isInitialized,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasSkippedLogin: hasSkippedLogin ?? this.hasSkippedLogin,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AuthEntity?>? _authSubscription;

  @override
  AuthState build() {
    final getAuthState = ref.watch(getAuthStateUseCaseProvider);
    final getSkipStatus = ref.watch(getSkipLoginStatusUseCaseProvider);

    _authSubscription?.cancel();
    _authSubscription = getAuthState().listen((user) {
      if (!ref.mounted) return;
      if (state.isLoading) {
        // Explicit auth action in progress; it manages its own state and sync.
        return;
      }
      final previousUser = state.currentUser;
      state = state.copyWith(
        currentUser: user,
        clearUser: user == null,
      );
      if (user != null) {
        // Automatically sync cloud habits, theme, and habitstats on app startup / session restoration
        if (previousUser?.uid != user.uid) {
          unawaited(_syncUserDataAfterAuth());
        }
      }
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Check initial skip login status
    Future.microtask(() async {
      final result = await getSkipStatus();
      if (!ref.mounted) return;
      result.fold(
        (_) => state = state.copyWith(hasSkippedLogin: false, isInitialized: true),
        (status) => state = state.copyWith(hasSkippedLogin: status, isInitialized: true),
      );
    });

    return const AuthState();
  }

  /// Synchronizes habits and theme from cloud, then refreshes habit statistics.
  Future<void> _syncUserDataAfterAuth() async {
    if (!ref.mounted) return;
    final fcm = ref.read(fcmServiceProvider);
    fcm?.syncTokenToFirestore();

    try {
      if (!ref.mounted) return;
      final syncNotifier = ref.read(syncNotifierProvider.notifier);
      final themeNotifier = ref.read(themeNotifierProvider.notifier);
      await Future.wait([
        syncNotifier.syncHabits(),
        themeNotifier.syncWithCloud(),
      ]);
    } catch (e) {
      debugPrint('Auto sync after authentication failed: $e');
    } finally {
      if (ref.mounted) {
        try {
          await ref.read(habitStatsNotifierProvider.notifier).refreshStats();
        } catch (e) {
          debugPrint('Failed to refresh habit stats after authentication: $e');
        }
      }
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final useCase = ref.read(signInWithEmailUseCaseProvider);
    final result = await useCase(email, password);

    return await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) async {
        if (!ref.mounted) return false;
        await _syncUserDataAfterAuth();
        if (!ref.mounted) return true;
        state = state.copyWith(isLoading: false, currentUser: user);
        return true;
      },
    );
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final useCase = ref.read(signUpWithEmailUseCaseProvider);
    final result = await useCase(email, password, displayName);

    return await result.fold(
      (failure) async {
        if (!ref.mounted) return false;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) async {
        if (!ref.mounted) return false;
        await _syncUserDataAfterAuth();
        if (!ref.mounted) return true;
        state = state.copyWith(isLoading: false, currentUser: user);
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final useCase = ref.read(signInWithGoogleUseCaseProvider);
    final result = await useCase();

    return await result.fold(
      (failure) async {
        if (!ref.mounted) return false;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) async {
        if (!ref.mounted) return false;
        if (user != null) {
          await _syncUserDataAfterAuth();
        }
        if (!ref.mounted) return user != null;
        state = state.copyWith(isLoading: false, currentUser: user);
        return user != null;
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final currentUid = state.currentUser?.uid ?? 'offline_user';
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

      // Refresh in-memory habit state and stats so UI is immediately cleared
      if (ref.mounted) {
        await ref.read(habitNotifierProvider.notifier).refreshData();
      }
      if (ref.mounted) {
        await ref.read(habitStatsNotifierProvider.notifier).refreshStats();
      }

      final signOutUseCase = ref.read(signOutUseCaseProvider);
      await signOutUseCase();

      if (ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          clearUser: true,
          hasSkippedLogin: false,
        );
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<bool> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final useCase = ref.read(resetPasswordUseCaseProvider);
    final result = await useCase(email);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<void> setSkipLogin(bool skipped) async {
    final useCase = ref.read(setSkipLoginUseCaseProvider);
    await useCase(skipped);
    state = state.copyWith(hasSkippedLogin: skipped);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
