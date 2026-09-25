import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_binding.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HabitStatsController>()) {
        Get.find<HabitStatsController>().refreshStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: NeumorphicCircularButton(
              size: 40,
              icon: Icons.arrow_back_ios_new_rounded,
              iconColor: colorScheme.onSurface,
              onPressed: () => Get.back(),
            ),
          ),
          title: Text(
            S.current.ratepagetitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: NeumorphicCircularButton(
                size: 40,
                icon: Icons.refresh_rounded,
                iconColor: colorScheme.primary,
                tooltip: 'Refresh',
                onPressed: () {
                  if (Get.isRegistered<HabitStatsController>()) {
                    Get.find<HabitStatsController>().refreshStats();
                  }
                },
              ),
            ),
          ],
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
                    borderRadius: 32,
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
          onTap: () {
            Get.to(
              () => const AiChatPage(),
              binding: AiChatBinding(),
            );
          },
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
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              primary,
              Color.lerp(primary, Colors.black, isDark ? 0.25 : 0.12) ?? primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
            width: 1.2,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ]
              : [
                  // Radiant primary bloom
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? 0.45 : 0.35),
                    offset: const Offset(0, 5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                  // Ambient light
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.8),
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
