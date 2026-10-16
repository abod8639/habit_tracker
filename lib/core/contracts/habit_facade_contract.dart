import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight Data Transfer Object representing habit summary data across features.
class HabitSummaryDto {
  final String id;
  final String name;
  final bool isCompleted;
  final Color color;

  const HabitSummaryDto({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.color,
  });
}

/// DTO providing high-level aggregated context for AI chat and statistics.
class HabitContextDto {
  final List<HabitSummaryDto> habits;
  final int streak;
  final int bestStreak;
  final String? startDay;
  final Map<DateTime, int> heatmap;

  const HabitContextDto({
    required this.habits,
    required this.streak,
    required this.bestStreak,
    this.startDay,
    this.heatmap = const {},
  });
}

/// Abstract boundary interface isolating habit operations from external feature dependencies.
abstract class IHabitFacade {
  /// Fetches an isolated summary of all current habits.
  Future<List<HabitSummaryDto>> getHabitsSummary();

  /// Fetches context required for external consumers (e.g., AI assistant).
  Future<HabitContextDto> getHabitContext();

  /// Adds a batch of habits generated externally (e.g., from Plan Generator).
  Future<void> addHabits(List<String> names, {List<Color>? colors});

  /// Retrieves list of existing habit names for deduplication.
  Future<List<String>> getExistingHabitNames();
}

/// Factory function signature for creating [IHabitFacade].
typedef HabitFacadeFactory = IHabitFacade Function(Ref ref);

HabitFacadeFactory? _habitFacadeFactory;

/// Registers the concrete factory for [IHabitFacade] (Inversion of Control).
void registerHabitFacadeFactory(HabitFacadeFactory factory) {
  _habitFacadeFactory = factory;
}

/// Global provider for the habit boundary facade.
final habitFacadeProvider = Provider<IHabitFacade>((ref) {
  final factory = _habitFacadeFactory;
  if (factory != null) {
    return factory(ref);
  }
  throw UnimplementedError('IHabitFacade has not been registered. Ensure home feature is loaded.');
});
