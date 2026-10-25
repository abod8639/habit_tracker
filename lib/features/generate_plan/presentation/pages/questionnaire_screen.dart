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
import 'package:habit_tracker/core/components/neu_surface.dart';
import '../widgets/octalysis_generation_loader.dart';
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
        body: const OctalysisGenerationLoader(),
      ),
      error: (err, _) {
        final message = err is Failure
            ? err.toMessage()
            : S.current.planGenerationFailed;
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

        // ── CD7: Labor Illusion Ritual Screen during generation ──────────────
        if (isLoading && state.isLastQuestion) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: OctalysisGenerationLoader(
                category: state.selectedCategory,
              ),
            ),
          );
        }

        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final progressVal = state.progress;
        final String stepMilestone;
        if (progressVal <= 0.35) {
          stepMilestone = isArabic
              ? '🏁 نقطة البداية • قياس الوضع الحالي'
              : '🏁 Calibration • Starting Point';
        } else if (progressVal <= 0.70) {
          stepMilestone = isArabic
              ? '⏱️ موازنة الوقت • تنظيم الروتين'
              : '⏱️ Capacity • Daily Rhythm';
        } else if (progressVal < 1.0) {
          stepMilestone = isArabic
              ? '🎯 الأهداف • ضبط الاستمرارية'
              : '🎯 Trajectory • Core Targets';
        } else {
          stepMilestone = isArabic
              ? '🚀 المحطة الأخيرة • جاهز للهندسة!'
              : '🚀 Final Lap • Ready to Architect!';
        }

        final categoryColor =
            state.selectedCategory?.color ?? theme.colorScheme.primary;

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
                          Expanded(
                            child: Text(
                              stepMilestone,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          NeuChip(
                            label: state.progressLabel,
                            color: categoryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      NeumorphicProgressBar(
                        value: state.progress,
                        accentColor: categoryColor,
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
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
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
                      child: NeuSurface(
                        depth: NeuDepth.inset,
                        borderRadius: AppRadius.mdRadius,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
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
                            NeuSurface(
                              onTap: () => _handleNext(context, ref),
                              borderRadius: AppRadius.pillRadius,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
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
                      onPressed: isLoading
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
      },
    );
  }
}
