import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/core/functions/add_habit.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/home_app_bar.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_fab.dart';
import 'package:habit_tracker/features/home/presentation/widget/sliver_monthly_summary.dart';

/// Clean Architecture Phone layout for the Habit Tracker Home screen.
class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final HabitController controller = Get.find<HabitController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(
        () => controller.isSelectionMode
            ? const SizedBox.shrink()
            : MyfloatingActionButton(
                onPressed: () => addHabit(context),
              ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return buildLoadingScreen();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return buildErrorScreen();
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
        }),
      ),
    );
  }
}
