import 'package:equatable/equatable.dart';

class HabitStatsEntity extends Equatable {
  final int totalHabits;
  final int completedHabits;
  final double completionRate;
  final int streak;
  final int bestStreak;

  const HabitStatsEntity({
    required this.totalHabits,
    required this.completedHabits,
    required this.completionRate,
    required this.streak,
    this.bestStreak = 0,
  });

  @override
  List<Object?> get props => [
    totalHabits,
    completedHabits,
    completionRate,
    streak,
    bestStreak,
  ];
}
