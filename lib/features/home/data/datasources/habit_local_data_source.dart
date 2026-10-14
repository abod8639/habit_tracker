import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/models/habit_vault_data.dart';
import 'package:habit_tracker/features/home/data/datasources/i_habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:hive/hive.dart';

class HabitLocalDataSource implements IHabitLocalDataSource {
  final Box _myBox;
  @override
  final HabitOfflineVaultDataSource? vaultDataSource;

  HabitLocalDataSource(this._myBox, {this.vaultDataSource});

  // Helper to get monthly box name
  String _getMonthlyBoxName(String yyyymmdd) {
    return "${HabitStorage.boxName}_history_${yyyymmdd.substring(0, 6)}";
  }

  Future<Box> _openMonthlyBox(String yyyymmdd) async {
    final boxName = _getMonthlyBoxName(yyyymmdd);
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  List<HabitModel> loadHabits() {
    if (_myBox.get(HabitStorage.habitListKey) != null) {
      final data = _myBox.get(HabitStorage.habitListKey);
      if (data is List && data.isNotEmpty && data.first is List) {
        return data.map((item) => HabitModel.fromLocalFormat(item)).toList();
      } else if (data is List) {
        return List<HabitModel>.from(data.cast<HabitModel>());
      }
    }
    return [];
  }

  @override
  Future<void> saveHabits(List<HabitModel> habits) async {
    _myBox.put(HabitStorage.habitListKey, habits);

    final String today = todaysDateFormatted();
    final historyBox = await _openMonthlyBox(today);

    // Store daily list in partitioned box
    await historyBox.put(today, habits);

    for (var habit in habits) {
      final String idKey = "${habit.id}_$today";
      final String nameKey = "${habit.name}_$today";
      await historyBox.put(idKey, habit.isCompleted);
      await historyBox.put(nameKey, habit.isCompleted);
    }
  }

  Future<List<HabitModel>> getHabitsForDate(String dateStr) async {
    try {
      final historyBox = await _openMonthlyBox(dateStr);
      final data = historyBox.get(dateStr) ?? _myBox.get(dateStr);

      if (data != null && data is List) {
        final List<HabitModel> result = [];
        for (var item in data) {
          if (item is HabitModel) {
            result.add(item);
          } else if (item is Map) {
            result.add(HabitModel.fromMap(Map<String, dynamic>.from(item)));
          } else if (item is List) {
            result.add(HabitModel.fromLocalFormat(item));
          }
        }
        return result;
      }
    } catch (_) {
      // Safe fallback
    }
    return [];
  }

  @override
  Future<Map<String, int>> getCompletionStatusForDate(DateTime date) async {
    final localDate = date.isUtc ? date.toLocal() : date;
    final normalizedDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);
    final dateStr = convertDateTimeToString(normalizedDate);
    final currentHabits = loadHabits();

    // 1. If it's today, return live habits count
    if (normalizedDate.isAtSameMomentAs(normalizedToday)) {
      final total = currentHabits.length;
      final completed = currentHabits.where((h) => h.isCompleted).length;
      return {'total': total, 'completed': completed};
    }

    // 2. If it's a future date, no habits can be completed
    if (normalizedDate.isAfter(normalizedToday)) {
      return {'total': currentHabits.length, 'completed': 0};
    }

    // 3. For past dates:
    final historyBox = await _openMonthlyBox(dateStr);

    // Check if we have a saved snapshot list for that specific date
    final habitsForDate = await getHabitsForDate(dateStr);

    if (habitsForDate.isNotEmpty) {
      int completed = 0;
      for (var habit in habitsForDate) {
        final idKey = "${habit.id}_$dateStr";
        final nameKey = "${habit.name}_$dateStr";
        final dynamic boxVal = historyBox.get(idKey) ?? historyBox.get(nameKey);
        if (boxVal is bool) {
          if (boxVal) completed++;
        } else if (habit.isCompleted) {
          completed++;
        }
      }
      return {'total': habitsForDate.length, 'completed': completed};
    }

    // If no snapshot list, query individual habit history for known habits
    int completedCount = 0;
    int trackedCount = 0;
    int eligibleHabitsCount = 0;

    for (var habit in currentHabits) {
      final habitCreatedDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      final existedOnDate = !habitCreatedDate.isAfter(normalizedDate);

      final idKey = "${habit.id}_$dateStr";
      final nameKey = "${habit.name}_$dateStr";
      final dynamic boxVal = historyBox.get(idKey) ?? historyBox.get(nameKey);

      if (boxVal != null && boxVal is bool) {
        trackedCount++;
        if (boxVal) {
          completedCount++;
        }
      }

      if (existedOnDate || boxVal != null) {
        eligibleHabitsCount++;
      }
    }

    // If we found any recorded completions or non-completions in history
    if (trackedCount > 0) {
      final total = eligibleHabitsCount > 0
          ? eligibleHabitsCount
          : (currentHabits.isNotEmpty ? currentHabits.length : trackedCount);
      return {
        'total': total,
        'completed': completedCount,
      };
    }

    // Also check habit strength if stored (e.g. from heatmap or previous sync)
    final strengthStr = await getHabitStrength(dateStr);
    if (strengthStr != null) {
      final double? strength = double.tryParse(strengthStr);
      if (strength != null && strength > 0) {
        final total = eligibleHabitsCount > 0
            ? eligibleHabitsCount
            : currentHabits.length;
        final calcCompleted = (strength * total).round();
        return {
          'total': total,
          'completed': calcCompleted > 0 ? calcCompleted : 1,
        };
      }
    }

    // If no activity or record exists for this past date, completed is 0
    final total = eligibleHabitsCount > 0
        ? eligibleHabitsCount
        : currentHabits.length;
    return {
      'total': total,
      'completed': 0,
    };
  }

  @override
  Future<void> saveHabitCompletionHistory(
    String habitId,
    bool isCompleted, {
    String? habitName,
  }) async {
    final String today = todaysDateFormatted();
    final historyBox = await _openMonthlyBox(today);
    await historyBox.put("${habitId}_$today", isCompleted);
    if (habitName != null && habitName != habitId) {
      await historyBox.put("${habitName}_$today", isCompleted);
    }
  }

  @override
  Future<void> renameHabitHistory(
    String habitId,
    String oldName,
    String newName,
  ) async {
    final startDateStr = getStartDate();
    final startDate = createDateTimeObject(startDateStr);
    final now = DateTime.now();

    var current = DateTime(startDate.year, startDate.month);
    while (current.isBefore(now) ||
        (current.year == now.year && current.month == now.month)) {
      final monthStr = convertDateTimeToString(current).substring(0, 6);
      final boxName = "${HabitStorage.boxName}_history_$monthStr";

      final Box historyBox;
      if (Hive.isBoxOpen(boxName)) {
        historyBox = Hive.box(boxName);
      } else {
        historyBox = await Hive.openBox(boxName);
      }

      final Map<String, dynamic> updates = {};
      final List<dynamic> keysToDelete = [];

      final oldPrefix = "${oldName}_";
      final idPrefix = "${habitId}_";

      for (var key in historyBox.keys) {
        final keyStr = key.toString();

        if (keyStr.startsWith(oldPrefix)) {
          final dateSuffix = keyStr.substring(oldName.length);
          final val = historyBox.get(key);
          updates["$habitId$dateSuffix"] = val;
          updates["$newName$dateSuffix"] = val;
          keysToDelete.add(key);
        } else if (keyStr.startsWith(idPrefix)) {
          final dateSuffix = keyStr.substring(habitId.length);
          final val = historyBox.get(key);
          updates["$newName$dateSuffix"] = val;
        } else if (keyStr.length == 8 && int.tryParse(keyStr) != null) {
          final dailyData = historyBox.get(key);
          if (dailyData is List) {
            bool listChanged = false;
            final updatedList = dailyData.map((item) {
              if (item is HabitModel && item.id == habitId) {
                listChanged = true;
                return HabitModel(
                  id: item.id,
                  name: newName,
                  isCompleted: item.isCompleted,
                  createdAt: item.createdAt,
                  completedAt: item.completedAt,
                  colorValue: item.colorValue,
                  index: item.index,
                  updatedAt: DateTime.now(),
                );
              }
              return item;
            }).toList();
            if (listChanged) {
              updates[keyStr] = updatedList;
            }
          }
        }
      }

      if (updates.isNotEmpty) {
        await historyBox.putAll(updates);
      }
      for (var k in keysToDelete) {
        await historyBox.delete(k);
      }

      current = DateTime(current.year, current.month + 1);
    }
  }

  void setStartDate() {
    _myBox.put(HabitStorage.startDayKey, todaysDateFormatted());
  }

  @override
  String getStartDate() {
    return _myBox.get(
      HabitStorage.startDayKey,
      defaultValue: todaysDateFormatted(),
    );
  }

  @override
  void updateStartDate(String date) {
    _myBox.put(HabitStorage.startDayKey, date);
  }

  @override
  Future<void> saveHabitStrength(String date, String strength) async {
    final historyBox = await _openMonthlyBox(date);
    final dateKey = "${HabitStorage.habitStrengthPrefix}$date";
    await historyBox.put(dateKey, strength);
  }

  Future<String?> getHabitStrength(String yyyymmdd) async {
    final historyBox = await _openMonthlyBox(yyyymmdd);
    return historyBox.get("${HabitStorage.habitStrengthPrefix}$yyyymmdd")
        as String?;
  }

  @override
  Future<Map<String, String>> getAllHabitStrengths() async {
    final Map<String, String> allHistory = {};

    // 1. Scan legacy _myBox for habit strengths stored before monthly partitioning
    for (var key in _myBox.keys) {
      if (key.toString().startsWith(HabitStorage.habitStrengthPrefix)) {
        String date = key.toString().replaceFirst(
          HabitStorage.habitStrengthPrefix,
          '',
        );
        if (date.startsWith('_')) {
          date = date.substring(1);
        }
        allHistory[date] = _myBox.get(key).toString();
      }
    }

    // 2. We need to iterate through all months since start date
    final startDateStr = getStartDate();
    final startDate = createDateTimeObject(startDateStr);
    final now = DateTime.now();

    var current = DateTime(startDate.year, startDate.month);
    while (current.isBefore(now) ||
        (current.year == now.year && current.month == now.month)) {
      final monthStr = convertDateTimeToString(current).substring(0, 6);
      final boxName = "${HabitStorage.boxName}_history_$monthStr";

      final Box historyBox;
      if (Hive.isBoxOpen(boxName)) {
        historyBox = Hive.box(boxName);
      } else {
        historyBox = await Hive.openBox(boxName);
      }

      for (var key in historyBox.keys) {
        if (key.toString().startsWith(HabitStorage.habitStrengthPrefix)) {
          // Strip the prefix, and remove any remaining underscore gracefully
          String date = key.toString().replaceFirst(
            HabitStorage.habitStrengthPrefix,
            '',
          );
          if (date.startsWith('_')) {
            date = date.substring(1);
          }
          var strength = historyBox.get(key).toString();

          // Self-heal: If strength was stored as "0.0" or "0" due to rounding bug,
          // check if any habits were actually completed on that date in history
          final parsedStrength = double.tryParse(strength) ?? 0.0;
          if (parsedStrength == 0.0) {
            bool hasCompletedHabit = false;
            final dailyList = historyBox.get(date) ?? _myBox.get(date);
            if (dailyList is List) {
              for (var item in dailyList) {
                if (item is HabitModel && item.isCompleted) {
                  hasCompletedHabit = true;
                  break;
                } else if (item is Map &&
                    (item['isCompleted'] == true ||
                        item['isCompleted'] == 1)) {
                  hasCompletedHabit = true;
                  break;
                }
              }
            }
            if (!hasCompletedHabit) {
              for (var k in historyBox.keys) {
                final kStr = k.toString();
                if (kStr.endsWith('_$date') &&
                    !kStr.startsWith(HabitStorage.habitStrengthPrefix)) {
                  final dynamic val = historyBox.get(k);
                  if (val == true || val == 1 || val == "true") {
                    hasCompletedHabit = true;
                    break;
                  }
                }
              }
            }
            if (hasCompletedHabit) {
              strength = "0.1";
              historyBox.put(key, "0.1");
            }
          }

          allHistory[date] = strength;
        }
      }

      // 3. Self-heal: Check for dates with habit snapshot lists where TODAY_HABIT is absent
      for (var key in historyBox.keys) {
        final kStr = key.toString();
        if (kStr.length == 8 && int.tryParse(kStr) != null && !allHistory.containsKey(kStr)) {
          final dailyList = historyBox.get(key) ?? _myBox.get(key);
          if (dailyList is List && dailyList.isNotEmpty) {
            int completed = 0;
            for (var item in dailyList) {
              if (item is HabitModel && item.isCompleted) {
                completed++;
              } else if (item is Map &&
                  (item['isCompleted'] == true || item['isCompleted'] == 1)) {
                completed++;
              }
            }
            if (completed > 0) {
              allHistory[kStr] = (completed / dailyList.length).toString();
            }
          }
        }
      }

      // Move to next month
      current = DateTime(current.year, current.month + 1);
    }

    return allHistory;
  }

  @override
  Future<void> saveAllHabitStrengths(Map<String, String> history) async {
    for (var entry in history.entries) {
      await saveHabitStrength(entry.key, entry.value);
    }
  }

  String getLastSavedDate() {
    return _myBox.get(HabitStorage.lastSavedDateKey, defaultValue: "");
  }

  void setLastSavedDate(String date) {
    _myBox.put(HabitStorage.lastSavedDateKey, date);
  }

  DateTime? getLastSyncTime() {
    final lastSyncStr = _myBox.get('last_sync');
    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }
    return null;
  }

  Future<void> markLastSyncTime() async {
    await _myBox.put('last_sync', DateTime.now().toIso8601String());
  }

  @override
  List<String> getLocalTombstones() {
    final data = _myBox.get('local_tombstones');
    if (data is List) {
      return data.cast<String>();
    }
    return [];
  }

  void addLocalTombstone(String id) {
    addLocalTombstones([id]);
  }

  @override
  void addLocalTombstones(List<String> ids) {
    if (ids.isEmpty) return;
    final tombstones = getLocalTombstones();
    bool changed = false;
    for (final id in ids) {
      if (!tombstones.contains(id)) {
        tombstones.add(id);
        changed = true;
      }
    }
    if (changed) {
      _myBox.put('local_tombstones', tombstones);
    }
  }

  @override
  void clearLocalTombstones() {
    _myBox.delete('local_tombstones');
  }

  void setLastUserId(String uid) {
    _myBox.put('last_user_id', uid);
  }

  @override
  String? getLastUserId() {
    return _myBox.get('last_user_id');
  }

  /// Creates a snapshot of all current habits, strengths, and metadata for offline vaulting.
  @override
  Future<HabitVaultData> createSnapshot({required String userId}) async {
    final habits = loadHabits();
    final strengths = await getAllHabitStrengths();
    final startDay = getStartDate();
    final rawDayCount = _myBox.get(HabitStorage.dayCountKey);
    final dayCount = rawDayCount is int ? rawDayCount : 1;
    final lastReset = await getLastResetDate();
    final tombstones = getLocalTombstones();

    return HabitVaultData(
      userId: userId,
      habits: habits,
      habitStrengths: strengths,
      startDay: startDay,
      dayCount: dayCount,
      lastResetDate: lastReset?.toIso8601String(),
      tombstones: tombstones,
      backedUpAt: DateTime.now(),
      isSynced: false,
    );
  }

  /// Restores habit data and metadata from a vaulted snapshot into active boxes.
  @override
  Future<void> restoreFromSnapshot(HabitVaultData data) async {
    // 1. Restore habits
    if (data.habits.isNotEmpty) {
      await saveHabits(data.habits);
    }
    // 2. Restore strengths
    if (data.habitStrengths.isNotEmpty) {
      await saveAllHabitStrengths(data.habitStrengths);
    }
    // 3. Restore startDay
    if (data.startDay.isNotEmpty) {
      updateStartDate(data.startDay);
    }
    // 4. Restore dayCount & reset date
    await _myBox.put(HabitStorage.dayCountKey, data.dayCount);
    if (data.lastResetDate != null) {
      await saveLastResetDate(DateTime.parse(data.lastResetDate!));
    }
    // 5. Restore tombstones
    if (data.tombstones.isNotEmpty) {
      addLocalTombstones(data.tombstones);
    }
  }

  @override
  Future<void> clearAllData({
    String? earliestDateStr,
    bool backupBeforeClear = true,
    String? userId,
  }) async {
    // Safeguard: Before clearing active boxes, store snapshot in offline vault
    if (backupBeforeClear && vaultDataSource != null) {
      final habits = loadHabits();
      if (habits.isNotEmpty) {
        final effectiveUserId =
            userId ?? getLastUserId() ?? 'offline_user';
        final snapshot = await createSnapshot(userId: effectiveUserId);
        await vaultDataSource!.saveBackup(snapshot);
      }
    }

    // 1. Iterate and clear monthly history boxes
    DateTime startDate;
    if (earliestDateStr != null && earliestDateStr.isNotEmpty) {
      final parsed = createDateTimeObject(earliestDateStr);
      final stored = createDateTimeObject(getStartDate());
      startDate = parsed.isBefore(stored) ? parsed : stored;
    } else {
      startDate = createDateTimeObject(getStartDate());
    }

    final now = DateTime.now();
    if (startDate.isAfter(now)) {
      startDate = now;
    }

    var current = DateTime(startDate.year, startDate.month);
    while (current.isBefore(now) ||
        (current.year == now.year && current.month == now.month)) {
      final monthStr = convertDateTimeToString(current).substring(0, 6);
      final boxName = "${HabitStorage.boxName}_history_$monthStr";

      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        } else {
          final box = await Hive.openBox(boxName);
          await box.clear();
        }
      } catch (_) {
        // Safe to ignore if box cannot be opened
      }

      // Move to next month
      current = DateTime(current.year, current.month + 1);
    }

    // 2. Clear main habit box
    await _myBox.clear();

    // 3. Reset start date to today
    setStartDate();
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    final String? dateStr = _myBox.get(HabitStorage.lastResetDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  @override
  Future<void> saveLastResetDate(DateTime date) async {
    await _myBox.put(HabitStorage.lastResetDateKey, date.toIso8601String());
  }

  @override
  Future<void> incrementDayCount([int amount = 1]) async {
    int currentCount = _myBox.get(HabitStorage.dayCountKey) ?? 1;
    await _myBox.put(HabitStorage.dayCountKey, currentCount + amount);
  }

  @override
  Future<void> saveHabitCompletionToHistory(
    String habitIdOrName,
    bool isCompleted,
    DateTime date, {
    String? habitName,
  }) async {
    final dateStr = convertDateTimeToString(date);
    final historyBox = await _openMonthlyBox(dateStr);
    await historyBox.put("${habitIdOrName}_$dateStr", isCompleted);
    if (habitName != null && habitName != habitIdOrName) {
      await historyBox.put("${habitName}_$dateStr", isCompleted);
    }
  }

  bool? _parseNullableBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  @override
  Future<Map<String, Map<DateTime, bool>>> getHabitHistoryMap(int days) async {
    final Map<String, Map<DateTime, bool>> historyMap = {};
    final now = DateTime.now();
    final habits = loadHabits();

    // Map each habit by BOTH its id and its name to support decoupling
    for (var habit in habits) {
      final habitDates = <DateTime, bool>{};
      historyMap[habit.id] = habitDates;
      historyMap[habit.name] = habitDates;
    }

    // Pre-cache open monthly boxes (at most 2 boxes for 30 days)
    final Map<String, Box> openBoxes = {};

    // Iterate backwards N days
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = convertDateTimeToString(date);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final monthStr = dateStr.substring(0, 6);

      Box? historyBox = openBoxes[monthStr];
      if (historyBox == null) {
        try {
          historyBox = await _openMonthlyBox(dateStr);
          openBoxes[monthStr] = historyBox;
        } catch (_) {
          // Fallback gracefully if monthly box fails to open
        }
      }

      // Check for daily snapshot list in historyBox or _myBox
      Map<String, bool>? snapshotHabitCompletions;
      final dailyListRaw = historyBox?.get(dateStr) ??
          _myBox.get(dateStr) ??
          _myBox.get("${HabitStorage.habitListKey}_$dateStr");

      if (dailyListRaw is List && dailyListRaw.isNotEmpty) {
        snapshotHabitCompletions = {};
        for (final item in dailyListRaw) {
          if (item is HabitModel) {
            snapshotHabitCompletions[item.id] = item.isCompleted;
            snapshotHabitCompletions[item.name] = item.isCompleted;
          } else if (item is Map) {
            final id = item['id']?.toString() ?? '';
            final name = (item['name'] ?? item['habit'] ?? item['title'])?.toString() ?? '';
            final isComp = _parseNullableBool(item['isCompleted'] ?? item['completed']);
            if (isComp != null) {
              if (id.isNotEmpty) snapshotHabitCompletions[id] = isComp;
              if (name.isNotEmpty) snapshotHabitCompletions[name] = isComp;
            }
          }
        }
      }

      for (var habit in habits) {
        final idKey = "${habit.id}_$dateStr";
        final nameKey = "${habit.name}_$dateStr";

        dynamic rawVal;
        if (historyBox != null) {
          rawVal = historyBox.get(idKey) ?? historyBox.get(nameKey);
        }
        rawVal ??= _myBox.get(idKey) ?? _myBox.get(nameKey);

        bool? isCompleted = _parseNullableBool(rawVal);

        // Fallback to daily snapshot list if not found as direct key
        if (isCompleted == null && snapshotHabitCompletions != null) {
          isCompleted = snapshotHabitCompletions[habit.id] ??
              snapshotHabitCompletions[habit.name];
        }

        // Fallback for today if still not explicitly recorded
        if (isCompleted == null && i == 0) {
          isCompleted = habit.isCompleted;
        }

        if (isCompleted != null) {
          historyMap[habit.id]![normalizedDate] = isCompleted;
          historyMap[habit.name]![normalizedDate] = isCompleted;
        }
      }
    }

    return historyMap;
  }

  @override
  Future<Map<DateTime, int>> getHeatmapData() async {
    final rawHistory = await getAllHabitStrengths();
    final Map<DateTime, int> heatmapData = {};
    for (var entry in rawHistory.entries) {
      try {
        String yyyymmdd = entry.key;
        if (yyyymmdd.length > 8) {
          yyyymmdd = yyyymmdd.substring(yyyymmdd.length - 8);
        }
        if (yyyymmdd.length != 8) continue;
        final yyyy = int.parse(yyyymmdd.substring(0, 4));
        final mm = int.parse(yyyymmdd.substring(4, 6));
        final dd = int.parse(yyyymmdd.substring(6, 8));
        final date = DateTime(yyyy, mm, dd);
        final doubleStrength = double.tryParse(entry.value) ?? 0.0;
        int strength = (doubleStrength * 10).toInt();
        if (strength == 0 && doubleStrength > 0) strength = 1;
        heatmapData[date] = strength;
      } catch (_) {}
    }
    return heatmapData;
  }
}
