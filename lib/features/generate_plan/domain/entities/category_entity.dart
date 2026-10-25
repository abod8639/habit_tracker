import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/generated/l10n.dart';

enum PlanCategory {
  sports,
  nutrition,
  study,
  learning;

  String get displayName {
    switch (this) {
      case PlanCategory.sports:
        return S.current.categorySports;
      case PlanCategory.nutrition:
        return S.current.categoryNutrition;
      case PlanCategory.study:
        return S.current.categoryStudy;
      case PlanCategory.learning:
        return S.current.categoryLearning;
    }
  }

  String get description {
    switch (this) {
      case PlanCategory.sports:
        return S.current.categorySportsDesc;
      case PlanCategory.nutrition:
        return S.current.categoryNutritionDesc;
      case PlanCategory.study:
        return S.current.categoryStudyDesc;
      case PlanCategory.learning:
        return S.current.categoryLearningDesc;
    }
  }

  IconData get icon {
    switch (this) {
      case PlanCategory.sports:
        return Icons.fitness_center_rounded;
      case PlanCategory.nutrition:
        return Icons.restaurant_rounded;
      case PlanCategory.study:
        return Icons.menu_book_rounded;
      case PlanCategory.learning:
        return Icons.lightbulb_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PlanCategory.sports:
        return const Color(0xFF3B82F6);
      case PlanCategory.nutrition:
        return const Color(0xFF10B981);
      case PlanCategory.study:
        return const Color(0xFF8B5CF6);
      case PlanCategory.learning:
        return const Color(0xFFF59E0B);
    }
  }

  /// Used in AI prompt construction
  String get coachRole {
    switch (this) {
      case PlanCategory.sports:
        return 'certified personal trainer and fitness coach';
      case PlanCategory.nutrition:
        return 'registered dietitian and nutrition coach';
      case PlanCategory.study:
        return 'expert academic coach and learning strategist';
      case PlanCategory.learning:
        return 'professional skill development coach';
    }
  }

  /// Octalysis Core Drive 1: Epic Meaning & Calling (Identity Archetype)
  String get archetypeTitle {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');
    switch (this) {
      case PlanCategory.sports:
        return isArabic ? 'البطل الرياضي' : 'Peak Athlete';
      case PlanCategory.nutrition:
        return isArabic ? 'مهندس الحيوية' : 'Vitality Master';
      case PlanCategory.study:
        return isArabic ? 'العقل الباحث' : 'Scholarly Mind';
      case PlanCategory.learning:
        return isArabic ? 'المبتكر المتقن' : 'Skill Innovator';
    }
  }

  /// Octalysis Core Drive 1: Quest Tagline
  String get questTagline {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');
    switch (this) {
      case PlanCategory.sports:
        return isArabic ? 'رحلة القوة والمرونة' : 'Quest for Peak Stamina';
      case PlanCategory.nutrition:
        return isArabic ? 'رحلة الطاقة وتجديد الجسد' : 'Quest for Clean Energy';
      case PlanCategory.study:
        return isArabic
            ? 'رحلة التفوق والتركيز العميق'
            : 'Quest for Deep Focus';
      case PlanCategory.learning:
        return isArabic
            ? 'رحلة إتقان مهارات المستقبل'
            : 'Quest for High Mastery';
    }
  }

  /// Visual badge emoji for quick motivation
  String get badgeEmoji {
    switch (this) {
      case PlanCategory.sports:
        return '⚡';
      case PlanCategory.nutrition:
        return '🌱';
      case PlanCategory.study:
        return '🎯';
      case PlanCategory.learning:
        return '💡';
    }
  }
}
