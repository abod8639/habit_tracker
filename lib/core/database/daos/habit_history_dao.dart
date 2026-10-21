import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';
import '../tables/habit_completions_table.dart';
import '../tables/app_metadata_table.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';

part 'habit_history_dao.g.dart';

/// Helper payload container for background isolate history processing
class HistoryMapInput {
  final List<Map<String, dynamic>> records;
  final Map<String, String> idToName;
  final Map<String, String> nameToId;

  const HistoryMapInput({
    required this.records,
    required this.idToName,
    required this.nameToId,
  });
}

@DriftAccessor(tables: [Habits, HabitCompletions, AppMetadata])
class HabitHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$HabitHistoryDaoMixin {
  HabitHistoryDao(super.db);

  static const Duration _defaultTimeout = Duration(seconds: 5);
  static const Duration _batchTimeout = Duration(seconds: 10);

  Future<void> recordCompletion(
    String habitId,
    String dateStr,
    bool isCompleted,
  ) {
    return into(habitCompletions)
        .insertOnConflictUpdate(
          HabitCompletionsCompanion(
            habitId: Value(habitId),
            dateStr: Value(dateStr),
            isCompleted: Value(isCompleted),
          ),
        )
        .timeout(_defaultTimeout);
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
    }).timeout(_batchTimeout);
  }

  Future<Map<DateTime, int>> getHeatmapData() async {
    // Query completion stats grouped by date with safe null-handling
    final results = await customSelect(
      '''
      SELECT date_str, 
             COUNT(*) as total_count, 
             SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_count
      FROM habit_completions
      GROUP BY date_str
      ''',
      readsFrom: {habitCompletions},
    ).get().timeout(_batchTimeout);

    final rawRows = results.map((row) {
      return {
        'date_str': row.readNullable<String>('date_str') ?? '',
        'total_count': row.readNullable<int>('total_count') ?? 0,
        'completed_count': row.readNullable<int>('completed_count') ?? 0,
      };
    }).toList();

    // Isolate computation via compute if payload exceeds 250 daily items
    if (rawRows.length > 250) {
      return await compute(_processHeatmapRows, rawRows);
    }
    return _processHeatmapRows(rawRows);
  }

  static Map<DateTime, int> _processHeatmapRows(List<Map<String, dynamic>> rows) {
    final Map<DateTime, int> heatmap = {};

    for (final row in rows) {
      final dateStr = (row['date_str'] as String?) ?? '';
      if (dateStr.length != 8) continue;

      try {
        final yyyy = int.tryParse(dateStr.substring(0, 4));
        final mm = int.tryParse(dateStr.substring(4, 6));
        final dd = int.tryParse(dateStr.substring(6, 8));
        if (yyyy == null || mm == null || dd == null) continue;
        if (mm < 1 || mm > 12 || dd < 1 || dd > 31) continue;

        final date = DateTime(yyyy, mm, dd);
        final total = (row['total_count'] as int?) ?? 0;
        final completed = (row['completed_count'] as int?) ?? 0;

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

    final habitRecords = await select(habits).get().timeout(_defaultTimeout);
    final idToName = {for (var h in habitRecords) h.id: h.name};
    final nameToId = {for (var h in habitRecords) h.name: h.id};

    final query = select(habitCompletions)
      ..where((t) => t.dateStr.isBiggerOrEqualValue(cutoffStr));

    final records = await query.get().timeout(_batchTimeout);

    final rawRecords = records.map((r) => {
      'habitId': r.habitId,
      'dateStr': r.dateStr,
      'isCompleted': r.isCompleted,
    }).toList();

    final input = HistoryMapInput(
      records: rawRecords,
      idToName: idToName,
      nameToId: nameToId,
    );

    // Isolate calculation via compute for large date ranges preventing UI stutter
    if (rawRecords.length > 300) {
      return await compute(_processHistoryRecords, input);
    }
    return _processHistoryRecords(input);
  }

  static Map<String, Map<DateTime, bool>> _processHistoryRecords(HistoryMapInput input) {
    final Map<String, Map<DateTime, bool>> historyMap = {};

    for (final rec in input.records) {
      final dateStr = (rec['dateStr'] as String?) ?? '';
      if (dateStr.length != 8) continue;

      try {
        final yyyy = int.tryParse(dateStr.substring(0, 4));
        final mm = int.tryParse(dateStr.substring(4, 6));
        final dd = int.tryParse(dateStr.substring(6, 8));
        if (yyyy == null || mm == null || dd == null) continue;
        if (mm < 1 || mm > 12 || dd < 1 || dd > 31) continue;

        final date = DateTime(yyyy, mm, dd);
        final habitId = rec['habitId'] as String;
        final isCompleted = (rec['isCompleted'] as bool?) ?? false;

        // Map by habitId
        historyMap.putIfAbsent(habitId, () => {})[date] = isCompleted;

        // Also map by habit name
        final habitName = input.idToName[habitId];
        if (habitName != null) {
          historyMap.putIfAbsent(habitName, () => {})[date] = isCompleted;
        }

        // Also map by habit ID if habitId was saved as habit name
        final habitIdResolved = input.nameToId[habitId];
        if (habitIdResolved != null) {
          historyMap.putIfAbsent(habitIdResolved, () => {})[date] = isCompleted;
        }
      } catch (_) {}
    }

    return historyMap;
  }

  Future<Map<String, int>> getCompletionStatusForDate(String dateStr) async {
    try {
      final results = await customSelect(
        '''
        SELECT COUNT(*) as total_count, 
               SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_count
        FROM habit_completions
        WHERE date_str = ?
        ''',
        variables: [Variable.withString(dateStr)],
        readsFrom: {habitCompletions},
      ).getSingleOrNull().timeout(_defaultTimeout);

      if (results == null) return {'total': 0, 'completed': 0};

      // Safely read nullable aggregate columns preventing DriftTypeException
      final total = results.readNullable<int>('total_count') ?? 0;
      final completed = results.readNullable<int>('completed_count') ?? 0;

      return {
        'total': total,
        'completed': completed,
      };
    } catch (_) {
      return {'total': 0, 'completed': 0};
    }
  }

  Future<String?> getMetadata(String key) async {
    try {
      final record = await (select(
        appMetadata,
      )..where((t) => t.key.equals(key))).getSingleOrNull().timeout(_defaultTimeout);
      return record?.value;
    } catch (_) {
      return null;
    }
  }

  Future<void> setMetadata(String key, String value) {
    return into(appMetadata)
        .insertOnConflictUpdate(
          AppMetadataCompanion(
            key: Value(key),
            value: Value(value),
          ),
        )
        .timeout(_defaultTimeout);
  }

  Future<Map<String, String>> getAllStrengthMetadata() async {
    try {
      final records = await (select(
        appMetadata,
      )..where((t) => t.key.like('${HabitStorage.habitStrengthPrefix}%')))
          .get()
          .timeout(_defaultTimeout);

      final Map<String, String> results = {};
      for (final r in records) {
        var dateKey = r.key.replaceFirst(HabitStorage.habitStrengthPrefix, '');
        if (dateKey.startsWith('_')) {
          dateKey = dateKey.substring(1);
        }
        results[dateKey] = r.value;
      }
      return results;
    } catch (_) {
      return {};
    }
  }

  Future<void> clearAllHistory() async {
    await delete(habitCompletions).go().timeout(_defaultTimeout);
    await (delete(
      appMetadata,
    )..where((t) => t.key.like('${HabitStorage.habitStrengthPrefix}%')))
        .go()
        .timeout(_defaultTimeout);
  }
}
