import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/database/migrators/hive_to_sql_migrator.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_sql_local_data_source.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('hive_sql_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await db.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('SQL Migration & Drift Database Tests', () {
    test('HabitDao performs CRUD, sorting, and sync operations in SQLite', () async {
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
      await dataSource.renameHabitHistory('h1', 'Exercise', 'Morning Workout');
      final renamedHabits = await dataSource.fetchHabitsFromDb();
      expect(renamedHabits.firstWhere((h) => h.id == 'h1').name, 'Morning Workout');

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
    });

    test('HabitHistoryDao performs single-pass aggregation for heatmap', () async {
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
    });

    test('HabitSqlLocalDataSource snapshots and restores complete state', () async {
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
    });

    test('HiveToSqlMigrator accurately migrates legacy Hive data into SQLite', () async {
      // 1. Populate legacy Hive box
      final mainBox = await Hive.openBox(HabitStorage.boxName);
      final legacyHabit = HabitModel(
        id: 'legacy_h1',
        name: 'Read Quran',
        isCompleted: true,
        createdAt: DateTime(2026, 1, 1),
        index: 0,
      );

      await mainBox.put(HabitStorage.habitListKey, [legacyHabit.toMap()]);
      await mainBox.put(HabitStorage.startDayKey, '20260101');
      await mainBox.put(HabitStorage.dayCountKey, 14);
      await mainBox.put(HabitStorage.lastResetDateKey, '2026-01-14T00:00:00.000');

      // Populate monthly history box (202601)
      final historyBox = await Hive.openBox('${HabitStorage.boxName}_history_202601');
      await historyBox.put('legacy_h1_20260101', true);
      await historyBox.put('legacy_h1_20260102', true);

      // 2. Execute migration
      final migrator = HiveToSqlMigrator(db);
      expect(await migrator.isMigrationDone(), false);

      await migrator.migrateIfNeeded();

      // 3. Verify migration in SQLite
      expect(await migrator.isMigrationDone(), true);

      final dataSource = HabitSqlLocalDataSource(db);
      final habits = await dataSource.fetchHabitsFromDb();
      expect(habits.length, 1);
      expect(habits.first.id, 'legacy_h1');
      expect(habits.first.name, 'Read Quran');

      final startDay = await db.habitHistoryDao.getMetadata(HabitStorage.startDayKey);
      expect(startDay, '20260101');

      final dayCount = await db.habitHistoryDao.getMetadata(HabitStorage.dayCountKey);
      expect(dayCount, '14');

      final heatmap = await dataSource.getHeatmapData();
      expect(heatmap[DateTime(2026, 1, 1)], 10);
      expect(heatmap[DateTime(2026, 1, 2)], 10);

      // 4. Verify idempotency
      await migrator.migrateIfNeeded();
      final habitsAfterSecondRun = await dataSource.fetchHabitsFromDb();
      expect(habitsAfterSecondRun.length, 1);
    });
  });
}
