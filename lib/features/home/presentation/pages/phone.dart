import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/home/presentation/dialogs/habit_dialogs.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/curved_bottom_nav_bar.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/home_app_bar.dart';
import 'package:habit_tracker/features/home/presentation/widget/sliver_monthly_summary.dart';

/// Clean Architecture Phone layout for the Habit Tracker Home screen.
class Phone extends ConsumerStatefulWidget {
  const Phone({super.key});

  @override
  ConsumerState<Phone> createState() => _PhoneState();
}

class _PhoneState extends ConsumerState<Phone> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for transient or operational failures and present a SnackBar with Retry
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

    final isSelectionMode = ref.watch(
      habitNotifierProvider.select((s) => s.isSelectionMode),
    );
    final asyncHabit = ref.watch(asyncHabitProvider);

    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        offset: isSelectionMode ? const Offset(0, 1.2) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelectionMode ? 0.0 : 1.0,
          child: isSelectionMode
              ? const SizedBox.shrink()
              : CurvedBottomNavBar(
                  onAddHabit: () => HabitDialogs.showAdd(context, ref: ref),
                ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: asyncHabit.when(
          loading: () => buildLoadingScreen(),
          error: (error, stackTrace) => ErrorView(
            errorMessage: error is Failure
                ? error.toMessage()
                : error.toString(),
            onRetry: () => ref.read(habitNotifierProvider.notifier).retry(),
          ),
          data: (habitState) => CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: const [
              HomeAppBar(),
              SliverMonthlySummary(),
              HabitList(),
              SliverToBoxAdapter(
                child: SizedBox(height: 115),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
