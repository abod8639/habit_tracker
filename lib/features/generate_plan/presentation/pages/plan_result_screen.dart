import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/plan_generator_providers.dart';
import '../widgets/plan_suggestion_card.dart';

class PlanResultScreen extends ConsumerWidget {
  const PlanResultScreen({super.key});

  Future<void> _handleAddHabits(BuildContext context, WidgetRef ref) async {
    final count = await ref
        .read(planGeneratorNotifierProvider.notifier)
        .addSelectedHabits();

    if (count != null && context.mounted) {
      context.go(AppRoutes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).planActivatedDesc(count)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (count == null && context.mounted) {
      final asyncVal = ref.read(planGeneratorNotifierProvider);
      final activeFailure = asyncVal.value?.activeFailure;
      final errorObj = asyncVal.error;
      final err =
          activeFailure?.toMessage() ??
          (errorObj is Failure
              ? errorObj.toMessage()
              : (asyncVal.value?.errorMessage.isNotEmpty == true
                  ? asyncVal.value!.errorMessage
                  : S.current.unexpectedError));

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
            onPressed: () => _handleAddHabits(context, ref),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlan = ref.watch(planGeneratorNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return asyncPlan.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (err, _) {
        final message =
            err is Failure ? err.toMessage() : S.current.unexpectedError;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: ErrorView(
            errorMessage: message,
            onRetry: () => _handleAddHabits(context, ref),
          ),
        );
      },
      data: (state) {
        final category = state.selectedCategory;
        final color = category?.color ?? theme.colorScheme.primary;
        final isLoading = asyncPlan.isLoading || state.isLoading;
        final hasInlineError = asyncPlan.hasError || state.hasError;
        final errorMessage =
            state.activeFailure?.toMessage() ??
            (asyncPlan.error is Failure
                ? (asyncPlan.error as Failure).toMessage()
                : state.errorMessage);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              MySliverAppBar(
                title: S.current.yourPlanTitle(category?.displayName ?? ''),
                leading: NeumorphicIconButton.square(
                  customShadows: AppShadows.buttonResting(isDark: isDark),
                  size: 40,
                  iconSize: 18,
                  icon: Icons.close_rounded,
                  accentColor: theme.colorScheme.onSurface,
                  onPressed: () {
                    ref.read(planGeneratorNotifierProvider.notifier).reset();
                    context.go(AppRoutes.home);
                  },
                ),
              ),
              if (state.suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: PageEntranceTransition(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              S.current.itemsSelected(state.selectedCount),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => ref
                                .read(planGeneratorNotifierProvider.notifier)
                                .selectAll(),
                            style: TextButton.styleFrom(
                              foregroundColor: color,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            child: Text(S.current.selectAll),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () => ref
                                .read(planGeneratorNotifierProvider.notifier)
                                .deselectAll(),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.hintColor,
                            ),
                            child: Text(S.current.clear),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.suggestions.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  sliver: SliverList.separated(
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => PageEntranceTransition(
                      index: index + 1,
                      child: PlanSuggestionCard(
                        suggestion: state.suggestions[index],
                        color: color,
                        onToggle: () => ref
                            .read(planGeneratorNotifierProvider.notifier)
                            .toggleSuggestion(index),
                      ),
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: PageEntranceTransition(
                      index: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: theme.hintColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            S.current.noHabitsYet,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: PageEntranceTransition(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasInlineError && errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
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
                                onPressed: () => _handleAddHabits(context, ref),
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
                    NeumorphicButton(
                      text: state.hasSelections
                          ? S.current.addHabitsToTracker(state.selectedCount)
                          : S.current.selectAtLeastOneHabit,
                      icon: Icons.add_task_rounded,
                      isLoading: isLoading,
                      accentColor: color,
                      onPressed: (state.hasSelections && !isLoading)
                          ? () => _handleAddHabits(context, ref)
                          : null,
                      width: double.infinity,
                      height: 52,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
