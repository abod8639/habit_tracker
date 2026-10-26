import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';
import '../tables/habit_completions_table.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits, HabitCompletions])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  static const Duration _defaultTimeout = Duration(seconds: 5);
  static const Duration _batchTimeout = Duration(seconds: 10);

  Future<List<HabitRecord>> getAllHabits() {
    return (select(
      habits,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get()
        .timeout(_defaultTimeout);
  }

  Stream<List<HabitRecord>> watchAllHabits() {
    return (select(
      habits,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch()
        .handleError((error, stackTrace) {
          // Prevent stream controller crash by emitting safe empty list
          return <HabitRecord>[];
        });
  }

  Future<HabitRecord?> getHabitById(String id) {
    return (select(habits)..where((t) => t.id.equals(id)))
        .getSingleOrNull()
        .timeout(_defaultTimeout);
  }

  Future<void> upsertHabit(HabitsCompanion habit) {
    return into(habits).insertOnConflictUpdate(habit).timeout(_defaultTimeout);
  }

  Future<void> insertMultipleHabits(List<HabitsCompanion> habitList) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(habits, habitList);
    }).timeout(_batchTimeout);
  }

  Future<void> syncHabits(List<HabitsCompanion> habitList) async {
    await transaction(() async {
      final activeIds = habitList.map((h) => h.id.value).toSet();
      if (activeIds.isEmpty) {
        // Prevent accidental table wipeout when an uninitialized/empty list is passed
        return;
      }
      await (delete(habits)..where((t) => t.id.isNotIn(activeIds))).go();
      await (delete(habitCompletions)..where((t) => t.habitId.isNotIn(activeIds))).go();
      await batch((b) {
        b.insertAllOnConflictUpdate(habits, habitList);
      });
    }).timeout(_batchTimeout);
  }

  Future<void> updateHabit(HabitsCompanion habit) {
    return (update(
      habits,
    )..where((t) => t.id.equals(habit.id.value)))
        .write(habit)
        .timeout(_defaultTimeout);
  }

  Future<void> deleteHabitById(String id) async {
    await transaction(() async {
      await (delete(habits)..where((t) => t.id.equals(id))).go();
      await (delete(habitCompletions)..where((t) => t.habitId.equals(id))).go();
    }).timeout(_defaultTimeout);
  }

  Future<void> deleteMultipleHabits(List<String> ids) async {
    if (ids.isEmpty) return;
    await transaction(() async {
      await (delete(habits)..where((t) => t.id.isIn(ids))).go();
      await (delete(habitCompletions)..where((t) => t.habitId.isIn(ids))).go();
    }).timeout(_defaultTimeout);
  }

  Future<void> updateHabitOrder(List<String> ids) async {
    await transaction(() async {
      for (int i = 0; i < ids.length; i++) {
        await (update(habits)..where((t) => t.id.equals(ids[i]))).write(
          HabitsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }).timeout(_batchTimeout);
  }

  Future<void> toggleHabitCompletion(
    String id,
    bool isCompleted,
    DateTime? completedAt,
  ) {
    return (update(habits)..where((t) => t.id.equals(id)))
        .write(
          HabitsCompanion(
            isCompleted: Value(isCompleted),
            completedAt: Value(completedAt),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .timeout(_defaultTimeout);
  }

  Future<void> resetAllHabitsCompletion() {
    return (update(habits))
        .write(
          HabitsCompanion(
            isCompleted: const Value(false),
            completedAt: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .timeout(_defaultTimeout);
  }

  Future<void> clearAllHabits() async {
    await transaction(() async {
      await delete(habits).go();
      await delete(habitCompletions).go();
    }).timeout(_defaultTimeout);
  }
}
