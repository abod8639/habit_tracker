import 'package:habit_tracker/features/home/data/models/habit_model.dart';

/// Data structure representing a full persistent offline snapshot of user habits,
/// strengths, history, and metadata. Saved in the offline vault to prevent data loss.
class HabitVaultData {
  final String userId;
  final List<HabitModel> habits;
  final Map<String, String> habitStrengths;
  final String startDay;
  final int dayCount;
  final String? lastResetDate;
  final List<String> tombstones;
  final DateTime backedUpAt;
  final bool isSynced;

  const HabitVaultData({
    required this.userId,
    required this.habits,
    required this.habitStrengths,
    required this.startDay,
    required this.dayCount,
    this.lastResetDate,
    required this.tombstones,
    required this.backedUpAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'habits': habits.map((h) => h.toMap()).toList(),
      'habitStrengths': habitStrengths,
      'startDay': startDay,
      'dayCount': dayCount,
      'lastResetDate': lastResetDate,
      'tombstones': tombstones,
      'backedUpAt': backedUpAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory HabitVaultData.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return HabitVaultData(
        userId: '',
        habits: const [],
        habitStrengths: const {},
        startDay: '',
        dayCount: 1,
        tombstones: const [],
        backedUpAt: DateTime.now(),
        isSynced: false,
      );
    }

    final rawHabits = map['habits'] as List? ?? [];
    final List<HabitModel> parsedHabits = [];
    for (var item in rawHabits) {
      if (item is HabitModel) {
        parsedHabits.add(item);
      } else if (item is Map) {
        parsedHabits.add(HabitModel.fromMap(Map<String, dynamic>.from(item)));
      } else if (item is List) {
        parsedHabits.add(HabitModel.fromLocalFormat(item));
      }
    }

    final rawStrengths = map['habitStrengths'] as Map? ?? {};
    final Map<String, String> parsedStrengths = {};
    for (var e in rawStrengths.entries) {
      parsedStrengths[e.key.toString()] = e.value.toString();
    }

    final rawTombstones = map['tombstones'] as List? ?? [];
    final tombstones = rawTombstones.map((e) => e.toString()).toList();

    int parseDayCount(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 1;
      return 1;
    }

    return HabitVaultData(
      userId: map['userId']?.toString() ?? '',
      habits: parsedHabits,
      habitStrengths: parsedStrengths,
      startDay: map['startDay']?.toString() ?? '',
      dayCount: parseDayCount(map['dayCount']),
      lastResetDate: map['lastResetDate']?.toString(),
      tombstones: tombstones,
      backedUpAt: map['backedUpAt'] != null
          ? DateTime.tryParse(map['backedUpAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSynced: map['isSynced'] == true,
    );
  }
}
