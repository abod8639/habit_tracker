import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_sql_local_data_source.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habitstats/data/datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/habitstats/data/repositories/habit_stats_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('sql_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('SQL Migration & Drift Database Tests', () {
    test(
      'HabitDao performs CRUD, sorting, and sync operations in SQLite',
      () async {
        final now = DateTime.now();
        final habit1 = HabitModel(
          id: 'h1',
          name: 'Exercise',
          isCompleted: false,
          createdAt: now,
          index: 0,
        );
        final habit2 = HabitModel(
          id: 'h2',
          name: 'Read Book',
          isCompleted: true,
          createdAt: now,
          index: 1,
        );

        final dataSource = HabitSqlLocalDataSource(db);
        await dataSource.init();

        // 1. Save habits
        await dataSource.saveHabits([habit1, habit2]);

        // 2. Load habits (both cached and directly from SQLite)
        final loaded = dataSource.loadHabits();
        expect(loaded.length, 2);
        expect(loaded[0].id, 'h1');
        expect(loaded[0].name, 'Exercise');
        expect(loaded[1].id, 'h2');
        expect(loaded[1].name, 'Read Book');

        final fromDb = await dataSource.fetchHabitsFromDb();
        expect(fromDb.length, 2);

        // 3. Rename habit
        await dataSource.renameHabitHistory(
          'h1',
          'Exercise',
          'Morning Workout',
        );
        final renamedHabits = await dataSource.fetchHabitsFromDb();
        expect(
          renamedHabits.firstWhere((h) => h.id == 'h1').name,
          'Morning Workout',
        );

        // 4. Sync habits (delete h2, keep h1)
        await dataSource.saveHabits([
          HabitModel(
            id: 'h1',
            name: 'Morning Workout',
            isCompleted: true,
            createdAt: now,
            index: 0,
          ),
        ]);

        final remaining = await dataSource.fetchHabitsFromDb();
        expect(remaining.length, 1);
        expect(remaining.first.id, 'h1');

        // 5. Repository editHabit
        final repository = HabitRepositoryImpl(
          localDataSource: dataSource,
          firestoreService: FirestoreService(),
        );
        final editResult = await repository.editHabit('h1', 'Super Workout');
        expect(editResult.isRight(), true);

        final habitsAfterEdit = await dataSource.fetchHabitsFromDb();
        expect(habitsAfterEdit.first.name, 'Super Workout');
        expect(dataSource.loadHabits().first.name, 'Super Workout');
      },
    );

    test(
      'HabitNotifier editHabit updates UI state optimistically and persists',
      () async {
        final dataSource = HabitSqlLocalDataSource(db);
        await dataSource.init();
        final now = DateTime.now();
        final habit = HabitModel(
          id: 'h_notifier_edit',
          name: 'Initial Habit',
          isCompleted: false,
          createdAt: now,
          index: 0,
        );
        await dataSource.saveHabits([habit]);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            habitLocalDataSourceProvider.overrideWithValue(dataSource),
          ],
        );

        // Wait for initialization
        await container.read(habitNotifierProvider.notifier).refreshData();
        final initialState = container.read(habitNotifierProvider);
        expect(initialState.habits.first.name, 'Initial Habit');

        // Edit habit
        await container
            .read(habitNotifierProvider.notifier)
            .editHabit('h_notifier_edit', 'Renamed Habit');

        final updatedState = container.read(habitNotifierProvider);
        expect(updatedState.habits.first.name, 'Renamed Habit');

        // Verify in SQLite
        final dbHabits = await dataSource.fetchHabitsFromDb();
        expect(dbHabits.first.name, 'Renamed Habit');
      },
    );

    test(
      'HabitHistoryDao performs single-pass aggregation for heatmap',
      () async {
        final dataSource = HabitSqlLocalDataSource(db);
        final now = DateTime.now();
        final date1 = DateTime(2026, 1, 1);
        final date2 = DateTime(2026, 1, 2);
        final date1Str = convertDateTimeToString(date1);
        final date2Str = convertDateTimeToString(date2);

        final habit = HabitModel(
          id: 'h_test',
          name: 'Gym',
          isCompleted: false,
          createdAt: now,
        );
        await dataSource.saveHabits([habit]);

        // Record completions
        await db.habitHistoryDao.recordCompletion('h_test', date1Str, true);
        await db.habitHistoryDao.recordCompletion('h_test', date2Str, false);

        // Verify that re-recording for the same habit and date (upsert) succeeds without UNIQUE constraint violation
        await db.habitHistoryDao.recordCompletion('h_test', date1Str, false);
        var statusUpdated = await dataSource.getCompletionStatusForDate(date1);
        expect(statusUpdated['completed'], 0);
        expect(statusUpdated['total'], 1);

        // Toggle back to true
        await db.habitHistoryDao.recordCompletion('h_test', date1Str, true);

        final heatmap = await dataSource.getHeatmapData();
        expect(heatmap[date1], 10); // 100% completed = strength 10
        expect(heatmap[date2], 0); // 0% completed = strength 0

        // Completion status for date
        final statusDate1 = await dataSource.getCompletionStatusForDate(date1);
        expect(statusDate1['completed'], 1);
        expect(statusDate1['total'], 1);

        final statusDate2 = await dataSource.getCompletionStatusForDate(date2);
        expect(statusDate2['completed'], 0);
        expect(statusDate2['total'], 1);
      },
    );

    test(
      'HabitSqlLocalDataSource snapshots and restores complete state',
      () async {
        final dataSource = HabitSqlLocalDataSource(db);
        final now = DateTime.now();
        final habit = HabitModel(
          id: 'snap_1',
          name: 'Meditation',
          isCompleted: true,
          createdAt: now,
          index: 0,
        );

        await dataSource.saveHabits([habit]);
        dataSource.updateStartDate('20260101');
        await dataSource.saveHabitStrength('20260101', '0.8');
        await dataSource.incrementDayCount(5);

        final snapshot = await dataSource.createSnapshot(userId: 'user_42');
        expect(snapshot.userId, 'user_42');
        expect(snapshot.habits.length, 1);
        expect(snapshot.startDay, '20260101');
        expect(snapshot.dayCount, 6); // 1 initial + 5

        // Clear all
        await dataSource.clearAllData();
        final cleared = await dataSource.fetchHabitsFromDb();
        expect(cleared.isEmpty, true);

        // Restore
        await dataSource.restoreFromSnapshot(snapshot);
        final restored = await dataSource.fetchHabitsFromDb();
        expect(restored.length, 1);
        expect(restored.first.id, 'snap_1');
        expect(dataSource.getStartDate(), '20260101');
      },
    );

    test(
      'HabitHistoryDao and HabitStatsRepository accurately track previous days history',
      () async {
        final dataSource = HabitSqlLocalDataSource(db);
        await dataSource.init();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final twoDaysAgo = today.subtract(const Duration(days: 2));

        final h1 = HabitModel(
          id: 'h_gym',
          name: 'Gym',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 10)),
          colorValue: 0xFFFF5722,
          index: 0,
        );
        final h2 = HabitModel(
          id: 'h_read',
          name: 'Reading',
          isCompleted: false,
          createdAt: now.subtract(const Duration(days: 10)),
          colorValue: 0xFF2196F3,
          index: 1,
        );

        await dataSource.saveHabits([h1, h2]);

        final yesterdayStr = convertDateTimeToString(yesterday);
        final twoDaysAgoStr = convertDateTimeToString(twoDaysAgo);

        // Record completions for past days:
        // Gym: completed yesterday (true), incomplete two days ago (false)
        // Reading: incomplete yesterday (false), completed two days ago (true)
        await db.habitHistoryDao.recordCompletion('h_gym', yesterdayStr, true);
        await db.habitHistoryDao.recordCompletion(
          'h_gym',
          twoDaysAgoStr,
          false,
        );

        await db.habitHistoryDao.recordCompletion(
          'h_read',
          yesterdayStr,
          false,
        );
        await db.habitHistoryDao.recordCompletion(
          'h_read',
          twoDaysAgoStr,
          true,
        );

        // 1. Verify getHabitHistoryMap indexes by both ID and Name
        final historyMap = await db.habitHistoryDao.getHabitHistoryMap(7);

        expect(historyMap['h_gym']?[yesterday], true);
        expect(historyMap['Gym']?[yesterday], true);
        expect(historyMap['h_gym']?[twoDaysAgo], false);
        expect(historyMap['Gym']?[twoDaysAgo], false);

        expect(historyMap['h_read']?[yesterday], false);
        expect(historyMap['Reading']?[yesterday], false);
        expect(historyMap['h_read']?[twoDaysAgo], true);
        expect(historyMap['Reading']?[twoDaysAgo], true);

        // 2. Verify HabitStatsRepositoryImpl produces accurate trends for previous days
        final habitRepo = HabitRepositoryImpl(
          localDataSource: dataSource,
          firestoreService: FirestoreService(),
        );

        final statsRepo = HabitStatsRepositoryImpl(
          localDataSource: HabitStatsLocalDataSourceImpl(),
          habitRepository: habitRepo,
        );

        final bundleResult = await statsRepo.getCompleteStatsBundle(7);
        expect(bundleResult.isRight(), true);

        bundleResult.fold(
          (failure) => fail(failure.toString()),
          (bundle) {
            final gymSpots = bundle.individualTrends['Gym']!;
            expect(gymSpots.length, 7);
            // Index 6 = Today (1.0 because isCompleted = true)
            expect(gymSpots[6].y, 1.0);
            // Index 5 = Yesterday (1.0 because completed = true)
            expect(gymSpots[5].y, 1.0);
            // Index 4 = Two days ago (0.0 because completed = false)
            expect(gymSpots[4].y, 0.0);

            final readSpots = bundle.individualTrends['Reading']!;
            expect(readSpots.length, 7);
            // Index 6 = Today (0.0 because isCompleted = false)
            expect(readSpots[6].y, 0.0);
            // Index 5 = Yesterday (0.0 because completed = false)
            expect(readSpots[5].y, 0.0);
            // Index 4 = Two days ago (1.0 because completed = true)
            expect(readSpots[4].y, 1.0);
          },
        );
      },
    );
  });
}
