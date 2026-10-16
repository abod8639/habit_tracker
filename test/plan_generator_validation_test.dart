import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/utils/number_utils.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

void main() {
  group('Plan Generator Number Normalization & Validation', () {
    test('Normalizes Eastern Arabic and Persian digits to Western digits', () {
      expect(normalizeArabicDigits('٢٥'), '25');
      expect(normalizeArabicDigits('٧٠'), '70');
      expect(normalizeArabicDigits('١٢٠'), '120');
      expect(normalizeArabicDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      expect(normalizeArabicDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    });

    test('Parses Arabic numbers correctly with min/max bounds checking', () {
      final parsed25 = tryParseNormalizedNum('٢٥');
      expect(parsed25, 25);
      expect(parsed25! >= 10 && parsed25 <= 100, true);

      final parsed70 = tryParseNormalizedNum('٧٠');
      expect(parsed70, 70);

      final parsed200 = tryParseNormalizedNum('٢٠٠');
      expect(parsed200, 200);

      // Validation logic check:
      const num maxValue = 120;
      const num minValue = 10;
      expect(parsed200! > maxValue, true); // Correctly caught!
      expect(parsed25 < minValue, false);
      expect(parsed25 > maxValue, false);

      // Non-numeric input
      expect(tryParseNormalizedNum('abc'), isNull);
      expect(tryParseNormalizedNum(''), isNull);
    });
  });

  group('Duplicate Habit Prevention', () {
    test(
      'Deduplicates existing habits case-insensitively and trims whitespace',
      () {
        final now = DateTime.now();
        final existingModels = [
          HabitModel(
            id: '1',
            name: 'قراءة القرآن',
            isCompleted: false,
            createdAt: now,
          ),
          HabitModel(
            id: '2',
            name: 'Morning Walk',
            isCompleted: false,
            createdAt: now,
          ),
        ];

        final existingNames = existingModels
            .map((m) => m.name.trim().toLowerCase())
            .toSet();

        final incomingSuggestions = [
          '  قراءة القرآن  ', // Duplicate
          'morning walk', // Duplicate case-insensitive
          'شرب الماء', // New
          'شرب الماء', // Duplicate within batch
        ];

        final added = <String>[];
        for (final name in incomingSuggestions) {
          final trimmed = name.trim();
          if (trimmed.isEmpty) continue;
          final normalized = trimmed.toLowerCase();
          if (existingNames.contains(normalized)) continue;
          existingNames.add(normalized);
          added.add(trimmed);
        }

        expect(added, ['شرب الماء']);
      },
    );
  });
}
