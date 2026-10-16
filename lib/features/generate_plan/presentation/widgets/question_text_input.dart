import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/neumorphic_input.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/plan_generator_providers.dart';

class QuestionTextInput extends ConsumerStatefulWidget {
  final QuestionEntity question;

  const QuestionTextInput({
    super.key,
    required this.question,
  });

  @override
  ConsumerState<QuestionTextInput> createState() => _QuestionTextInputState();
}

class _QuestionTextInputState extends ConsumerState<QuestionTextInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initialAnswer = ref
        .read(planGeneratorNotifierProvider)
        .getAnswer(widget.question.id);
    _textController = TextEditingController(
      text: initialAnswer?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ref.watch(
      planGeneratorNotifierProvider.select((s) => s.selectedCategory?.color),
    );

    return NeumorphicInput(
      controller: _textController,
      onChanged: (v) => ref
          .read(planGeneratorNotifierProvider.notifier)
          .setAnswer(widget.question.id, v),
      hintText: widget.question.hint,
      accentColor: color,
      minLines: 1,
      maxLines: 3,
    );
  }
}
