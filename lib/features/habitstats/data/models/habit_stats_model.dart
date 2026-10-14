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
      totalHabits: (map['totalHabits'] as num?)?.toInt() ?? 0,
      completedHabits: (map['completedHabits'] as num?)?.toInt() ?? 0,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 0.0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
    );
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
