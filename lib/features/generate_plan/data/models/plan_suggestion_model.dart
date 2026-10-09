import '../../domain/entities/plan_suggestion.dart';

class PlanSuggestionModel extends PlanSuggestion {
  PlanSuggestionModel({
    required super.name,
    required super.description,
    required super.frequency,
    required super.category,
    super.isSelected = true,
  });

  factory PlanSuggestionModel.fromJson(Map<String, dynamic> json) {
    return PlanSuggestionModel(
      name: (json['name'] as String?)?.trim() ?? 'Unnamed Habit',
      description: (json['description'] as String?)?.trim() ?? '',
      frequency: (json['frequency'] as String?)?.trim() ?? 'daily',
      category: (json['category'] as String?)?.trim() ?? '',
      isSelected: json['isSelected'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'frequency': frequency,
      'category': category,
      'isSelected': isSelected,
    };
  }

  factory PlanSuggestionModel.fromEntity(PlanSuggestion entity) {
    return PlanSuggestionModel(
      name: entity.name,
      description: entity.description,
      frequency: entity.frequency,
      category: entity.category,
      isSelected: entity.isSelected,
    );
  }
}
