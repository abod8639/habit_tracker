import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home_app_widget/data/datasources/home_app_widget_payload_processor.dart';
import 'package:habit_tracker/features/home_app_widget/data/models/home_app_widget_snapshot_model.dart';
import 'package:habit_tracker/features/home_app_widget/domain/entities/home_app_widget_data_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeAppWidgetSnapshotModel Safe Parsing Tests', () {
    test('handles completely null or empty map gracefully', () {
      final model = HomeAppWidgetSnapshotModel.fromMap(null);
      expect(model.uncompletedHabits, isEmpty);
      expect(model.heatmapDatasets, isEmpty);
      expect(model.totalCount, 0);
      expect(model.completedCount, 0);
      expect(model.lastUpdated, isNotNull);
    });

    test('ignores corrupted habit and heatmap items without crashing', () {
      final corruptedMap = {
        'uncompletedHabits': [
          null,
          'invalid string habit',
          12345,
          {
            'id': 'habit-1',
            'name': 'Drink Water',
            'isCompleted': false,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ],
        'heatmapDatasets': {
          'invalid_date': 'corrupted_value',
          DateTime.now().toIso8601String(): '5',
        },
        'totalCount': 'invalid_count_string',
        'completedCount': null,
      };

      final model = HomeAppWidgetSnapshotModel.fromMap(corruptedMap);
      expect(model.uncompletedHabits.length, 1);
      expect(model.uncompletedHabits.first.id, 'habit-1');
      expect(model.uncompletedHabits.first.name, 'Drink Water');
      expect(model.heatmapDatasets.length, 1);
      expect(model.completedCount, 0);
    });

    test(
      'parses JSON string safely and handles malformed JSON without crash',
      () {
        final jsonStr =
            '''
      {
        "uncompletedHabits": [],
        "heatmapDatasets": {},
        "totalCount": 2,
        "completedCount": 1,
        "lastUpdated": "${DateTime.now().toIso8601String()}"
      }
      ''';

        final model = HomeAppWidgetSnapshotModel.fromJson(jsonStr);
        expect(model.totalCount, 2);
        expect(model.completedCount, 1);

        // tryParseJson on malformed JSON
        final malformed = HomeAppWidgetSnapshotModel.tryParseJson('{ bad json');
        expect(malformed, isNull);
      },
    );

    test('converts cleanly to and from domain entity', () {
      final entity = HomeAppWidgetDataEntity(
        uncompletedHabits: [
          HabitEntity(
            id: 'h1',
            name: 'Read Quran',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ],
        heatmapDatasets: {
          DateTime(2026, 1, 1): 3,
        },
        totalCount: 5,
        completedCount: 4,
        lastUpdated: DateTime.now(),
      );

      final model = HomeAppWidgetSnapshotModel.fromEntity(entity);
      expect(model.totalCount, 5);
      expect(model.completedCount, 4);

      final restoredEntity = model.toEntity();
      expect(restoredEntity.totalCount, 5);
      expect(restoredEntity.pendingCount, 1);
      expect(restoredEntity.isAllCompleted, isFalse);
    });
  });

  group('HomeAppWidgetPayloadProcessor Tests', () {
    test('filters uncompleted habits and computes window accurately', () async {
      final now = DateTime.now();
      final habits = [
        HabitEntity(
          id: '1',
          name: 'Gym',
          isCompleted: false,
          createdAt: now,
        ),
        HabitEntity(
          id: '2',
          name: 'Run',
          isCompleted: true,
          createdAt: now,
        ),
      ];

      final heatmap = {
        now: 5,
        now.subtract(const Duration(days: 10)): 3,
        now.subtract(const Duration(days: 90)): 1, // Outside 55-day window
      };

      final data = await HomeAppWidgetPayloadProcessor.processWidgetData(
        habits: habits,
        heatmapData: heatmap,
      );

      expect(data.totalCount, 2);
      expect(data.completedCount, 1);
      expect(data.uncompletedHabits.length, 1);
      expect(data.uncompletedHabits.first.name, 'Gym');
      expect(data.heatmapDatasets.length, 2); // Excludes outside window
    });

    test('parses large JSON payload via compute safely', () async {
      final jsonStr =
          '''
      {
        "uncompletedHabits": [],
        "heatmapDatasets": {},
        "totalCount": 10,
        "completedCount": 8,
        "lastUpdated": "${DateTime.now().toIso8601String()}"
      }
      ''';

      final model = await HomeAppWidgetPayloadProcessor.computeParseJsonPayload(
        jsonStr,
      );
      expect(model.totalCount, 10);
      expect(model.completedCount, 8);
    });
  });

  group('HomeAppWidgetDataEntity Integrity Tests', () {
    test('calculates safe completion rate avoiding division by zero', () {
      final empty = HomeAppWidgetDataEntity.empty();
      expect(empty.completionRate, 0.0);
      expect(empty.isAllCompleted, isFalse);
      expect(empty.pendingCount, 0);

      final active = empty.copyWith(totalCount: 4, completedCount: 2);
      expect(active.completionRate, 0.5);

      final completed = active.copyWith(completedCount: 4);
      expect(completed.isAllCompleted, isTrue);
    });
  });
}
