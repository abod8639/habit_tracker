import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/neumorphic_selection_tile.dart';
import '../../domain/entities/question_entity.dart';
import '../controllers/plan_generator_controller.dart';

class QuestionChoiceInput extends StatelessWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const QuestionChoiceInput({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final color = controller.selectedCategory.value?.color ?? Colors.blue;
    final isMultiple = question.type == QuestionType.multipleChoice;

    return Obx(
      () => Column(
        children: (question.choices ?? []).map((choice) {
          final isSelected = controller.isOptionSelected(question.id, choice);

          return NeumorphicSelectionTile(
            key: ValueKey('${question.id}_$choice'),
            titleText: choice,
            isSelected: isSelected,
            isMultiple: isMultiple,
            accentColor: color,
            onTap: () {
              if (isMultiple) {
                controller.toggleMultipleChoiceOption(question.id, choice);
              } else {
                controller.setAnswer(question.id, choice);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
