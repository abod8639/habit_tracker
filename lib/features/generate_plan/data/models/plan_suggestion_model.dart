import '../../domain/entities/plan_suggestion.dart';

class PlanSuggestionModel extends PlanSuggestion {
  PlanSuggestionModel({
    required super.name,
    required super.description,
    required super.frequency,
    required super.category,
    super.tier,
    super.personalReason,
    super.levelUp,
    super.dailyMinutes,
    super.isSelected = true,
  });

  factory PlanSuggestionModel.fromJson(Map<String, dynamic> json) {
    return PlanSuggestionModel(
      name: _parseString(json['name'], fallback: 'Unnamed Habit'),
      description: _parseString(json['description'], fallback: ''),
      frequency: _parseString(json['frequency'], fallback: 'daily'),
      category: _parseString(json['category'], fallback: ''),
      tier: HabitTier.fromString(json['tier']?.toString()),
      personalReason: _parseString(json['personalReason'], fallback: ''),
      levelUp: _parseString(json['levelUp'], fallback: ''),
      dailyMinutes: PlanSuggestion.parseMinutes(json['dailyMinutes']),
      isSelected: _parseBool(json['isSelected'], fallback: true),
    );
  }

  static String _parseString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    return str.isEmpty ? fallback : str;
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'frequency': frequency,
      'category': category,
      'tier': tier.name,
      'personalReason': personalReason,
      'levelUp': levelUp,
      'dailyMinutes': dailyMinutes,
      'isSelected': isSelected,
    };
  }

  factory PlanSuggestionModel.fromEntity(PlanSuggestion entity) {
    return PlanSuggestionModel(
      name: entity.name,
      description: entity.description,
      frequency: entity.frequency,
      category: entity.category,
      tier: entity.tier,
      personalReason: entity.personalReason,
      levelUp: entity.levelUp,
      dailyMinutes: entity.dailyMinutes,
      isSelected: entity.isSelected,
    );
  }
}
