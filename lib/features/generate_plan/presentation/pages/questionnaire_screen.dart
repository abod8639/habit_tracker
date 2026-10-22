import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_progress_bar.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
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

    final currentState =
        ref.read(planGeneratorNotifierProvider).value ??
        const PlanGeneratorState();
    if (currentState.isLastQuestion) {
      final success = await notifier.generatePlan();
      if (success && context.mounted) {
        context.push(AppRoutes.result);
      } else if (!success && context.mounted) {
        final asyncVal = ref.read(planGeneratorNotifierProvider);
        final activeFailure = asyncVal.value?.activeFailure;
        final errorObj = asyncVal.error;
        final err =
            activeFailure?.toMessage() ??
            (errorObj is Failure
                ? errorObj.toMessage()
                : (asyncVal.value?.errorMessage.isNotEmpty == true
                    ? asyncVal.value!.errorMessage
                    : S.current.planGenerationFailed));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    err,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: S.of(context).retry,
              textColor: Colors.white,
              onPressed: () => _handleNext(context, ref),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      notifier.next();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlan = ref.watch(planGeneratorNotifierProvider);
    final theme = Theme.of(context);

    // Fallback UI if complete catastrophic failure with no state
    return asyncPlan.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (err, _) {
        final message =
            err is Failure ? err.toMessage() : S.current.planGenerationFailed;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: ErrorView(
            errorMessage: message,
            onRetry: () => _handleNext(context, ref),
          ),
        );
      },
      data: (state) {
        final isLoading = asyncPlan.isLoading || state.isLoading;
        final hasInlineError = asyncPlan.hasError || state.hasError;
        final errorMessage =
            state.activeFailure?.toMessage() ??
            (asyncPlan.error is Failure
                ? (asyncPlan.error as Failure).toMessage()
                : state.errorMessage);

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
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
                          transitionBuilder: (child, animation) =>
                              SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child:
                                FadeTransition(opacity: animation, child: child),
                          ),
                          child: QuestionContent(
                            key: ValueKey(question.id),
                            question: question,
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Inline Error Alert with Retry ───────────────────────────
                  if (hasInlineError && errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.2),
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: theme.colorScheme.error
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _handleNext(context, ref),
                              child: Text(
                                S.current.retry,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Next / Generate action button ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: NeumorphicButton(
                      text: state.isLastQuestion
                          ? S.current.generateMyPlan
                          : S.current.continueButton,
                      icon: state.isLastQuestion
                          ? Icons.auto_awesome_rounded
                          : Icons.arrow_forward_rounded,
                      isLoading: isLoading,
                      accentColor: state.selectedCategory?.color,
                      onPressed:
                          isLoading ? null : () => _handleNext(context, ref),
                      width: double.infinity,
                      height: 52,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
