import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_input.dart';
import '../../domain/entities/question_entity.dart';
import '../controllers/plan_generator_controller.dart';

class QuestionTextInput extends StatefulWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const QuestionTextInput({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<QuestionTextInput> createState() => _QuestionTextInputState();
}

class _QuestionTextInputState extends State<QuestionTextInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.getAnswer(widget.question.id)?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.controller.selectedCategory.value?.color;

    return NeumorphicInput(
      controller: _textController,
      onChanged: (v) => widget.controller.setAnswer(widget.question.id, v),
      hintText: widget.question.hint,
      accentColor: color,
      minLines: 1,
      maxLines: 3,
    );
  }
}
