import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/functions/get_smart_notification_content.dart';
import 'package:habit_tracker/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Regex to ensure no emoji characters are present in any notification strings
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
    unicode: true,
  );

  group('Smart Notification Content Tests (Arabic)', () {
    setUp(() async {
      Intl.defaultLocale = 'ar';
      await S.load(const Locale('ar'));
    });

    test('Returns no-tasks message when total habits is 0', () {
      final content = getSmartNotificationContent(
        remainingCount: 0,
        totalCount: 0,
      );

      expect(content.title, 'متتبع العادات');
      expect(
        content.body,
        'لا توجد مهام مسجلة بعد، ابدأ بإضافة عاداتك اليومية.',
      );
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns all-completed message when all habits are done', () {
      final content = getSmartNotificationContent(
        remainingCount: 0,
        totalCount: 5,
      );

      expect(content.title, 'متتبع العادات');
      expect(content.body, 'رائع جداً! لقد أكملت جميع مهامك اليوم بنجاح.');
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns singular (1 task) message in Arabic', () {
      final content = getSmartNotificationContent(
        remainingCount: 1,
        totalCount: 5,
      );

      expect(content.title, 'متتبع العادات');
      expect(content.body, 'لديك مهمة واحدة متبقية بحاجة للإنجاز اليوم.');
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns dual (2 tasks) message in Arabic', () {
      final content = getSmartNotificationContent(
        remainingCount: 2,
        totalCount: 5,
      );

      expect(content.title, 'متتبع العادات');
      expect(content.body, 'لديك مهمتان متبقيتان بحاجة للإنجاز اليوم.');
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns few plural (3-10 tasks) message in Arabic', () {
      final content3 = getSmartNotificationContent(
        remainingCount: 3,
        totalCount: 5,
      );
      expect(content3.body, 'لديك 3 مهام متبقية بحاجة للإنجاز اليوم.');
      expect(emojiRegex.hasMatch(content3.body), isFalse);

      final content7 = getSmartNotificationContent(
        remainingCount: 7,
        totalCount: 10,
      );
      expect(content7.body, 'لديك 7 مهام متبقية بحاجة للإنجاز اليوم.');
      expect(emojiRegex.hasMatch(content7.body), isFalse);
    });

    test('Returns many plural (11+ tasks) message in Arabic', () {
      final content11 = getSmartNotificationContent(
        remainingCount: 11,
        totalCount: 15,
      );
      expect(content11.body, 'لديك 11 مهمة متبقية بحاجة للإنجاز اليوم.');
      expect(emojiRegex.hasMatch(content11.body), isFalse);
    });
  });

  group('Smart Notification Content Tests (English)', () {
    setUp(() async {
      Intl.defaultLocale = 'en';
      await S.load(const Locale('en'));
    });

    test('Returns no-tasks message when total habits is 0', () {
      final content = getSmartNotificationContent(
        remainingCount: 0,
        totalCount: 0,
      );

      expect(content.title, 'Habit Tracker');
      expect(
        content.body,
        'No tasks registered yet. Start adding your daily habits today.',
      );
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns all-completed message when all habits are done', () {
      final content = getSmartNotificationContent(
        remainingCount: 0,
        totalCount: 5,
      );

      expect(content.title, 'Habit Tracker');
      expect(
        content.body,
        'Awesome! You have completed all your tasks for today.',
      );
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns singular (1 task) message in English', () {
      final content = getSmartNotificationContent(
        remainingCount: 1,
        totalCount: 4,
      );

      expect(content.title, 'Habit Tracker');
      expect(content.body, 'You have 1 task left to complete today.');
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });

    test('Returns plural (>1 tasks) message in English', () {
      final content = getSmartNotificationContent(
        remainingCount: 3,
        totalCount: 5,
      );

      expect(content.title, 'Habit Tracker');
      expect(content.body, 'You have 3 tasks left to complete today.');
      expect(emojiRegex.hasMatch(content.body), isFalse);
    });
  });
}
