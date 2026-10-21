import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/database/database_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitHistoryDao Safe Execution & Null-Safety Tests', () {
    test(
      'getCompletionStatusForDate handles non-existent date gracefully without NullCheck/Type crash',
      () async {
        // Querying a date with no records previously produced DriftTypeException due to SUM returning null
        final status =
            await db.habitHistoryDao.getCompletionStatusForDate('20261022');
        expect(status['total'], equals(0));
        expect(status['completed'], equals(0));
      },
    );

    test('getCompletionStatusForDate computes counts accurately when data exists', () async {
      await db.habitHistoryDao.recordCompletion('h1', '20261022', true);
      await db.habitHistoryDao.recordCompletion('h2', '20261022', false);

      final status =
          await db.habitHistoryDao.getCompletionStatusForDate('20261022');
      expect(status['total'], equals(2));
      expect(status['completed'], equals(1));
    });

    test('getHeatmapData calculates accurately without throwing on zero/null aggregates', () async {
      await db.habitHistoryDao.recordCompletion('h1', '20261020', false);
      await db.habitHistoryDao.recordCompletion('h2', '20261020', false);

      final heatmap = await db.habitHistoryDao.getHeatmapData();
      final date = DateTime(2026, 10, 20);
      expect(heatmap.containsKey(date), isTrue);
      expect(heatmap[date], equals(0));
    });

    test('getHabitHistoryMap aggregates completion histories safely', () async {
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      await db.habitDao.upsertHabit(
        HabitsCompanion.insert(
          id: 'h_test',
          name: 'Meditation',
          createdAt: now,
        ),
      );
      await db.habitHistoryDao.recordCompletion('h_test', dateStr, true);

      final historyMap = await db.habitHistoryDao.getHabitHistoryMap(7);
      expect(historyMap.containsKey('h_test'), isTrue);
      expect(historyMap['h_test']![DateTime(now.year, now.month, now.day)], isTrue);
    });
  });

  group('HabitDao CRUD and Stream Tests', () {
    test('upsertHabit and getAllHabits operate within timeouts', () async {
      final now = DateTime.now();
      await db.habitDao.upsertHabit(
        HabitsCompanion.insert(
          id: 'h_code',
          name: 'Coding',
          createdAt: now,
        ),
      );

      final habits = await db.habitDao.getAllHabits();
      expect(habits.length, equals(1));
      expect(habits.first.name, equals('Coding'));
    });

    test('watchAllHabits stream emits changes correctly', () async {
      final stream = db.habitDao.watchAllHabits();
      final expectation = expectLater(
        stream,
        emits(predicate<List<HabitRecord>>((list) => list.length == 1)),
      );

      await db.habitDao.upsertHabit(
        HabitsCompanion.insert(
          id: 'h_stream',
          name: 'Reading',
          createdAt: DateTime.now(),
        ),
      );

      await expectation;
    });
  });

  group('AppDatabase & Riverpod Provider Tests', () {
    test('AppDatabase ping returns true on healthy database', () async {
      final isHealthy = await db.ping();
      expect(isHealthy, isTrue);
    });

    test('DatabaseStatusNotifier checks health successfully via Riverpod', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(databaseStatusProvider.notifier);
      final either = await notifier.checkHealth();

      expect(either.isRight(), isTrue);
      either.fold(
        (failure) => fail('Expected health check to succeed'),
        (healthy) => expect(healthy, isTrue),
      );
    });
  });
}
