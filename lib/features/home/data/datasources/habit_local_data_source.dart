import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:hive/hive.dart';

class HabitLocalDataSource {
  final Box _myBox;

  HabitLocalDataSource(this._myBox);

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

  List<HabitModel> loadHabits() {
    if (_myBox.get(HabitStorage.habitListKey) != null) {
      final data = _myBox.get(HabitStorage.habitListKey);
      if (data is List && data.isNotEmpty && data.first is List) {
        return data.map((item) => HabitModel.fromLocalFormat(item)).toList();
      } else if (data is List) {
        return data.cast<HabitModel>();
      }
    }
    return [];
  }

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
    final historyBox = await _openMonthlyBox(dateStr);
    final data = historyBox.get(dateStr);
    
    if (data != null && data is List) {
      if (data.isNotEmpty && data.first is List) {
        return data.map((item) => HabitModel.fromLocalFormat(item)).toList();
      } else {
        return data.cast<HabitModel>();
      }
    }
    return [];
  }

  Future<void> saveHabitCompletionHistory(String habitName, bool isCompleted) async {
    final String today = todaysDateFormatted();
    final historyBox = await _openMonthlyBox(today);
    final String historyKey = "${habitName}_$today";
    await historyBox.put(historyKey, isCompleted);
  }

  void setStartDate() {
    _myBox.put(HabitStorage.startDayKey, todaysDateFormatted());
  }

  String getStartDate() {
    return _myBox.get(
      HabitStorage.startDayKey,
      defaultValue: todaysDateFormatted(),
    );
  }

  void updateStartDate(String date) {
    _myBox.put(HabitStorage.startDayKey, date);
  }

  Future<void> saveHabitStrength(String date, String strength) async {
    final historyBox = await _openMonthlyBox(date);
    final dateKey = "${HabitStorage.habitStrengthPrefix}$date";
    await historyBox.put(dateKey, strength);
  }

  Future<String?> getHabitStrength(String yyyymmdd) async {
    final historyBox = await _openMonthlyBox(yyyymmdd);
    return historyBox.get("${HabitStorage.habitStrengthPrefix}$yyyymmdd") as String?;
  }

  Future<Map<String, String>> getAllHabitStrengths() async {
    final Map<String, String> allHistory = {};
    
    // We need to iterate through all months since start date
    final startDateStr = getStartDate();
    final startDate = createDateTimeObject(startDateStr);
    final now = DateTime.now();
    
    var current = DateTime(startDate.year, startDate.month);
    while (current.isBefore(now) || (current.year == now.year && current.month == now.month)) {
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
          String date = key.toString().replaceFirst(HabitStorage.habitStrengthPrefix, '');
          if (date.startsWith('_')) {
            date = date.substring(1);
          }
          final strength = historyBox.get(key).toString();
          allHistory[date] = strength;
        }
      }
      
      // Move to next month
      current = DateTime(current.year, current.month + 1);
    }
    
    return allHistory;
  }

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

  List<String> getLocalTombstones() {
    final data = _myBox.get('local_tombstones');
    if (data is List) {
      return data.cast<String>();
    }
    return [];
  }

  void addLocalTombstone(String id) {
    final tombstones = getLocalTombstones();
    if (!tombstones.contains(id)) {
      tombstones.add(id);
      _myBox.put('local_tombstones', tombstones);
    }
  }

  void clearLocalTombstones() {
    _myBox.delete('local_tombstones');
  }

  Future<void> clearAllData() async {
    // 1. Iterate and clear monthly history boxes
    final startDateStr = getStartDate();
    final startDate = createDateTimeObject(startDateStr);
    final now = DateTime.now();
    
    var current = DateTime(startDate.year, startDate.month);
    while (current.isBefore(now) || (current.year == now.year && current.month == now.month)) {
      final monthStr = convertDateTimeToString(current).substring(0, 6);
      final boxName = "${HabitStorage.boxName}_history_$monthStr";
      
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else {
        final box = await Hive.openBox(boxName);
        await box.clear();
      }
      
      // Move to next month
      current = DateTime(current.year, current.month + 1);
    }
    
    // 2. Clear main habit box
    await _myBox.clear();
  }

  Future<DateTime?> getLastResetDate() async {
    final String? dateStr = _myBox.get(HabitStorage.lastResetDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  Future<void> saveLastResetDate(DateTime date) async {
    await _myBox.put(HabitStorage.lastResetDateKey, date.toIso8601String());
  }

  Future<void> incrementDayCount([int amount = 1]) async {
    int currentCount = _myBox.get(HabitStorage.dayCountKey) ?? 1;
    await _myBox.put(HabitStorage.dayCountKey, currentCount + amount);
  }

  Future<void> saveHabitCompletionToHistory(String habitIdOrName, bool isCompleted, DateTime date, {String? habitName}) async {
    final dateStr = convertDateTimeToString(date);
    final historyBox = await _openMonthlyBox(dateStr);
    await historyBox.put("${habitIdOrName}_$dateStr", isCompleted);
    if (habitName != null && habitName != habitIdOrName) {
      await historyBox.put("${habitName}_$dateStr", isCompleted);
    }
  }

  Future<Map<String, Map<DateTime, bool>>> getHabitHistoryMap(int days) async {
    final Map<String, Map<DateTime, bool>> historyMap = {};
    final now = DateTime.now();
    final habits = loadHabits();
    
    // Create map for each habit keyed by name for display compatibility
    for (var habit in habits) {
      historyMap[habit.name] = {};
    }

    // Iterate backwards N days
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = convertDateTimeToString(date);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      final historyBox = await _openMonthlyBox(dateStr);
      
      for (var habit in habits) {
        final idKey = "${habit.id}_$dateStr";
        final nameKey = "${habit.name}_$dateStr";
        final bool? isCompleted = historyBox.get(idKey) ?? historyBox.get(nameKey);
        
        if (isCompleted != null) {
          historyMap[habit.name]![normalizedDate] = isCompleted;
        }
      }
    }
    
    return historyMap;
  }
}
