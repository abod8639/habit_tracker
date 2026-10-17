import 'package:drift/drift.dart';

@DataClassName('HabitCompletionRecord')
@TableIndex(name: 'idx_completions_date', columns: {#dateStr})
class HabitCompletions extends Table {
  TextColumn get habitId => text()();
  TextColumn get dateStr => text()(); // e.g. 'YYYYMMDD'
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {habitId, dateStr};
}
