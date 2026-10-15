import 'package:drift/drift.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:hive/hive.dart';
import '../app_database.dart';

class HiveToSqlMigrator {
  final AppDatabase db;
  static const String migrationKey = 'HIVE_MIGRATION_V2_COMPLETED';

  HiveToSqlMigrator(this.db);

  Future<bool> isMigrationDone() async {
    final value = await db.habitHistoryDao.getMetadata(migrationKey);
    return value == 'true';
  }

  Future<void> migrateIfNeeded() async {
    try {
      if (await isMigrationDone()) return;

      // 1. Open main Hive box if not already open
      final Box mainBox;
      if (Hive.isBoxOpen(HabitStorage.boxName)) {
        mainBox = Hive.box(HabitStorage.boxName);
      } else {
        mainBox = await Hive.openBox(HabitStorage.boxName);
      }

      // 2. Migrate current active habits
      final rawHabits = mainBox.get(HabitStorage.habitListKey);
      final List<HabitModel> habitsToMigrate = [];

      if (rawHabits is List && rawHabits.isNotEmpty) {
        for (var item in rawHabits) {
          if (item is HabitModel) {
            habitsToMigrate.add(item);
          } else if (item is Map) {
            habitsToMigrate.add(HabitModel.fromMap(Map<String, dynamic>.from(item)));
          } else if (item is List) {
            habitsToMigrate.add(HabitModel.fromLocalFormat(item));
          }
        }
      }

      if (habitsToMigrate.isNotEmpty) {
        final companions = habitsToMigrate.asMap().entries.map((entry) {
          final index = entry.key;
          final h = entry.value;
          return HabitsCompanion(
            id: Value(h.id),
            name: Value(h.name),
            isCompleted: Value(h.isCompleted),
            createdAt: Value(h.createdAt),
            completedAt: Value(h.completedAt),
            colorValue: Value(h.colorValue),
            sortOrder: Value(h.index ?? index),
            updatedAt: Value(h.updatedAt),
          );
        }).toList();

        await db.habitDao.insertMultipleHabits(companions);
      }

      // Fetch all known habits (both newly migrated and existing in DB)
      final existingDbHabits = await db.habitDao.getAllHabits();
      final Map<String, String> idAndNameToId = {};
      for (final h in habitsToMigrate) {
        idAndNameToId[h.id] = h.id;
        idAndNameToId[h.name] = h.id;
      }
      for (final h in existingDbHabits) {
        idAndNameToId[h.id] = h.id;
        idAndNameToId[h.name] = h.id;
      }

      // Helper to record completions safely
      Future<void> recordIfMatches(String habitIdOrName, String dateStr, bool isCompleted) async {
        final resolvedId = idAndNameToId[habitIdOrName] ?? habitIdOrName;
        await db.habitHistoryDao.recordCompletion(
          resolvedId,
          dateStr,
          isCompleted,
        );
      }

      // Helper to process daily lists
      Future<void> processDailyList(String dateStr, dynamic dailyList) async {
        if (dailyList is List && dateStr.length == 8) {
          for (final item in dailyList) {
            if (item is HabitModel) {
              await recordIfMatches(item.id, dateStr, item.isCompleted);
            } else if (item is Map) {
              final id = item['id']?.toString() ?? '';
              final name = item['name']?.toString() ?? '';
              final isComp = item['isCompleted'] == true ||
                  item['is_completed'] == true ||
                  item['completed'] == true;
              if (id.isNotEmpty) {
                await recordIfMatches(id, dateStr, isComp);
              } else if (name.isNotEmpty) {
                await recordIfMatches(name, dateStr, isComp);
              }
            }
          }
        }
      }

      // 3. Migrate completions from mainBox
      for (final key in mainBox.keys) {
        final keyStr = key.toString();
        if (keyStr.length > 9 && keyStr.contains('_')) {
          final lastUnderscore = keyStr.lastIndexOf('_');
          final habitIdOrName = keyStr.substring(0, lastUnderscore);
          final dateStr = keyStr.substring(lastUnderscore + 1);

          if (dateStr.length == 8 && int.tryParse(dateStr) != null) {
            final dynamic val = mainBox.get(key);
            final bool isCompleted = val == true || val == 1 || val == 'true';
            await recordIfMatches(habitIdOrName, dateStr, isCompleted);
          }
        } else if (keyStr.length == 8 && int.tryParse(keyStr) != null) {
          await processDailyList(keyStr, mainBox.get(key));
        } else if (keyStr.startsWith("${HabitStorage.habitListKey}_")) {
          final dateStr = keyStr.replaceFirst("${HabitStorage.habitListKey}_", '');
          await processDailyList(dateStr, mainBox.get(key));
        }
      }

      // 4. Migrate historical completions from monthly boxes
      final String? startDayStr = mainBox.get(HabitStorage.startDayKey);
      final DateTime startDate = startDayStr != null && startDayStr.length == 8
          ? createDateTimeObject(startDayStr)
          : DateTime.now().subtract(const Duration(days: 90));

      final DateTime now = DateTime.now();
      var currentMonth = DateTime(startDate.year, startDate.month);

      while (currentMonth.isBefore(now) ||
          (currentMonth.year == now.year && currentMonth.month == now.month)) {
        final monthStr = convertDateTimeToString(currentMonth).substring(0, 6);
        final boxName = "${HabitStorage.boxName}_history_$monthStr";

        try {
          final Box historyBox;
          if (Hive.isBoxOpen(boxName)) {
            historyBox = Hive.box(boxName);
          } else {
            historyBox = await Hive.openBox(boxName);
          }

          for (final key in historyBox.keys) {
            final keyStr = key.toString();
            // Match pattern habitId_YYYYMMDD where date is 8 digits
            if (keyStr.length > 9 && keyStr.contains('_')) {
              final lastUnderscore = keyStr.lastIndexOf('_');
              final habitIdOrName = keyStr.substring(0, lastUnderscore);
              final dateStr = keyStr.substring(lastUnderscore + 1);

              if (dateStr.length == 8 && int.tryParse(dateStr) != null) {
                final dynamic val = historyBox.get(key);
                final bool isCompleted = val == true || val == 1 || val == 'true';
                await recordIfMatches(habitIdOrName, dateStr, isCompleted);
              }
            } else if (keyStr.length == 8 && int.tryParse(keyStr) != null) {
              await processDailyList(keyStr, historyBox.get(key));
            }
          }
        } catch (_) {}

        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      }

      // 4. Migrate metadata
      final lastReset = mainBox.get(HabitStorage.lastResetDateKey);
      if (lastReset != null) {
        await db.habitHistoryDao.setMetadata(
          HabitStorage.lastResetDateKey,
          lastReset.toString(),
        );
      }

      final startDay = mainBox.get(HabitStorage.startDayKey);
      if (startDay != null) {
        await db.habitHistoryDao.setMetadata(
          HabitStorage.startDayKey,
          startDay.toString(),
        );
      }

      final dayCount = mainBox.get(HabitStorage.dayCountKey);
      if (dayCount != null) {
        await db.habitHistoryDao.setMetadata(
          HabitStorage.dayCountKey,
          dayCount.toString(),
        );
      }

      // 5. Mark migration completed
      await db.habitHistoryDao.setMetadata(migrationKey, 'true');
    } catch (_) {
      // Keep app resilient if migration fails
    }
  }
}
