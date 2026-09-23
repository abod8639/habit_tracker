import 'package:flutter/material.dart';
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
}
