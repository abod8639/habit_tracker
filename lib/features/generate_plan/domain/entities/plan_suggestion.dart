import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HabitTier {
  ignition,
  mastery,
  recovery;

  String get label {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');
    switch (this) {
      case HabitTier.ignition:
        return isArabic ? 'انطلاق (2-دقيقة)' : 'Ignition (2-min)';
      case HabitTier.mastery:
        return isArabic ? 'عادة تمكن' : 'Mastery Habit';
      case HabitTier.recovery:
        return isArabic ? 'حماية وتعافي' : 'Shield & Recovery';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitTier.ignition:
        return Icons.bolt_rounded;
      case HabitTier.mastery:
        return Icons.military_tech_rounded;
      case HabitTier.recovery:
        return Icons.shield_rounded;
    }
  }

  Color get color {
    switch (this) {
      case HabitTier.ignition:
        return const Color(0xFFF59E0B);
      case HabitTier.mastery:
        return const Color(0xFF3B82F6);
      case HabitTier.recovery:
        return const Color(0xFF10B981);
    }
  }

  static HabitTier fromString(
    String? value, {
    HabitTier fallback = HabitTier.mastery,
  }) {
    if (value == null) return fallback;
    final val = value.toLowerCase().trim();
    if (val.contains('ignition') ||
        val.contains('2-min') ||
        val.contains('انطلاق')) {
      return HabitTier.ignition;
    }
    if (val.contains('recovery') ||
        val.contains('shield') ||
        val.contains('حماية') ||
        val.contains('تعافي') ||
        val.contains('reflection')) {
      return HabitTier.recovery;
    }
    return HabitTier.mastery;
  }
}

class PlanSuggestion {
  final String name;
  final String description;
  final String frequency;
  final String category;
  final HabitTier tier;

  /// Why this habit fits this specific user, tied to one of their answers
  /// (Octalysis CD3: transparent feedback on how their choices shaped the plan).
  final String personalReason;

  /// What the habit grows into once it feels automatic (CD2: visible mastery path).
  final String levelUp;

  /// Realistic daily time cost; lets the user judge the plan's load (CD8 without anxiety).
  final int dailyMinutes;
  bool isSelected;

  PlanSuggestion({
    required this.name,
    required this.description,
    required this.frequency,
    required this.category,
    this.tier = HabitTier.mastery,
    this.personalReason = '',
    this.levelUp = '',
    this.dailyMinutes = 0,
    this.isSelected = true,
  });

  factory PlanSuggestion.fromJson(Map<String, dynamic> json) {
    return PlanSuggestion(
      name: _parseString(json['name'], fallback: 'Unnamed Habit'),
      description: _parseString(json['description'], fallback: ''),
      frequency: _parseString(json['frequency'], fallback: 'daily'),
      category: _parseString(json['category'], fallback: ''),
      tier: HabitTier.fromString(json['tier']?.toString()),
      personalReason: _parseString(json['personalReason'], fallback: ''),
      levelUp: _parseString(json['levelUp'], fallback: ''),
      dailyMinutes: parseMinutes(json['dailyMinutes']),
    );
  }

  /// Clamps AI-provided minutes into a sane 1–120 range; 0 means unknown.
  static int parseMinutes(dynamic value) {
    final parsed = value is num
        ? value.round()
        : int.tryParse('${value ?? ''}'.trim());
    if (parsed == null || parsed <= 0) return 0;
    return parsed.clamp(1, 120);
  }

  static String _parseString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    return str.isEmpty ? fallback : str;
  }

  /// Converts to the Map your existing Habit model/service expects.
  /// Adjust keys to match your HabitEntity/HabitModel fields.
  Map<String, dynamic> toHabitMap() {
    return {
      'name': name,
      'description': description,
      'frequency': frequency,
      'category': category,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
      'streak': 0,
      'completedDates': <String>[],
    };
  }

  PlanSuggestion copyWith({
    String? name,
    String? description,
    String? frequency,
    String? category,
    HabitTier? tier,
    String? personalReason,
    String? levelUp,
    int? dailyMinutes,
    bool? isSelected,
  }) {
    return PlanSuggestion(
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      personalReason: personalReason ?? this.personalReason,
      levelUp: levelUp ?? this.levelUp,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
