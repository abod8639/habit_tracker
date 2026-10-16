import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_sql_local_data_source.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late HabitSqlLocalDataSource dataSource;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = HabitSqlLocalDataSource(db);
    await dataSource.init();
  });

  tearDown(() async {
    await db.close();
  });

  group('SQL & Firebase Compatibility Tests', () {
    test(
      'HabitModel formats seamlessly between Firestore payloads and SQLite tables',
      () async {
        final now = DateTime.now();
        final original = HabitModel(
          id: 'firebase_habit_1',
          name: 'Daily Meditation',
          isCompleted: true,
          createdAt: now,
          completedAt: now,
          colorValue: 0xFF4CAF50,
          index: 2,
          updatedAt: now,
        );

        // 1. Convert to Firestore map (as uploaded by FirestoreService)
        final firestoreMap = original.toFirestore();
        expect(firestoreMap['name'], 'Daily Meditation');
        expect(firestoreMap['isCompleted'], true);
        expect(firestoreMap['colorValue'], 0xFF4CAF50);
        expect(firestoreMap['index'], 2);

        // 2. In Firestore, the habit ID is stored as the document ID (doc.id)
        const docId = 'firebase_habit_1';
        final fromCloud = HabitModel.fromMap({
          'id': docId,
          'name': firestoreMap['name'],
          'isCompleted': firestoreMap['isCompleted'],
          'colorValue': firestoreMap['colorValue'],
          'index': firestoreMap['index'],
          'createdAt': original.createdAt.toIso8601String(),
          'completedAt': original.completedAt?.toIso8601String(),
          'updatedAt': original.updatedAt?.toIso8601String(),
        });
        expect(fromCloud.id, original.id);
        expect(fromCloud.name, original.name);
        expect(fromCloud.isCompleted, original.isCompleted);
        expect(fromCloud.colorValue, original.colorValue);
        expect(fromCloud.index, original.index);

        // 3. Persist downloaded cloud model into Drift SQLite
        await dataSource.saveHabits([fromCloud]);

        final localList = dataSource.loadHabits();
        expect(localList.length, 1);
        expect(localList.first.id, 'firebase_habit_1');
        expect(localList.first.name, 'Daily Meditation');
        expect(localList.first.isCompleted, true);
        expect(localList.first.colorValue, 0xFF4CAF50);
        expect(localList.first.index, 2);
      },
    );

    test(
      'Cloud habitHistory sync merges into SQLite and computes accurate heatmap & streaks',
      () async {
        // 1. Simulate habits synced from Firestore
        final habit = HabitModel(
          id: 'h_cloud',
          name: 'Quran',
          isCompleted: true,
          createdAt: DateTime(2026, 1, 1),
        );
        await dataSource.saveHabits([habit]);

        // 2. Simulate historical habitHistory downloaded from Firestore collection 'habitHistory'
        final cloudHistory = {
          '20260101': '1.0',
          '20260102': '0.5',
          '20260103': '0.8',
        };
        await dataSource.saveAllHabitStrengths(cloudHistory);

        // 3. Verify getHeatmapData() reflects synced cloud strengths
        final heatmap = await dataSource.getHeatmapData();
        expect(heatmap[DateTime(2026, 1, 1)], 10); // 1.0 * 10 = 10
        expect(heatmap[DateTime(2026, 1, 2)], 5); // 0.5 * 10 = 5
        expect(heatmap[DateTime(2026, 1, 3)], 8); // 0.8 * 10 = 8

        // 4. Verify getAllHabitStrengths() returns complete history for cloud uploading
        final localStrengths = await dataSource.getAllHabitStrengths();
        expect(localStrengths['20260101'], '1.0');
        expect(localStrengths['20260102'], '0.5');
        expect(localStrengths['20260103'], '0.8');
      },
    );

    test(
      'Local completions and Cloud history coexist seamlessly without conflicts',
      () async {
        final habit = HabitModel(
          id: 'h_local',
          name: 'Gym',
          isCompleted: true,
          createdAt: DateTime(2026, 1, 1),
        );
        await dataSource.saveHabits([habit]);

        // Local completion for Jan 1 (recorded in habit_completions)
        await dataSource.saveHabitCompletionToHistory(
          'h_local',
          true,
          DateTime(2026, 1, 1),
        );

        // Cloud history for Jan 2 (synced into app_metadata)
        await dataSource.saveHabitStrength('20260102', '1.0');

        final heatmap = await dataSource.getHeatmapData();
        expect(heatmap[DateTime(2026, 1, 1)], 10); // from habit_completions
        expect(heatmap[DateTime(2026, 1, 2)], 10); // from app_metadata

        final allStrengths = await dataSource.getAllHabitStrengths();
        expect(allStrengths.containsKey('20260101'), true);
        expect(allStrengths.containsKey('20260102'), true);
      },
    );

    test('Cloud startDay and metadata sync into SQLite', () async {
      // Start day update from cloud
      dataSource.updateStartDate('20260115');
      expect(dataSource.getStartDate(), '20260115');

      final storedStartDay = await db.habitHistoryDao.getMetadata(
        HabitStorage.startDayKey,
      );
      expect(storedStartDay, '20260115');
    });
  });
}
