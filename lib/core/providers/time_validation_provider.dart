import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/core/services/time_validation_service.dart';

/// State of date and time validation
class TimeValidationState {
  final bool isValidating;
  final bool isTampered;
  final String? reason;
  final DateTime? deviceTime;
  final DateTime? trustedTime;

  const TimeValidationState({
    this.isValidating = false,
    this.isTampered = false,
    this.reason,
    this.deviceTime,
    this.trustedTime,
  });

  TimeValidationState copyWith({
    bool? isValidating,
    bool? isTampered,
    String? reason,
    DateTime? deviceTime,
    DateTime? trustedTime,
  }) {
    return TimeValidationState(
      isValidating: isValidating ?? this.isValidating,
      isTampered: isTampered ?? this.isTampered,
      reason: reason ?? this.reason,
      deviceTime: deviceTime ?? this.deviceTime,
      trustedTime: trustedTime ?? this.trustedTime,
    );
  }
}

/// Service provider for TimeValidationService
final timeValidationServiceProvider = Provider<TimeValidationService>((ref) {
  final storage = ref.watch(keyValueStorageProvider);
  final db = ref.watch(appDatabaseProvider);
  return TimeValidationService(
    storage: storage,
    db: db,
  );
});

/// Riverpod notifier managing time validation state
class TimeValidationNotifier extends Notifier<TimeValidationState> {
  @override
  TimeValidationState build() {
    // Trigger full async validation asynchronously upon initialization
    Future.microtask(() => validate());

    return TimeValidationState(
      isValidating: true,
      isTampered: false,
      deviceTime: DateTime.now(),
    );
  }

  /// Re-runs the validation check and updates the state.
  Future<TimeValidationResult> validate() async {
    state = state.copyWith(isValidating: true);
    final service = ref.read(timeValidationServiceProvider);
    final result = await service.validateTime();

    state = state.copyWith(
      isValidating: false,
      isTampered: result.isTampered,
      reason: result.reason,
      deviceTime: result.deviceTime,
      trustedTime: result.trustedTime,
    );

    return result;
  }
}

final timeValidationNotifierProvider =
    NotifierProvider<TimeValidationNotifier, TimeValidationState>(
      TimeValidationNotifier.new,
    );
