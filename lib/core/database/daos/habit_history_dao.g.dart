// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_history_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $HabitCompletionsTable get habitCompletions =>
      attachedDatabase.habitCompletions;
  $AppMetadataTable get appMetadata => attachedDatabase.appMetadata;
  HabitHistoryDaoManager get managers => HabitHistoryDaoManager(this);
}

class HabitHistoryDaoManager {
  final _$HabitHistoryDaoMixin _db;
  HabitHistoryDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.habitCompletions,
      );
  $$AppMetadataTableTableManager get appMetadata =>
      $$AppMetadataTableTableManager(_db.attachedDatabase, _db.appMetadata);
}
