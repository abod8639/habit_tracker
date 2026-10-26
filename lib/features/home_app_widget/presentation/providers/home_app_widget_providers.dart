import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import '../../data/repositories/home_app_widget_repository_impl.dart';
import '../../domain/entities/home_app_widget_data_entity.dart';
import '../../domain/repositories/home_app_widget_repository.dart';
import '../../domain/usecases/process_home_app_widget_usecase.dart';
import '../../domain/usecases/sync_home_app_widget_usecase.dart';

/// Repository Provider for HomeAppWidget
final homeAppWidgetRepositoryProvider = Provider<HomeAppWidgetRepository>((
  ref,
) {
  final homeWidgetService = ref.watch(homeWidgetServiceProvider);
  return HomeAppWidgetRepositoryImpl(homeWidgetService: homeWidgetService);
});

/// Use Case Provider for triggering OS widget sync
final syncHomeAppWidgetUseCaseProvider = Provider<SyncHomeAppWidgetUseCase>((
  ref,
) {
  final repository = ref.watch(homeAppWidgetRepositoryProvider);
  return SyncHomeAppWidgetUseCase(repository);
});

/// Use Case Provider for background snapshot calculation
final processHomeAppWidgetUseCaseProvider =
    Provider<ProcessHomeAppWidgetUseCase>((ref) {
      final repository = ref.watch(homeAppWidgetRepositoryProvider);
      return ProcessHomeAppWidgetUseCase(repository);
    });

/// AsyncNotifier managing the Home App Widget lifecycle, data preparation,
/// and OS snapshot synchronization with full AsyncValue and cancellation handling.
class HomeAppWidgetNotifier extends AsyncNotifier<HomeAppWidgetDataEntity> {
  Timer? _debounceTimer;
  bool _isDisposed = false;

  @override
  FutureOr<HomeAppWidgetDataEntity> build() async {
    _isDisposed = false;

    ref.onDispose(() {
      _isDisposed = true;
      _debounceTimer?.cancel();
      _debounceTimer = null;
    });

    final habitState = ref.watch(habitNotifierProvider);
    final processUseCase = ref.watch(processHomeAppWidgetUseCaseProvider);

    final result = await processUseCase(
      habits: habitState.habits,
      heatmapData: habitState.heatmapDateSet,
    );

    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }

  /// Triggers a re-computation and background sync to the native widget platform.
  Future<void> syncWidget() async {
    if (_isDisposed) return;
    state = const AsyncValue.loading();

    final habitState = ref.read(habitNotifierProvider);
    final processUseCase = ref.read(processHomeAppWidgetUseCaseProvider);

    final processResult = await processUseCase(
      habits: habitState.habits,
      heatmapData: habitState.heatmapDateSet,
    );

    await processResult.fold(
      (failure) async {
        if (!_isDisposed) {
          state = AsyncValue.error(failure, StackTrace.current);
        }
      },
      (data) async {
        if (_isDisposed) return;
        state = AsyncValue.data(data);

        final syncUseCase = ref.read(syncHomeAppWidgetUseCaseProvider);
        final syncResult = await syncUseCase(
          habits: habitState.habits,
          heatmapData: habitState.heatmapDateSet,
        );

        syncResult.fold(
          (syncFailure) {
            if (!_isDisposed) {
              state = AsyncValue.error(syncFailure, StackTrace.current);
            }
          },
          (_) => null,
        );
      },
    );
  }

  /// Debounces rapid successive synchronization requests to avoid UI and thread flooding.
  void debouncedSync({Duration duration = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    if (_isDisposed) return;
    _debounceTimer = Timer(duration, () {
      if (!_isDisposed) {
        syncWidget();
      }
    });
  }

  /// Retry action when a failure occurs.
  Future<void> retry() => syncWidget();
}

/// Provider for the HomeAppWidget AsyncNotifier
final homeAppWidgetNotifierProvider =
    AsyncNotifierProvider<HomeAppWidgetNotifier, HomeAppWidgetDataEntity>(() {
      return HomeAppWidgetNotifier();
    });

/// Exposes active [Failure] from the notifier for SnackBar or banner notifications.
final homeAppWidgetFailureProvider = Provider<Failure?>((ref) {
  final asyncState = ref.watch(homeAppWidgetNotifierProvider);
  return asyncState.whenOrNull(
    error: (err, _) => err is Failure ? err : ServerFailure(err.toString()),
  );
});
