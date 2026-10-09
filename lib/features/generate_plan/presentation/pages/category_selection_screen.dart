import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/entities/category_entity.dart';
import '../controllers/plan_generator_controller.dart';
import '../widgets/category_card.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanGeneratorController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: myAppBar(
        title: S.current.generatePlan,
        context: context,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              const SizedBox(height: 8),
              Text(
                S.current.generatePlanTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.current.generatePlanSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // ── Category grid ─────────────────────────────────────────────
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.88,
                  children: PlanCategory.values
                      .map(
                        (category) => CategoryCard(
                          category: category,
                          onTap: () {
                            controller.selectCategory(category);
                            context.push(AppRoutes.questionnaire);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
