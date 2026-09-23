import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';

import '../../domain/entities/plan_suggestion.dart';
import '../controllers/plan_generator_controller.dart';

class PlanResultScreen extends StatelessWidget {
  const PlanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanGeneratorController>();
    final category = controller.selectedCategory.value;
    final color = category?.color ?? Colors.blue;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.until((r) => r.isFirst),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.current.yourPlanTitle(category?.displayName ?? ''),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => Text(
                              S.current.habitsGeneratedCount(controller.suggestions.length),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Select all / Deselect controls ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Obx(() => Row(
                    children: [
                      Text(
                        S.current.itemsSelected(controller.selectedCount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: controller.selectAll,
                        child: Text(S.current.selectAll),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: controller.deselectAll,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade500,
                        ),
                        child: Text(S.current.clear),
                      ),
                    ],
                  )),
            ),

            // ── Habit list ────────────────────────────────────────────────
            Expanded(
              child: Obx(() => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: controller.suggestions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _HabitSuggestionCard(
                      suggestion: controller.suggestions[index],
                      color: color,
                      onToggle: () => controller.toggleSuggestion(index),
                    ),
                  )),
            ),

            // ── Add button ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Obx(() => Column(
                    children: [
                      if (controller.hasError) ...[
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (controller.hasSelections &&
                                  !controller.isLoading)
                              ? controller.addSelectedHabits
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
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
                                  controller.hasSelections
                                      ? 'Add ${controller.selectedCount} Habit${controller.selectedCount > 1 ? "s" : ""} to Tracker'
                                      : 'Select at least one habit',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HabitSuggestionCard extends StatelessWidget {
  final PlanSuggestion suggestion;
  final Color color;
  final VoidCallback onToggle;

  const _HabitSuggestionCard({
    required this.suggestion,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selected = suggestion.isSelected;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha:0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color.withValues(alpha:0.4) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 2),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? color : Colors.grey.shade300,
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

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Frequency badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha:0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat_rounded,
                          size: 12,
                          color: selected
                              ? color
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          suggestion.frequency,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? color
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
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
