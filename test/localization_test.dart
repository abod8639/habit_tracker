import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/features/categorys/data/datasources/questions_datasource.dart';
import 'package:habit_tracker/features/categorys/domain/entities/category_entity.dart';
import 'package:habit_tracker/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Parity & Switching Tests', () {
    test('S loads English strings accurately', () async {
      await S.load(const Locale('en'));

      expect(S.current.dailyReminderTitle, 'Habit Tracker');
      expect(S.current.systemLanguage, 'System Language');
      expect(S.current.categorySports, 'Sports & Fitness');
      expect(S.current.deleteSelected, 'Delete Selected');
      expect(S.current.somethingWentWrong, 'Something went wrong');
      expect(S.current.dailyReminderBody, 'Time to check your habits!');
    });

    test('S loads Arabic strings accurately', () async {
      await S.load(const Locale('ar'));

      expect(S.current.dailyReminderTitle, 'متتبع العادات');
      expect(S.current.systemLanguage, 'لغة النظام');
      expect(S.current.categorySports, 'الرياضة واللياقة');
      expect(S.current.deleteSelected, 'حذف المحدد');
      expect(S.current.somethingWentWrong, 'حدث خطأ ما');
      expect(S.current.dailyReminderBody, 'حان وقت التحقق من عاداتك اليومية!');
    });

    test(
      'PlanCategory displayName and description match active locale',
      () async {
        await S.load(const Locale('en'));
        expect(PlanCategory.sports.displayName, 'Sports & Fitness');
        expect(PlanCategory.nutrition.displayName, 'Nutrition');

        await S.load(const Locale('ar'));
        expect(PlanCategory.sports.displayName, 'الرياضة واللياقة');
        expect(PlanCategory.nutrition.displayName, 'التغذية والصحة');
      },
    );

    test(
      'QuestionsDataSource returns localized questions based on locale',
      () async {
        // Test Arabic
        Intl.defaultLocale = 'ar';
        await S.load(const Locale('ar'));

        final arQuestions = QuestionsDataSource.forCategory(
          PlanCategory.sports,
        );
        expect(arQuestions.isNotEmpty, true);
        expect(arQuestions.first.text, 'كم عمرك؟');

        // Test English
        Intl.defaultLocale = 'en';
        await S.load(const Locale('en'));

        final enQuestions = QuestionsDataSource.forCategory(
          PlanCategory.sports,
        );
        expect(enQuestions.isNotEmpty, true);
        expect(enQuestions.first.text, 'How old are you?');
      },
    );
  });
}
