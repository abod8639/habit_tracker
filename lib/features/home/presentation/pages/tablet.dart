import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/home/presentation/dialogs/habit_dialogs.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/drawer_menu_button.dart';
import 'package:habit_tracker/features/home/presentation/widget/expanded_checkbox_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/monthly_summary.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_fab.dart';
import 'package:habit_tracker/features/home/presentation/widget/no_habits_yet.dart';

class Tablet extends ConsumerWidget {
  const Tablet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for failures and show floating SnackBar with retry
    ref.listen<Failure?>(
      habitNotifierProvider.select((s) => s.activeFailure),
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(next.toMessage()),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: S.of(context).retry,
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () {
                  ref.read(habitNotifierProvider.notifier).retry();
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          ref.read(habitNotifierProvider.notifier).clearActiveFailure();
        }
      },
    );

    final asyncHabit = ref.watch(asyncHabitProvider);

    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Hero(
        tag: 'ai_button',
        child: MyfloatingActionButton(
          onPressed: () => HabitDialogs.showAdd(context, ref: ref),
        ),
      ),
      body: asyncHabit.when(
        loading: () => buildLoadingScreen(),
        error: (error, stackTrace) => ErrorView(
          errorMessage: error is Failure ? error.toMessage() : error.toString(),
          onRetry: () => ref.read(habitNotifierProvider.notifier).retry(),
        ),
        data: (habitState) {
          final datasets = habitState.heatmapDateSet;
          final startDay = ref.watch(habitStartDayProvider);

          return Stack(
            children: [
              Row(
                children: [
                  // Middle: Monthly Summary
                  Expanded(
                    flex: ResponsiveUtils.isDesktop(context) ? 8 : 9,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        key: const ValueKey<String>('heatmap'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: MonthlySummary(
                          key: ValueKey(startDay),
                          datasets: Map<DateTime, int>.from(datasets),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: ResponsiveUtils.isDesktop(context) ? 9 : 13,
                    child: habitState.habits.isEmpty
                        ? const NoHabitsYet()
                        : const CheckboxList(),
                  ),
                ],
              ),
              if (!ResponsiveUtils.isDesktop(context))
                const PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: DrawerMenuButton(),
                ),
            ],
          );
        },
      ),
    );
  }
}
