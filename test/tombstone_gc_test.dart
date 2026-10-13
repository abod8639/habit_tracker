import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';

void main() {
  group('Tombstone Garbage Collection & Retention Tests', () {
    test('Default retention window is set to 30 days', () {
      expect(FirestoreService.tombstoneRetentionPeriod.inDays, 30);
    });

    test('Separates active tombstones from expired tombstones by cutoff date', () {
      final now = DateTime.now();
      final cutoffDate = now.subtract(FirestoreService.tombstoneRetentionPeriod);

      final recentTombstoneDate = now.subtract(const Duration(days: 5));
      final staleTombstoneDate = now.subtract(const Duration(days: 45));

      final isRecentActive = !recentTombstoneDate.isBefore(cutoffDate);
      final isStaleActive = !staleTombstoneDate.isBefore(cutoffDate);

      // Recent tombstone (5 days ago) is within active window:
      expect(isRecentActive, true);

      // Stale tombstone (45 days ago) is expired and eligible for GC:
      expect(isStaleActive, false);
    });

    test('Active tombstones filter ignores expired entries', () {
      final now = DateTime.now();
      final cutoff = now.subtract(FirestoreService.tombstoneRetentionPeriod);

      final tombstones = [
        {'id': 'h_1', 'deletedAt': now.subtract(const Duration(days: 2))},
        {'id': 'h_2', 'deletedAt': now.subtract(const Duration(days: 20))},
        {'id': 'h_3', 'deletedAt': now.subtract(const Duration(days: 60))},
        {'id': 'h_4', 'deletedAt': now.subtract(const Duration(days: 120))},
      ];

      final activeMap = {
        for (var t in tombstones)
          if (!(t['deletedAt'] as DateTime).isBefore(cutoff)) t['id'] as String: true,
      };

      expect(activeMap.containsKey('h_1'), true);
      expect(activeMap.containsKey('h_2'), true);
      expect(activeMap.containsKey('h_3'), false);
      expect(activeMap.containsKey('h_4'), false);
      expect(activeMap.length, 2);
    });
  });
}
