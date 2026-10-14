import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
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
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planGeneratorNotifierProvider);
    final theme = Theme.of(context);
    final category = state.selectedCategory;
    final color = category?.color ?? theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: myAppBar(
        title: S.current.yourPlanTitle(category?.displayName ?? ''),
        context: context,
        leading: Center(
          child: NeumorphicIconButton.square(
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Sub-header: items count & selection controls ───────────────
            Padding(
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
                    onPressed: () =>
                        ref.read(planGeneratorNotifierProvider.notifier).selectAll(),
                    style: TextButton.styleFrom(
                      foregroundColor: color,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
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

            // ── Habit list ────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                itemCount: state.suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => PlanSuggestionCard(
                  suggestion: state.suggestions[index],
                  color: color,
                  onToggle: () => ref
                      .read(planGeneratorNotifierProvider.notifier)
                      .toggleSuggestion(index),
                ),
              ),
            ),

            // ── Add button ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.hasError) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        state.errorMessage,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  NeumorphicButton(
                    text: state.hasSelections
                        ? S.current.addHabitsToTracker(state.selectedCount)
                        : S.current.selectAtLeastOneHabit,
                    icon: Icons.add_task_rounded,
                    isLoading: state.isLoading,
                    accentColor: color,
                    onPressed: (state.hasSelections && !state.isLoading)
                        ? () => _handleAddHabits(context, ref)
                        : null,
                    width: double.infinity,
                    height: 52,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
