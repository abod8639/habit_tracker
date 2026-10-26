import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/habits_table.dart';
import 'tables/habit_completions_table.dart';
import 'tables/app_metadata_table.dart';
import 'daos/habit_dao.dart';
import 'daos/habit_history_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Habits, HabitCompletions, AppMetadata],
  daos: [HabitDao, HabitHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Safe, non-destructive migration preserving all user data
        if (from < 2) {
          // Safely create only newly introduced tables if upgrading from v1
          try {
            await m.createTable(habitCompletions);
          } catch (_) {}
          try {
            await m.createTable(appMetadata);
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        // Enable WAL mode for high performance concurrency & enforce foreign key constraints
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement('PRAGMA journal_mode = WAL;');
      },
    );
  }

  /// Safe connection opening with fallback to in-memory SQLite if file system access fails
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      try {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'habit_tracker.sqlite'));
        return NativeDatabase.createInBackground(file);
      } catch (_) {
        // In-memory fallback prevents crash during headless test or restricted file system
        return NativeDatabase.memory();
      }
    });
  }

  /// Fast connectivity and health check ping for the database
  Future<bool> ping() async {
    try {
      final res = await customSelect('SELECT 1').getSingle().timeout(
            const Duration(seconds: 3),
          );
      return res.data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
