import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/models/habit_vault_data.dart';
import 'package:habit_tracker/features/home/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late KeyValueStorage storage;
  late HabitOfflineVaultDataSource vaultDataSource;
  late HabitLocalDataSource localDataSource;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = KeyValueStorage(db);
    await storage.init();

    vaultDataSource = HabitOfflineVaultDataSource(storage);
    localDataSource = HabitLocalDataSource(
      db,
      vaultDataSource: vaultDataSource,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitOfflineVaultDataSource Tests', () {
    test(
      'saveBackup and getBackup saves and retrieves full snapshot',
      () async {
        final habit = HabitModel(
          id: 'h1',
          name: 'Morning Workout',
          isCompleted: true,
          createdAt: DateTime(2026, 1, 1),
        );

        final snapshot = HabitVaultData(
          userId: 'user_123',
          habits: [habit],
          habitStrengths: {'20261014': '1.0'},
          startDay: '20261001',
          dayCount: 5,
          lastResetDate: '2026-10-14T00:00:00.000',
          tombstones: ['deleted_old_1'],
          backedUpAt: DateTime.now(),
          isSynced: false,
        );

        await vaultDataSource.saveBackup(snapshot);

        expect(vaultDataSource.hasUnsyncedBackup(userId: 'user_123'), true);

        final retrieved = vaultDataSource.getBackup('user_123');
        expect(retrieved, isNotNull);
        expect(retrieved!.userId, 'user_123');
        expect(retrieved.habits.length, 1);
        expect(retrieved.habits.first.name, 'Morning Workout');
        expect(retrieved.habitStrengths['20261014'], '1.0');
        expect(retrieved.startDay, '20261001');
        expect(retrieved.dayCount, 5);
        expect(retrieved.tombstones, ['deleted_old_1']);
        expect(retrieved.isSynced, false);
      },
    );

    test(
      'markBackupSynced updates isSynced to true and removes from pending',
      () async {
        final snapshot = HabitVaultData(
          userId: 'user_abc',
          habits: [],
          habitStrengths: {},
          startDay: '20261014',
          dayCount: 1,
          tombstones: [],
          backedUpAt: DateTime.now(),
          isSynced: false,
        );

        await vaultDataSource.saveBackup(snapshot);
        expect(vaultDataSource.hasUnsyncedBackup(userId: 'user_abc'), true);

        await vaultDataSource.markBackupSynced('user_abc');
        expect(vaultDataSource.hasUnsyncedBackup(userId: 'user_abc'), false);

        final retrieved = vaultDataSource.getBackup('user_abc');
        expect(retrieved!.isSynced, true);
      },
    );
  });

  group('HabitLocalDataSource Vault Integration Tests', () {
    test(
      'createSnapshot captures active habits and strengths accurately',
      () async {
        final habit = HabitModel(
          id: 'h2',
          name: 'Read 30 mins',
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        await localDataSource.saveHabits([habit]);
        await localDataSource.saveHabitStrength('20261014', '0.8');

        final snapshot = await localDataSource.createSnapshot(
          userId: 'user_999',
        );

        expect(snapshot.userId, 'user_999');
        expect(snapshot.habits.length, 1);
        expect(snapshot.habits.first.name, 'Read 30 mins');
        expect(snapshot.habitStrengths['20261014'], '0.8');
      },
    );

    test(
      'clearAllData with backupBeforeClear automatically safeguards data into vault',
      () async {
        final habit = HabitModel(
          id: 'h3',
          name: 'Deep Focus',
          isCompleted: true,
          createdAt: DateTime.now(),
        );

        localDataSource.setLastUserId('user_to_wipe');
        await localDataSource.saveHabits([habit]);
        await localDataSource.saveHabitStrength('20261014', '1.0');

        // Clear active database
        await localDataSource.clearAllData(
          backupBeforeClear: true,
          userId: 'user_to_wipe',
        );

        // Active box should be cleared
        expect(localDataSource.loadHabits().isEmpty, true);

        // BUT vault must preserve the snapshot intact!
        expect(vaultDataSource.hasUnsyncedBackup(userId: 'user_to_wipe'), true);
        final vaultData = vaultDataSource.getBackup('user_to_wipe');
        expect(vaultData, isNotNull);
        expect(vaultData!.habits.first.name, 'Deep Focus');
        expect(vaultData.habitStrengths['20261014'], '1.0');

        // Restoring from vault brings back all data seamlessly
        await localDataSource.restoreFromSnapshot(vaultData);
        expect(localDataSource.loadHabits().length, 1);
        expect(localDataSource.loadHabits().first.name, 'Deep Focus');
      },
    );
  });

  group('HabitRepositoryImpl Vault Methods Tests', () {
    test(
      'backupToVault and restoreFromVault preserves and recovers data across sessions',
      () async {
        final repository = HabitRepositoryImpl(
          localDataSource: localDataSource,
          firestoreService: FirestoreService(),
          vaultDataSource: vaultDataSource,
        );

        await repository.addHabit('Meditation');
        final habitsBefore = await repository.getHabits();
        expect(habitsBefore.getOrElse(() => []).length, 1);

        // Backup to vault
        await repository.backupToVault(userId: 'meditation_user');

        // Simulate a wipe or logout
        await localDataSource.clearAllData(backupBeforeClear: false);
        final habitsAfterWipe = await repository.getHabits();
        expect(habitsAfterWipe.getOrElse(() => []).isEmpty, true);

        // Restore from vault
        final restoreResult = await repository.restoreFromVault(
          userId: 'meditation_user',
        );
        expect(restoreResult.getOrElse(() => false), true);

        final habitsRestored = await repository.getHabits();
        expect(habitsRestored.getOrElse(() => []).length, 1);
        expect(habitsRestored.getOrElse(() => []).first.name, 'Meditation');
      },
    );

    test(
      'Token Expiry Protection: unexpected session disconnect safeguards habits in vault without data loss',
      () async {
        final repository = HabitRepositoryImpl(
          localDataSource: localDataSource,
          firestoreService: FirestoreService(),
          vaultDataSource: vaultDataSource,
        );

        await repository.addHabit('Night Reading');
        await repository.saveHabitCompletionToHistory(
          'h_read',
          true,
          DateTime(2026, 10, 14),
        );

        // Simulate token expiry / unexpected session disconnect:
        // 1. Snapshot is vaulted
        await repository.backupToVault(userId: 'expiry_user');

        // Check vault has pending unsynced data
        expect(vaultDataSource.hasUnsyncedBackup(userId: 'expiry_user'), true);

        // Verify active database still has the habits
        final activeHabits = await repository.getHabits();
        expect(activeHabits.getOrElse(() => []).isNotEmpty, true);
        expect(activeHabits.getOrElse(() => []).first.name, 'Night Reading');
      },
    );

    test(
      'Logout Vault Protection: explicit logout vaults data before clean workspace transition and restores on login',
      () async {
        final repository = HabitRepositoryImpl(
          localDataSource: localDataSource,
          firestoreService: FirestoreService(),
          vaultDataSource: vaultDataSource,
        );

        await repository.addHabit('Coding Kata');

        // 1. Explicit sign out vaults data first
        await repository.backupToVault(userId: 'user_switch');

        // 2. Active database is cleared for new session
        await localDataSource.clearAllData(backupBeforeClear: false);
        expect(localDataSource.loadHabits().isEmpty, true);

        // 3. User reconnects or logs back in -> restored from vault
        final restored = await repository.restoreFromVault(
          userId: 'user_switch',
        );
        expect(restored.getOrElse(() => false), true);

        final restoredHabits = await repository.getHabits();
        expect(restoredHabits.getOrElse(() => []).length, 1);
        expect(restoredHabits.getOrElse(() => []).first.name, 'Coding Kata');

        // 4. Mark synced when cloud sync succeeds
        await repository.markVaultSynced(userId: 'user_switch');
        expect(vaultDataSource.hasUnsyncedBackup(userId: 'user_switch'), false);
      },
    );
  });
}
