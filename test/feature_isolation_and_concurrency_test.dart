import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/contracts/habit_facade_contract.dart';
import 'package:habit_tracker/core/events/app_event_bus.dart';
import 'package:habit_tracker/features/habitstats/data/datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/habitstats/data/models/habit_stats_model.dart';
import 'package:habit_tracker/features/habitstats/data/repositories/habit_stats_repository_impl.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';

class MockHabitRepository implements HabitRepository {
  List<HabitEntity> habits = [];
  Map<DateTime, int> heatmap = {};
  Map<String, Map<DateTime, bool>> history = {};

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async => Right(habits);

  @override
  Future<Either<Failure, Map<DateTime, int>>> getHeatmapData() async =>
      Right(heatmap);

  @override
  Future<Either<Failure, Map<String, Map<DateTime, bool>>>> getHabitHistoryMap(
    int days,
  ) async => Right(history);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHabitStatsLocalDataSource implements HabitStatsLocalDataSource {
  HabitStatsModel? cached;

  @override
  Future<void> cacheStats(HabitStatsModel stats) async {
    cached = stats;
  }

  @override
  HabitStatsModel? getCachedStats() => cached;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Feature Isolation - AppEventBus Tests', () {
    test(
      'EventBus delivers typed events asynchronously to isolated listeners',
      () async {
        final bus = AppEventBus();
        final receivedHabitEvents = <HabitCreatedEvent>[];
        final receivedBatchEvents = <HabitsBatchCreatedEvent>[];

        final sub1 = bus.on<HabitCreatedEvent>().listen(
          receivedHabitEvents.add,
        );
        final sub2 = bus.on<HabitsBatchCreatedEvent>().listen(
          receivedBatchEvents.add,
        );

        bus.fire(HabitCreatedEvent(habitId: 'h1', habitName: 'Morning Run'));
        bus.fire(
          HabitsBatchCreatedEvent(habitNames: ['Read Book', 'Drink Water']),
        );

        // Allow event loop to process stream events
        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedHabitEvents.length, equals(1));
        expect(receivedHabitEvents.first.habitName, equals('Morning Run'));

        expect(receivedBatchEvents.length, equals(1));
        expect(
          receivedBatchEvents.first.habitNames,
          equals(['Read Book', 'Drink Water']),
        );

        await sub1.cancel();
        await sub2.cancel();
        bus.dispose();
      },
    );

    test('Isolated event subscribers do not block each other', () async {
      final bus = AppEventBus();
      final order = <int>[];

      bus.on<HabitCreatedEvent>().listen((_) {
        order.add(1);
      });
      bus.on<HabitCreatedEvent>().listen((_) {
        order.add(2);
      });

      bus.fire(HabitCreatedEvent(habitId: 'h2', habitName: 'Meditation'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(order, containsAllInOrder([1, 2]));
      bus.dispose();
    });
  });

  group('Concurrency & Background Isolate Tests', () {
    test(
      'HabitStatsRepositoryImpl computes stats bundle in isolate worker',
      () async {
        final mockRepo = MockHabitRepository();
        final mockLocalDs = MockHabitStatsLocalDataSource();
        final statsRepo = HabitStatsRepositoryImpl(
          localDataSource: mockLocalDs,
          habitRepository: mockRepo,
        );

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = DateTime(today.year, today.month, today.day - 1);

        mockRepo.habits = [
          HabitEntity(
            id: '1',
            name: 'Workout',
            isCompleted: true,
            colorValue: 0xFF4CAF50,
            createdAt: now,
          ),
          HabitEntity(
            id: '2',
            name: 'Read',
            isCompleted: false,
            colorValue: 0xFF2196F3,
            createdAt: now,
          ),
        ];
        mockRepo.heatmap = {
          today: 1,
          yesterday: 2,
        };
        mockRepo.history = {
          '1': {today: true, yesterday: true},
          '2': {today: false, yesterday: true},
        };

        final result = await statsRepo.getCompleteStatsBundle(7);

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got: $failure'),
          (bundle) {
            expect(bundle.overallStats.totalHabits, equals(2));
            expect(bundle.overallStats.completedHabits, equals(1));
            expect(bundle.overallStats.completionRate, equals(50.0));
            expect(bundle.overallStats.streak, equals(2));
            expect(bundle.overallTrend.length, equals(7));
            expect(bundle.individualTrends.containsKey('Workout'), isTrue);
            expect(bundle.individualTrends['Workout']!.length, equals(7));
          },
        );

        expect(mockLocalDs.cached, isNotNull);
        expect(mockLocalDs.cached!.streak, equals(2));
      },
    );
  });

  group('Feature Decoupling - Facade Contracts', () {
    test(
      'HabitSummaryDto and HabitContextDto correctly isolate domain models',
      () {
        const dto = HabitContextDto(
          habits: [
            HabitSummaryDto(
              id: 'h1',
              name: 'Gym',
              isCompleted: true,
              color: Color(0xFF00FF00),
            ),
          ],
          streak: 5,
          bestStreak: 12,
          startDay: '2026-01-01',
        );

        expect(dto.habits.first.name, equals('Gym'));
        expect(dto.streak, equals(5));
        expect(dto.bestStreak, equals(12));
        expect(dto.startDay, equals('2026-01-01'));
      },
    );
  });
}
