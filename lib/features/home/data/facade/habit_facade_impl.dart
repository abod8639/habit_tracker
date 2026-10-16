import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/contracts/habit_facade_contract.dart';
import 'package:habit_tracker/core/events/app_event_bus.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';

/// Concrete implementation of [IHabitFacade] decoupling external features
/// from internal implementation details of the home module.
class HabitFacadeImpl implements IHabitFacade {
  final Ref _ref;

  HabitFacadeImpl(this._ref);

  /// Registers this implementation with the core contract registry.
  static void register() {
    registerHabitFacadeFactory((ref) => HabitFacadeImpl(ref));
  }

  @override
  Future<List<HabitSummaryDto>> getHabitsSummary() async {
    final habitState = _ref.read(habitNotifierProvider);
    return habitState.habits
        .map(
          (h) => HabitSummaryDto(
            id: h.id,
            name: h.name,
            isCompleted: h.isCompleted,
            color: Color(h.colorValue ?? 0xFF4CAF50),
          ),
        )
        .toList();
  }

  @override
  Future<HabitContextDto> getHabitContext() async {
    final habitState = _ref.read(habitNotifierProvider);
    final notifier = _ref.read(habitNotifierProvider.notifier);

    return HabitContextDto(
      habits: habitState.habits
          .map(
            (h) => HabitSummaryDto(
              id: h.id,
              name: h.name,
              isCompleted: h.isCompleted,
              color: Color(h.colorValue ?? 0xFF4CAF50),
            ),
          )
          .toList(),
      streak: habitState.streak,
      bestStreak: habitState.bestStreak,
      startDay: notifier.getStartDay(),
      heatmap: habitState.heatmapDateSet,
    );
  }

  @override
  Future<void> addHabits(List<String> names, {List<Color>? colors}) async {
    final notifier = _ref.read(habitNotifierProvider.notifier);
    await notifier.addMultipleHabits(names);

    // Fire decoupled asynchronous event
    final eventBus = _ref.read(appEventBusProvider);
    eventBus.fire(HabitsBatchCreatedEvent(habitNames: names));
  }

  @override
  Future<List<String>> getExistingHabitNames() async {
    final habitState = _ref.read(habitNotifierProvider);
    return habitState.habits.map((h) => h.name).toList();
  }
}

/// Feature provider wiring the concrete [HabitFacadeImpl] into [habitFacadeProvider].
final habitFacadeImplementationProvider = Provider<IHabitFacade>((ref) {
  return HabitFacadeImpl(ref);
});
