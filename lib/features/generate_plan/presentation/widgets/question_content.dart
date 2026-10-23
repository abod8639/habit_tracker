import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/plan_generator_providers.dart';
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

    final accentColor = ref.watch(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppRadius.smRadius,
                          boxShadow: AppShadows.subtleCard(isDark: isDark),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              S.current.optional,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.hintColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref
                              .read(planGeneratorNotifierProvider.notifier)
                              .next(),
                          borderRadius: AppRadius.smRadius,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: AppRadius.smRadius,
                              boxShadow: AppShadows.subtleCard(isDark: isDark),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: isDark ? 0.10 : 0.06,
                      ),
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: isDark ? 0.25 : 0.18,
                        ),
                        width: 1,
                      ),
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
              QuestionType.multipleChoice =>
                QuestionChoiceInput(
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
