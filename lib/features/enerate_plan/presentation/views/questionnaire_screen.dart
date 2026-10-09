import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';

import '../../domain/entities/question_entity.dart';
import '../controllers/plan_generator_controller.dart';

class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanGeneratorController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Obx(
          () => controller.isFirstQuestion
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: controller.previous,
                ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ──────────────────────────────────────────────
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedCategory.value?.displayName ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          controller.progressLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: controller.progress,
                        minHeight: 5,
                        backgroundColor: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.selectedCategory.value?.color ??
                              Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Question content ──────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final question = controller.currentQuestion;
                if (question == null) return const SizedBox.shrink();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: _QuestionContent(
                    key: ValueKey(question.id),
                    question: question,
                    controller: controller,
                  ),
                );
              }),
            ),

            // ── Next / Generate button ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : controller.next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.selectedCategory.value?.color ??
                          Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.isLastQuestion
                                ? S.current.generateMyPlan
                                : S.current.continueButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _QuestionContent extends StatelessWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const _QuestionContent({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          if (question.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              question.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],

          if (!question.isRequired) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                S.current.optional,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Input by type ─────────────────────────────────────────────
          switch (question.type) {
            QuestionType.text => _TextInput(
              question: question,
              controller: controller,
            ),
            QuestionType.number => _NumberInput(
              question: question,
              controller: controller,
            ),
            QuestionType.singleChoice => _SingleChoiceInput(
              question: question,
              controller: controller,
            ),
            QuestionType.multipleChoice => _MultipleChoiceInput(
              question: question,
              controller: controller,
            ),
          },

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Text input ────────────────────────────────────────────────────────────────

class _TextInput extends StatefulWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const _TextInput({required this.question, required this.controller});

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
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
    final theme = Theme.of(context);
    return TextField(
      controller: _textController,
      onChanged: (v) => widget.controller.setAnswer(widget.question.id, v),
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: widget.question.hint,
        hintStyle: TextStyle(color: theme.hintColor),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                widget.controller.selectedCategory.value?.color ?? Colors.blue,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      minLines: 1,
      maxLines: 3,
    );
  }
}

// ── Number input ──────────────────────────────────────────────────────────────

class _NumberInput extends StatefulWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const _NumberInput({required this.question, required this.controller});

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
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
    final theme = Theme.of(context);
    final color =
        widget.controller.selectedCategory.value?.color ?? Colors.blue;

    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            controller: _textController,
            onChanged: (v) =>
                widget.controller.setAnswer(widget.question.id, v),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            decoration: InputDecoration(
              hintText: widget.question.hint ?? '0',
              hintStyle: TextStyle(
                color: theme.hintColor.withValues(alpha: 0.2),
                fontSize: 32,
              ),
              filled: true,
              fillColor: color.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
        if (widget.question.unit != null) ...[
          const SizedBox(width: 12),
          Text(
            widget.question.unit!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.hintColor,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Single choice ─────────────────────────────────────────────────────────────

class _SingleChoiceInput extends StatelessWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const _SingleChoiceInput({required this.question, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = controller.selectedCategory.value?.color ?? Colors.blue;

    return Obx(
      () => Column(
        children: (question.choices ?? []).map((choice) {
          final selected = controller.isOptionSelected(question.id, choice);
          return GestureDetector(
            onTap: () => controller.setAnswer(question.id, choice),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.12)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : theme.dividerColor,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      choice,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? color
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? color : Colors.transparent,
                      border: Border.all(
                        color: selected ? color : theme.disabledColor,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Multiple choice ───────────────────────────────────────────────────────────

class _MultipleChoiceInput extends StatelessWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const _MultipleChoiceInput({
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = controller.selectedCategory.value?.color ?? Colors.blue;

    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: (question.choices ?? []).map((choice) {
          final selected = controller.isOptionSelected(question.id, choice);
          return GestureDetector(
            onTap: () =>
                controller.toggleMultipleChoiceOption(question.id, choice),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.12)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? color : theme.dividerColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check_rounded, size: 14, color: color),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    choice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected
                          ? color
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
