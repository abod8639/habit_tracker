import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/plan_generator_controller.dart';
import '../widgets/plan_suggestion_card.dart';

class PlanResultScreen extends StatelessWidget {
  const PlanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanGeneratorController>();
    final theme = Theme.of(context);
    final category = controller.selectedCategory.value;
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
              controller.reset();
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
              child: Obx(
                () => Row(
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
                        S.current.itemsSelected(controller.selectedCount),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.selectAll,
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: Text(S.current.selectAll),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: controller.deselectAll,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.hintColor,
                      ),
                      child: Text(S.current.clear),
                    ),
                  ],
                ),
              ),
            ),

            // ── Habit list ────────────────────────────────────────────────
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  itemCount: controller.suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => PlanSuggestionCard(
                    suggestion: controller.suggestions[index],
                    color: color,
                    onToggle: () => controller.toggleSuggestion(index),
                  ),
                ),
              ),
            ),

            // ── Add button ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.hasError) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    NeumorphicButton(
                      text: controller.hasSelections
                          ? S.current.addHabitsToTracker(controller.selectedCount)
                          : S.current.selectAtLeastOneHabit,
                      icon: Icons.add_task_rounded,
                      isLoading: controller.isLoading,
                      accentColor: color,
                      onPressed: (controller.hasSelections && !controller.isLoading)
                          ? controller.addSelectedHabits
                          : null,
                      width: double.infinity,
                      height: 52,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
