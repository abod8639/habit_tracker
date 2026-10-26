import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'app_database.dart';
import 'daos/habit_dao.dart';
import 'daos/habit_history_dao.dart';

/// Primary Drift SQLite Database Provider with safe in-memory fallback
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  try {
    return AppInitializer.database;
  } catch (_) {
    final db = AppDatabase(NativeDatabase.memory());
    ref.onDispose(() {
      db.close();
    });
    return db;
  }
});

/// Direct Provider for HabitDao
final habitDaoProvider = Provider<HabitDao>((ref) {
  return ref.watch(appDatabaseProvider).habitDao;
});

/// Direct Provider for HabitHistoryDao
final habitHistoryDaoProvider = Provider<HabitHistoryDao>((ref) {
  return ref.watch(appDatabaseProvider).habitHistoryDao;
});

/// Reactive StreamProvider for watching all habits with auto-managed lifecycle
final watchHabitsStreamProvider = StreamProvider<List<HabitRecord>>((ref) {
  final dao = ref.watch(habitDaoProvider);
  return dao.watchAllHabits();
});

/// Database Health Notifier using AsyncNotifier with AsyncValue representation
class DatabaseStatusNotifier extends AsyncNotifier<bool> {
  bool _isDisposed = false;

  @override
  FutureOr<bool> build() async {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });
    return _checkHealth();
  }

  Future<bool> _checkHealth() async {
    final db = ref.read(appDatabaseProvider);
    final isAlive = await db.ping();
    if (!isAlive) {
      throw const CacheFailure('Database health check failed');
    }
    return true;
  }

  /// Retries or performs on-demand database health check, mapping Either to AsyncValue
  Future<Either<Failure, bool>> checkHealth() async {
    state = const AsyncValue.loading();
    final result = await NetworkErrorHandler.guard(() async {
      final healthy = await _checkHealth();
      return healthy;
    });

    if (!_isDisposed) {
      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (healthy) {
          state = AsyncValue.data(healthy);
        },
      );
    }

    return result;
  }
}

final databaseStatusProvider =
    AsyncNotifierProvider<DatabaseStatusNotifier, bool>(
      DatabaseStatusNotifier.new,
    );
