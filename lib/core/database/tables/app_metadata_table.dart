import 'package:drift/drift.dart';

@DataClassName('AppMetadataRecord')
class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
