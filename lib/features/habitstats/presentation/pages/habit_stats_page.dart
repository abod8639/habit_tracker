import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/functions/ai_guard.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import '../widget/fade_animation_summary_card.dart';
import '../widget/fade_animation_charts_section.dart';
import '../widget/fade_animation_trend_chart.dart';
import '../widget/fade_animation_habit_list_card.dart';
import '../widget/stats_neumorphic_utils.dart';

class HabitStatsPage extends StatefulWidget {
  const HabitStatsPage({super.key});

  @override
  State<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends State<HabitStatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: myAppBar(
          context: context,
          title: S.current.ratepagetitle,
        ),
        body: GetX<HabitStatsController>(
          builder: (controller) {
            if (controller.stats.value == null && controller.isLoading.value) {
              return Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: StatsNeumorphicTheme.wellDecoration(
                    context,
                    borderRadius: AppRadius.dialog,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color: colorScheme.primary,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeAnimationSummaryCard(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 16),
                    FadeAnimationChartsSection(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 16),
                    FadeAnimationTrendChart(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 16),
                    FadeAnimationHabitListCard(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 84), // extra padding for FAB
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: _NeumorphicAiFab(
          onTap: () => AiGuard.protect(
            context,
            onValid: () => context.push(AppRoutes.aiCoach),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Neumorphic Floating Action Button for AI Coach
class _NeumorphicAiFab extends StatefulWidget {
  final VoidCallback onTap;

  const _NeumorphicAiFab({required this.onTap});

  @override
  State<_NeumorphicAiFab> createState() => _NeumorphicAiFabState();
}

class _NeumorphicAiFabState extends State<_NeumorphicAiFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color primary = colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          gradient: LinearGradient(
            colors: [
              primary,
              Color.lerp(primary, Colors.black, isDark ? 0.25 : 0.12) ??
                  primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
            width: 1.2,
          ),
          boxShadow: _isPressed
              ? AppShadows.buttonPressed(isDark: isDark)
              : [
                  ...AppShadows.bloom(
                    color: primary,
                    isDark: isDark,
                    blur: 14.0,
                    spread: 1.0,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.80),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              S.current.aiCoach,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
