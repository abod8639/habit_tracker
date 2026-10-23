import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/services/time_validation_service.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late KeyValueStorage storage;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = KeyValueStorage(db);
    await storage.init();
  });

  tearDown(() async {
    await db.close();
  });

  group('TimeValidationService Tests', () {
    test('Detects synchronous rollback when last valid timestamp is in the future', () async {
      final futureTimestamp = DateTime.now().toUtc().add(const Duration(hours: 2)).millisecondsSinceEpoch;
      await storage.setInt(TimeValidationService.keyLastValidTimestampMs, futureTimestamp);

      final service = TimeValidationService(
        storage: storage,
        db: db,
      );

      expect(service.isClockRolledBackSynchronously(), isTrue);
    });

    test('Passes synchronous check when last valid timestamp is reasonable', () async {
      final pastTimestamp = DateTime.now().toUtc().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch;
      await storage.setInt(TimeValidationService.keyLastValidTimestampMs, pastTimestamp);

      final service = TimeValidationService(
        storage: storage,
        db: db,
      );

      expect(service.isClockRolledBackSynchronously(), isFalse);
    });

    test('Detects tampering when device date is earlier than existing recorded completions', () async {
      // Record a completion with date 20991231 (in the far future relative to today)
      await db.habitHistoryDao.recordCompletion('h1', '20991231', true);

      final service = TimeValidationService(
        storage: storage,
        db: db,
      );

      final result = await service.validateTime();
      expect(result.isTampered, isTrue);
      expect(result.reason, contains('Device date is earlier than existing habit completions'));
    });

    test('Detects tampering when network time differs by more than 30 minutes', () async {
      // Mock HTTP client that returns a server time 3 hours ahead of device
      final serverUtc = DateTime.now().toUtc().add(const Duration(hours: 3));
      final rfc1123Date = HttpDate.format(serverUtc);

      final mockClient = MockClient((request) async {
        return http.Response('', 200, headers: {'date': rfc1123Date});
      });

      final service = TimeValidationService(
        storage: storage,
        db: db,
        httpClient: mockClient,
      );

      final result = await service.validateTime();
      expect(result.isTampered, isTrue);
      expect(result.reason, contains('Device clock does not match network time'));
    });

    test('Passes validation when device time matches network time within tolerance', () async {
      // Server time matches device within 1 minute
      final serverUtc = DateTime.now().toUtc();
      final rfc1123Date = HttpDate.format(serverUtc);

      final mockClient = MockClient((request) async {
        return http.Response('', 200, headers: {'date': rfc1123Date});
      });

      final service = TimeValidationService(
        storage: storage,
        db: db,
        httpClient: mockClient,
      );

      final result = await service.validateTime();
      expect(result.isTampered, isFalse);
      expect(result.trustedTime, isNotNull);
    });
  });
}
