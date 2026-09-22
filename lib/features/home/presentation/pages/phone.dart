import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/core/functions/add_habit.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/sliver_monthly_summary.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_fab.dart';

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
              MyAppBar(),
              SliverMonthlySummary(),
              HabitList(),
            ],
          );
        }),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return Obx(() {
      if (controller.isSelectionMode) {
        return SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => controller.clearSelection(),
          ),
          title: Text(
            '${controller.selectedHabitIds.length} Selected',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.color_lens, color: Colors.white),
              onPressed: () => _showColorPicker(context, controller),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showBatchDeleteConfirm(context, controller),
            ),
          ],
        );
      }

      return SliverAppBar(
        pinned: true,
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        floating: true,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                color: Theme.of(context).colorScheme.onSurface,
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).primaryColor,
            ),
            tooltip: 'Generate Plan',
            onPressed: () => Get.toNamed(AppRoutes.categorySelection),
          ),
        ],
      );
    });
  }

  void _showColorPicker(BuildContext context, HabitController controller) {
    final colors = [
      Colors.red[400]!, Colors.pink[400]!, Colors.purple[400]!,
      Colors.deepPurple[400]!, Colors.indigo[400]!, Colors.blue[400]!,
      Colors.lightBlue[400]!, Colors.cyan[400]!, Colors.teal[400]!,
      Colors.green[400]!, Colors.lightGreen[500]!, Colors.lime[600]!,
      Colors.yellow[700]!, Colors.amber[500]!, Colors.orange[600]!,
      Colors.deepOrange[500]!, Colors.brown[400]!, Colors.blueGrey[400]!,
      const Color(0xFF6C63FF), const Color(0xFF2D2D2D),
    ];

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: -4,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 80,
                spreadRadius: -10,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Choose Color',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      controller.updateSelectedHabitsColor(color);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                            blurStyle: BlurStyle.inner,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBatchDeleteConfirm(
    BuildContext context,
    HabitController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 60,
                spreadRadius: -8,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Selected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete ${controller.selectedHabitIds.length} habit(s)? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteSelectedHabits();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.red.withValues(alpha: 0.4),
                      ).copyWith(
                        elevation: WidgetStateProperty.all(4),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
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
