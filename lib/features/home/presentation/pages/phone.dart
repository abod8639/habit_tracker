import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/features/home/presentation/dialogs/habit_dialogs.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/home_app_bar.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_fab.dart';
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
    final isLoading = ref.watch(
      habitNotifierProvider.select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      habitNotifierProvider.select((s) => s.errorMessage),
    );
    final isSelectionMode = ref.watch(
      habitNotifierProvider.select((s) => s.isSelectionMode),
    );

    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isSelectionMode
          ? const SizedBox.shrink()
          : MyfloatingActionButton(
              onPressed: () => HabitDialogs.showAdd(context, ref: ref),
            ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (isLoading) {
              return buildLoadingScreen();
            }

            if (errorMessage.isNotEmpty) {
              return ErrorView(
                errorMessage: errorMessage,
                onRetry: () => ref.read(habitNotifierProvider.notifier).retry(),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: const [
                HomeAppBar(),
                SliverMonthlySummary(),
                HabitList(),
                SliverToBoxAdapter(
                  child: SizedBox(height: 85),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
