import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/entities/question_entity.dart';
import '../controllers/plan_generator_controller.dart';
import 'question_choice_input.dart';
import 'question_number_input.dart';
import 'question_text_input.dart';

class QuestionContent extends StatelessWidget {
  final QuestionEntity question;
  final PlanGeneratorController controller;

  const QuestionContent({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),

          if (question.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              question.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: theme.hintColor,
                height: 1.4,
              ),
            ),
          ],

          if (!question.isRequired) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: AppRadius.smRadius,
                boxShadow: AppShadows.badge(isDark: isDark),
              ),
              child: Text(
                S.current.optional,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Input by type ─────────────────────────────────────────────
          switch (question.type) {
            QuestionType.text => QuestionTextInput(
                question: question,
                controller: controller,
              ),
            QuestionType.number => QuestionNumberInput(
                question: question,
                controller: controller,
              ),
            QuestionType.singleChoice || QuestionType.multipleChoice =>
              QuestionChoiceInput(
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
