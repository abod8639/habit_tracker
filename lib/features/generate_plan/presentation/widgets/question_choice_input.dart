import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/neumorphic_selection_tile.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/plan_generator_providers.dart';

class QuestionChoiceInput extends ConsumerWidget {
  final QuestionEntity question;

  const QuestionChoiceInput({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(planGeneratorNotifierProvider).value ??
        const PlanGeneratorState();
    final color = state.selectedCategory?.color ?? Colors.blue;
    final isMultiple = question.type == QuestionType.multipleChoice;

    return Column(
      children: (question.choices ?? []).map((choice) {
        final isSelected = state.isOptionSelected(question.id, choice);

        return NeumorphicSelectionTile(
          key: ValueKey('${question.id}_$choice'),
          titleText: choice,
          isSelected: isSelected,
          isMultiple: isMultiple,
          accentColor: color,
          onTap: () {
            if (isMultiple) {
              ref
                  .read(planGeneratorNotifierProvider.notifier)
                  .toggleMultipleChoiceOption(question.id, choice);
            } else {
              ref
                  .read(planGeneratorNotifierProvider.notifier)
                  .setAnswer(question.id, choice);
            }
          },
        );
      }).toList(),
    );
  }
}
