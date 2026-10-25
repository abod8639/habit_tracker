import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/datasources/i_habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/models/habit_vault_data.dart';

class HabitSqlLocalDataSource implements IHabitLocalDataSource {
  static const String _persistentTombstonesKey = 'PERSISTENT_HABIT_TOMBSTONES';
  final AppDatabase db;
  @override
  final HabitOfflineVaultDataSource? vaultDataSource;
  final List<String> _tombstones = [];
  String? _lastUserId;
  String _cachedStartDate = todaysDateFormatted();

  HabitSqlLocalDataSource(this.db, {this.vaultDataSource}) {
    // Initial async warm-up of memory cache
    init();
  }

  List<HabitModel> _cachedHabits = [];

  Future<void> init() async {
    await fetchHabitsFromDb();
    final startDay = await db.habitHistoryDao.getMetadata(
      HabitStorage.startDayKey,
    );
    if (startDay != null) {
      _cachedStartDate = startDay;
    }

    try {
      final storedTombstones = await db.habitHistoryDao.getMetadata(
        _persistentTombstonesKey,
      );
      if (storedTombstones != null && storedTombstones.isNotEmpty) {
        final decoded = jsonDecode(storedTombstones);
        if (decoded is List) {
          _tombstones.clear();
          _tombstones.addAll(decoded.map((e) => e.toString()));
        }
      }
    } catch (_) {}
  }

  Future<List<HabitModel>> fetchHabitsFromDb() async {
    final records = await db.habitDao.getAllHabits();
    _cachedHabits = records.map((r) => _recordToModel(r)).toList();
    return List<HabitModel>.from(_cachedHabits);
  }

  @override
  List<HabitModel> loadHabits() {
    return List<HabitModel>.from(_cachedHabits);
  }

  HabitModel _recordToModel(HabitRecord r) {
    return HabitModel(
      id: r.id,
      name: r.name,
      isCompleted: r.isCompleted,
      createdAt: r.createdAt,
      completedAt: r.completedAt,
      colorValue: r.colorValue,
      index: r.sortOrder,
      updatedAt: r.updatedAt,
    );
  }

  HabitsCompanion _modelToCompanion(HabitModel m, int sortOrder) {
    return HabitsCompanion(
      id: Value(m.id),
      name: Value(m.name),
      isCompleted: Value(m.isCompleted),
      createdAt: Value(m.createdAt),
      completedAt: Value(m.completedAt),
      colorValue: Value(m.colorValue),
      sortOrder: Value(m.index ?? sortOrder),
      updatedAt: Value(m.updatedAt ?? DateTime.now()),
    );
  }

  @override
  Future<void> saveHabits(List<HabitModel> habits) async {
    final companions = habits.asMap().entries.map((e) {
      return _modelToCompanion(e.value, e.key);
    }).toList();

    await db.habitDao.syncHabits(companions);
    _cachedHabits = List.from(habits);

    final String today = todaysDateFormatted();
    final completions = {for (var h in habits) h.id: h.isCompleted};
    await db.habitHistoryDao.recordCompletionsForDate(today, completions);
  }

  @override
  Future<void> saveHabitCompletionHistory(
    String habitId,
    bool isCompleted, {
    String? habitName,
  }) async {
    final String today = todaysDateFormatted();
    await db.habitHistoryDao.recordCompletion(habitId, today, isCompleted);
  }

  @override
  Future<void> renameHabitHistory(
    String habitId,
    String oldName,
    String newName,
  ) async {
    final habit = await db.habitDao.getHabitById(habitId);
    if (habit != null) {
      await db.habitDao.updateHabit(
        HabitsCompanion(
          id: Value(habitId),
          name: Value(newName),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await fetchHabitsFromDb();
    }
  }

  @override
  Future<void> saveHabitStrength(String dateStr, String strength) async {
    await db.habitHistoryDao.setMetadata(
      '${HabitStorage.habitStrengthPrefix}_$dateStr',
      strength,
    );
  }

  @override
  Future<Map<DateTime, int>> getHeatmapData() async {
    final heatmap = await db.habitHistoryDao.getHeatmapData();
    final metaStrengths = await db.habitHistoryDao.getAllStrengthMetadata();
    for (final entry in metaStrengths.entries) {
      final dateStr = entry.key;
      if (dateStr.length == 8) {
        try {
          final yyyy = int.parse(dateStr.substring(0, 4));
          final mm = int.parse(dateStr.substring(4, 6));
          final dd = int.parse(dateStr.substring(6, 8));
          final date = DateTime(yyyy, mm, dd);
          final rate = double.tryParse(entry.value) ?? 0.0;
          int strength = (rate * 10).toInt();
          if (strength == 0 && rate > 0) strength = 1;
          if (!heatmap.containsKey(date) || (heatmap[date] == 0 && strength > 0)) {
            heatmap[date] = strength;
          }
        } catch (_) {}
      }
    }
    return heatmap;
  }

  @override
  Future<Map<String, String>> getAllHabitStrengths() async {
    final heatmap = await getHeatmapData();
    final result = heatmap.map(
      (k, v) => MapEntry(convertDateTimeToString(k), (v / 10).toString()),
    );
    final metaStrengths = await db.habitHistoryDao.getAllStrengthMetadata();
    for (final entry in metaStrengths.entries) {
      if (!result.containsKey(entry.key)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  @override
  Future<Map<String, Map<DateTime, bool>>> getHabitHistoryMap(int days) async {
    return await db.habitHistoryDao.getHabitHistoryMap(days);
  }

  @override
  Future<Map<String, Map<String, bool>>> getAllHabitCompletions() async {
    return await db.habitHistoryDao.getAllCompletionsGroupedByDate();
  }

  @override
  Future<void> saveAllHabitCompletions(
    Map<String, Map<String, bool>> completions,
  ) async {
    await db.habitHistoryDao.saveBulkCompletions(completions);
  }

  @override
  Future<Map<String, int>> getCompletionStatusForDate(DateTime date) async {
    final dateStr = convertDateTimeToString(date);
    return await db.habitHistoryDao.getCompletionStatusForDate(dateStr);
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    final val = await db.habitHistoryDao.getMetadata(
      HabitStorage.lastResetDateKey,
    );
    return val != null ? DateTime.tryParse(val) : null;
  }

  @override
  Future<void> saveLastResetDate(DateTime date) async {
    await db.habitHistoryDao.setMetadata(
      HabitStorage.lastResetDateKey,
      date.toIso8601String(),
    );
  }

  @override
  void updateStartDate(String date) {
    _cachedStartDate = date;
    db.habitHistoryDao.setMetadata(HabitStorage.startDayKey, date);
  }

  @override
  Future<void> saveAllHabitStrengths(Map<String, String> strengths) async {
    if (strengths.isEmpty) return;
    await db.batch((b) {
      for (var entry in strengths.entries) {
        b.insert(
          db.appMetadata,
          AppMetadataCompanion(
            key: Value('${HabitStorage.habitStrengthPrefix}_${entry.key}'),
            value: Value(entry.value),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  String getStartDate() {
    return _cachedStartDate;
  }

  @override
  Future<void> incrementDayCount([int amount = 1]) async {
    final val = await db.habitHistoryDao.getMetadata(HabitStorage.dayCountKey);
    final count = int.tryParse(val ?? '1') ?? 1;
    await db.habitHistoryDao.setMetadata(
      HabitStorage.dayCountKey,
      (count + amount).toString(),
    );
  }

  @override
  Future<void> saveHabitCompletionToHistory(
    String habitIdOrName,
    bool isCompleted,
    DateTime date, {
    String? habitName,
  }) async {
    final dateStr = convertDateTimeToString(date);
    await db.habitHistoryDao.recordCompletion(
      habitIdOrName,
      dateStr,
      isCompleted,
    );
  }

  @override
  List<String> getLocalTombstones() => List.unmodifiable(_tombstones);

  @override
  void addLocalTombstones(List<String> ids) {
    _tombstones.addAll(ids);
    _persistTombstones();
  }

  @override
  void clearLocalTombstones() {
    _tombstones.clear();
    _persistTombstones();
  }

  Future<void> _persistTombstones() async {
    try {
      await db.habitHistoryDao.setMetadata(
        _persistentTombstonesKey,
        jsonEncode(_tombstones),
      );
    } catch (_) {}
  }

  @override
  String? getLastUserId() => _lastUserId;

  void setLastUserId(String? userId) {
    _lastUserId = userId;
  }

  @override
  Future<void> clearAllData({
    String? earliestDateStr,
    bool backupBeforeClear = false,
    String? userId,
  }) async {
    if (backupBeforeClear && vaultDataSource != null) {
      final uid = userId ?? _lastUserId;
      if (uid != null && uid.isNotEmpty) {
        final snapshot = await createSnapshot(userId: uid);
        await vaultDataSource!.saveBackup(snapshot);
      }
    }
    await db.habitDao.clearAllHabits();
    await db.habitHistoryDao.clearAllHistory();
    _cachedHabits.clear();
    clearLocalTombstones();
  }

  @override
  Future<HabitVaultData> createSnapshot({required String userId}) async {
    final habits = await fetchHabitsFromDb();
    final strengths = await getAllHabitStrengths();
    final lastReset = await getLastResetDate();
    final dayCountStr = await db.habitHistoryDao.getMetadata(
      HabitStorage.dayCountKey,
    );

    return HabitVaultData(
      userId: userId,
      habits: List<HabitModel>.from(habits),
      habitStrengths: Map<String, String>.from(strengths),
      startDay: getStartDate(),
      dayCount: int.tryParse(dayCountStr ?? '1') ?? 1,
      lastResetDate: lastReset?.toIso8601String(),
      tombstones: List<String>.from(getLocalTombstones()),
      backedUpAt: DateTime.now(),
      isSynced: false,
    );
  }

  @override
  Future<void> restoreFromSnapshot(HabitVaultData snapshot) async {
    await clearAllData();
    if (snapshot.habits.isNotEmpty) {
      await saveHabits(snapshot.habits);
    }
    if (snapshot.habitStrengths.isNotEmpty) {
      await saveAllHabitStrengths(snapshot.habitStrengths);
    }
    if (snapshot.startDay.isNotEmpty) {
      updateStartDate(snapshot.startDay);
    }
    await db.habitHistoryDao.setMetadata(
      HabitStorage.dayCountKey,
      snapshot.dayCount.toString(),
    );
    if (snapshot.lastResetDate != null) {
      final parsedDate = DateTime.tryParse(snapshot.lastResetDate!);
      if (parsedDate != null) {
        await saveLastResetDate(parsedDate);
      }
    }
    if (snapshot.tombstones.isNotEmpty) {
      addLocalTombstones(snapshot.tombstones);
    }
  }
}
