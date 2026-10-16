import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/theme/presentation/providers/theme_providers.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/auth/domain/entities/auth_entity.dart';
import 'package:habit_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/get_skip_login_status_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/set_skip_login_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:habit_tracker/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_state.dart';
import 'package:habit_tracker/features/setting/domain/repositories/setting_repository.dart';
import 'package:habit_tracker/features/setting/domain/usecases/sync_habits_usecase.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<AuthEntity?> _authStream =
      StreamController<AuthEntity?>.broadcast();
  AuthEntity? currentUser;

  void emitUser(AuthEntity? user) {
    currentUser = user;
    _authStream.add(user);
  }

  @override
  Stream<AuthEntity?> get authStateChanges => _authStream.stream;

  @override
  Future<Either<Failure, AuthEntity?>> signInWithGoogle() async {
    final user = const AuthEntity(
      uid: 'test_uid_123',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    currentUser = user;
    _authStream.add(user);
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    currentUser = null;
    _authStream.add(null);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> getSkipLoginStatus() async =>
      const Right(false);

  @override
  Future<Either<Failure, void>> setSkipLogin(bool skipped) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirestoreService implements FirestoreService {
  @override
  bool get isUserLoggedIn => true;

  Map<String, dynamic>? cloudTheme;

  @override
  Future<Map<String, dynamic>?> downloadTheme() async => cloudTheme;

  @override
  Future<void> uploadTheme(
    dynamic themeName,
    dynamic mode,
    dynamic useCustomBg,
    dynamic customBgColor,
  ) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingRepository implements SettingRepository {
  int syncCallCount = 0;

  @override
  Future<Either<Failure, List<HabitModel>>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  }) async {
    syncCallCount++;
    return Right([
      HabitModel(
        id: 'habit_1',
        name: 'Cloud Exercise',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    return Right(DateTime.now());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHabitRepository implements HabitRepository {
  List<HabitEntity> storedHabits = [];

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async {
    return Right(storedHabits);
  }

  @override
  List<String> getLocalTombstones() => [];

  @override
  void clearLocalTombstones() {}

  @override
  Future<Either<Failure, void>> markVaultSynced({String? userId}) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> backupToVault({String? userId}) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHabitNotifier extends HabitNotifier {
  bool refreshed = false;

  @override
  HabitState build() => const HabitState();

  @override
  String getStartDay([String? storedStartDate]) => '20260101';

  @override
  Future<void> refreshData() async {
    refreshed = true;
    state = state.copyWith(
      habits: [
        HabitEntity(
          id: 'habit_1',
          name: 'Cloud Exercise',
          isCompleted: false,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late FakeSettingRepository fakeSettingRepo;
  late FakeHabitRepository fakeHabitRepo;
  late FakeFirestoreService fakeFirestore;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    fakeSettingRepo = FakeSettingRepository();
    fakeHabitRepo = FakeHabitRepository();
    fakeFirestore = FakeFirestoreService();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        getAuthStateUseCaseProvider.overrideWithValue(
          GetAuthStateUseCase(mockAuthRepo),
        ),
        getSkipLoginStatusUseCaseProvider.overrideWithValue(
          GetSkipLoginStatusUseCase(mockAuthRepo),
        ),
        signInWithGoogleUseCaseProvider.overrideWithValue(
          SignInWithGoogleUseCase(mockAuthRepo),
        ),
        signOutUseCaseProvider.overrideWithValue(
          SignOutUseCase(mockAuthRepo),
        ),
        setSkipLoginUseCaseProvider.overrideWithValue(
          SetSkipLoginUseCase(mockAuthRepo),
        ),
        settingRepositoryProvider.overrideWithValue(fakeSettingRepo),
        syncHabitsUseCaseProvider.overrideWithValue(
          SyncHabitsUseCase(fakeSettingRepo),
        ),
        habitRepositoryProvider.overrideWithValue(fakeHabitRepo),
        firestoreServiceProvider.overrideWithValue(fakeFirestore),
        habitNotifierProvider.overrideWith(() => FakeHabitNotifier()),
      ],
    );
  }

  test(
    'Signing in with Google automatically triggers syncHabits and refreshes habit state',
    () async {
      final container = createContainer();
      final authNotifier = container.read(authNotifierProvider.notifier);

      expect(fakeSettingRepo.syncCallCount, 0);

      final success = await authNotifier.signInWithGoogle();

      expect(success, true);
      expect(fakeSettingRepo.syncCallCount, 1);
      expect(container.read(authNotifierProvider).isLoggedIn, true);

      final habitNotifier =
          container.read(habitNotifierProvider.notifier) as FakeHabitNotifier;
      expect(habitNotifier.refreshed, true);
      expect(container.read(habitNotifierProvider).habits.length, 1);
      expect(
        container.read(habitNotifierProvider).habits.first.name,
        'Cloud Exercise',
      );
    },
  );

  test(
    'Restoring auth session on app startup triggers automatic background sync',
    () async {
      final container = createContainer();

      // Trigger notifier creation
      container.read(authNotifierProvider);

      expect(fakeSettingRepo.syncCallCount, 0);

      // Emit existing restored session
      mockAuthRepo.emitUser(
        const AuthEntity(
          uid: 'restored_uid',
          email: 'restored@example.com',
        ),
      );

      // Allow microtask to process stream event and sync
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeSettingRepo.syncCallCount, 1);
    },
  );

  test('SyncNotifier prevents duplicate concurrent sync calls', () async {
    final container = createContainer();
    final syncNotifier = container.read(syncNotifierProvider.notifier);

    // Call sync twice concurrently
    final future1 = syncNotifier.syncHabits();
    final future2 = syncNotifier.syncHabits();

    await Future.wait([future1, future2]);

    // Should only have triggered sync once because state was syncing
    expect(fakeSettingRepo.syncCallCount, 1);
  });

  test(
    'Signing in with Google immediately synchronizes and applies cloud theme without restart',
    () async {
      fakeFirestore.cloudTheme = {
        'themeName': 'github',
        'themeMode': ThemeMode.light.index,
        'useCustomBg': false,
      };

      final container = createContainer();
      final authNotifier = container.read(authNotifierProvider.notifier);

      // Initial theme before login is default
      expect(
        container.read(themeNotifierProvider).currentTheme,
        'github_dark_green',
      );

      final success = await authNotifier.signInWithGoogle();

      expect(success, true);
      // Theme is immediately updated to the Google account's stored theme
      expect(container.read(themeNotifierProvider).currentTheme, 'github');
      expect(container.read(themeNotifierProvider).themeMode, ThemeMode.light);
    },
  );
}
