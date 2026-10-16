import '../app_database.dart';

/// Legacy migration placeholder - SQLite is now the sole local database engine.
class HiveToSqlMigrator {
  final AppDatabase db;
  static const String migrationKey = 'HIVE_MIGRATION_V2_COMPLETED';

  HiveToSqlMigrator(this.db);

  Future<bool> isMigrationDone() async => true;

  Future<void> migrateIfNeeded() async {
    // Migration is already completed / SQLite is initialized directly.
  }
}
