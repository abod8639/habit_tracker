import '../../domain/entities/habit_stats_entity.dart';

class HabitStatsModel extends HabitStatsEntity {
  const HabitStatsModel({
    required super.totalHabits,
    required super.completedHabits,
    required super.completionRate,
    required super.streak,
    super.bestStreak = 0,
  });

  factory HabitStatsModel.fromEntity(HabitStatsEntity entity) {
    return HabitStatsModel(
      totalHabits: entity.totalHabits,
      completedHabits: entity.completedHabits,
      completionRate: entity.completionRate,
      streak: entity.streak,
      bestStreak: entity.bestStreak,
    );
  }

  factory HabitStatsModel.fromMap(Map<dynamic, dynamic> map) {
    return HabitStatsModel(
      totalHabits: _parseInt(map['totalHabits'], fallback: 0),
      completedHabits: _parseInt(map['completedHabits'], fallback: 0),
      completionRate: _parseDouble(map['completionRate'], fallback: 0.0),
      streak: _parseInt(map['streak'], fallback: 0),
      bestStreak: _parseInt(map['bestStreak'], fallback: 0),
    );
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static double _parseDouble(dynamic value, {required double fallback}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  Map<String, dynamic> toMap() {
    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completionRate': completionRate,
      'streak': streak,
      'bestStreak': bestStreak,
    };
  }
}
