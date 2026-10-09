class PlanSuggestion {
  final String name;
  final String description;
  final String frequency;
  final String category;
  bool isSelected;

  PlanSuggestion({
    required this.name,
    required this.description,
    required this.frequency,
    required this.category,
    this.isSelected = true,
  });

  factory PlanSuggestion.fromJson(Map<String, dynamic> json) {
    return PlanSuggestion(
      name: (json['name'] as String?)?.trim() ?? 'Unnamed Habit',
      description: (json['description'] as String?)?.trim() ?? '',
      frequency: (json['frequency'] as String?)?.trim() ?? 'daily',
      category: (json['category'] as String?)?.trim() ?? '',
    );
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
    bool? isSelected,
  }) {
    return PlanSuggestion(
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
