import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';
import '../tables/habit_completions_table.dart';
import '../tables/app_metadata_table.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';

part 'habit_history_dao.g.dart';

@DriftAccessor(tables: [Habits, HabitCompletions, AppMetadata])
class HabitHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$HabitHistoryDaoMixin {
  HabitHistoryDao(super.db);

  Future<void> recordCompletion(
    String habitId,
    String dateStr,
    bool isCompleted,
  ) {
    return into(habitCompletions).insertOnConflictUpdate(
      HabitCompletionsCompanion(
        habitId: Value(habitId),
        dateStr: Value(dateStr),
        isCompleted: Value(isCompleted),
      ),
    );
  }

  Future<void> recordCompletionsForDate(
    String dateStr,
    Map<String, bool> completions,
  ) async {
    await batch((b) {
      for (final entry in completions.entries) {
        b.insert(
          habitCompletions,
          HabitCompletionsCompanion(
            habitId: Value(entry.key),
            dateStr: Value(dateStr),
            isCompleted: Value(entry.value),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<Map<DateTime, int>> getHeatmapData() async {
    // Query completion stats grouped by date
    final results = await customSelect(
      '''
      SELECT date_str, 
             COUNT(*) as total_count, 
             SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_count
      FROM habit_completions
      GROUP BY date_str
      ''',
      readsFrom: {habitCompletions},
    ).get();

    final Map<DateTime, int> heatmap = {};

    for (final row in results) {
      final dateStr = row.read<String>('date_str');
      if (dateStr.length != 8) continue;

      try {
        final yyyy = int.parse(dateStr.substring(0, 4));
        final mm = int.parse(dateStr.substring(4, 6));
        final dd = int.parse(dateStr.substring(6, 8));
        final date = DateTime(yyyy, mm, dd);

        final total = row.read<int>('total_count');
        final completed = row.read<int>('completed_count');

        if (total > 0) {
          final rate = completed / total;
          int strength = (rate * 10).toInt();
          if (strength == 0 && completed > 0) strength = 1;
          heatmap[date] = strength;
        }
      } catch (_) {}
    }

    return heatmap;
  }

  Future<Map<String, Map<DateTime, bool>>> getHabitHistoryMap(int days) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoffDate = today.subtract(Duration(days: days + 1));
    final cutoffStr =
        '${cutoffDate.year}${cutoffDate.month.toString().padLeft(2, '0')}${cutoffDate.day.toString().padLeft(2, '0')}';

    final habitRecords = await select(habits).get();
    final idToName = {for (var h in habitRecords) h.id: h.name};
    final nameToId = {for (var h in habitRecords) h.name: h.id};

    final query = select(habitCompletions)
      ..where((t) => t.dateStr.isBiggerOrEqualValue(cutoffStr));

    final records = await query.get();
    final Map<String, Map<DateTime, bool>> historyMap = {};

    for (final rec in records) {
      if (rec.dateStr.length != 8) continue;
      try {
        final yyyy = int.parse(rec.dateStr.substring(0, 4));
        final mm = int.parse(rec.dateStr.substring(4, 6));
        final dd = int.parse(rec.dateStr.substring(6, 8));
        final date = DateTime(yyyy, mm, dd);

        // Map by habitId
        historyMap.putIfAbsent(rec.habitId, () => {})[date] = rec.isCompleted;

        // Also map by habit name
        final habitName = idToName[rec.habitId];
        if (habitName != null) {
          historyMap.putIfAbsent(habitName, () => {})[date] = rec.isCompleted;
        }

        // Also map by habit ID if rec.habitId was saved as habit name
        final habitId = nameToId[rec.habitId];
        if (habitId != null) {
          historyMap.putIfAbsent(habitId, () => {})[date] = rec.isCompleted;
        }
      } catch (_) {}
    }

    return historyMap;
  }

  Future<Map<String, int>> getCompletionStatusForDate(String dateStr) async {
    final results = await customSelect(
      '''
      SELECT COUNT(*) as total_count, 
             SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_count
      FROM habit_completions
      WHERE date_str = ?
      ''',
      variables: [Variable.withString(dateStr)],
      readsFrom: {habitCompletions},
    ).getSingleOrNull();

    if (results == null) return {'total': 0, 'completed': 0};

    return {
      'total': results.read<int>('total_count'),
      'completed': results.read<int>('completed_count'),
    };
  }

  Future<String?> getMetadata(String key) async {
    final record = await (select(appMetadata)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return record?.value;
  }

  Future<void> setMetadata(String key, String value) {
    return into(appMetadata).insertOnConflictUpdate(
      AppMetadataCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  Future<Map<String, String>> getAllStrengthMetadata() async {
    final records = await (select(appMetadata)
          ..where((t) => t.key.like('${HabitStorage.habitStrengthPrefix}%')))
        .get();

    final Map<String, String> results = {};
    for (final r in records) {
      var dateKey = r.key.replaceFirst(HabitStorage.habitStrengthPrefix, '');
      if (dateKey.startsWith('_')) {
        dateKey = dateKey.substring(1);
      }
      results[dateKey] = r.value;
    }
    return results;
  }

  Future<void> clearAllHistory() async {
    await delete(habitCompletions).go();
    await (delete(appMetadata)
          ..where((t) => t.key.like('${HabitStorage.habitStrengthPrefix}%')))
        .go();
  }
}
