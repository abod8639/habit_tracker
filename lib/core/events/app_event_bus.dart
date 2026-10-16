import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for all cross-feature decoupled events.
abstract class AppEvent {
  final DateTime timestamp;
  AppEvent() : timestamp = DateTime.now();
}

/// Event dispatched when a habit is added or created.
class HabitCreatedEvent extends AppEvent {
  final String habitId;
  final String habitName;
  HabitCreatedEvent({required this.habitId, required this.habitName});
}

/// Event dispatched when multiple habits are created in batch (e.g. from Plan Generator).
class HabitsBatchCreatedEvent extends AppEvent {
  final List<String> habitNames;
  HabitsBatchCreatedEvent({required this.habitNames});
}

/// Event dispatched when a habit is toggled (completed/uncompleted).
class HabitToggledEvent extends AppEvent {
  final String habitId;
  final bool isCompleted;
  final DateTime date;
  HabitToggledEvent({
    required this.habitId,
    required this.isCompleted,
    required this.date,
  });
}

/// Event dispatched when a habit is modified (name, color, order).
class HabitUpdatedEvent extends AppEvent {
  final String habitId;
  final String? newName;
  HabitUpdatedEvent({required this.habitId, this.newName});
}

/// Event dispatched when a habit is removed.
class HabitDeletedEvent extends AppEvent {
  final String habitId;
  HabitDeletedEvent({required this.habitId});
}

/// Event dispatched when cloud/local sync is requested.
class HabitsSyncRequestedEvent extends AppEvent {}

/// Decoupled, asynchronous event broker enabling features to interact
/// in an isolated, non-blocking manner without direct compile-time coupling.
class AppEventBus {
  final StreamController<AppEvent> _controller;

  AppEventBus({bool sync = false})
    : _controller = StreamController<AppEvent>.broadcast(sync: sync);

  /// Dispatches an event to all interested subscribers asynchronously.
  void fire(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Listens to events of type [T].
  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Disposes of the underlying event stream controller.
  void dispose() {
    _controller.close();
  }
}

/// Global provider for the application event bus.
final appEventBusProvider = Provider<AppEventBus>((ref) {
  final bus = AppEventBus();
  ref.onDispose(() => bus.dispose());
  return bus;
});
