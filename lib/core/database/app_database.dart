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
          // Ensure all tables and indices exist without dropping existing user history
          await m.createAll();
        }
      },
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'habit_tracker.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
