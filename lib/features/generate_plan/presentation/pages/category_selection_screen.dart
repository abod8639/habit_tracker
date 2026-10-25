import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/plan_generator_providers.dart';
import '../widgets/category_card.dart';
import '../widgets/neu_surface.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  void _selectAndNavigate(
    BuildContext context,
    WidgetRef ref,
    PlanCategory category,
  ) {
    ref.read(planGeneratorNotifierProvider.notifier).selectCategory(category);
    context.push(AppRoutes.questionnaire);
  }

  void _pickMysteryCategory(BuildContext context, WidgetRef ref) {
    final random = Random();
    final categories = PlanCategory.values;
    final picked = categories[random.nextInt(categories.length)];
    _selectAndNavigate(context, ref, picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Intl.getCurrentLocale().startsWith('ar');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          MySliverAppBar(title: S.current.generatePlan),
          SliverToBoxAdapter(
            child: PageEntranceTransition(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ── Personal plan tag (engraved pill) ───────────────────
                    NeuChip(
                      icon: Icons.auto_awesome_rounded,
                      color: colorScheme.primary,
                      label: isArabic
                          ? 'خطة شخصية مبنية على إجاباتك'
                          : 'A personal plan built from your answers',
                    ),
                    const SizedBox(height: 14),

                    // ── Call to Quest Title ─────────────────────────────────
                    Text(
                      isArabic
                          ? 'اختر مسار تحولك القادم'
                          : S.current.generatePlanTitle,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Quest Subtitle ──────────────────────────────────────
                    Text(
                      isArabic
                          ? 'خطة مبنية على دوافعك الذاتية؛ نصمم لك 3-4 عادات متوازنة تضمن الاستمرار بدون إجهاد قوة الإرادة.'
                          : S.current.generatePlanSubtitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── How it works (CD2 clear progress path, ethical CD8:
                    // no fake urgency or invented social proof) ─────────────
                    _HowItWorks(isArabic: isArabic),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.90,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = PlanCategory.values[index];
                return PageEntranceTransition(
                  index: index + 1,
                  child: CategoryCard(
                    category: category,
                    questionCount: ref
                        .read(getQuestionsUseCaseProvider)(category)
                        .length,
                    onTap: () => _selectAndNavigate(context, ref, category),
                  ),
                );
              }, childCount: PlanCategory.values.length),
            ),
          ),

          // ── Mystery Quest Picker (CD7: Unpredictability & Curiosity) ────────
          SliverToBoxAdapter(
            child: PageEntranceTransition(
              index: PlanCategory.values.length + 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: NeuSurface(
                  onTap: () => _pickMysteryCategory(context, ref),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const NeuOrb(
                        size: 40,
                        emoji: '🎲',
                        depth: NeuDepth.inset,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic
                                  ? 'لست متأكداً من أين تبدأ؟'
                                  : 'Not sure where to begin?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isArabic
                                  ? 'دع التطبيق يختار لك مسار البداية'
                                  : 'Let the app pick a starting path for you',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isArabic
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three engraved steps showing the whole journey up front.
class _HowItWorks extends StatelessWidget {
  final bool isArabic;

  const _HowItWorks({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final steps = isArabic
        ? const [
            (Icons.quiz_outlined, 'أسئلة قصيرة'),
            (Icons.tune_rounded, '3–4 عادات تناسب وقتك'),
            (Icons.bolt_rounded, 'فوز سريع اليوم'),
          ]
        : const [
            (Icons.quiz_outlined, 'A few questions'),
            (Icons.tune_rounded, '3–4 habits that fit'),
            (Icons.bolt_rounded, 'A quick win today'),
          ];

    return NeuSurface(
      depth: NeuDepth.inset,
      borderRadius: AppRadius.wellRadius,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: Column(
                children: [
                  NeuOrb(
                    size: 38,
                    icon: steps[i].$1,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[i].$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
