import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Future<List<HabitRecord>> getAllHabits() {
    return (select(
      habits,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
  }

  Stream<List<HabitRecord>> watchAllHabits() {
    return (select(
      habits,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  }

  Future<HabitRecord?> getHabitById(String id) {
    return (select(habits)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertHabit(HabitsCompanion habit) {
    return into(habits).insertOnConflictUpdate(habit);
  }

  Future<void> insertMultipleHabits(List<HabitsCompanion> habitList) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(habits, habitList);
    });
  }

  Future<void> syncHabits(List<HabitsCompanion> habitList) async {
    await transaction(() async {
      final activeIds = habitList.map((h) => h.id.value).toSet();
      if (activeIds.isEmpty) {
        await delete(habits).go();
      } else {
        await (delete(habits)..where((t) => t.id.isNotIn(activeIds))).go();
        await batch((b) {
          b.insertAllOnConflictUpdate(habits, habitList);
        });
      }
    });
  }

  Future<void> updateHabit(HabitsCompanion habit) {
    return (update(
      habits,
    )..where((t) => t.id.equals(habit.id.value))).write(habit);
  }

  Future<void> deleteHabitById(String id) {
    return (delete(habits)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteMultipleHabits(List<String> ids) {
    return (delete(habits)..where((t) => t.id.isIn(ids))).go();
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
    });
  }

  Future<void> toggleHabitCompletion(
    String id,
    bool isCompleted,
    DateTime? completedAt,
  ) {
    return (update(habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(
        isCompleted: Value(isCompleted),
        completedAt: Value(completedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> resetAllHabitsCompletion() {
    return (update(habits)).write(
      HabitsCompanion(
        isCompleted: const Value(false),
        completedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearAllHabits() {
    return delete(habits).go();
  }
}
