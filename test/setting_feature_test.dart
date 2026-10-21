import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/setting/data/models/setting_model.dart';
import 'package:habit_tracker/features/setting/domain/entities/app_update_info.dart';
import 'package:habit_tracker/features/setting/domain/entities/setting_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingModel Safe Parsing Tests', () {
    test('handles completely null or empty map gracefully', () {
      final model = SettingModel.fromJson(null);
      expect(model.languageCode, SettingEntity.defaultLanguage);
      expect(model.isNotificationEnabled, isFalse);
      expect(model.notificationTime, isNull);
    });

    test('handles malformed notification time formats without crashing', () {
      final malformedCases = [
        {'notificationTime': 'invalid_string'},
        {'notificationTime': '99:99'},
        {'notificationTime': '12'},
        {'notificationTime': 12345},
        {'notificationTime': null},
      ];

      for (final map in malformedCases) {
        final model = SettingModel.fromJson(map);
        expect(model.notificationTime, isNull);
      }
    });

    test('parses valid notification time format accurately', () {
      final map = {
        'languageCode': 'ar',
        'isNotificationEnabled': true,
        'notificationTime': '21:45',
      };

      final model = SettingModel.fromJson(map);
      expect(model.languageCode, 'ar');
      expect(model.isNotificationEnabled, isTrue);
      expect(model.notificationTime, const TimeOfDay(hour: 21, minute: 45));
    });

    test('converts cleanly to JSON string and parses back', () {
      const original = SettingModel(
        languageCode: 'en',
        isNotificationEnabled: true,
        notificationTime: TimeOfDay(hour: 8, minute: 30),
      );

      final jsonStr = original.toJsonString();
      final restored = SettingModel.fromJsonString(jsonStr);

      expect(restored.languageCode, 'en');
      expect(restored.isNotificationEnabled, isTrue);
      expect(restored.notificationTime, const TimeOfDay(hour: 8, minute: 30));
    });

    test('tryParseJson returns null on corrupted string without throwing', () {
      final result = SettingModel.tryParseJson('bad json {');
      expect(result, isNull);
    });
  });

  group('AppUpdateInfo Entity Tests', () {
    test('creates safe empty fallback instance', () {
      final empty = AppUpdateInfo.empty(currentVersion: '1.2.0');
      expect(empty.hasUpdate, isFalse);
      expect(empty.currentVersion, '1.2.0');
      expect(empty.latestVersion, '1.2.0');
      expect(empty.downloadUrl, isEmpty);
    });

    test('copyWith updates state immutably', () {
      final info = AppUpdateInfo.empty().copyWith(
        hasUpdate: true,
        latestVersion: '2.0.0',
        downloadUrl: 'https://example.com/app.apk',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, '2.0.0');
      expect(info.downloadUrl, 'https://example.com/app.apk');
    });
  });
}
