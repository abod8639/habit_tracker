import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/guards/ai_guard.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/utils/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/habitstats_providers.dart';
import '../widget/fade_animation_summary_card.dart';
import '../widget/fade_animation_charts_section.dart';
import '../widget/fade_animation_trend_chart.dart';
import '../widget/fade_animation_habit_list_card.dart';
import '../widget/stats_neumorphic_utils.dart';

class HabitStatsPage extends ConsumerStatefulWidget {
  const HabitStatsPage({super.key});

  @override
  ConsumerState<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends ConsumerState<HabitStatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(habitStatsNotifierProvider.notifier).refreshStats();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final asyncVal = ref.watch(habitStatsNotifierProvider);
    final state = asyncVal.value ?? const HabitStatsState();

    // Listen to transient failures and show floating SnackBar with retry
    ref.listen<Failure?>(
      habitStatsNotifierProvider.select((s) => s.value?.activeFailure),
      (prev, nextFailure) {
        if (nextFailure != null && mounted) {
          final errorMessage = nextFailure.toMessage();
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
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: S.of(context).retry,
                textColor: Colors.white,
                onPressed: () => ref
                    .read(habitStatsNotifierProvider.notifier)
                    .refreshStats(),
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );

    final bool isInitialLoading =
        state.stats == null && (asyncVal.isLoading || state.isLoading);
    final bool isFatalError =
        state.stats == null && (asyncVal.hasError || state.hasError);

    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) => AppKeyboardShortcuts.handlePageKey(event),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(habitStatsNotifierProvider.notifier).refreshStats(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              MySliverAppBar(
                title: S.current.ratepagetitle,
              ),
              if (isInitialLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                  ),
                )
              else if (isFatalError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 56,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.activeFailure?.toMessage() ??
                                (asyncVal.error is Failure
                                    ? (asyncVal.error as Failure).toMessage()
                                    : S.current.unexpectedError),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          NeumorphicButton(
                            text: S.current.retry,
                            onPressed: () => ref
                                .read(habitStatsNotifierProvider.notifier)
                                .refreshStats(),
                            width: 160,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (state.hasError && state.activeFailure != null) ...[
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
                              borderRadius: BorderRadius.circular(12),
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
                                    state.activeFailure!.toMessage(),
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => ref
                                      .read(habitStatsNotifierProvider.notifier)
                                      .refreshStats(),
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
                      ],
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
                    ]),
                  ),
                ),
            ],
          ),
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
              ? AppShadows.buttonResting(isDark: isDark)
              : AppShadows.buttonPressed(isDark: isDark),
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
