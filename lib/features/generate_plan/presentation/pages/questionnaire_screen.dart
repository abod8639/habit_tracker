import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_progress_bar.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/plan_generator_controller.dart';
import '../widgets/question_content.dart';

class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlanGeneratorController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => myAppBar(
            title: controller.selectedCategory.value?.displayName ?? '',
            context: context,
            // onBack: controller.previous,
            // showLeading: !controller.isFirstQuestion,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress indicator ──────────────────────────────────────────
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedCategory.value?.displayName ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          controller.progressLabel,
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
                      value: controller.progress,
                      accentColor: controller.selectedCategory.value?.color,
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Question content ────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final question = controller.currentQuestion;
                if (question == null) return const SizedBox.shrink();

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
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
                    controller: controller,
                  ),
                );
              }),
            ),

            // ── Next / Generate action button ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Obx(
                () => NeumorphicButton(
                  text: controller.isLastQuestion
                      ? S.current.generateMyPlan
                      : S.current.continueButton,
                  icon: controller.isLastQuestion
                      ? Icons.auto_awesome_rounded
                      : Icons.arrow_forward_rounded,
                  isLoading: controller.isLoading,
                  accentColor: controller.selectedCategory.value?.color,
                  onPressed: controller.isLoading ? null : controller.next,
                  width: double.infinity,
                  height: 52,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
