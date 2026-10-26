import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_local_datasource.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_remote_datasource.dart';
import 'package:habit_tracker/features/setting/data/repositories/setting_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/repositories/setting_repository.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_all_data_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_language_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_last_sync_time_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_notification_time_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/is_notification_enabled_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_language_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/set_notification_enabled_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/set_notification_time_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/sync_habits_usecase.dart';
import 'package:habit_tracker/generated/l10n.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

enum ApiKeyStatus {
  unknown,
  validating,
  valid,
  invalid,
}

// Data Sources
final settingLocalDataSourceProvider = Provider<SettingLocalDataSource>((ref) {
  final langStorage = ref.watch(langStorageServiceProvider);
  final settingsStorage = ref.watch(settingsStorageServiceProvider);
  final themeStorage = ref.watch(themeStorageServiceProvider);
  return SettingLocalDataSourceImpl(
    langStorage: langStorage,
    settingsStorage: settingsStorage,
    themeStorage: themeStorage,
  );
});

final settingRemoteDataSourceProvider = Provider<SettingRemoteDataSource>((
  ref,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SettingRemoteDataSourceImpl(firestoreService);
});

// Repository
final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  final localDataSource = ref.watch(settingLocalDataSourceProvider);
  final remoteDataSource = ref.watch(settingRemoteDataSourceProvider);
  final habitLocalDataSource = ref.watch(habitLocalDataSourceProvider);
  return SettingRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    habitLocalDataSource: habitLocalDataSource,
  );
});

// Use Cases
final getLanguageUseCaseProvider = Provider<GetLanguageUseCase>((ref) {
  return GetLanguageUseCase(ref.watch(settingRepositoryProvider));
});

final saveLanguageUseCaseProvider = Provider<SaveLanguageUseCase>((ref) {
  return SaveLanguageUseCase(ref.watch(settingRepositoryProvider));
});

final isNotificationEnabledUseCaseProvider =
    Provider<IsNotificationEnabledUseCase>((ref) {
      return IsNotificationEnabledUseCase(ref.watch(settingRepositoryProvider));
    });

final setNotificationEnabledUseCaseProvider =
    Provider<SetNotificationEnabledUseCase>((ref) {
      return SetNotificationEnabledUseCase(
        ref.watch(settingRepositoryProvider),
      );
    });

final getNotificationTimeUseCaseProvider = Provider<GetNotificationTimeUseCase>(
  (ref) {
    return GetNotificationTimeUseCase(ref.watch(settingRepositoryProvider));
  },
);

final setNotificationTimeUseCaseProvider = Provider<SetNotificationTimeUseCase>(
  (ref) {
    return SetNotificationTimeUseCase(ref.watch(settingRepositoryProvider));
  },
);

final syncHabitsUseCaseProvider = Provider<SyncHabitsUseCase>((ref) {
  return SyncHabitsUseCase(ref.watch(settingRepositoryProvider));
});

final getLastSyncTimeUseCaseProvider = Provider<GetLastSyncTimeUseCase>((ref) {
  return GetLastSyncTimeUseCase(ref.watch(settingRepositoryProvider));
});

final clearAllDataUseCaseProvider = Provider<ClearAllDataUseCase>((ref) {
  return ClearAllDataUseCase(ref.watch(settingRepositoryProvider));
});

final getCustomApiKeyUseCaseProvider = Provider<GetCustomApiKeyUseCase>((ref) {
  return GetCustomApiKeyUseCase(ref.watch(settingRepositoryProvider));
});

final saveCustomApiKeyUseCaseProvider = Provider<SaveCustomApiKeyUseCase>((
  ref,
) {
  return SaveCustomApiKeyUseCase(ref.watch(settingRepositoryProvider));
});

final clearCustomApiKeyUseCaseProvider = Provider<ClearCustomApiKeyUseCase>((
  ref,
) {
  return ClearCustomApiKeyUseCase(ref.watch(settingRepositoryProvider));
});

// ── SYNC STATE & NOTIFIER ──────────────────────────────────────────────────
class SyncState {
  final SyncStatus syncStatus;
  final bool isAutoSyncEnabled;
  final DateTime? lastSyncTime;
  final String errorMessage;
  final Failure? activeFailure;

  const SyncState({
    this.syncStatus = SyncStatus.idle,
    this.isAutoSyncEnabled = true,
    this.lastSyncTime,
    this.errorMessage = '',
    this.activeFailure,
  });

  SyncState copyWith({
    SyncStatus? syncStatus,
    bool? isAutoSyncEnabled,
    DateTime? lastSyncTime,
    String? errorMessage,
    Failure? activeFailure,
    bool clearFailure = false,
  }) {
    return SyncState(
      syncStatus: syncStatus ?? this.syncStatus,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFailure: clearFailure ? null : (activeFailure ?? this.activeFailure),
    );
  }

  String get syncStatusMessage {
    switch (syncStatus) {
      case SyncStatus.idle:
        return lastSyncTime != null
            ? '${S.current.lastSync}: ${_formatTime(lastSyncTime!)}'
            : S.current.notSyncedYet;
      case SyncStatus.syncing:
        return S.current.syncing;
      case SyncStatus.success:
        return S.current.syncSuccess;
      case SyncStatus.error:
        return errorMessage.isNotEmpty
            ? errorMessage
            : S.current.syncFailed;
    }
  }

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return S.current.justNow;
    if (difference.inHours < 1) {
      return S.current.minutesAgo(difference.inMinutes);
    }
    if (difference.inDays < 1) {
      return S.current.hoursAgo(difference.inHours);
    }
    return S.current.daysAgo(difference.inDays);
  }
}

class SyncNotifier extends Notifier<SyncState> {
  bool _isDisposed = false;

  @override
  SyncState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });

    Future.microtask(() => loadLastSyncTime());
    return const SyncState();
  }

  Future<void> loadLastSyncTime() async {
    final getLastSync = ref.read(getLastSyncTimeUseCaseProvider);
    final result = await getLastSync();
    if (_isDisposed) return;
    result.fold(
      (_) => null,
      (time) {
        if (!_isDisposed) {
          state = state.copyWith(lastSyncTime: time);
        }
      },
    );
  }

  void toggleAutoSync(bool value) {
    state = state.copyWith(isAutoSyncEnabled: value);
  }

  Future<void> syncHabits() async {
    if (_isDisposed || state.syncStatus == SyncStatus.syncing) return;
    state = state.copyWith(
      syncStatus: SyncStatus.syncing,
      errorMessage: '',
      clearFailure: true,
    );

    final habitRepo = ref.read(habitRepositoryProvider);
    final localResult = await habitRepo.getHabits();
    if (_isDisposed) return;

    final habits = localResult.fold(
      (_) => ref.read(habitNotifierProvider).habits,
      (list) => list,
    );
    final habitsModels = habits.map((e) => HabitModel.fromEntity(e)).toList();
    final result = await manualSync(habitsModels);
    if (_isDisposed) return;

    if (result != null) {
      habitRepo.invalidateHeatmapCache();
      await ref.read(habitNotifierProvider.notifier).refreshData();
    }
  }

  Future<List<HabitModel>?> manualSync(List<HabitModel> localHabits) async {
    final firestore = ref.read(firestoreServiceProvider);
    if (!firestore.isUserLoggedIn) {
      return null;
    }

    try {
      state = state.copyWith(
        syncStatus: SyncStatus.syncing,
        errorMessage: '',
        clearFailure: true,
      );

      final habitRepo = ref.read(habitRepositoryProvider);
      final localTombstones = habitRepo.getLocalTombstones();
      final localStartDay = ref
          .read(habitNotifierProvider.notifier)
          .getStartDay();

      final syncUseCase = ref.read(syncHabitsUseCaseProvider);
      final result = await syncUseCase(
        localHabits,
        localTombstones: localTombstones,
        localStartDay: localStartDay,
      );

      if (_isDisposed) return null;

      return result.fold<List<HabitModel>?>(
        (failure) {
          if (!_isDisposed) {
            state = state.copyWith(
              syncStatus: SyncStatus.error,
              errorMessage: failure.toMessage(),
              activeFailure: failure,
            );
          }
          return null;
        },
        (mergedHabits) {
          habitRepo.clearLocalTombstones();
          habitRepo.markVaultSynced();
          final now = DateTime.now();
          if (!_isDisposed) {
            state = state.copyWith(
              syncStatus: SyncStatus.success,
              lastSyncTime: now,
              errorMessage: '',
              clearFailure: true,
            );
          }
          return mergedHabits;
        },
      );
    } catch (e, stack) {
      if (!_isDisposed) {
        final failure = NetworkErrorHandler.handle(e, stack);
        state = state.copyWith(
          syncStatus: SyncStatus.error,
          errorMessage: failure.toMessage(),
          activeFailure: failure,
        );
      }
      return null;
    }
  }

  Future<List<HabitModel>?> autoSync(List<HabitModel> localHabits) async {
    if (!state.isAutoSyncEnabled) return null;
    final firestore = ref.read(firestoreServiceProvider);
    if (!firestore.isUserLoggedIn) return null;

    try {
      state = state.copyWith(syncStatus: SyncStatus.syncing);

      final habitRepo = ref.read(habitRepositoryProvider);
      final localTombstones = habitRepo.getLocalTombstones();
      final localStartDay = ref
          .read(habitNotifierProvider.notifier)
          .getStartDay();

      final syncUseCase = ref.read(syncHabitsUseCaseProvider);
      final result = await syncUseCase(
        localHabits,
        localTombstones: localTombstones,
        localStartDay: localStartDay,
      );

      if (_isDisposed) return null;

      return result.fold<List<HabitModel>?>(
        (failure) {
          if (!_isDisposed) {
            state = state.copyWith(
              syncStatus: SyncStatus.error,
              errorMessage: failure.toMessage(),
              activeFailure: failure,
            );
          }
          return null;
        },
        (mergedHabits) {
          habitRepo.clearLocalTombstones();
          habitRepo.markVaultSynced();
          final now = DateTime.now();
          if (!_isDisposed) {
            state = state.copyWith(
              syncStatus: SyncStatus.success,
              lastSyncTime: now,
              errorMessage: '',
              clearFailure: true,
            );
          }
          return mergedHabits;
        },
      );
    } catch (e, stack) {
      if (!_isDisposed) {
        final failure = NetworkErrorHandler.handle(e, stack);
        state = state.copyWith(
          syncStatus: SyncStatus.error,
          errorMessage: failure.toMessage(),
          activeFailure: failure,
        );
      }
      return null;
    }
  }
}

final syncNotifierProvider = NotifierProvider<SyncNotifier, SyncState>(() {
  return SyncNotifier();
});

/// Exposes active sync [Failure] for floating SnackBar notifications and retry actions.
final syncFailureProvider = Provider<Failure?>((ref) {
  return ref.watch(syncNotifierProvider.select((s) => s.activeFailure));
});

// ── NOTIFICATION STATE & NOTIFIER ──────────────────────────────────────────
class NotificationState {
  final bool isNotificationEnabled;
  final TimeOfDay? notificationTime;
  final bool isBatteryOptimizationIgnored;

  const NotificationState({
    this.isNotificationEnabled = false,
    this.notificationTime,
    this.isBatteryOptimizationIgnored = true,
  });

  NotificationState copyWith({
    bool? isNotificationEnabled,
    TimeOfDay? notificationTime,
    bool? isBatteryOptimizationIgnored,
  }) {
    return NotificationState(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      isBatteryOptimizationIgnored:
          isBatteryOptimizationIgnored ?? this.isBatteryOptimizationIgnored,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  bool _isDisposed = false;

  @override
  NotificationState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });

    Future.microtask(() => _loadSettings());
    return const NotificationState();
  }

  Future<void> _loadSettings() async {
    final isEnabledUseCase = ref.read(isNotificationEnabledUseCaseProvider);
    final getTimeUseCase = ref.read(getNotificationTimeUseCaseProvider);

    final enabledResult = await isEnabledUseCase();
    final timeResult = await getTimeUseCase();

    if (_isDisposed) return;

    final isEnabled = enabledResult.getOrElse(() => false);
    final time = timeResult.getOrElse(() => null);

    state = state.copyWith(
      isNotificationEnabled: isEnabled,
      notificationTime: time,
    );

    if (isEnabled && time != null && !_isDisposed) {
      await _scheduleDailyReminder(time);
    }

    if (!_isDisposed) {
      await checkBatteryOptimization();
    }
  }

  Future<void> checkBatteryOptimization() async {
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService != null) {
      final ignored = await notificationService
          .isIgnoringBatteryOptimizations();
      if (!_isDisposed) {
        state = state.copyWith(isBatteryOptimizationIgnored: ignored);
      }
    }
  }

  Future<void> requestBatteryOptimization() async {
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService != null) {
      await notificationService.requestIgnoreBatteryOptimizations();
      if (!_isDisposed) {
        await checkBatteryOptimization();
      }
    }
  }

  Future<void> openAppSettings() async {
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService != null) {
      await notificationService.openAppSettings();
    }
  }

  Future<void> _scheduleDailyReminder(TimeOfDay time) async {
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService != null) {
      await notificationService.scheduleDailyNotification(
        id: 1001,
        title: S.current.dailyReminderTitle,
        body: S.current.dailyReminderBody,
        time: time,
      );
    }
  }

  Future<void> sendTestNotification() async {
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService != null) {
      await notificationService.showTestNotification(
        title: S.current.notificationTestTitle,
        body: S.current.notificationTestSent,
      );
    }
  }

  Future<void> toggleNotification(bool enabled) async {
    final notificationService = ref.read(notificationServiceProvider);
    if (enabled && notificationService != null) {
      await notificationService.requestPermissions(
        requestBatteryExemption: true,
      );
      if (!_isDisposed) {
        await checkBatteryOptimization();
      }
    }

    final setEnabled = ref.read(setNotificationEnabledUseCaseProvider);
    await setEnabled(enabled);
    if (_isDisposed) return;

    state = state.copyWith(isNotificationEnabled: enabled);

    if (enabled) {
      if (state.notificationTime != null && !_isDisposed) {
        await _scheduleDailyReminder(state.notificationTime!);
      }
    } else {
      if (notificationService != null) {
        await notificationService.cancelAllNotifications();
      }
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    final setTime = ref.read(setNotificationTimeUseCaseProvider);
    await setTime(time);
    if (_isDisposed) return;

    state = state.copyWith(notificationTime: time);

    if (state.isNotificationEnabled && !_isDisposed) {
      await _scheduleDailyReminder(time);
    }
  }
}

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
      return NotificationNotifier();
    });

// ── AI SETTINGS STATE & NOTIFIER ───────────────────────────────────────────
class AiSettingsState {
  final String customApiKey;
  final bool isCustom;
  final bool obscureText;
  final bool isLoading;
  final bool isValidating;
  final ApiKeyStatus apiKeyStatus;
  final Failure? activeFailure;

  const AiSettingsState({
    this.customApiKey = '',
    this.isCustom = false,
    this.obscureText = true,
    this.isLoading = false,
    this.isValidating = false,
    this.apiKeyStatus = ApiKeyStatus.unknown,
    this.activeFailure,
  });

  bool get isKeyWorking => apiKeyStatus == ApiKeyStatus.valid;

  String get maskedKey {
    if (customApiKey.isEmpty) return '';
    if (customApiKey.length <= 10) return '••••••••';
    return '${customApiKey.substring(0, 6)}...${customApiKey.substring(customApiKey.length - 4)}';
  }

  AiSettingsState copyWith({
    String? customApiKey,
    bool? isCustom,
    bool? obscureText,
    bool? isLoading,
    bool? isValidating,
    ApiKeyStatus? apiKeyStatus,
    Failure? activeFailure,
    bool clearFailure = false,
  }) {
    return AiSettingsState(
      customApiKey: customApiKey ?? this.customApiKey,
      isCustom: isCustom ?? this.isCustom,
      obscureText: obscureText ?? this.obscureText,
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      apiKeyStatus: apiKeyStatus ?? this.apiKeyStatus,
      activeFailure: clearFailure ? null : (activeFailure ?? this.activeFailure),
    );
  }
}

class AiSettingsNotifier extends Notifier<AiSettingsState> {
  bool _isDisposed = false;

  @override
  AiSettingsState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });

    Future.microtask(() => loadApiKey());
    return const AiSettingsState();
  }

  Future<void> loadApiKey() async {
    final getCustomKey = ref.read(getCustomApiKeyUseCaseProvider);
    final result = await getCustomKey();
    if (_isDisposed) return;

    result.fold(
      (_) => null,
      (key) {
        if (!_isDisposed) {
          state = state.copyWith(
            customApiKey: key ?? '',
            isCustom: key?.isNotEmpty ?? false,
            apiKeyStatus: (key?.isNotEmpty ?? false)
                ? ApiKeyStatus.valid
                : ApiKeyStatus.unknown,
          );
        }
      },
    );
  }

  Future<bool> saveApiKey(String key) async {
    final sanitizedKey = key.trim();
    if (_isDisposed) return false;

    state = state.copyWith(
      isLoading: true,
      isValidating: true,
      clearFailure: true,
    );

    try {
      final isValid = await GeminiService.validateApiKey(sanitizedKey).timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );

      if (_isDisposed) return false;

      if (!isValid) {
        state = state.copyWith(
          isLoading: false,
          isValidating: false,
          apiKeyStatus: ApiKeyStatus.invalid,
          activeFailure: const ServerFailure('Invalid Gemini API Key'),
        );
        return false;
      }

      final saveKey = ref.read(saveCustomApiKeyUseCaseProvider);
      final result = await saveKey(sanitizedKey);
      if (_isDisposed) return false;

      final savedSuccessfully = result.fold<bool>(
        (failure) {
          if (!_isDisposed) {
            state = state.copyWith(
              isLoading: false,
              isValidating: false,
              apiKeyStatus: ApiKeyStatus.invalid,
              activeFailure: failure,
            );
          }
          return false;
        },
        (_) {
          GeminiService.resetModelInstance();
          if (!_isDisposed) {
            state = state.copyWith(
              customApiKey: sanitizedKey,
              isCustom: true,
              isLoading: false,
              isValidating: false,
              apiKeyStatus: ApiKeyStatus.valid,
              clearFailure: true,
            );
          }
          return true;
        },
      );
      return savedSuccessfully;
    } catch (e, stack) {
      if (!_isDisposed) {
        final failure = NetworkErrorHandler.handle(e, stack);
        state = state.copyWith(
          isLoading: false,
          isValidating: false,
          apiKeyStatus: ApiKeyStatus.invalid,
          activeFailure: failure,
        );
      }
      return false;
    }
  }

  Future<void> clearApiKey() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true, clearFailure: true);

    final clearKey = ref.read(clearCustomApiKeyUseCaseProvider);
    await clearKey();
    GeminiService.resetModelInstance();

    if (!_isDisposed) {
      state = state.copyWith(
        customApiKey: '',
        isCustom: false,
        isLoading: false,
        apiKeyStatus: ApiKeyStatus.unknown,
        clearFailure: true,
      );
    }
  }

  void toggleObscure() {
    state = state.copyWith(obscureText: !state.obscureText);
  }
}

final aiSettingsNotifierProvider =
    NotifierProvider<AiSettingsNotifier, AiSettingsState>(() {
      return AiSettingsNotifier();
    });
