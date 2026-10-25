import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_empty_state.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/components/neumorphic_input.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/plan_generator_providers.dart';
import '../../domain/entities/plan_suggestion.dart';
import '../widgets/neu_surface.dart';
import '../widgets/octalysis_generation_loader.dart';
import '../widgets/plan_activation_celebration_dialog.dart';
import '../widgets/plan_suggestion_card.dart';

class PlanResultScreen extends ConsumerWidget {
  const PlanResultScreen({super.key});

  Future<void> _handleAddHabits(BuildContext context, WidgetRef ref) async {
    final state = ref.read(planGeneratorNotifierProvider).value;
    final selectedHabits = state?.selectedSuggestions ?? [];
    final category = state?.selectedCategory;
    final totalMinutes = state?.totalDailyMinutes ?? 0;
    final firstWin = state?.firstWinHabit;

    final count = await ref
        .read(planGeneratorNotifierProvider.notifier)
        .addSelectedHabits();

    if (count != null && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        builder: (dialogCtx) => PlanActivationCelebrationDialog(
          category: category,
          activatedHabits: selectedHabits,
          totalDailyMinutes: totalMinutes,
          firstWinHabit: firstWin,
          onContinue: () {
            Navigator.of(dialogCtx).pop();
            context.go(AppRoutes.home);
          },
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

  Future<void> _handleRegenerate(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(planGeneratorNotifierProvider.notifier)
        .regeneratePlan();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.planGenerationFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    PlanSuggestion suggestion,
    Color color,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _EditHabitDialog(
        suggestion: suggestion,
        color: color,
        onSave: (name, description) => ref
            .read(planGeneratorNotifierProvider.notifier)
            .updateSuggestion(index, name: name, description: description),
      ),
    );
  }

  Future<void> _handleClose(BuildContext context, WidgetRef ref) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final shouldLeave = await AppConfirmationDialog.show(
      context: context,
      icon: Icons.warning_amber_rounded,
      title: isArabic ? 'هل تريد مغادرة الخطة؟' : 'Leave Your Plan?',
      message: isArabic
          ? 'هذه العادات صُممت حسب إجاباتك. إذا غادرت الآن لن تُحفظ.'
          : 'These habits were built from your answers. Leaving now will discard them.',
      confirmText: isArabic ? 'مغادرة' : 'Leave',
      cancelText: isArabic ? 'البقاء في الخطة' : 'Keep My Plan',
      isDestructive: true,
    );

    if (shouldLeave == true && context.mounted) {
      ref.read(planGeneratorNotifierProvider.notifier).reset();
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlan = ref.watch(planGeneratorNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return asyncPlan.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const OctalysisGenerationLoader(),
      ),
      error: (err, _) {
        final message = err is Failure
            ? err.toMessage()
            : S.current.unexpectedError;
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

        // Regenerating: suggestions are cleared while the new plan is built.
        if (isLoading && state.suggestions.isEmpty) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: OctalysisGenerationLoader(category: category),
            ),
          );
        }

        final ignitionCount = state.suggestions
            .where((s) => s.tier == HabitTier.ignition)
            .length;

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
                  onPressed: () => _handleClose(context, ref),
                ),
              ),

              // ── CD1 & CD4: identity header with honest plan load ──────────
              if (state.suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: PageEntranceTransition(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
                      child: NeuSurface(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                NeuOrb(
                                  size: 44,
                                  emoji: category?.badgeEmoji ?? '🎯',
                                  depth: NeuDepth.inset,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isArabic
                                        ? 'خطتك تقودك لتصبح: ${category?.archetypeTitle ?? ''}'
                                        : 'Your path to becoming: ${category?.archetypeTitle ?? ''}',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isArabic
                                  ? 'كل عادة هنا مبنية على إجاباتك — اضغط ✏️ لتعديل أي عادة بكلماتك.'
                                  : 'Every habit here is built from your answers — tap ✏️ to make any of them yours.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.70,
                                ),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                NeuChip(
                                  icon: Icons.timer_outlined,
                                  label: isArabic
                                      ? '${state.totalDailyMinutes} دقيقة يومياً'
                                      : '${state.totalDailyMinutes} min / day',
                                  color: color,
                                ),
                                if (ignitionCount > 0)
                                  NeuChip(
                                    icon: HabitTier.ignition.icon,
                                    label: isArabic
                                        ? 'فوز سريع يحمي سلسلتك'
                                        : 'Quick win protects your streak',
                                    color: HabitTier.ignition.color,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Selection toolbar ─────────────────────────────────────────
              if (state.suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: PageEntranceTransition(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          NeuChip(
                            label: S.current.itemsSelected(state.selectedCount),
                            color: color,
                            fontSize: 12,
                          ),
                          const Spacer(),
                          // CD3 + CD7: user can re-roll for a fresh combination
                          NeumorphicIconButton.circle(
                            tooltip: isArabic
                                ? 'توليد خطة بديلة'
                                : 'Generate another plan',
                            size: 36,
                            iconSize: 18,
                            icon: Icons.casino_rounded,
                            accentColor: color,
                            onPressed: () {
                              if (!isLoading) _handleRegenerate(context, ref);
                            },
                          ),
                          const SizedBox(width: 10),
                          _ToolbarPill(
                            label: S.current.selectAll,
                            color: color,
                            onTap: () => ref
                                .read(planGeneratorNotifierProvider.notifier)
                                .selectAll(),
                          ),
                          const SizedBox(width: 8),
                          _ToolbarPill(
                            label: S.current.clear,
                            color: theme.hintColor,
                            onTap: () => ref
                                .read(planGeneratorNotifierProvider.notifier)
                                .deselectAll(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.suggestions.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  sliver: SliverList.separated(
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
                    itemBuilder: (context, index) => PageEntranceTransition(
                      index: index + 2,
                      child: PlanSuggestionCard(
                        suggestion: state.suggestions[index],
                        color: color,
                        onToggle: () => ref
                            .read(planGeneratorNotifierProvider.notifier)
                            .toggleSuggestion(index),
                        onEdit: () => _openEditDialog(
                          context,
                          ref,
                          index,
                          state.suggestions[index],
                          color,
                        ),
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
                      child: NeumorphicEmptyState(
                        icon: Icons.inbox_rounded,
                        message: S.current.noHabitsYet,
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
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: NeuSurface(
                          depth: NeuDepth.inset,
                          borderRadius: AppRadius.mdRadius,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
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
                              _ToolbarPill(
                                label: S.current.retry,
                                color: theme.colorScheme.error,
                                onTap: () => _handleAddHabits(context, ref),
                              ),
                            ],
                          ),
                        ),
                      ),
                    NeumorphicButton(
                      text: state.hasSelections
                          ? (isArabic
                                ? 'تفعيل الخطة وبدء اليوم 1 (${state.selectedCount})'
                                : 'Activate Plan & Secure Day 1 (${state.selectedCount})')
                          : S.current.selectAtLeastOneHabit,
                      icon: Icons.rocket_launch_rounded,
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

/// Small raised pill button that presses in on tap.
class _ToolbarPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeuSurface(
      onTap: onTap,
      borderRadius: AppRadius.pillRadius,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Neumorphic sheet for renaming a habit in the user's own words (CD4 Ownership).
class _EditHabitDialog extends StatefulWidget {
  final PlanSuggestion suggestion;
  final Color color;
  final void Function(String name, String description) onSave;

  const _EditHabitDialog({
    required this.suggestion,
    required this.color,
    required this.onSave,
  });

  @override
  State<_EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<_EditHabitDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.suggestion.name);
    _descController = TextEditingController(
      text: widget.suggestion.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      widget.onSave(newName, _descController.text.trim());
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface.withValues(alpha: 0.70),
        ),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: NeuSurface(
        borderRadius: AppRadius.dialogRadius,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NeuOrb(
                    size: 40,
                    icon: Icons.edit_note_rounded,
                    color: widget.color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? 'اجعلها عادتك' : 'Make It Yours',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              label(isArabic ? 'عنوان العادة' : 'Habit name'),
              NeumorphicInput(
                controller: _nameController,
                accentColor: widget.color,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              label(isArabic ? 'الوصف والتوقيت' : 'Description & trigger'),
              NeumorphicInput(
                controller: _descController,
                accentColor: widget.color,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      text: isArabic ? 'إلغاء' : 'Cancel',
                      isPrimary: false,
                      accentColor: widget.color,
                      onPressed: () => Navigator.of(context).pop(),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: NeumorphicButton(
                      text: isArabic ? 'حفظ' : 'Save',
                      icon: Icons.check_rounded,
                      accentColor: widget.color,
                      onPressed: _save,
                      height: 46,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
