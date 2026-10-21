import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/theme/data/models/theme_model.dart';
import 'package:habit_tracker/features/theme/domain/entities/theme_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModel Safe Parsing Tests', () {
    test('handles null json gracefully by returning empty model', () {
      final model = ThemeModel.fromJson(null);
      expect(model.themeName, ThemeEntity.defaultTheme);
      expect(model.themeMode, ThemeMode.dark);
      expect(model.useCustomBackground, isFalse);
      expect(model.customBackgroundColor, isNull);
    });

    test('handles corrupted and edge case types without throwing', () {
      final malformedMap = {
        'themeName': null,
        'themeMode': 'invalid_mode_string',
        'useCustomBg': 'not_a_bool',
        'customBgColor': 'invalid_color_hex',
      };

      final model = ThemeModel.fromJson(malformedMap);
      expect(model.themeName, ThemeEntity.defaultTheme);
      expect(model.themeMode, ThemeMode.system);
      expect(model.useCustomBackground, isFalse);
      expect(model.customBackgroundColor, isNull);
    });

    test('parses numeric and string boolean flags correctly', () {
      final model1 = ThemeModel.fromJson({'useCustomBg': 1});
      expect(model1.useCustomBackground, isTrue);

      final model2 = ThemeModel.fromJson({'useCustomBg': 'true'});
      expect(model2.useCustomBackground, isTrue);

      final model3 = ThemeModel.fromJson({'useCustomBg': 0});
      expect(model3.useCustomBackground, isFalse);
    });

    test('parses hex string and int colors correctly', () {
      final modelHex = ThemeModel.fromJson({
        'customBgColor': '#FF00FF',
      });
      expect(modelHex.customBackgroundColor?.toARGB32(), const Color(0xFFFF00FF).toARGB32());

      final modelInt = ThemeModel.fromJson({
        'customBgColor': 0xFF123456,
      });
      expect(modelInt.customBackgroundColor?.toARGB32(), const Color(0xFF123456).toARGB32());
    });

    test('round-trips toJsonString and fromJsonString', () {
      const original = ThemeModel(
        themeName: 'dracula',
        themeMode: ThemeMode.light,
        useCustomBackground: true,
        customBackgroundColor: Color(0xFF282A36),
      );

      final jsonStr = original.toJsonString();
      final restored = ThemeModel.fromJsonString(jsonStr);

      expect(restored.themeName, 'dracula');
      expect(restored.themeMode, ThemeMode.light);
      expect(restored.useCustomBackground, isTrue);
      expect(
        restored.customBackgroundColor?.toARGB32(),
        const Color(0xFF282A36).toARGB32(),
      );
    });

    test('tryParseJson safely returns null for corrupted JSON strings', () {
      expect(ThemeModel.tryParseJson(''), isNull);
      expect(ThemeModel.tryParseJson(null), isNull);
      expect(ThemeModel.tryParseJson('{corrupted json'), isNull);
    });
  });

  group('ThemeEntity Immutability and Fallback Tests', () {
    test('creates empty entity with correct defaults', () {
      final empty = ThemeEntity.empty();
      expect(empty.themeName, ThemeEntity.defaultTheme);
      expect(empty.themeMode, ThemeMode.dark);
      expect(empty.useCustomBackground, isFalse);
      expect(empty.customBackgroundColor, isNull);
    });

    test('copyWith produces updated immutable instance', () {
      final original = ThemeEntity.empty();
      final updated = original.copyWith(
        themeName: 'nord',
        themeMode: ThemeMode.light,
        useCustomBackground: true,
      );

      expect(updated.themeName, 'nord');
      expect(updated.themeMode, ThemeMode.light);
      expect(updated.useCustomBackground, isTrue);
      expect(original.themeName, ThemeEntity.defaultTheme);
    });

    test('equality checks value identity', () {
      final e1 = ThemeEntity.empty();
      final e2 = ThemeEntity.empty();
      expect(e1, equals(e2));
    });
  });
}
