import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/core/functions/add_habit.dart';
import 'package:habit_tracker/features/home/presentation/widget/drawer_menu_button.dart';
import 'package:habit_tracker/features/home/presentation/widget/expanded_checkbox_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/no_habits_yet.dart';
import 'package:habit_tracker/features/home/presentation/widget/monthly_summary.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_fab.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';

class Tablet extends StatelessWidget {
  const Tablet({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();
    
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MyfloatingActionButton(
        onPressed: () => addHabit(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return buildLoadingScreen();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return buildErrorScreen();
        }

        return Stack(
          children: [
            Row(
              children: [
                // Middle: Monthly Summary
                Expanded(
                  flex: ResponsiveUtils.isDesktop(context) ? 8 : 9,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: SingleChildScrollView(
                      reverse: true,
                      key: const ValueKey<String>('heatmap'),
                      scrollDirection: Axis.horizontal,
                      child: Obx(() => MonthlySummary(
                        datasets: controller.heatmapDateSet,
                      )),
                    ),
                  ),
                ),

                Expanded(
                  flex: ResponsiveUtils.isDesktop(context) ? 9 : 13,
                  child: Obx(() => controller.habits.isEmpty
                      ? const NoHabitsYet()
                      : const CheckboxList()),
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
      }),
    );
  }
}
