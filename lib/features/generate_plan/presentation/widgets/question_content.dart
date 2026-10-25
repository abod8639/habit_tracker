import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/plan_generator_providers.dart';
import 'package:habit_tracker/core/components/neu_surface.dart';
import 'question_choice_input.dart';
import 'question_number_input.dart';
import 'question_text_input.dart';

class QuestionContent extends ConsumerWidget {
  final QuestionEntity question;

  const QuestionContent({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final accentColor =
        ref.watch(
          planGeneratorNotifierProvider.select(
            (s) => s.value?.selectedCategory?.color,
          ),
        ) ??
        colorScheme.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Guidance Section ─────────────────────────────────────
          PageEntranceTransition(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional / Skip Header Row (if question is optional)
                if (!question.isRequired) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeuChip(
                        icon: Icons.info_outline_rounded,
                        label: S.current.optional,
                        color: theme.hintColor,
                      ),
                      NeuSurface(
                        onTap: () => ref
                            .read(planGeneratorNotifierProvider.notifier)
                            .next(),
                        borderRadius: AppRadius.pillRadius,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.current.skipNow,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: accentColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Main Question Text (Bold & Prominent)
                Text(
                  question.text,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.35,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                  ),
                ),

                // Motivational / Behavioral Subtitle Guidance Card
                if (question.subtitle != null &&
                    question.subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  NeuSurface(
                    depth: NeuDepth.inset,
                    borderRadius: AppRadius.mdRadius,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            question.subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13.5,
                              height: 1.5,
                              color: colorScheme.onSurface.withValues(
                                alpha: isDark ? 0.85 : 0.78,
                              ),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Input Interactive Section ─────────────────────────────────────
          PageEntranceTransition(
            index: 1,
            child: switch (question.type) {
              QuestionType.text => QuestionTextInput(
                question: question,
              ),
              QuestionType.number => QuestionNumberInput(
                question: question,
              ),
              QuestionType.singleChoice ||
              QuestionType.multipleChoice => QuestionChoiceInput(
                question: question,
              ),
            },
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
