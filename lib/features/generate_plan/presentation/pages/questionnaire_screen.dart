import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_progress_bar.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/plan_generator_providers.dart';
import '../widgets/question_content.dart';

class QuestionnaireScreen extends ConsumerWidget {
  const QuestionnaireScreen({super.key});

  Future<void> _handleNext(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(planGeneratorNotifierProvider.notifier);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final validationError = notifier.validateCurrentAnswer(isArabic: isArabic);

    if (validationError != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentState = ref.read(planGeneratorNotifierProvider);
    if (currentState.isLastQuestion) {
      final success = await notifier.generatePlan();
      if (success && context.mounted) {
        context.push(AppRoutes.result);
      } else if (!success && context.mounted) {
        final err = ref.read(planGeneratorNotifierProvider).errorMessage;
        if (err.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      notifier.next();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planGeneratorNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySliverAppBar(
            title: state.selectedCategory?.displayName ?? '',
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.selectedCategory?.displayName ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        state.progressLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  NeumorphicProgressBar(
                    value: state.progress,
                    accentColor: state.selectedCategory?.color,
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final question = state.currentQuestion;
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
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: QuestionContent(
                        key: ValueKey(question.id),
                        question: question,
                      ),
                    );
                  },
                ),
              ),

              // ── Next / Generate action button ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: NeumorphicButton(
                  text: state.isLastQuestion
                      ? S.current.generateMyPlan
                      : S.current.continueButton,
                  icon: state.isLastQuestion
                      ? Icons.auto_awesome_rounded
                      : Icons.arrow_forward_rounded,
                  isLoading: state.isLoading,
                  accentColor: state.selectedCategory?.color,
                  onPressed: state.isLoading
                      ? null
                      : () => _handleNext(context, ref),
                  width: double.infinity,
                  height: 52,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
