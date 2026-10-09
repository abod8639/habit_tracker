import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_input.dart';
import '../../domain/entities/question_entity.dart';
import '../controllers/plan_generator_controller.dart';

class QuestionNumberInput extends StatefulWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const QuestionNumberInput({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<QuestionNumberInput> createState() => _QuestionNumberInputState();
}

class _QuestionNumberInputState extends State<QuestionNumberInput> {
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
      hintText: widget.question.hint ?? '0',
      unit: widget.question.unit,
      accentColor: color,
      isNumber: true,
      autofocus: true,
      textAlign: TextAlign.center,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
