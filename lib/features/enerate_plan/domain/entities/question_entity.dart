enum QuestionType {
  text,
  number,
  singleChoice,
  multipleChoice,
}

class QuestionEntity {
  final String id;
  final String text;
  final String? subtitle;
  final QuestionType type;
  final List<String>? choices;
  final String? hint;
  final String? unit; // e.g., "kg", "cm", "years"
  final bool isRequired;

  const QuestionEntity({
    required this.id,
    required this.text,
    this.subtitle,
    required this.type,
    this.choices,
    this.hint,
    this.unit,
    this.isRequired = true,
  });

  /// Human-readable label for prompt construction
  String get label => id.replaceAll('_', ' ');

  bool get isNumeric => type == QuestionType.number;
  bool get isChoice =>
      type == QuestionType.singleChoice || type == QuestionType.multipleChoice;
}
