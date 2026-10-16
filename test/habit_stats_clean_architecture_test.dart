import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';
import 'package:habit_tracker/features/habitstats/data/datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/habitstats/data/models/habit_stats_model.dart';
import 'package:habit_tracker/features/habitstats/data/repositories/habit_stats_repository_impl.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';

class FakeHabitRepository implements HabitRepository {
  List<HabitEntity> habits = [];
  Map<DateTime, int> heatmapData = {};
  Map<String, Map<DateTime, bool>> historyMap = {};

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async {
    return Right(habits);
  }

  @override
  Future<Either<Failure, Map<DateTime, int>>> getHeatmapData() async {
    return Right(heatmapData);
  }

  @override
  Future<Either<Failure, Map<String, Map<DateTime, bool>>>> getHabitHistoryMap(
    int days,
  ) async {
    return Right(historyMap);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('HabitStats Clean Architecture & Data Flow Tests', () {
    late AppDatabase db;
    late KeyValueStorage storage;
    late HabitStatsLocalDataSource localDataSource;
    late FakeHabitRepository fakeHabitRepo;
    late HabitStatsRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      storage = KeyValueStorage(db);
      await storage.init();
      localDataSource = HabitStatsLocalDataSourceImpl(storage: storage);
      fakeHabitRepo = FakeHabitRepository();
      repository = HabitStatsRepositoryImpl(
        localDataSource: localDataSource,
        habitRepository: fakeHabitRepo,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('HabitStatsModel serialization and deserialization', () {
      const model = HabitStatsModel(
        totalHabits: 10,
        completedHabits: 8,
        completionRate: 80.0,
        streak: 5,
        bestStreak: 12,
      );

      final map = model.toMap();
      final fromMap = HabitStatsModel.fromMap(map);

      expect(fromMap.totalHabits, 10);
      expect(fromMap.completedHabits, 8);
      expect(fromMap.completionRate, 80.0);
      expect(fromMap.streak, 5);
      expect(fromMap.bestStreak, 12);
    });

    test(
      'HabitStatsLocalDataSource caching works via SQLite KeyValueStorage',
      () async {
        expect(localDataSource.getCachedStats(), isNull);

        const stats = HabitStatsModel(
          totalHabits: 5,
          completedHabits: 3,
          completionRate: 60.0,
          streak: 2,
          bestStreak: 4,
        );

        await localDataSource.cacheStats(stats);
        final cached = localDataSource.getCachedStats();

        expect(cached, isNotNull);
        expect(cached!.totalHabits, 5);
        expect(cached.completedHabits, 3);
        expect(cached.streak, 2);

        await localDataSource.clearCache();
        expect(localDataSource.getCachedStats(), isNull);
      },
    );

    test(
      'HabitStatsRepositoryImpl computes aggregated bundle and caches stats',
      () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = DateTime(today.year, today.month, today.day - 1);

        fakeHabitRepo.habits = [
          HabitEntity(
            id: '1',
            name: 'Read Quran',
            isCompleted: true,
            createdAt: yesterday,
          ),
          HabitEntity(
            id: '2',
            name: 'Exercise',
            isCompleted: false,
            createdAt: yesterday,
          ),
        ];

        fakeHabitRepo.heatmapData = {
          today: 5,
          yesterday: 8,
        };

        fakeHabitRepo.historyMap = {
          '1': {today: true, yesterday: true},
          '2': {today: false, yesterday: true},
        };

        final result = await repository.getCompleteStatsBundle(7);

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not fail: $failure'),
          (bundle) {
            expect(bundle.overallStats.totalHabits, 2);
            expect(bundle.overallStats.completedHabits, 1);
            expect(bundle.overallStats.completionRate, 50.0);
            expect(
              bundle.overallStats.streak,
              2,
            ); // today & yesterday completed
            expect(bundle.todayHabits.length, 2);
            expect(bundle.overallTrend.length, 7);
            expect(bundle.individualTrends.containsKey('Read Quran'), isTrue);
            expect(bundle.individualTrends.containsKey('Exercise'), isTrue);
          },
        );

        // Verify that overall stats were cached into localDataSource
        final cached = localDataSource.getCachedStats();
        expect(cached, isNotNull);
        expect(cached!.totalHabits, 2);
        expect(cached.completedHabits, 1);
        expect(cached.streak, 2);
      },
    );
  });
}
